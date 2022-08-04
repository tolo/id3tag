import 'dart:io';
import 'package:test/test.dart';

import 'package:id3tag/src/id3_parser.dart';
import 'package:id3tag/src/extensions/iterable_extension.dart';


void main() {
  // test('Truncate file to ID3 tag size', () {
  //   final file = File('test/truncated.mp3');
  //   final parser = ID3Parser(file);
  //   final fileID3TagSize = parser.id3CompleteTagSize;
  //
  //   final RandomAccessFile raf = file.openSync(mode: FileMode.append);
  //   raf.truncateSync(fileID3TagSize);
  //   raf.flushSync();
  //   raf.closeSync();
  // });

  test('Tag should contain basic metadata', () {
    final parser = ID3Parser(File('test/chap.mp3'));
    final tag = parser.readTagSync();
    expect(tag.tagFound, true);
    expect(tag.tagVersion, "2.3.0");
    expect(tag.title, isNotNull);
    expect(tag.duration, isNotNull);
    expect(tag.frameDictionaries.length, greaterThan(2));
  });

  test('Tag should contain chapters', () {
    final parser = ID3Parser(File('test/chap.mp3'));
    final tag = parser.readTagSync();
    final chapters = tag.chapters;
    expect(chapters.length, 13);
    expect(chapters.first.title, isNotEmpty);
  });

  test('Tag should contain table of contents', () {
    final parser = ID3Parser(File('test/ctoc.mp3'));
    final tag = parser.readTagSync();
    final tableOfContents = tag.tableOfContents;
    final topLevelTOC = tag.topLevelTOC;
    expect(tableOfContents.length, greaterThan(0));
    expect(topLevelTOC, isNotNull);

    // Get chapters objects for the toc
    final chapters = tag.chaptersForTOC(topLevelTOC!);
    expect(chapters.length, 15);
    expect(chapters.first.title, isNotEmpty);
    // Check url and image support
    expect(chapters[13].url?.url, isNotEmpty);
    expect(chapters[14].picture?.imageData, isNotEmpty);
  });

  test('Tag should contain picture', () {
    final parser = ID3Parser(File('test/apic.mp3'));
    final tag = parser.readTagSync();
    final frame = tag.frames.firstWhereOrNull((f) => f.frameName == 'APIC');
    expect(frame, isNotNull);
  });

  test('Tag should contain lyrics', () {
    final parser = ID3Parser(File('test/apic.mp3')); // apic test file also contains uslt
    final tag = parser.readTagSync();
    final frame = tag.frames.firstWhereOrNull((f) => f.frameName == 'USLT');
    expect(frame, isNotNull);
  });
}
