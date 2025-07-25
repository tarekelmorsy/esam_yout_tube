class PlaylistModel {
  final String id;
  final String title;
  final String thumbnailUrl;

  PlaylistModel({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? '',
      title: json['snippet']['title'] ?? '',
      thumbnailUrl: json['snippet']['thumbnails']['default']['url'] ?? '',
    );
  }
}
