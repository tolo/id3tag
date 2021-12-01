
extension IterableExtensions<E> on Iterable<E> {

  E? firstIfAny({minLength = 1}) => length >= minLength ? first : null;

  E? lastIfAny({minLength = 1}) => length >= minLength ? last : null;

}
