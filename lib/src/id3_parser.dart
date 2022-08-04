///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///
/// Partially derived from https://github.com/sanket143/id3 (Copyright (c) 2019 Sanket Chaudhari)
///

import 'dart:convert';
import 'dart:io';

import 'extensions/byte_list_extension.dart';
import 'frames/frames.dart';
import 'id3_tag.dart';
import 'id3_tag_reader.dart';
import 'raw_frame.dart';


class ID3Parser implements ID3TagReader {

  static const int id3FileHeaderLength = 10;

  static final Map<String, FrameParser> _defaultParsers = _setupDefaultParsers();


  final Map<String, FrameParser> _parsers;

  @override bool get id3TagFound => id3FileHeader.id3TagSize > 0;

  int get id3CompleteTagSize => id3FileHeaderLength + _id3TagBytes.length;

  final ID3FileHeader id3FileHeader;

  final List<int> _id3TagBytes;
  final int _initialOffset;

  int get _frameNameLength => id3FileHeader.frameNameLength;
  int get _frameSizeLength => id3FileHeader.frameSizeLength;
  int get _frameHeaderLength => id3FileHeader.frameHeaderLength;

  final _frameNameMatcher = RegExp(r'[A-Z0-9]+');

  final List<Frame> _parsedFrames = [];
  @override ID3Tag get tag => ID3Tag(tagVersion: id3FileHeader.id3TagVersion, tagFound: id3TagFound, frames: _parsedFrames);


  ID3Parser._raw({required Map<String, FrameParser> frameParsers, required this.id3FileHeader,
    required List<int> id3TagBytes, required int initialOffset}) :
        _parsers = frameParsers, _id3TagBytes = id3TagBytes, _initialOffset = initialOffset;

  factory ID3Parser(File file, {Map<String, FrameParser>? frameParsers}) {
    final RandomAccessFile reader = file.openSync(mode: FileMode.read);

    try {
      final length = reader.lengthSync();
      final List<int> fileHeaderBytes = length > id3FileHeaderLength ? reader.readSync(id3FileHeaderLength) : [];
      // Assume ID3 tag is at beginning of file
      final List<int>? id3FileTag = fileHeaderBytes.length == id3FileHeaderLength ? fileHeaderBytes.sublist(0, 3) : null;

      if (id3FileTag != null && latin1.decode(id3FileTag) == 'ID3') {
        final headerBytes = fileHeaderBytes.toList();
        final header = ID3FileHeader.fromHeaderBytes(headerBytes);

        final id3TagBytes = reader.readSync(header.id3TagSize);

        int initialOffset = 0;
        if (header.hasExtendedHeader) {
          final extendedHeaderSize = id3TagBytes.sublist(0, 4).parseInt(header.tagMinorVersion);
          initialOffset = extendedHeaderSize + 4; // Size doesn't include size itself
        }

        return ID3Parser._raw(frameParsers: frameParsers ?? ID3Parser._defaultParsers, id3FileHeader: header,
            id3TagBytes: id3TagBytes, initialOffset: initialOffset);
      } else {
        return ID3Parser._raw(frameParsers: {}, id3FileHeader: ID3FileHeader.empty(),
            id3TagBytes: [], initialOffset: 0);
      }
    } finally {
      reader.closeSync();
    }
  }


  @override
  Future<ID3Tag> readTag() async {
    // TODO: Implement read async support
    return Future.sync(() => readTagSync());
  }

  @override
  ID3Tag readTagSync() {
    if (!id3TagFound) return ID3Tag(tagVersion: '', tagFound: false, frames: []);
    _parsedFrames.clear();

    int offset = _initialOffset;
    while (true) {
      final frame = parseRawFrame(_id3TagBytes, offset: offset);
      if (frame == null) break;

      final parser = _parsers[frame.frameName];
      if (parser != null) {
        final parsedFrame = parser.parseFrame(frame);
        if (parsedFrame != null) _parsedFrames.add(parsedFrame);
      }

      offset += frame.frameSize;
    }

    return tag;
  }

  Frame? parseSubFrame(RawFrame? rawFrame) {
    if (rawFrame == null) return null;
    final parser = _parsers[rawFrame.frameName];
    return parser?.parseFrame(rawFrame);
  }

  RawFrame? parseRawFrame(List<int> buffer, {int offset = 0}) {
    if (buffer.length < (offset + _frameHeaderLength)) return null;

    final List<int> frameHeader = buffer.sublist(offset, offset + _frameHeaderLength);
    final List<int> frameNameBytes = frameHeader.sublist(0, _frameNameLength);
    final String frameName = latin1.decode(frameNameBytes);

    if (frameName != _frameNameMatcher.stringMatch(frameName)) {
      return null;
    }

    int frameContentSize = frameHeader.sublist(_frameNameLength, _frameNameLength + _frameSizeLength)
        .parseInt(id3FileHeader.tagMinorVersion);
    final List<int> frameContent = buffer
        .sublist(offset + _frameHeaderLength, offset + _frameHeaderLength + frameContentSize);

    return RawFrame(this, frameName, _frameHeaderLength + frameContentSize, frameContent);
  }


  static Map<String, FrameParser> _setupDefaultParsers() {
    Map<String, FrameParser> parserMap = {};
    // ignore: prefer_function_declarations_over_variables
    final addParser = (FrameParser parser) => parserMap.addEntries(parser.frameNames.map((e) => MapEntry(e, parser)));

    addParser(ChapterFrameParser());
    addParser(TableOfContentsFrameParser());
    addParser(CommentFrameParser());
    addParser(PictureFrameParser());
    addParser(TextInformationFrameParser());
    //addParser(UrlFrameParser()); // TODO
    addParser(UserUrlFrameParser());
    addParser(TranscriptionFrameParser());

    return parserMap;
  }
}


class ID3FileHeader {
  final String id3TagVersion;
  /// The ID3 minor version, i.e. the X in 2.X.0
  final int tagMinorVersion;

  final int id3TagSize;

  // Note: Only supporting ID3v2.3 and above right now
  final int frameNameLength = 4;
  final int frameSizeLength = 4;
  final int frameTagLength = 2;
  late final int frameHeaderLength = frameNameLength + frameSizeLength + frameTagLength;

  final bool hasExtendedHeader;


  ID3FileHeader.raw({required this.id3TagVersion, required this.tagMinorVersion, required this.id3TagSize,
    required this.hasExtendedHeader});

  factory ID3FileHeader.fromHeaderBytes(List<int> headerBytes) {
    final int tagMinorVersion = headerBytes[3];
    final int tagMicroVersion = headerBytes[4];
    final int flag = headerBytes[5];

    //final bool unsync = (0x40 & flag != 0);
    final bool hasExtendedHeader = (0x20 & flag != 0);
    //final bool experimental = (0x10 & flag != 0);

    final id3TagSize = headerBytes.sublist(6, 10).parseID3FileHeaderSize();

    return ID3FileHeader.raw(
      id3TagVersion: '2.$tagMinorVersion.$tagMicroVersion',
      tagMinorVersion: tagMinorVersion,
      id3TagSize: id3TagSize,
      hasExtendedHeader: hasExtendedHeader,
    );
  }

  factory ID3FileHeader.empty() {
    return ID3FileHeader.raw(id3TagVersion: '-', tagMinorVersion: 0, id3TagSize: 0, hasExtendedHeader: false);
  }
}
