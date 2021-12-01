import 'frame.dart';
import 'text_information_frame.dart';
import 'frame_parser.dart';
import '../raw_frame.dart';


const String _frameName = 'CHAP';


class Chapter extends Frame {
  @override String get frameName => _frameName;

  final String elementId;
  final String title;
  final String? description;
  final int startTimeMilliseconds;
  final int endTimeMilliseconds;

  Chapter({required this.elementId, required this.title, this.description,
    required this.startTimeMilliseconds, required this.endTimeMilliseconds});

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName' : frameName,
      'elementId' : elementId,
      'title' : title,
      'description' : description ?? '',
      'startTimeMilliseconds' : startTimeMilliseconds,
      'endTimeMilliseconds' : endTimeMilliseconds,
    };
  }
}


class ChapterFrameParser extends FrameParser<Chapter> {
  @override
  List<String> get frameNames => [_frameName];

  @override
  Chapter? parseFrame(RawFrame rawFrame) {
    final frameContent = rawFrame.frameContent;
    final elementId = frameContent.readString(checkEncoding: false);

    final int startTimeMilliseconds = frameContent.readInt();
    final int endTimeMilliseconds = frameContent.readInt();
    /*final int startByteOffset =*/ frameContent.readInt();
    /*final int endByteOffset =*/ frameContent.readInt();

    String? chapterName;
    String? chapterDescription;
    if (frameContent.remainingBytes > 0) {
      final subFrame1 = rawFrame.parseSubFrame();
      final subFrame2 = rawFrame.parseSubFrame();

      if (subFrame1 != null && subFrame1 is TextInformation) { // TIT2 or TIT3
        chapterName = subFrame1.frameName == 'TIT2' ? subFrame1.value : null;
        chapterDescription = subFrame1.frameName == 'TIT3' ? subFrame1.value : null;
      }
      if (subFrame2 != null && subFrame2 is TextInformation) { // TIT2 or TIT3
        chapterName = subFrame2.frameName == 'TIT2' ? subFrame2.value : chapterName;
        chapterDescription = subFrame2.frameName == 'TIT3' ? subFrame2.value : chapterDescription;
      }
    }

    return Chapter(elementId: elementId, title: chapterName ?? elementId, description: chapterDescription,
        startTimeMilliseconds: startTimeMilliseconds, endTimeMilliseconds: endTimeMilliseconds);
  }
}
