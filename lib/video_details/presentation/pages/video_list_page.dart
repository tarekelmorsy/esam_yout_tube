import 'package:esam_yout_tube/video_details/data/models/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../cubits/video_list/video_list_cubit.dart';
import '../cubits/video_list/video_list_state.dart';
import 'video_detail_page.dart';
import 'carousel_with_indicator.dart';

class VideoListPage extends StatefulWidget {
  const VideoListPage({Key? key}) : super(key: key);

  @override
  _VideoListPageState createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final cubit = context.read<VideoListCubit>();
    final state = cubit.state;

    // تحقق مما إذا كان المستخدم قد وصل إلى نهاية القائمة
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        state.nextPageToken != null &&
        !state.isLoadingMore) {
      print(
          'Fetching more videos: playlistId=${state.currentPlaylistId}, nextPageToken=${state.nextPageToken}');
      cubit.fetchVideos(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // استخدام BlocBuilder للوصول إلى حالة VideoListCubit
    return BlocBuilder<VideoListCubit, VideoListState>(
      builder: (context, state) {
        // Debugging: طباعة قيم playlistId و nextPageToken
        print('Current Playlist ID: ${state.currentPlaylistId}');
        print('Next Page Token: ${state.nextPageToken}');

        return Scaffold(
          appBar: AppBar(
            title: Text(state.currentPlaylistTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<VideoListCubit>().fetchVideos();
                },
              ),
            ],
          ),
          drawer: const VideoDrawer(),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  await context.read<VideoListCubit>().fetchVideos();
                },
                child: Column(
                  children: [
                    const CarouselWithIndicator(),
                    Expanded(
                      child: state.videos.isEmpty && state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state.videos.isEmpty && state.errorMessage != null
                          ? Center(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 16),
                        ),
                      )
                          : ListView.builder(
                        controller: _scrollController,
                        itemCount: state.videos.length +
                            (state.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < state.videos.length) {
                            final video = state.videos[index];
                            return VideoListItem(video: video);
                          } else {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                    child:
                                    CircularProgressIndicator()),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isLoading && state.videos.isEmpty)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }
}

class VideoListItem extends StatelessWidget {
  final VideoModel video;

  const VideoListItem({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ListTile(
        leading: video.thumbnailUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: video.thumbnailUrl,
          width: 80,
          fit: BoxFit.cover,
          placeholder: (context, url) => Image.asset(
              'assets/placeholder.jpg',
              width: 80,
              fit: BoxFit.cover),
          errorWidget: (context, url, error) => Image.asset(
              'assets/placeholder.jpg',
              width: 80,
              fit: BoxFit.cover),
        )
            : Image.asset('assets/placeholder.jpg',
            width: 80, fit: BoxFit.cover),
        title: Text(
          video.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          video.formattedPublishedAt,
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () {
          if (video.videoId.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoDetailPage(
                  videoId: video.videoId,
                  apiKey:
                  'YOUR_API_KEY_HERE', // استبدلها بمفتاح الـ API الخاص بك
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class VideoDrawer extends StatelessWidget {
  const VideoDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام BlocBuilder للوصول إلى حالة VideoListCubit
    return Drawer(
      child: BlocBuilder<VideoListCubit, VideoListState>(
        builder: (context, state) {
          return Column(
            children: [
              // صورة في الأعلى
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Center(
                  child: Image.asset('assets/placeholder.jpg',
                      width: 100, height: 100),
                ),
              ),
              // جميع الفيديوهات
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('جميع الفيديوهات'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<VideoListCubit>().selectPlaylist(null);
                },
              ),
              const Divider(),
              // قوائم التشغيل
              state.isPlaylistsLoading
                  ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              )
                  : Expanded(
                child: state.playlists.isEmpty
                    ? const Center(child: Text('لا توجد قوائم تشغيل'))
                    : ListView.builder(
                  itemCount: state.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = state.playlists[index];
                    return ListTile(
                      leading: const Icon(Icons.playlist_play),
                      title: Text(playlist.title),
                      onTap: () {
                        Navigator.pop(context);
                        context
                            .read<VideoListCubit>()
                            .selectPlaylist(playlist.id);
                      },
                    );
                  },
                ),
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
