#!/usr/bin/env python3
"""
fake_rtsp_generator.py
======================
Phase A: Fake RTSP stream generator with H.264 SEI AI metadata injection.

Generates a GStreamer pipeline that:
  - Produces fake video frames (test pattern with moving rectangles).
  - Generates fake AI metadata per frame for >= 2 use-cases
    (moving bounding boxes, labels, optional scores).
  - Encodes video with CPU H.264 (x264enc tune=zerolatency).
  - Injects one SEI user_data_unregistered NAL (payloadType=5) per frame
    containing MsgPack-encoded multi-usecase metadata.
  - Serves the stream via GStreamer RTSP server.

Requirements:
    pip install msgpack
    apt-get install gstreamer1.0-tools gstreamer1.0-plugins-{base,good,bad,ugly}
                    gstreamer1.0-rtsp python3-gst-1.0 python3-gi

Usage:
    python3 fake_rtsp_generator.py

Stream URL: rtsp://127.0.0.1:8554/test

Acceptance:
    ffplay rtsp://127.0.0.1:8554/test
    ffprobe -show_packets rtsp://127.0.0.1:8554/test   # shows NAL unit type 6 (SEI)
"""

import sys
import math
import struct
import threading
import time

import msgpack

try:
    import gi
    gi.require_version('Gst', '1.0')
    gi.require_version('GstApp', '1.0')
    gi.require_version('GstRtspServer', '1.0')
    from gi.repository import Gst, GstApp, GstRtspServer, GLib
except ImportError as exc:
    sys.exit(
        f"Missing GStreamer Python bindings: {exc}\n"
        "Install: apt-get install python3-gst-1.0 python3-gi"
    )

# ---------------------------------------------------------------------------
# SEI constants
# ---------------------------------------------------------------------------

# 16-byte UUID that matches AI_SEI_METADATA_UUID in RTCTransform.worker.js
AI_SEI_UUID = bytes.fromhex('b4d9e6b12c8a4b3da5e79f1c2d3e4f50')

# Video dimensions
WIDTH = 960
HEIGHT = 540
FRAMERATE = 30

# ---------------------------------------------------------------------------
# Metadata generation helpers
# ---------------------------------------------------------------------------

def _make_traffic_objects(frame_idx: int) -> list:
    """One car and one truck moving horizontally."""
    t = (frame_idx % FRAMERATE) / FRAMERATE  # 0..1 oscillation per second
    x1 = int(50 + 400 * t)
    x2 = int(WIDTH - 200 - 300 * t)
    return [
        {"x": x1, "y": 80, "w": 100, "h": 60, "label": "car", "score": round(0.91 + 0.05 * math.sin(t * math.pi), 3)},
        {"x": x2, "y": 300, "w": 90, "h": 55, "label": "truck", "score": round(0.85 + 0.05 * math.cos(t * math.pi), 3)},
    ]


def _make_security_objects(frame_idx: int) -> list:
    """One person bouncing vertically."""
    t = (frame_idx % (FRAMERATE * 2)) / (FRAMERATE * 2)
    y = int(50 + (HEIGHT - 200) * abs(math.sin(t * math.pi)))
    return [
        {"x": 300, "y": y, "w": 60, "h": 120, "label": "person", "score": round(0.78 + 0.1 * math.sin(t * math.pi * 3), 3)},
    ]


def make_ai_metadata(frame_idx: int) -> bytes:
    """
    Build MsgPack-encoded AI metadata payload for the current frame.

    Schema:
        {
          "v":  1,
          "ts": <frame_idx>,
          "usecases": [
            {"id": "traffic",  "objects": [...]},
            {"id": "security", "objects": [...]}
          ]
        }
    """
    metadata = {
        "v":  1,
        "ts": frame_idx,
        "usecases": [
            {"id": "traffic",  "objects": _make_traffic_objects(frame_idx)},
            {"id": "security", "objects": _make_security_objects(frame_idx)},
        ],
    }
    return msgpack.packb(metadata, use_bin_type=True)


# ---------------------------------------------------------------------------
# H.264 SEI NAL construction
# ---------------------------------------------------------------------------

def _add_emulation_prevention(data: bytes) -> bytes:
    """
    Insert emulation prevention bytes (0x03) before 0x00/0x01/0x02/0x03
    when preceded by two zero bytes, as required by H.264 Annex B.
    """
    result = bytearray()
    zeros = 0
    for b in data:
        if zeros >= 2 and b in (0x00, 0x01, 0x02, 0x03):
            result.append(0x03)
            zeros = 0
        result.append(b)
        zeros = (zeros + 1) if b == 0x00 else 0
    return bytes(result)


def build_sei_nalu(uuid: bytes, payload: bytes) -> bytes:
    """
    Build a complete H.264 SEI NAL unit (Annex-B framed) containing a single
    user_data_unregistered (payloadType=5) message.

    Layout (before emulation prevention):
        [payloadType=5] [payloadSize...] [16-byte UUID] [payload bytes] [0x80]

    Returns: b'\\x00\\x00\\x00\\x01' + nal_header(0x06) + sei_rbsp_ep
    """
    sei_data = uuid + payload  # 16 + len(payload) bytes
    sei_size = len(sei_data)

    # Encode payloadType = 5 as ff-terminated byte sequence
    type_bytes = b'\x05'

    # Encode size in MFF format (0xFF bytes until remainder)
    size_bytes = bytearray()
    remaining = sei_size
    while remaining >= 255:
        size_bytes.append(0xFF)
        remaining -= 255
    size_bytes.append(remaining)

    rbsp = type_bytes + bytes(size_bytes) + sei_data + b'\x80'  # trailing RBSP stop bit
    rbsp_ep = _add_emulation_prevention(rbsp)

    nal_header = b'\x06'  # forbidden_zero=0, nal_ref_idc=0, nal_unit_type=6
    return b'\x00\x00\x00\x01' + nal_header + rbsp_ep


def prepend_sei_to_au(au_bytes: bytes, sei_nalu: bytes) -> bytes:
    """
    Prepend an SEI NAL unit to an H.264 access unit (Annex-B format).
    The SEI must come before the first VCL NAL.
    """
    return sei_nalu + au_bytes


# ---------------------------------------------------------------------------
# GStreamer appsrc → x264enc → h264parse → rtph264pay pipeline
# ---------------------------------------------------------------------------

class FakeRtspFactory(GstRtspServer.RTSPMediaFactory):
    """RTSP media factory that wraps a custom appsrc pipeline."""

    def __init__(self):
        super().__init__()
        self._frame_idx = 0
        self._lock = threading.Lock()
        self.set_shared(True)

    def do_create_element(self, url):
        pipeline_str = (
            "appsrc name=vsrc format=time is-live=true block=false "
            f"caps=video/x-h264,stream-format=byte-stream,alignment=au,width={WIDTH},height={HEIGHT},framerate={FRAMERATE}/1 "
            "! h264parse "
            "! rtph264pay name=pay0 pt=96 config-interval=-1"
        )
        pipeline = Gst.parse_launch(pipeline_str)
        appsrc = pipeline.get_by_name('vsrc')

        encoder_pipeline_str = (
            f"videotestsrc pattern=ball ! "
            f"video/x-raw,width={WIDTH},height={HEIGHT},framerate={FRAMERATE}/1,format=I420 ! "
            f"x264enc tune=zerolatency key-int-max=30 bframes=0 ! "
            f"video/x-h264,stream-format=byte-stream,alignment=au ! "
            f"appsink name=esink sync=false"
        )
        enc_pipeline = Gst.parse_launch(encoder_pipeline_str)
        esink = enc_pipeline.get_by_name('esink')

        enc_pipeline.set_state(Gst.State.PLAYING)

        def _push_frames():
            frame_idx = 0
            while True:
                sample = esink.emit('pull-sample')
                if sample is None:
                    time.sleep(0.001)
                    continue
                buf = sample.get_buffer()
                ok, mapinfo = buf.map(Gst.MapFlags.READ)
                if not ok:
                    continue
                au_bytes = bytes(mapinfo.data)
                buf.unmap(mapinfo)

                metadata_bytes = make_ai_metadata(frame_idx)
                sei_nalu = build_sei_nalu(AI_SEI_UUID, metadata_bytes)
                augmented_au = prepend_sei_to_au(au_bytes, sei_nalu)

                new_buf = Gst.Buffer.new_wrapped(augmented_au)
                new_buf.pts = buf.pts
                new_buf.dts = buf.dts
                new_buf.duration = buf.duration

                appsrc.emit('push-buffer', new_buf)
                frame_idx += 1

        t = threading.Thread(target=_push_frames, daemon=True)
        t.start()

        return pipeline


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    Gst.init(None)

    loop = GLib.MainLoop()

    server = GstRtspServer.RTSPServer()
    server.set_service('8554')

    mounts = server.get_mount_points()
    factory = FakeRtspFactory()
    mounts.add_factory('/test', factory)

    server.attach(None)

    print(f"RTSP server running at rtsp://127.0.0.1:8554/test")
    print("Press Ctrl+C to stop.")

    try:
        loop.run()
    except KeyboardInterrupt:
        print("\nStopping.")


if __name__ == '__main__':
    main()
