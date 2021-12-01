///
/// Copyright (c) 2021 Tobias Löfstrand. License: MIT (see LICENSE file).
///
/// Partially derived from https://github.com/sanket143/id3 (Copyright (c) 2019 Sanket Chaudhari)
///

class ID3ParserException implements Exception {
  final String cause;

  ID3ParserException(this.cause);

  @override
  String toString() => cause;
}
