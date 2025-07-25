import 'package:equatable/equatable.dart';

class CommentsModel  extends Equatable{
  final String userName;
  final String userImage;
  final String timeAgo;
  final String text;
  final int likes;

  const CommentsModel({
    required this.userName,
    required this.userImage,
    required this.timeAgo,
    required this.text,
    required this.likes,
  });

  factory CommentsModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet']['topLevelComment']['snippet'];
    return CommentsModel(
      userName: snippet['authorDisplayName'] ?? '',
      userImage: snippet['authorProfileImageUrl'] ?? '',
      timeAgo: calculateTimeAgo(snippet['publishedAt']),
      text: snippet['textDisplay'] ?? '',
      likes: snippet['likeCount'] ?? 0,
    );
  }

  static String calculateTimeAgo(String publishedAt) {
    final publishedDate = DateTime.parse(publishedAt).toLocal();
    final now = DateTime.now();
    final diff = now.difference(publishedDate);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ساعة';
    } else if (diff.inDays < 30) {
      return '${diff.inDays} يوم';
    } else {
      final months = diff.inDays ~/ 30;
      return '$months شهر';
    }
  }
  @override
  List<Object?> get props => [
    userName,
    userImage,
    timeAgo,
    text,
    likes,
  ];
}
