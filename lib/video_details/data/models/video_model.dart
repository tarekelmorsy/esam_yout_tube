class VideoModel {
  final String videoId;
  final String title;
  final String publishedAt;
  final String thumbnailUrl;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.publishedAt,
    required this.thumbnailUrl,
  });

  factory VideoModel.fromSearchJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['id']['videoId'] ?? '',
      title: json['snippet']['title'] ?? '',
      publishedAt: json['snippet']['publishedAt'] ?? '',
      thumbnailUrl: json['snippet']['thumbnails']?['medium']?['url'] ??
          json['snippet']['thumbnails']?['default']?['url'] ??
          '',
    );
  }

  factory VideoModel.fromPlaylistJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['snippet']['resourceId']['videoId'] ?? '',
      title: json['snippet']['title'] ?? '',
      publishedAt: json['snippet']['publishedAt'] ?? '',
      thumbnailUrl: json['snippet']['thumbnails']?['medium']?['url'] ??
          json['snippet']['thumbnails']?['default']?['url'] ??
          '',
    );
  }

  String get formattedPublishedAt {
    final publishDate = DateTime.tryParse(publishedAt);
    if (publishDate == null) return '';
    return 'قبل ${calculateTimeAgo(publishDate)}';
  }

  String calculateTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365} عام';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} شهر';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} أيام';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعات';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقائق';
    } else {
      return 'الآن';
    }
  }
}
