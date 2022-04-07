import 'frame.dart';
import 'picture_frame.dart';
import 'text_information_frame.dart';
import 'frame_parser.dart';
import '../raw_frame.dart';
import 'user_url_frame.dart';

const String _frameName = 'CHAP';

class Chapter extends Frame {
  @override
  String get frameName => _frameName;

  final String elementId;
  final String title;
  final String? description;
  final int startTimeMilliseconds;
  final int endTimeMilliseconds;
  final Picture? picture;
  final UserUrl? url;

  Chapter({
    required this.elementId,
    required this.title,
    this.description,
    required this.startTimeMilliseconds,
    required this.endTimeMilliseconds,
    this.picture,
    this.url,
  });

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName': frameName,
      'elementId': elementId,
      'title': title,
      'description': description ?? '',
      'startTimeMilliseconds': startTimeMilliseconds,
      'endTimeMilliseconds': endTimeMilliseconds,
      'picture': picture,
      'url': url,
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
    Picture? picture;
    UserUrl? url;
    if (frameContent.remainingBytes > 0) {
      final subFrame1 = rawFrame.parseSubFrame();
      final subFrame2 = rawFrame.parseSubFrame();

      if (subFrame1 != null) {
        if (subFrame1 is TextInformation) {
          // TIT2 or TIT3
          chapterName = subFrame1.frameName == 'TIT2' ? subFrame1.value : null;
          chapterDescription =
              subFrame1.frameName == 'TIT3' ? subFrame1.value : null;
        } else if (subFrame1 is Picture) {
          picture = subFrame1;
        } else if (subFrame1 is UserUrl) {
          url = subFrame1;
        }
      }

      if (subFrame2 != null) {
        if (subFrame2 is TextInformation) {
          // TIT2 or TIT3
          chapterName =
              subFrame2.frameName == 'TIT2' ? subFrame2.value : chapterName;
          chapterDescription = subFrame2.frameName == 'TIT3'
              ? subFrame2.value
              : chapterDescription;
        } else if (subFrame2 is Picture) {
          picture = subFrame2;
        } else if (subFrame2 is UserUrl) {
          url = subFrame2;
        }
      }
    }

    return Chapter(
      elementId: elementId,
      title: chapterName ?? elementId,
      description: chapterDescription,
      startTimeMilliseconds: startTimeMilliseconds,
      endTimeMilliseconds: endTimeMilliseconds,
      picture: picture,
      url: url,
    );
  }
}
