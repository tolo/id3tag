import 'dart:convert';

import 'frame.dart';
import '../raw_frame.dart';
import 'frame_parser.dart';


const String _frameName = 'USLT';


class Lyrics extends Frame {
  @override String get frameName => _frameName;

  final String language;
  final String contentDescriptor;
  final String lyrics;

  Lyrics({required this.language, required this.contentDescriptor, required this.lyrics});

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName' : frameName,
      'language' : language,
      'contentDescriptor' : contentDescriptor,
      'lyrics' : lyrics,
    };
  }
}


class TranscriptionFrameParser extends FrameParser<Lyrics> {
  @override
  List<String> get frameNames => [_frameName];

  @override
  Lyrics? parseFrame(RawFrame rawFrame) {
    final frameContent = rawFrame.frameContent;
    frameContent.readEncoding();
    final language = latin1.decode(frameContent.readBytes(3));
    var contentDescriptor = frameContent.readString(checkEncoding: false);

    var lyrics = '';
    if (frameContent.remainingBytes > 0) {
      lyrics = frameContent.readString(checkEncoding: false, terminatorMandatory: false);
    } else {
      lyrics = contentDescriptor;
      contentDescriptor = '';
    }

    return Lyrics(language: language, contentDescriptor: contentDescriptor, lyrics: lyrics);
  }
}
