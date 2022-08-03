import 'dart:io';
import 'package:test/test.dart';

import 'package:id3tag/src/id3_parser.dart';
import 'package:id3tag/src/extensions/iterable_extension.dart';


void main() {
  /*test('Truncate file to ID3 tag size', () {
    final file = File('test/truncate.mp3');
    final parser = ID3Parser(file);
    final fileID3TagSize = parser.id3CompleteTagSize;

    final RandomAccessFile raf = file.openSync(mode: FileMode.append);
    raf.truncateSync(fileID3TagSize);
    raf.flushSync();
    raf.closeSync();
  });*/

  test('Tag should contain chapters', () {
    final parser = ID3Parser(File('test/chap.mp3'));
    final tag = parser.readTagSync();
    // print('ID3 tag found: ${tag.tagFound} - version: ${tag.tagVersion}');
    // print('Title: ${tag.title}');
    // print('Duration: ${tag.duration}');
    // print('Chapters: ${tag.chapters}');
    // print('frameDictionaries: ${tag.frameDictionaries}');
    final frame = tag.frames.firstWhereOrNull((f) => f.frameName == 'CHAP');
    expect(frame, isNotNull);
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
