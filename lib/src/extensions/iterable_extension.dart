
extension IterableExtensions<E> on Iterable<E> {

  E? firstIfAny({minLength = 1}) => length >= minLength ? first : null;

  E? lastIfAny({minLength = 1}) => length >= minLength ? last : null;

  E? firstWhereOrNull(bool Function(E element) test) {
    try {
      return firstWhere(test);
    } catch(e) {
      return null;
    }
  }
}
