import 'package:cached_network_image/cached_network_image.dart';
import 'package:esam_yout_tube/video_detail_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'notificatios/utils/cloud_messaging.dart';
/*
حاليا عايز اضيف جزئية النتفكيشن عايز اول اما فديو جديد ينزل يبعت لكل اليوزر اشعار علي التطبيق ان في فديو جديد نزل لو ضغط علي الاشعار يفتح الفديو علي طول يفتح صفحه الvideo_detail_page بداتا الفديو
انا مش عايا باك اند فلاتر فقط قلي نعمل ده ازاي
 */
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  // InAppWebViewPlatform.instance = WebKitInAppWebViewPlatform();
  await initializeFirebase();
  // await initializeServes();
  // await Upgrader.clearSavedSettings();
  FirebaseMessaging.onBackgroundMessage(
      userFirebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

// ضع مفتاح الـAPI الخاص بك هنا:
const String apiKey = 'AIzaSyATvIHo8sbo7UO8ene6xeqmfKeoF1p5p6U';


// ضع الـChannel ID الخاص بالقناة هنا. على سبيل المثال افتراضياً:
const String channelId = 'UCvejmf3XCqrv0kjFZ_EmSsA'; // مثال، يجب تغييره إلى القناة المطلوبة


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
@override
void initState() {
   // الاشتراك في Topic
  FirebaseMessaging.instance.subscribeToTopic('NewVideos');
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قائمة فيديوهات اليوتيوب',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),
      home: const VideoListPage(),
    );
  }
}

class VideoListPage extends StatefulWidget {
  const VideoListPage({Key? key}) : super(key: key);

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  List<dynamic> videos = [];
  bool isLoading = false;
  String? nextPageToken;
  final ScrollController _scrollController = ScrollController();
  final int maxResults = 30;

  // قوائم التشغيل
  List<dynamic> playlists = [];
  bool isPlaylistsLoading = false;

  // إذا currentPlaylistId = null => "جميع الفيديوهات"
  // غير ذلك: قم بجلب الفيديوهات من playlistId المحدد.
  String? currentPlaylistId;

  @override
  void initState() {
    super.initState();
    fetchPlaylists();
    fetchVideos();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchPlaylists() async {
    setState(() {
      isPlaylistsLoading = true;
    });
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=$channelId&maxResults=50&key=$apiKey');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          playlists = data['items'] ?? [];
        });
      } else {
        print('خطأ في جلب قوائم التشغيل: ${response.statusCode}');
      }
    } catch (e) {
      print('حدث خطأ عند جلب قوائم التشغيل: $e');
    }

    setState(() {
      isPlaylistsLoading = false;
    });
  }

  Future<void> fetchVideos({bool loadMore = false}) async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });

    Uri url;
    if (currentPlaylistId == null) {
      // جميع الفيديوهات (باستخدام search)
      url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/search'
              '?key=$apiKey'
              '&channelId=$channelId'
              '&part=snippet,id'
              '&order=date'
              '&maxResults=$maxResults' +
              (nextPageToken != null && loadMore ? '&pageToken=$nextPageToken' : ''));
    } else {
      // فيديوهات قائمة تشغيل معينة
      url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/playlistItems'
              '?key=$apiKey'
              '&playlistId=$currentPlaylistId'
              '&part=snippet'
              '&maxResults=$maxResults' +
              (nextPageToken != null && loadMore ? '&pageToken=$nextPageToken' : ''));
    }

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newItems = data['items'] ?? [];

        setState(() {
          if (!loadMore) {
            videos = newItems;
          } else {
            videos.addAll(newItems);
          }
          nextPageToken = data['nextPageToken'];
        });
      } else {
        print('خطأ في جلب الفيديوهات: ${response.statusCode}');
      }
    } catch (e) {
      print('حدث خطأ عند جلب الفيديوهات: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        canLoadMore) {
      fetchVideos(loadMore: true);
    }
  }

  bool get canLoadMore => nextPageToken != null && nextPageToken!.isNotEmpty;

  Widget buildVideoItem(dynamic video) {
    // إذا currentPlaylistId != null, الفيديوهات تأتي من playlistItems
    // شكل الاستجابة يختلف قليلا: الفيديو id موجود داخل snippet.resourceId.videoId
    // أما في search: video['id']['videoId']
    String? videoId;
    String title;
    String publishedAt;
    String? thumbnailUrl;

    if (currentPlaylistId == null) {
      // جميع الفيديوهات من search
      final snippet = video['snippet'];
      title = snippet['title'];
      publishedAt = snippet['publishedAt'];
      thumbnailUrl = snippet['thumbnails']?['medium']?['url'] ??
          snippet['thumbnails']?['default']?['url'];
      videoId = video['id']['videoId'];
    } else {
      // فيديوهات من playlistItems
      final snippet = video['snippet'];
      title = snippet['title'];
      publishedAt = snippet['publishedAt'];
      thumbnailUrl = snippet['thumbnails']?['medium']?['url'] ??
          snippet['thumbnails']?['default']?['url'];
      videoId = snippet['resourceId']?['videoId'];
    }

    final publishDate = DateTime.tryParse(publishedAt);
    String formattedDate = '';
    if (publishDate != null) {
      formattedDate = 'قبل ${calculateTimeAgo(publishDate)}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ListTile(
        leading: thumbnailUrl != null && thumbnailUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: thumbnailUrl,
          width: 80,
          fit: BoxFit.cover,
          placeholder: (context, url) =>
              Image.asset('assets/placeholder.jpg', width: 80, fit: BoxFit.cover),
          errorWidget: (context, url, error) =>
              Image.asset('assets/placeholder.jpg', width: 80, fit: BoxFit.cover),
        )
            : Image.asset('assets/placeholder.jpg', width: 80, fit: BoxFit.cover),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          formattedDate,
          style: const TextStyle(color: Colors.grey),
        ),
        onTap: () {
          if (videoId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoDetailPage(
                  videoId: videoId??"",
                  apiKey: apiKey,
                ),
              ),
            );
          }
        },
      ),
    );
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

  Widget buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // صورة في الأعلى
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Center(
              child: Image.asset('assets/placeholder.jpg', width: 100, height: 100),
            ),
          ),
          // جميع الفيديوهات
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('جميع الفيديوهات'),
            onTap: () {
              Navigator.pop(context);
              // إعادة تعيين currentPlaylistId
              setState(() {
                currentPlaylistId = null;
                nextPageToken = null;
              });
              fetchVideos();
            },
          ),
          const Divider(),

          if (isPlaylistsLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final p = playlists[index];
                  final pSnippet = p['snippet'];
                  final pTitle = pSnippet['title'];
                  final playlistId = p['id'];

                  return ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(pTitle),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        currentPlaylistId = playlistId;
                        nextPageToken = null;
                      });
                      fetchVideos();
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = 'جميع الفيديوهات';
    if (currentPlaylistId != null) {
      // ابحث عن اسم playlist المختار
      final playlist = playlists.firstWhere((p) => p['id'] == currentPlaylistId,
          orElse: () => null);
      if (playlist != null) {
        appBarTitle = playlist['snippet']['title'];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              nextPageToken = null;
              fetchVideos();
            },
          ),
        ],
      ),
      drawer: buildDrawer(),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              nextPageToken = null;
              await fetchVideos();
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: videos.length + (canLoadMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < videos.length) {
                  final video = videos[index];
                  return buildVideoItem(video);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
          if (isLoading && videos.isEmpty)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
