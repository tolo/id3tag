///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///

import 'extensions/iterable_extension.dart';
import 'frames/frames.dart';
import 'frames/chapter_frame.dart';


class ID3Tag {

  final String tagVersion;
  final bool tagFound;
  final List<Frame> frames;

  List<Map<String, dynamic>> get frameDictionaries => frames.map((e) => e.toDictionary()).toList();

  String? get title => frameWithTypeAndName<TextInformation>('TIT2')?.value;

  String? get artist => frameWithTypeAndName<TextInformation>('TPE1')?.value;
  Transcription? get lyric => frameWithTypeAndName<Transcription>('USLT');

  String? get album => frameWithTypeAndName<TextInformation>('TALB')?.value;

  String? get track => frameWithTypeAndName<TextInformation>('TRCK')?.value;
  String? get trackNumber => track?.split('/').firstIfAny(minLength: 2);
  String? get trackTotal => track?.split('/').lastIfAny(minLength: 2);

  Duration? get duration {
    final durationRaw = frameWithTypeAndName<TextInformation>('TLEN')?.value;
    return durationRaw != null && durationRaw.isNotEmpty ? Duration(milliseconds: int.parse(durationRaw)) : null;
  }

  List<Picture> get pictures => framesWithTypeAndName<Picture>('APIC');

  /// Gets the first comment found in the tag
  Comment? get comment => frameWithTypeAndName<Comment>('COMM');
  List<Comment> get comments => framesWithTypeAndName<Comment>('COMM');

  /// Gets the chapter (`CHAP`) frames, represented as [Chapter] objects. The returned chapters are sorted according to
  /// start time.
  List<Chapter> get chapters {
    final _chapters = framesWithType<Chapter>();
    _chapters.sort((a, b) => a.startTimeMilliseconds.compareTo(b.startTimeMilliseconds));
    return _chapters;
  }


  ID3Tag({required this.tagVersion, required this.tagFound, required this.frames});


  /// Returns all frame matching the specified [name]
  List<Frame> framesWithName(String name) {
    return frames
        .where((e) => e.frameName == name)
        .toList();
  }

  /// Returns all frame matching the specified [name] and type
  List<T> framesWithType<T extends Frame>() {
    return frames
        .whereType<T>()
        .toList();
  }

  /// Returns all frame matching the specified [name] and type
  List<T> framesWithTypeAndName<T extends Frame>(String name) {
    return frames
        .whereType<T>()
        .where((e) => e.frameName == name)
        .toList();
  }

  /// Returns the first frame with the specified [name] and type
  Frame? frameWithName(String name) {
    return framesWithName(name).firstIfAny();
  }

  /// Returns the first frame with the specified [name] and type
  T? frameWithTypeAndName<T extends Frame>(String name) {
    return framesWithTypeAndName<T>(name).firstIfAny();
  }
}


