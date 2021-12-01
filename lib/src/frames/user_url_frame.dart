import 'frame.dart';
import '../raw_frame.dart';
import 'frame_parser.dart';


const String _frameName = 'WXXX';


class UserUrl extends Frame {
  @override String get frameName => _frameName;

  final String description;
  final String url;

  UserUrl({required this.description, required this.url});

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName' : frameName,
      'description' : description,
      'url' : url,
    };
  }
}


class UserUrlFrameParser extends FrameParser<UserUrl> {
  @override
  List<String> get frameNames => [_frameName];

  @override
  UserUrl? parseFrame(RawFrame rawFrame) {
    final frameContent = rawFrame.frameContent;
    return UserUrl(
      description: frameContent.readString(),
      url: frameContent.readLatin1String(terminatorMandatory: false)
    );
  }
}
