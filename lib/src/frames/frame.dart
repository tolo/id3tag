
abstract class Frame {
  String get frameName;

  Map<String, dynamic> toDictionary();

  @override
  String toString() {
    return '$runtimeType(${toDictionary().toString()})';
  }
}
