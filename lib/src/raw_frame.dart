///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///

import 'frames/frame.dart';
import 'frame_body.dart';
import 'id3_parser.dart';
import 'extensions/iterable_extension.dart';


class RawFrame {
  final ID3Parser id3Parser;
  final String frameName;
  final int frameSize;
  final FrameBody frameContent;

  RawFrame(this.id3Parser, this.frameName, this.frameSize, List<int> frameContentBytes) :
        frameContent = FrameBody(frameContentBytes, id3Parser.id3FileHeader.tagMinorVersion);


  RawFrame? parseRawSubFrame(List<int> buffer, {int offset = 0}) {
     return id3Parser.parseRawFrame(buffer, offset: offset);
  }

  Frame? parseSubFrame() {
    var bytes = frameContent.readRemainingBytes();
    final rawSubFrame = parseRawSubFrame(bytes);
    if (rawSubFrame != null) {
      frameContent.pos += rawSubFrame.frameSize;
      return id3Parser.parseSubFrame(rawSubFrame);
    }
    return null;
  }

  List<Frame> parseSubFrames() {
    List<Frame> subFrames = [];
    var pos = 0;
    do {
      pos = frameContent.pos;
      subFrames.addNotNull(parseSubFrame());
    } while (frameContent.remainingBytes > 0 && frameContent.pos != pos);
    return subFrames;
  }
}
