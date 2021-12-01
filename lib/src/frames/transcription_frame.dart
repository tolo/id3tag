import 'dart:convert';

import 'frame.dart';
import '../raw_frame.dart';
import 'frame_parser.dart';


const String _frameName = 'USLT';


class Transcription extends Frame {
  @override String get frameName => _frameName;

  final String language;
  final String contentDescriptor;
  final String lyrics;

  Transcription({required this.language, required this.contentDescriptor, required this.lyrics});

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


class TranscriptionFrameParser extends FrameParser<Transcription> {
  @override
  List<String> get frameNames => [_frameName];

  @override
  Transcription? parseFrame(RawFrame rawFrame) {
    final frameContent = rawFrame.frameContent;
    frameContent.readEncoding();
    final language = latin1.decode(frameContent.readBytes(3));
    var contentDescriptor = frameContent.readString(checkEncoding: false);
    final lyrics = (frameContent.remainingBytes > 0)
        ? frameContent.readString(checkEncoding: false, terminatorMandatory: false)
        : contentDescriptor;

    // TODO: Review
    if (frameContent.remainingBytes == 0) {
      contentDescriptor = '';
    }

    return Transcription(language: language, contentDescriptor: contentDescriptor, lyrics: lyrics);
  }
}
