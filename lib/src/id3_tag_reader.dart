///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///

import 'dart:io';

import 'id3_tag.dart';
import 'frames/frame_parser.dart';
import 'id3_parser.dart';


abstract class ID3TagReader {

  bool get id3TagFound;

  ID3Tag get tag;


  factory ID3TagReader.path(String filePath, {Map<String, FrameParser>? frameParsers}) {
    return ID3Parser(File(filePath), frameParsers: frameParsers);
  }

  factory ID3TagReader(File file, {Map<String, FrameParser>? frameParsers}) {
    return ID3Parser(file, frameParsers: frameParsers);
  }


  /// Reads the ID3 Tag of the file and parses the frames asynchronously. If an error occurs (or if the file doesn't
  /// contain an ID3 tag), [ID3Tag.id3TagFound] will be false.
  Future<ID3Tag> readTag();

  /// Reads the ID3 Tag of the file and parses the frames. If an error occurs (or if the file doesn't contain an ID3
  /// tag), [ID3Tag.id3TagFound] will be false.
  ID3Tag readTagSync();
}