import '../raw_frame.dart';
import 'frame_parser.dart';
import 'frame.dart';


const String _frameName = 'APIC';


class Picture extends Frame {
  @override String get frameName => _frameName;

  final String mime;
  final String picType;
  final String description;
  final List<int> imageData;

  Picture({required this.mime, required this.picType,
    required this.description, required this.imageData});

  @override
  Map<String, dynamic> toDictionary() {
    return {
      'frameName' : frameName,
      'mime' : mime,
      'picType' : picType,
      'description' : description,
      'imageDataLength' : imageData.length,
    };
  }
}


class PictureFrameParser extends FrameParser<Picture> {
  @override
  List<String> get frameNames => [_frameName];

  @override
  Picture? parseFrame(RawFrame rawFrame) {
    final frameContent = rawFrame.frameContent;
    frameContent.readEncoding();
    final mime = frameContent.readLatin1String();
    final picType = _picType[frameContent.readBytes(1).first] ?? 'Unknown';
    final description = frameContent.readString(checkEncoding: false);
    final imageData = frameContent.readRemainingBytes();
    return Picture(mime: mime, picType: picType, description: description, imageData: imageData);
  }
}


const _picType = {
  0x00: 'Other',
  0x01: 'FileIcon',
  0x02: 'OtherFileIcon',
  0x03: 'FrontCover',
  0x04: 'BackCover',
  0x05: 'LeafletPage',
  0x06: 'Media (e.g. lable side of CD)',
  0x07: 'LeadArtist',
  0x08: 'Artist',
  0x09: 'Conductor',
  0x0A: 'Band',
  0x0B: 'Composer',
  0x0C: 'Lyricist',
  0x0D: 'RecordingLocation',
  0x0E: 'DuringRecording',
  0x0F: 'DuringPerformance',
  0x10: 'VideoStill',
  // Might be a joke but it's in the ID3 spec
  0x11: 'ABrightColouredFish',
  0x12: 'Illustration',
  0x13: 'ArtistLogo',
  0x14: 'PublisherLogo'
};
