class PaginationMeta {
  final int currentPage;
  final int pageSize;
  final int totalItems;
  final int totalPages;
  final bool hasMore;

  PaginationMeta({
    required this.currentPage,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      hasMore: json['hasMore'] ?? false,
    );
  }

  /// Default empty pagination (used as initial state)
  factory PaginationMeta.empty() {
    return PaginationMeta(
      currentPage: 0,
      pageSize: 10,
      totalItems: 0,
      totalPages: 0,
      hasMore: true,
    );
  }
}
