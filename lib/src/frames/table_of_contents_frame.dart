import 'package:id3tag/src/frames/frames.dart';

import '../raw_frame.dart';


const String _frameName = 'CTOC';


class TableOfContents extends Frame {
  @override String get frameName => _frameName;

  final String elementId;
  final bool isTopLevel;
  final bool isOrdered;
  final List<String> childElementIds;
  final String? description;

  TableOfContents({required this.elementId, required this.isTopLevel, required this.isOrdered,
    required this.childElementIds, this.description});

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName': frameName,
      'elementId': elementId,
      'topLevel': isTopLevel,
      'ordered': isOrdered,
      'description': description,
      'childElementIds': childElementIds,
    };
  }
}

class TableOfContentsFrameParser extends FrameParser<TableOfContents> {
  @override
  List<String> get frameNames => [_frameName];

  @override
  TableOfContents? parseFrame(RawFrame rawFrame) {
    final frameContent = rawFrame.frameContent;
    final elementId = frameContent.readString(checkEncoding: false);
    final flags = frameContent.readBytes(1);
    final int entryCount = frameContent.readBytes(1).first;

    List<String> childElementIds = [];
    for (var i=0; i<entryCount; i++) {
      childElementIds.add(frameContent.readString());
    }

    String? description;
    if (frameContent.remainingBytes > 0) {
      final subFrame = rawFrame.parseSubFrame();
      if (subFrame is TextInformation) { // TIT2
        description = subFrame.value;
      }
    }

    return TableOfContents(elementId: elementId,
      isTopLevel: (flags.first & 0x2) > 0, isOrdered: (flags.first & 0x1) > 0,
      childElementIds: childElementIds, description: description,
    );
  }
}