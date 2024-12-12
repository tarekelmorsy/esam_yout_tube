import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoDetailPage extends StatefulWidget {
  final String videoId;
  final String apiKey;

  const VideoDetailPage({
    Key? key,
    required this.videoId,
    required this.apiKey,
  }) : super(key: key);

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  bool isLoading = true;
  String title = '';
  String description = '';
  String viewCount = '';
  String likeCount = '';
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        enableCaption: true,
        isLive: false,
      ),
    );

    _controller.addListener(_controllerListener);
    fetchVideoDetails();
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
  }

  Future<void> fetchVideoDetails() async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/videos'
          '?part=snippet,statistics'
          '&id=${widget.videoId}'
          '&key=${widget.apiKey}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if ((data['items'] as List).isNotEmpty) {
          final videoData = data['items'][0];
          final snippet = videoData['snippet'];
          final stats = videoData['statistics'];
          setState(() {
            title = snippet['title'] ?? '';
            description = snippet['description'] ?? '';
            viewCount = formatNumber(stats['viewCount'] ?? '0');
            likeCount = formatNumber(stats['likeCount'] ?? '0');
            isLoading = false;
          });
        }
      } else {
        print('Error fetching video details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatNumber(String number) {
    final count = int.tryParse(number) ?? 0;
    if (count >= 1000000000) {
      return (count / 1000000000).toStringAsFixed(1) + 'B';
    } else if (count >= 1000000) {
      return (count / 1000000).toStringAsFixed(1) + 'M';
    } else if (count >= 1000) {
      return (count / 1000).toStringAsFixed(1) + 'K';
    } else {
      return count.toString();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }


  Widget buildDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$viewCount مشاهدات', style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 16),
              Text('$likeCount إعجابات', style: const TextStyle(color: Colors.grey))
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // هنا نستخدم Linkify بدلاً من Text لعرض الوصف
          // Linkify(
          //   onOpen: (link) async {
          //     final uri = Uri.parse(link.url);
          //     if (await canLaunchUrl(uri)) {
          //       await launchUrl(uri, mode: LaunchMode.externalApplication);
          //     } else {
          //       print('Could not launch $uri');
          //     }
          //   },
          //   text: description,
          //   style: const TextStyle(
          //     fontSize: 14,
          //     height: 1.4,
          //     color: Colors.black,
          //   ),
          //   linkStyle: const TextStyle(
          //     color: Colors.blue,
          //     decoration: TextDecoration.underline,
          //   ),
          //   linkifiers: const [UrlLinkifier(), EmailLinkifier()],
          // ),
          Linkify(
            onOpen: (link) async {
              final uri = Uri.parse(link.url.startsWith('http') ? link.url : 'https://${link.url}');
              // جرّب بدون التحقق المسبق عبر canLaunchUrl
              try {
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                  print('Could not launch $uri');
                }
              } catch (e) {
                print('Error launching $uri: $e');
              }
            },
            text: description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black,
            ),
            linkStyle: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            linkifiers: const [UrlLinkifier(), EmailLinkifier()],
          ),

        ],
      ),
    );
  }
  // Widget buildDetails() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         const SizedBox(height: 8),
  //         Row(
  //           children: [
  //             Text('$viewCount مشاهدات', style: const TextStyle(color: Colors.grey)),
  //             const SizedBox(width: 16),
  //             Text('$likeCount إعجابات', style: const TextStyle(color: Colors.grey))
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         const Divider(),
  //         const SizedBox(height: 8),
  //         Text(
  //           description,
  //           style: const TextStyle(fontSize: 14, height: 1.4),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        bottomActions: [
          const SizedBox(width: 14.0),
          CurrentPosition(),
          const SizedBox(width: 8.0),
          ProgressBar(isExpanded: true),
          const PlaybackSpeedButton(),
          FullScreenButton(),
        ],
      ),
      builder: (context, player) {
        if (_isFullScreen) {
          // وضع ملء الشاشة: عرض الفيديو فقط على كامل المساحة
          return Scaffold(
            body: SafeArea(
              child: Container(
                color: Colors.black,
                child: Center(child: player),
              ),
            ),
          );
        } else {
          // الوضع العادي: عرض الفيديو + التفاصيل
          return Scaffold(
            appBar: AppBar(
              title: const Text('مشاهدة الفيديو'),
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: player,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: buildDetails(),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
