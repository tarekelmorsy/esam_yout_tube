import 'package:equatable/equatable.dart';
import 'package:esam_yout_tube/video_details/data/models/playlist_model.dart';
import 'package:esam_yout_tube/video_details/data/models/video_model.dart';

class VideoListState extends Equatable {
  final List<VideoModel> videos;
  final List<PlaylistModel> playlists;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isPlaylistsLoading;
  final String? nextPageToken;
  final String? currentPlaylistId;
  final String currentPlaylistTitle;
  final String? errorMessage;

  const VideoListState({
    this.videos = const [],
    this.playlists = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isPlaylistsLoading = false,
    this.nextPageToken,
    this.currentPlaylistId,
    this.currentPlaylistTitle = 'جميع الفيديوهات',
    this.errorMessage,
  });

  VideoListState copyWith({
    List<VideoModel>? videos,
    List<PlaylistModel>? playlists,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isPlaylistsLoading,
    String? nextPageToken,
    String? currentPlaylistId,
    String? currentPlaylistTitle,
    String? errorMessage,
  }) {
    return VideoListState(
      videos: videos ?? this.videos,
      playlists: playlists ?? this.playlists,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isPlaylistsLoading: isPlaylistsLoading ?? this.isPlaylistsLoading,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      currentPlaylistId: currentPlaylistId ?? this.currentPlaylistId,
      currentPlaylistTitle:
      currentPlaylistTitle ?? this.currentPlaylistTitle,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    videos,
    playlists,
    isLoading,
    isLoadingMore,
    isPlaylistsLoading,
    nextPageToken,
    currentPlaylistId,
    currentPlaylistTitle,
    errorMessage,
  ];
}
