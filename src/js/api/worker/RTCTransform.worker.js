/**
 * Created by rock on 2025. 2
 */

const OVENMEDIAENGINE_SEI_METADATA_UUID = '464d4c475241494e434f4c4f55524201';

// UUID for multi-usecase AI metadata (user_data_unregistered SEI)
const AI_SEI_METADATA_UUID = 'b4d9e6b12c8a4b3da5e79f1c2d3e4f50';

/**
 * Minimal MessagePack decoder supporting the types used by the AI metadata schema.
 * Handles: positive/negative fixint, fixmap, fixarray, fixstr, nil, bool,
 *          float32, float64, uint8/16/32, int8/16/32, str8/str16, array16, map16.
 * @param {Uint8Array} bytes
 * @returns {*} decoded value
 */
function decodeMsgPack(bytes) {
  let offset = 0;
  const view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);

  function readByte() {
    return bytes[offset++];
  }

  function decodeValue() {
    const byte = readByte();

    // Positive fixint 0x00-0x7F
    if (byte <= 0x7F) return byte;

    // Fixmap 0x80-0x8F
    if ((byte & 0xF0) === 0x80) {
      const len = byte & 0x0F;
      const obj = {};
      for (let i = 0; i < len; i++) {
        const key = decodeValue();
        obj[key] = decodeValue();
      }
      return obj;
    }

    // Fixarray 0x90-0x9F
    if ((byte & 0xF0) === 0x90) {
      const len = byte & 0x0F;
      const arr = [];
      for (let i = 0; i < len; i++) arr.push(decodeValue());
      return arr;
    }

    // Fixstr 0xA0-0xBF
    if ((byte & 0xE0) === 0xA0) {
      const len = byte & 0x1F;
      const slice = bytes.subarray(offset, offset + len);
      offset += len;
      return decodeUtf8(slice);
    }

    // Negative fixint 0xE0-0xFF
    if (byte >= 0xE0) return byte - 256;

    switch (byte) {
      case 0xC0: return null;
      case 0xC2: return false;
      case 0xC3: return true;
      case 0xCA: { const v = view.getFloat32(offset); offset += 4; return v; }
      case 0xCB: { const v = view.getFloat64(offset); offset += 8; return v; }
      case 0xCC: return readByte();
      case 0xCD: { const v = view.getUint16(offset); offset += 2; return v; }
      case 0xCE: { const v = view.getUint32(offset); offset += 4; return v; }
      case 0xD0: { const v = view.getInt8(offset); offset += 1; return v; }
      case 0xD1: { const v = view.getInt16(offset); offset += 2; return v; }
      case 0xD2: { const v = view.getInt32(offset); offset += 4; return v; }
      case 0xD9: {
        const len = readByte();
        const slice = bytes.subarray(offset, offset + len);
        offset += len;
        return decodeUtf8(slice);
      }
      case 0xDA: {
        const len = view.getUint16(offset); offset += 2;
        const slice = bytes.subarray(offset, offset + len);
        offset += len;
        return decodeUtf8(slice);
      }
      case 0xDC: {
        const len = view.getUint16(offset); offset += 2;
        const arr = [];
        for (let i = 0; i < len; i++) arr.push(decodeValue());
        return arr;
      }
      case 0xDE: {
        const len = view.getUint16(offset); offset += 2;
        const obj = {};
        for (let i = 0; i < len; i++) {
          const key = decodeValue();
          obj[key] = decodeValue();
        }
        return obj;
      }
      default:
        // Unknown or unsupported MsgPack format byte — skip gracefully
        if (typeof console !== 'undefined') {
          console.warn('RTCTransform: unsupported MsgPack byte 0x' + byte.toString(16));
        }
        return null;
    }
  }

  return decodeValue();
}

function decodeUtf8(bytes) {
  if (typeof TextDecoder !== 'undefined') {
    return new TextDecoder().decode(bytes);
  }
  // Fallback: percent-decode UTF-8 via the URI trick (handles multi-byte sequences)
  try {
    return decodeURIComponent(
      Array.from(bytes, b => '%' + ('0' + b.toString(16)).slice(-2)).join('')
    );
  } catch (e) {
    // If decoding fails, return a hex representation of the raw bytes
    return Array.from(bytes, b => ('0' + b.toString(16)).slice(-2)).join('');
  }
}

function removeEmulationPreventionBytes(data) {
  const rbsp = [];
  for (let i = 0; i < data.length; i++) {

    if (i > 2 && data[i - 2] === 0x00 && data[i - 1] === 0x00 && data[i] === 0x03) {
      continue; // skip 0x03
    }
    rbsp.push(data[i]);
  }
  return new Uint8Array(rbsp);
}

function parseSEIPayload(rbsp) {

  const messages = [];

  let i = 0;
  const rbspLength = rbsp[rbsp.length - 1] === 0x80 ? rbsp.length - 1 : rbsp.length;

  while (i < rbspLength) {

    let type = 0;
    while (rbsp[i] === 0xFF) {
      type += 255;
      i++;
    }
    type += rbsp[i++];

    let size = 0;
    while (rbsp[i] === 0xFF) {
      size += 255;
      i++;
    }
    size += rbsp[i++];

    const payload = rbsp.slice(i, i + size);
    i += size;

    messages.push({ type, size, payload });

    return { type, size, payload };
  }

  return messages;
}

function toHexString(byteArray, delimiter = '') {
  return Array.from(byteArray, byte => {
    return ('0' + (byte & 0xFF).toString(16)).slice(-2);
  }).join(delimiter);
}

function toHexArray(byteArray) {
  return Array.from(byteArray, byte => {
    return ('0' + (byte & 0xFF).toString(16)).slice(-2);
  });
}

function toUUID(byteArray) {
  const hexString = toHexString(byteArray);
  return [
    hexString.slice(0, 8),
    hexString.slice(8, 12),
    hexString.slice(12, 16),
    hexString.slice(16, 20),
    hexString.slice(20, 24),
    hexString.slice(24, 32)
  ].join('-');
}

function toTimestamp(byteArray) {
  const hexString = toHexString(byteArray);
  return parseInt(hexString, 16);
}

function toAsciiString(byteArray) {
  return String.fromCharCode.apply(null, byteArray);
}

function findNalStartIndex(frameData, offset) {
  while (offset < frameData.byteLength - 4) {
    if ((frameData[offset] === 0x00 && frameData[offset + 1] === 0x00)
      && (frameData[offset + 2] === 0x01 || (frameData[offset + 2] === 0x00 && frameData[offset + 3] === 0x01))) {
      return offset;
    } else {
      offset += 1;
    }
  }
  return -1;
}

function getNalus(frameData) {

  let offset = 0;
  const headerSize = 1;
  const nalus = [];

  while (offset < frameData.byteLength - 4) {

    const startCodeIndex = findNalStartIndex(frameData, offset);

    if (startCodeIndex >= offset) {

      const startCodeLength = frameData[startCodeIndex + 2] === 0x01 ? 3 : 4;
      const nextStartCodeIndex = findNalStartIndex(frameData, startCodeIndex + startCodeLength + headerSize);

      if (nextStartCodeIndex > startCodeIndex) {

        nalus.push(frameData.subarray(startCodeIndex, nextStartCodeIndex));
        offset = nextStartCodeIndex;
      } else {

        nalus.push(frameData.subarray(startCodeIndex));
        break;
      }
    } else {
      break;
    }
  }
  return nalus;
}

function createReceiverTransform() {
  return new TransformStream({
    start() { },
    flush() { },
    async transform(encodedFrame, controller) {

      const nalus = getNalus(new Uint8Array(encodedFrame.data));

      nalus.forEach((nalu) => {

        const startCodeLength = nalu[2] === 0x01 ? 3 : 4;
        const headerCodeLength = 1;
        const nalHeader = nalu[startCodeLength];
        const nalType = nalHeader & 0x1F;

        // NAL Type SEI
        if (nalType === 6) {

          const rbsp = removeEmulationPreventionBytes(nalu.subarray(startCodeLength + headerCodeLength));

          const parsedSei = parseSEIPayload(rbsp);

          const eventData = {
            nalu: nalu,
            sei: parsedSei
          };

          const uuid = toHexString(parsedSei.payload.subarray(0, 16));

          if (uuid === OVENMEDIAENGINE_SEI_METADATA_UUID) {

            postMessage({
              action: 'sei', data: {
                ...eventData,
                registered: true,
                uuid: toUUID(parsedSei.payload.subarray(0, 16)),
                timecode: toTimestamp(parsedSei.payload.subarray(16, 24)),
                userdata: parsedSei.payload.subarray(24)
              }
            });

          } else if (uuid === AI_SEI_METADATA_UUID) {

            let metadata = null;
            try {
              metadata = decodeMsgPack(parsedSei.payload.subarray(16));
            } catch (e) {
              metadata = null;
            }

            postMessage({
              action: 'sei', data: {
                ...eventData,
                registered: true,
                uuid: toUUID(parsedSei.payload.subarray(0, 16)),
                aiMetadata: metadata
              }
            });

          } else {

            postMessage({
              action: 'sei', data: {
                ...eventData,
                registered: false
              }
            });
          }
        }
      });

      controller.enqueue(encodedFrame);
    }
  })
}

function setupPipe({ readable, writable }, transform) {
  readable
    .pipeThrough(transform)
    .pipeTo(writable)
}

addEventListener('rtctransform', (event) => {
  setupPipe(event.transformer, createReceiverTransform());
});

addEventListener('message', (event) => {
  const { action } = event.data;

  switch (action) {
    case 'rtctransform':
      setupPipe(event.data, createReceiverTransform())
      break;
    default:
      break;
  }
});
