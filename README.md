# ID3Tag

ID3Tag is a small library for reading common ID3 meta data from mp3-files and other types of media files. 
There are of course already other libraries for doing this out there, but at the time of creating this library, none of 
them provided support in three critical areas: 

- Reading **chapter** (`CHAP`) and **table of contents** (`CTOC`) frames
- Reading ID3 meta data without having to load the entire file into memory
- Easy extensibility to be able to implement support for additional frame types

Thus, the above list was the basic motivation for creating this library. Also, the specific use case of supporting mp3 
audio books was another motivating factor (hence support for chapters and large file sizes).  


## Features

- Support for ID3 v2.3 (and above)
- Support for common ID3 frames, such as:
    - Text information frames [see here](https://id3.org/id3v2.3.0#Text_information_frames) 
    - Chapter frames, i.e. [`CHAP` frames](https://id3.org/id3v2-chapters-1.0#Chapter_frame)
    - Table of contents frames, i.e. [`CTOC` frames](https://id3.org/id3v2-chapters-1.0#Table_of_contents_frame)
    - Attached picture frames, i.e. [`APIC` frames](https://id3.org/id3v2.3.0#Attached_picture)
    - Comment frames, i.e. [`COMM` frames](https://id3.org/id3v2.3.0#Comments)


## Usage

To use this package, simply include the dependency, import the package and then use the class `ID3TagReader` to read 
the ID3 tag from a file.  

```dart
final parser = ID3TagReader.path('path to a file');
final tag = parser.readTagSync();
print('Title: ${tag.title}');
print('All chapters: ${tag.chapters}');
// Or: 
print('Chapters in top level table of contents: ${tag.topLevelChapters}');
```

During development, it may sometimes be convenient to use files in the form of asset resources. To accomplish this, you 
can use the snippet below (requires the [path_provider package](https://pub.dev/packages/path_provider)): 

```dart
import 'package:path_provider/path_provider.dart';
...
final ByteData fileData = await rootBundle.load('some asset file');
final filePath = '${(await getTemporaryDirectory()).path}/a file name';
File(filePath).writeAsBytesSync(fileData.buffer.asUint8List(fileData.offsetInBytes, fileData.lengthInBytes));
```


## Additional information

This library was initially derived from the package [id3](https://github.com/sanket143/id3), but later refactored,
rewritten and and rearchitected for better extensibility, readability and robustness. The architecture was in part
inspired by [OutcastID3](https://github.com/CrunchyBagel/OutcastID3). 
