extension FirstOrNullExtension<T> on Iterable<T> {
  T? firstOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
