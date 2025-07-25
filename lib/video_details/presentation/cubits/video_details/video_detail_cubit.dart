import 'package:esam_yout_tube/video_details/data/models/comment_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_detail_state.dart';
import 'package:esam_yout_tube/video_details/data/repositories/video_repository.dart';

class VideoDetailCubit extends Cubit<VideoDetailState> {
  final VideoRepository repository;
  final String videoId;

  VideoDetailCubit({required this.repository, required this.videoId})
      : super(const VideoDetailState()) {
    fetchVideoDetails();
    fetchComments();
  }

  Future<void> fetchVideoDetails() async {
    try {
      final videoData = await repository.fetchVideoDetails(videoId);
      if (videoData != null) {
        final snippet = videoData['snippet'];
        final stats = videoData['statistics'];
        emit(state.copyWith(
          title: snippet['title'] ?? '',
          description: snippet['description'] ?? '',
          viewCount: formatNumber(stats['viewCount'] ?? '0'),
          likeCount: formatNumber(stats['likeCount'] ?? '0'),
          commentCount: int.tryParse(stats['commentCount'] ?? '0') ?? 0,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      debugPrint('Error fetching video details: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> fetchComments() async {
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final data = await repository.fetchComments(videoId, state.nextPageToken);
      final newItems = data['items'] as List?;
      final nextPageToken = data['nextPageToken'];

      if (newItems != null && newItems.isNotEmpty) {
        List<CommentsModel> fetchedComments =
            newItems.map((item) => CommentsModel.fromJson(item)).toList();

        emit(state.copyWith(
          comments: [...state.comments, ...fetchedComments],
          isLoadingMore: false,
          hasMore: fetchedComments.length < 15 || nextPageToken == null
              ? false
              : true,
          nextPageToken: nextPageToken,
        ));
      } else {
        emit(state.copyWith(
          hasMore: false,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      emit(state.copyWith(
        isLoadingMore: false,
        hasMore: false,
      ));
    }
  }

  String formatNumber(String number) {
    final count = int.tryParse(number) ?? 0;
    if (count >= 1000000000) {
      return '${(count / 1000000000).toStringAsFixed(1)}B';
    } else if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
