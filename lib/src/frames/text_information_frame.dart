import 'frame_parser.dart';
import '../raw_frame.dart';

import 'frame.dart';


class TextInformation extends Frame {
  @override
  final String frameName;
  final String frameDescription;
  final String value;

  TextInformation({required this.frameName, required this.frameDescription, required this.value});

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName' : frameName,
      'frameDescription' : frameDescription,
      'value' : value,
    };
  }
}


class TextInformationFrameParser extends FrameParser<TextInformation> {

  static final List<String> _frameNames = _textFrames.keys.toList();

  @override
  List<String> get frameNames => _frameNames;

  @override
  TextInformation? parseFrame(RawFrame rawFrame) {
    final frameName = rawFrame.frameName;
    final frameContent = rawFrame.frameContent;
    final value = frameContent.readString(terminatorMandatory: false);
    return TextInformation(frameName: frameName, frameDescription: _textFrames[frameName] ?? '-', value: value);
  }
}



const Map<String, String> _textFrames = {
  'IPLS': 'People',
  'TALB': 'Album',
  'TBPM': 'BPM',
  'TCOM': 'Composer',
  'TCON': 'Genre',
  'TCOP': 'Copyright',
  'TDAT': 'Date',
  'TDLY': 'Playlist',
  'TENC': 'EncodedBy',
  'TEXT': 'Lyricist',
  'TFLT': 'FileType',
  'TIME': 'Time',
  'TIT1': 'Content',
  'TIT2': 'Title',
  'TIT3': 'SubTitle',
  'TKEY': 'Key',
  'TLAN': 'Language',
  'TLEN': 'Length',
  'TMED': 'MediaType',
  'TOAL': 'OriginalAlbum',
  'TOFN': 'OriginalFilename',
  'TOLY': 'OriginalLyricist',
  'TOPE': 'OriginalPerformer',
  'TORY': 'OriginalReleaseYear',
  'TOWN': 'Owner',
  'TPE1': 'Artist',
  'TPE2': 'Accompaniment',
  'TPE3': 'Conductor',
  'TPE4': 'ModifiedBy',
  'TPOS': 'TPOS',
  'TPUB': 'Publisher',
  'TRCK': 'Track',
  'TRDA': 'RecordedOn',
  'TRSN': 'RadioStation',
  'TRSO': 'RadioStationOwner',
  'TSIZ': 'Size',
  'TSRC': 'ISRC',
  'TSSE': 'Settings',
  'TYER': 'Year',
  'TXXX': 'AdditionalInfo',
  'TDES': 'Podcast Description',
};

