class PaginatedResult<T> {
  final List<T> results;
  final int count;
  final String? next;
  final String? previous;

  const PaginatedResult({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });
}
