// ignore_for_file: avoid_print
import 'package:id3tag/id3tag.dart';

void main() {
  final parser = ID3TagReader.path('path to a file');
  final tag = parser.readTagSync();
  print('ID3 tag found: ${tag.tagFound} - version: ${tag.tagVersion}');
  print('Title: ${tag.title}');
  print('Duration: ${tag.duration}');
  print('Chapters: ${tag.chapters}');
}
