///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///
/// Partially derived from https://github.com/sanket143/id3 (Copyright (c) 2019 Sanket Chaudhari)
///

import 'dart:convert';

import 'extensions/byte_list_extension.dart';
import 'exceptions.dart';

class FrameBody {
  final List<int> buffer;
  final int tagMinorVersion;
  int pos = 0;
  int lastEncoding = 0x00; // default to latin1

  FrameBody(this.buffer, this.tagMinorVersion);

  List<int> readUntilTerminator(List<int> terminator, {bool aligned = false, bool terminatorMandatory = true}) {
    if (remainingBytes == 0) {
      return [];
    }
    for (int i = pos; i < buffer.length - (terminator.length - 1); i += (aligned ? terminator.length : 1)) {
      bool foundTerminator = true;
      for (int j = 0; j < terminator.length; j++) {
        if (buffer[i + j] != terminator[j]) {
          foundTerminator = false;
          break;
        }
      }
      if (foundTerminator) {
        final start = pos;
        pos = i + terminator.length;
        return buffer.sublist(start, pos - terminator.length);
      }
    }
    if (terminatorMandatory) {
      throw ID3ParserException("Did not find terminator $terminator in ${buffer.sublist(pos)}");
    } else {
      return buffer.sublist(pos);
    }
  }

  String readLatin1String({bool terminatorMandatory = true}) {
    return latin1.decode(readUntilTerminator([0x00], terminatorMandatory: terminatorMandatory));
  }

  String readUTF16LEString({bool terminatorMandatory = true}) {
    final bytes = readUntilTerminator([0x00, 0x00], aligned: true, terminatorMandatory: terminatorMandatory);
    final utf16les = List.generate((bytes.length / 2).ceil(), (index) => 0);

    for (int i = 0; i < bytes.length; i++) {
      if (i % 2 == 0) {
        utf16les[i ~/ 2] = bytes[i];
      } else {
        utf16les[i ~/ 2] |= (bytes[i] << 8);
      }
    }
    return String.fromCharCodes(utf16les);
  }

  String readUTF16BEString({bool terminatorMandatory = true}) {
    final bytes = readUntilTerminator([0x00, 0x00], terminatorMandatory: terminatorMandatory);
    final utf16bes = List.generate((bytes.length / 2).ceil(), (index) => 0);

    for (int i = 0; i < bytes.length; i++) {
      if (i % 2 == 0) {
        utf16bes[i ~/ 2] = (bytes[i] << 8);
      } else {
        utf16bes[i ~/ 2] |= bytes[i];
      }
    }
    return String.fromCharCodes(utf16bes);
  }

  String readUTF16String({bool terminatorMandatory = true}) {
    final bom = buffer.sublist(pos, pos + 2);
    if (bom[0] == 0xFF && bom[1] == 0xFE) {
      pos += 2;
      return readUTF16LEString(terminatorMandatory: terminatorMandatory);
    } else if (bom[0] == 0xFE && bom[1] == 0xFF) {
      pos += 2;
      return readUTF16BEString(terminatorMandatory: terminatorMandatory);
    } else if (bom[0] == 0x00 && bom[1] == 0x00) {
      pos += 2;
      return "";
    } else {
      throw ID3ParserException("Unknown UTF-16 BOM: $bom in ${buffer.sublist(pos)}");
    }
  }

  String readUTF8String({bool terminatorMandatory = true}) {
    final bytes = readUntilTerminator([0x00], terminatorMandatory: terminatorMandatory);
    return const Utf8Decoder().convert(bytes);
  }

  void readEncoding() {
    if (buffer[pos] < 20) {
      if (lastEncoding == 0x01) {
        // Do not modify the BOM, 0x01 must apply to each field
        pos++;
      } else {
        lastEncoding = buffer[pos++];
      }
    }
  }

  String readString({bool terminatorMandatory = true, bool checkEncoding = true}) {
    if (checkEncoding) {
      readEncoding();
    }
    if (pos == buffer.length) {
      return '';
    }
    if (lastEncoding == 0x00) {
      return readLatin1String(terminatorMandatory: terminatorMandatory);
    } else if (lastEncoding == 0x01) {
      return readUTF16String(terminatorMandatory: terminatorMandatory);
    } else if (lastEncoding == 0x02) {
      return readUTF16BEString(terminatorMandatory: terminatorMandatory);
    } else if (lastEncoding == 0x03) {
      return readUTF8String(terminatorMandatory: terminatorMandatory);
    } else {
      throw ID3ParserException("Unknown Byte-Order Marker: $lastEncoding in $buffer");
    }
  }

  List<int> readBytes(int length) {
    pos += length;
    return buffer.sublist(pos - length, pos);
  }

  int readInt() {
    return readBytes(4).parseInt(tagMinorVersion);
  }
  int readIntRaw() {
    return readBytes(4).parseInt(-1);// force non safescan
  }
  
  List<int> readRemainingBytes() {
    return buffer.sublist(pos);
  }

  int get remainingBytes {
    return buffer.length - pos;
  }
}
