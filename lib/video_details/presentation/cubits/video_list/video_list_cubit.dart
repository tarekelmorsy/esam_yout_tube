import 'package:esam_yout_tube/video_details/data/models/playlist_model.dart';
import 'package:esam_yout_tube/video_details/data/models/video_model.dart';
import 'package:esam_yout_tube/video_details/data/repositories/video_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_list_state.dart';

class VideoListCubit extends Cubit<VideoListState> {
  final VideoRepository repository;
  final String channelId;

  VideoListCubit({required this.repository, required this.channelId})
      : super(const VideoListState()) {
    fetchPlaylists();
    fetchVideos();
  }

  Future<void> fetchPlaylists() async {
    emit(state.copyWith(isPlaylistsLoading: true, errorMessage: null));
    try {
      List<PlaylistModel> playlists = await repository.fetchPlaylists(channelId);
      emit(state.copyWith(playlists: playlists, isPlaylistsLoading: false));
    } catch (e) {
      print('Error fetching playlists: $e');
      emit(state.copyWith(
          isPlaylistsLoading: false, errorMessage: 'فشل في جلب قوائم التشغيل'));
    }
  }

  Future<void> fetchVideos({bool loadMore = false}) async {
    if (loadMore && state.isLoadingMore) return;
    if (!loadMore && state.isLoading) return;

    if (loadMore) {
      emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    } else {
      emit(state.copyWith(
          isLoading: true,
          videos: [],
          nextPageToken: null,
          errorMessage: null));
    }

    try {
      final data = await repository.fetchVideos(
        channelId: channelId,
        playlistId: state.currentPlaylistId,
        pageToken: loadMore ? state.nextPageToken : null,
      );

      List<dynamic> items = data['items'] ?? [];
      String? nextToken = data['nextPageToken'];

      print("nextToken $nextToken");
      print("channelId $channelId");
      print("playlistId ${state.currentPlaylistId}");

      List<VideoModel> fetchedVideos = items.map((item) {
        if (state.currentPlaylistId == null) {
          return VideoModel.fromSearchJson(item);
        } else {
          return VideoModel.fromPlaylistJson(item);
        }
      }).toList();

      if (loadMore) {
        emit(state.copyWith(
          videos: [...state.videos, ...fetchedVideos],
          nextPageToken: nextToken,
          isLoadingMore: false,
        ));
      } else {
        String title = state.currentPlaylistId == null
            ? 'جميع الفيديوهات'
            : state.playlists
            .firstWhere(
                (playlist) => playlist.id == state.currentPlaylistId,
            orElse: () => PlaylistModel(
                id: '', title: 'جميع الفيديوهات', thumbnailUrl: ''))
            .title;
        emit(state.copyWith(
          videos: fetchedVideos,
          nextPageToken: nextToken,
          isLoading: false,
          currentPlaylistTitle: title,
        ));
      }
    } catch (e) {
      print('Error fetching videos: $e');
      if (loadMore) {
        emit(state.copyWith(
            isLoadingMore: false, errorMessage: 'فشل في جلب المزيد من الفيديوهات'));
      } else {
        emit(state.copyWith(isLoading: false, errorMessage: 'فشل في جلب الفيديوهات'));
      }
    }
  }

  void selectPlaylist(String? playlistId) {
    emit(state.copyWith(
      currentPlaylistId: playlistId,
      videos: [],
      nextPageToken: null,
      currentPlaylistTitle: playlistId == null ? 'جميع الفيديوهات' : '',
      errorMessage: null,
    ));
    fetchVideos();
  }
}
