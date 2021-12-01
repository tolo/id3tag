///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///

import 'frames/frame.dart';
import 'frame_body.dart';
import 'id3_parser.dart';


class RawFrame {
  final ID3Parser id3Parser;
  final String frameName;
  final int frameSize;
  final FrameBody frameContent;

  RawFrame(this.id3Parser, this.frameName, this.frameSize, List<int> frameContentBytes) :
        frameContent = FrameBody(frameContentBytes);


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
  }
}
