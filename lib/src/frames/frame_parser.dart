import 'frame.dart';
import '../raw_frame.dart';


abstract class FrameParser<T extends Frame> {
  List<String> get frameNames;

  T? parseFrame(RawFrame rawFrame);
}
