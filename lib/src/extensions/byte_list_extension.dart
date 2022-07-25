
import '../exceptions.dart';

extension ID3ByteList on List<int> {

  int _parseInt({required bool syncSafe}) {
    int value;
    if (length == 4) {
      if (syncSafe) {
        value = (this[0] & 0x7f) << 21;
        value += (this[1] & 0x7f) << 14;
        value += (this[2] & 0x7f) << 7;
        value += (this[3] & 0x7f);
      } else {
        value = this[0] << 24;
        value += this[1] << 16;
        value += this[2] << 8;
        value += this[3];
      }
    } else {
      throw ID3ParserException("Unable to parse int value from byte array of length $length");
    }

    return value;
  }

  int parseInt(int id3MinorVersion) {
    return _parseInt(syncSafe: id3MinorVersion >= 4);
  }

  int parseID3FileHeaderSize() {
    int size;
    if (length == 4) {
      size = _parseInt(syncSafe: true);
    } else if (length == 3) {
      size = this[0] << 16;
      size += this[1] << 8;
      size += this[2];
    } else {
      throw ID3ParserException("Unable to parse size from byte array of length $length");
    }

    return size;
  }

}
