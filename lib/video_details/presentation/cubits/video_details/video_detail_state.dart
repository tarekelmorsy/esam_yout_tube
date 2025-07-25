import 'package:equatable/equatable.dart';
import 'package:esam_yout_tube/video_details/data/models/comment_model.dart';

class VideoDetailState extends Equatable {
  final bool isLoading;
  final String title;
  final String description;
  final String viewCount;
  final String likeCount;
  final int commentCount;
  final List<CommentsModel> comments;
  final bool hasMore;
  final String? nextPageToken;
  final bool isLoadingMore;

  const VideoDetailState({
    this.isLoading = true,
    this.title = '',
    this.description = '',
    this.viewCount = '',
    this.likeCount = '',
    this.commentCount = 0,
    this.comments = const [],
    this.hasMore = true,
    this.nextPageToken,
    this.isLoadingMore = false,
  });

  VideoDetailState copyWith({
    bool? isLoading,
    String? title,
    String? description,
    String? viewCount,
    String? likeCount,
    int? commentCount,
    List<CommentsModel>? comments,
    bool? hasMore,
    String? nextPageToken,
    bool? isLoadingMore,
  }) {
    return VideoDetailState(
      isLoading: isLoading ?? this.isLoading,
      title: title ?? this.title,
      description: description ?? this.description,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      comments: comments ?? this.comments,
      hasMore: hasMore ?? this.hasMore,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    title,
    description,
    viewCount,
    likeCount,
    commentCount,
    comments,
    hasMore,
    nextPageToken,
    isLoadingMore,
  ];
}

