class SearchResult {
  SearchResult({
    required this.title,
    required this.url,
    required this.date,
  });

  final String title;
  final String url;
  final String date;

  factory SearchResult.fromJson(Map<String, dynamic> data) {
    return SearchResult(
      title: data['title'],
      url: data['url'],
      date: data['date'],
    );
  }
}
