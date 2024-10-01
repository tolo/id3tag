import '../raw_frame.dart';
import 'frame.dart';
import 'frame_parser.dart';
import 'text_information_frame.dart';
import 'user_url_frame.dart';
import 'picture_frame.dart';


const String _frameName = 'CHAP';


class Chapter extends Frame {
  @override String get frameName => _frameName;

  final String elementId;
  final String title;
  final String? description;
  final int startTimeMilliseconds;
  final int endTimeMilliseconds;
  final Picture? picture;
  final UserUrl? url;

  Chapter({required this.elementId, required this.title, this.description,
    required this.startTimeMilliseconds, required this.endTimeMilliseconds, this.picture, this.url});

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
      'url': url
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

    // Following four ints are not safe scan according to ID3v2.4
    final int startTimeMilliseconds = frameContent.readIntRaw();
    final int endTimeMilliseconds = frameContent.readIntRaw();
    /*final int startByteOffset =*/ frameContent.readIntRaw();
    /*final int endByteOffset =*/ frameContent.readIntRaw();

    String? chapterName;
    String? chapterDescription;
    Picture? picture;
    UserUrl? url;
    if (frameContent.remainingBytes > 0) {
      final subFrames = rawFrame.parseSubFrames();
      for(var frame in subFrames) {
        if (frame is TextInformation) { // TIT2 or TIT3
          chapterName = frame.frameName == 'TIT2' ? frame.value : chapterName;
          chapterDescription = frame.frameName == 'TIT3' ? frame.value : chapterDescription;
        } else if (frame is Picture) {
          picture = frame;
        } else if (frame is UserUrl) {
          url = frame;
        }
      }
    }

    return Chapter(elementId: elementId, title: chapterName ?? elementId, description: chapterDescription,
        startTimeMilliseconds: startTimeMilliseconds, endTimeMilliseconds: endTimeMilliseconds,
        picture: picture, url: url);
  }
}
