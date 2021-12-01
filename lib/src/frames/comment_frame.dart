import 'dart:convert';

import '../raw_frame.dart';
import 'frame.dart';
import 'frame_parser.dart';


const String _frameName = 'COMM';


class Comment extends Frame {
  @override String get frameName => _frameName;

  final String language;
  final String description;
  final String comment;

  Comment({required this.language, required this.description, required this.comment});

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName' : frameName,
      'language' : language,
      'description' : description,
      'comment' : comment,
    };
  }
}


class CommentFrameParser extends FrameParser<Comment> {
  @override
  List<String> get frameNames => [_frameName];

  @override
  Comment? parseFrame(RawFrame rawFrame) {
    final frameContent = rawFrame.frameContent;
    frameContent.readEncoding();
    final language = latin1.decode(frameContent.readBytes(3));
    final description = frameContent.readString(checkEncoding: false);
    final comment = frameContent.readString(terminatorMandatory: false, checkEncoding: false);

    return Comment(language: language, description: description, comment: comment);
  }
}
