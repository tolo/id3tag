
import '../exceptions.dart';

extension ID3ByteList on List<int> {

  int parseInt() {
    int value;
    if (length == 4) {
      value = this[0] << 24;
      value += this[1] << 16;
      value += this[2] << 8;
      value += this[3];
    } else {
      throw ID3ParserException("Unable to parse int value from byte array of length $length");
    }

    return value;
  }

  int parseID3FileHeaderSize() {
    int size;
    if (length == 4) {
      size = (this[0] & 0x7f) << 21;
      size += (this[1] & 0x7f) << 14;
      size += (this[2] & 0x7f) << 7;
      size += (this[3] & 0x7f);
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
