///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///

import 'extensions/iterable_extension.dart';
import 'frames/frames.dart';


class ID3Tag {

  final String tagVersion;
  final bool tagFound;
  final List<Frame> frames;

  List<Map<String, dynamic>> get frameDictionaries => frames.map((e) => e.toDictionary()).toList();

  String? get title => frameWithTypeAndName<TextInformation>('TIT2')?.value;

  String? get artist => frameWithTypeAndName<TextInformation>('TPE1')?.value;

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

  /// Gets all the chapter (`CHAP`) frames defined in the tag, represented as [Chapter] objects. The returned chapters
  /// are sorted according to start time. **NOTE: ** Consider getting chapters via table of contents or by using
  /// [topLevelChapters].
  List<Chapter> get chapters {
    final chapters = framesWithType<Chapter>();
    chapters.sort((a, b) => a.startTimeMilliseconds.compareTo(b.startTimeMilliseconds));
    return chapters;
  }

  /// Gets the table of contents (`CTOC`) frames, represented as [TableOfContents] objects.
  List<TableOfContents> get tableOfContents => framesWithType<TableOfContents>();
  /// Gets the the top level table of contents (`CTOC`) frame or the first one if no top level is found.
  TableOfContents? get topLevelTOC {
    final toc = tableOfContents;
    return toc.firstWhereOrNull((toc) => toc.isTopLevel) ?? toc.firstIfAny();
  }

  /// Gets all the chapters referenced by the top level table of contents (or the first one). Falls back to [chapters]
  /// if no table of contents frame is present.
  List<Chapter> get topLevelChapters {
    final toc = topLevelTOC;
    if (toc != null && toc.childElementIds.isNotEmpty) { return chaptersForTOC(toc); }
    else { return chapters; }
  }

  /// Gets the unsynchronized lyric/text transcription ('USLT') frame, represented as a [Lyrics] object.
  List<Lyrics> get lyrics => framesWithTypeAndName<Lyrics>('USLT');


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

  /// Gets the chapters matching the element ids in the specified [TableOfContents] object.
  List<Chapter> chaptersForTOC(TableOfContents toc) {
    final chapters = framesWithType<Chapter>();
    List<Chapter> tocChapters = [];
    for (var elementId in toc.childElementIds) {
      final index = chapters.indexWhere((c) => c.elementId == elementId);
      if (index > -1) {
        tocChapters.add(chapters[index]);
        chapters.removeAt(index);
      }
    }
    return tocChapters;
  }
}
