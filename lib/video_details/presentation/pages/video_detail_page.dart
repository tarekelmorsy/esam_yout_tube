// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
// import 'package:http/http.dart' as http;
// import 'package:share_plus/share_plus.dart';
// import 'dart:convert';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import 'package:linkify/linkify.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class VideoDetailPage extends StatefulWidget {
//   final String videoId;
//   final String apiKey;
//
//   const VideoDetailPage({
//     Key? key,
//     required this.videoId,
//     required this.apiKey,
//   }) : super(key: key);
//
//   @override
//   State<VideoDetailPage> createState() => _VideoDetailPageState();
// }
//
// class _VideoDetailPageState extends State<VideoDetailPage> {
//   bool isLoading = true;
//   String title = '';
//   String description = '';
//   String viewCount = '';
//   String likeCount = '';
//   int commentCount = 0;
//   late YoutubePlayerController _controller;
//   bool _isFullScreen = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: widget.videoId,
//       flags: const YoutubePlayerFlags(
//         autoPlay: false,
//         enableCaption: true,
//         isLive: false,
//       ),
//     );
//
//     _controller.addListener(_controllerListener);
//     fetchVideoDetails();
//   }
//
//   void _controllerListener() {
//     if (mounted) {
//       setState(() {
//         _isFullScreen = _controller.value.isFullScreen;
//       });
//     }
//   }
//
//   Future<void> fetchVideoDetails() async {
//     final url = Uri.parse(
//       'https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=${widget.videoId}&key=${widget.apiKey}',
//     );
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if ((data['items'] as List).isNotEmpty) {
//           final videoData = data['items'][0];
//           final snippet = videoData['snippet'];
//           final stats = videoData['statistics'];
//           setState(() {
//             title = snippet['title'] ?? '';
//             description = snippet['description'] ?? '';
//             viewCount = formatNumber(stats['viewCount'] ?? '0');
//             likeCount = formatNumber(stats['likeCount'] ?? '0');
//             commentCount = int.tryParse(stats['commentCount'] ?? '0') ?? 0;
//             isLoading = false;
//           });
//         }
//       } else {
//         print('Error fetching video details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error: $e');
//     }
//   }
//
//   String formatNumber(String number) {
//     final count = int.tryParse(number) ?? 0;
//     if (count >= 1000000000) {
//       return (count / 1000000000).toStringAsFixed(1) + 'B';
//     } else if (count >= 1000000) {
//       return (count / 1000000).toStringAsFixed(1) + 'M';
//     } else if (count >= 1000) {
//       return (count / 1000).toStringAsFixed(1) + 'K';
//     } else {
//       return count.toString();
//     }
//   }
//
//   void showCommentsSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         return DraggableScrollableSheet(
//           initialChildSize: 0.9,
//           maxChildSize: 0.95,
//           minChildSize: 0.5,
//           expand: false,
//           builder: (context, scrollController) {
//             return CommentsBottomSheet(
//               commentCount: commentCount,
//               scrollController: scrollController,
//               apiKey: widget.apiKey,
//               videoId: widget.videoId,
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.removeListener(_controllerListener);
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Widget buildDetails() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // الكارد الأول: عنوان + مشاهدات + إعجابات
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             elevation: 0,
//             margin: EdgeInsets.zero,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
//                       const SizedBox(width: 4),
//                       Text('$viewCount', style: const TextStyle(color: Colors.grey)),
//                       const SizedBox(width: 16),
//                       const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
//                       const SizedBox(width: 4),
//                       Text('$likeCount', style: const TextStyle(color: Colors.grey)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // الكارد الثاني: التعليقات
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             elevation: 0,
//             margin: EdgeInsets.zero,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 children: [
//                   const Icon(Icons.comment, size: 20, color: Colors.blueGrey),
//                   const SizedBox(width: 8),
//                   Text(
//                     '$commentCount التعليقات',
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   const Spacer(),
//                   ElevatedButton(
//                     onPressed: () {
//                       showCommentsSheet(context);
//                     },
//                     child: const Text('عرض التعليقات'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // الكارد الثالث: الوصف
//           Card(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             elevation: 0,
//             margin: EdgeInsets.zero,
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Linkify(
//                 onOpen: (link) async {
//                   final uri = Uri.parse(
//                       link.url.startsWith('http') ? link.url : 'https://${link.url}');
//                   try {
//                     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//                       print('Could not launch $uri');
//                     }
//                   } catch (e) {
//                     print('Error launching $uri: $e');
//                   }
//                 },
//                 text: description,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   height: 1.4,
//                   color: Colors.black,
//                 ),
//                 linkStyle: const TextStyle(
//                   color: Colors.blue,
//                   decoration: TextDecoration.underline,
//                 ),
//                 linkifiers: const [UrlLinkifier(), EmailLinkifier()],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerBuilder(
//       player: YoutubePlayer(
//         controller: _controller,
//         showVideoProgressIndicator: true,
//         bottomActions: [
//           const SizedBox(width: 14.0),
//           CurrentPosition(),
//           const SizedBox(width: 8.0),
//           ProgressBar(isExpanded: true),
//           const PlaybackSpeedButton(),
//           FullScreenButton(),
//         ],
//       ),
//       builder: (context, player) {
//         if (_isFullScreen) {
//           return Scaffold(
//             body: SafeArea(
//               child: Container(
//                 color: Colors.black,
//                 child: Center(child: player),
//               ),
//             ),
//           );
//         } else {
//           return Scaffold(
//             appBar: AppBar(
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back),
//                 onPressed: () {
//                   Navigator.pop(context); // الرجوع إلى الصفحة السابقة
//                 },
//               ),
//               title: const Text('مشاهدة الفيديو'),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.share),
//                   onPressed: (){
//                     onShare(context, 'https://www.youtube.com/watch?v=${widget.videoId}\n \n تمت المشاركة من برنامج عشاق السيارات مع عصام غنايم', title);
//                   },
//                 ),
//               ],
//             ),
//
//             body: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : Column(
//               children: [
//                 AspectRatio(
//                   aspectRatio: 16 / 9,
//                   child: player,
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: buildDetails(),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
//   onShare(BuildContext context ,String text,String subject ) async {
//     final box = context.findRenderObject() as RenderBox?;
//
//     await Share.share(
//       text,
//       subject: subject,
//       sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
//
//     );
//   }
// }
//
// class CommentsBottomSheet extends StatefulWidget {
//   final int commentCount;
//   final ScrollController scrollController;
//   final String apiKey;
//   final String videoId;
//
//   const CommentsBottomSheet({
//     super.key,
//     required this.commentCount,
//     required this.scrollController,
//     required this.apiKey,
//     required this.videoId,
//   });
//
//   @override
//   State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
// }
//
// class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
//   List<CommentModel> comments = [];
//   bool isLoadingMore = false;
//   bool hasMore = true;
//   int pageSize = 15;
//   String? nextPageToken;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchComments();
//     widget.scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (widget.scrollController.position.pixels >=
//         widget.scrollController.position.maxScrollExtent - 100) {
//       if (!isLoadingMore && hasMore) {
//         fetchComments();
//       }
//     }
//   }
//
//   Future<void> fetchComments() async {
//     setState(() {
//       isLoadingMore = true;
//     });
//
//     final url = Uri.parse(
//       'https://www.googleapis.com/youtube/v3/commentThreads'
//           '?part=snippet,replies'
//           '&videoId=${widget.videoId}'
//           '&maxResults=$pageSize'
//           '${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}'
//           '&key=${widget.apiKey}',
//     );
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         final newItems = data['items'] as List?;
//         nextPageToken = data['nextPageToken'];
//
//         if (newItems != null && newItems.isNotEmpty) {
//           List<CommentModel> fetchedComments = newItems.map((item) {
//             final topLevelComment = item['snippet']['topLevelComment'];
//             final snippet = topLevelComment['snippet'];
//             return CommentModel(
//               userName: snippet['authorDisplayName'],
//               userImage: snippet['authorProfileImageUrl'],
//               timeAgo: calculateTimeAgo(snippet['publishedAt']),
//               text: snippet['textDisplay'],
//               likes: snippet['likeCount'] ?? 0,
//             );
//           }).toList();
//
//           setState(() {
//             comments.addAll(fetchedComments);
//             isLoadingMore = false;
//             if (fetchedComments.length < pageSize || nextPageToken == null) {
//               hasMore = false;
//             }
//           });
//         } else {
//           setState(() {
//             hasMore = false;
//             isLoadingMore = false;
//           });
//         }
//       } else {
//         print('Error fetching comments: ${response.statusCode}');
//         setState(() {
//           isLoadingMore = false;
//           hasMore = false;
//         });
//       }
//     } catch (e) {
//       print('Error: $e');
//       setState(() {
//         isLoadingMore = false;
//         hasMore = false;
//       });
//     }
//   }
//
//   String calculateTimeAgo(String publishedAt) {
//     final publishedDate = DateTime.parse(publishedAt).toLocal();
//     final now = DateTime.now();
//     final diff = now.difference(publishedDate);
//
//     if (diff.inMinutes < 1) {
//       return 'الآن';
//     } else if (diff.inMinutes < 60) {
//       return '${diff.inMinutes} دقيقة';
//     } else if (diff.inHours < 24) {
//       return '${diff.inHours} ساعة';
//     } else if (diff.inDays < 30) {
//       return '${diff.inDays} يوم';
//     } else {
//       final months = diff.inDays ~/ 30;
//       return '${months} شهر';
//     }
//   }
//   String calculateTimeAgo4(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
//
//     if (difference.inDays > 365) {
//       return '${difference.inDays ~/ 365} عام';
//     } else if (difference.inDays > 30) {
//       return '${difference.inDays ~/ 30} شهر';
//     } else if (difference.inDays > 0) {
//       return '${difference.inDays} أيام';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} ساعات';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} دقائق';
//     } else {
//       return 'الآن';
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding:
//       const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
//       child: Column(
//         children: [
//           // Header
//           Row(
//             children: [
//               const Text(
//                 'Comments',
//                 style: TextStyle(
//                     fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.yellow[700],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${widget.commentCount}',
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Colors.black),
//                 ),
//               ),
//               const Spacer(),
//               InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Icon(Icons.close, size: 24),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           Expanded(
//             child: ListView.builder(
//               controller: widget.scrollController,
//               itemCount: comments.length + (isLoadingMore ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index < comments.length) {
//                   final c = comments[index];
//                   return buildCommentItem(c);
//                 } else {
//                   return const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildCommentItem(CommentModel c) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Avatar
//           CircleAvatar(
//             backgroundImage: NetworkImage(c.userImage),
//             radius: 20,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Line with name and time
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         c.userName.replaceAll('@', ''), // إزالة @ من الاسم
//                         style: const TextStyle(
//                             fontWeight: FontWeight.w600, fontSize: 16),
//                         overflow: TextOverflow.ellipsis, // للتأكد من عدم تجاوز العرض
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     const Text("•",
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(width: 6),
//                     Text(
//                       c.timeAgo,
//                       style:
//                       const TextStyle(color: Colors.grey, fontSize: 14),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 4),
//                 // النص هنا يأتي بـHTML formatting من يوتيوب، عادة textDisplay يكون HTML
//                 // الأفضل استخدام widget يدعم HTML لو أردت تنسيق أو اكتفِ بtext.
//                 Text(
//                   c.text,
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Column(
//             children: [
//               Icon(Icons.favorite_border, color: Colors.grey[700]),
//               Text('${c.likes}',
//                   style: TextStyle(color: Colors.grey[700], fontSize: 14))
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CommentModel {
//   final String userName;
//   final String userImage;
//   final String timeAgo;
//   final String text;
//   final int likes;
//
//   CommentModel({
//     required this.userName,
//     required this.userImage,
//     required this.timeAgo,
//     required this.text,
//     required this.likes,
//   });
// }



//////////////////////////////////////

import 'package:esam_yout_tube/video_details/data/repositories/video_repository.dart';
import 'package:esam_yout_tube/video_details/presentation/cubits/video_details/video_detail_cubit.dart';
import 'package:esam_yout_tube/video_details/presentation/cubits/video_details/video_detail_state.dart';
import 'package:esam_yout_tube/video_details/presentation/widgets/comments_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';


class VideoDetailPage extends StatefulWidget {
  final String videoId;
  final String apiKey;

  const VideoDetailPage({
    super.key,
    required this.videoId,
    required this.apiKey,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
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
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }
// داخل VideoDetailContent أو أي مكان تفتح فيه الـBottom Sheet
  void showCommentsSheet(BuildContext context, int commentCount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<VideoDetailCubit>(), // تمرير الـCubit الحالي
          child: CommentsBottomSheet(
            commentCount: commentCount,
            scrollController: ScrollController(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoDetailCubit(
        repository: VideoRepository(apiKey: widget.apiKey),
        videoId: widget.videoId,
      ),
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          bottomActions: const [
            SizedBox(width: 14.0),
            CurrentPosition(),
            SizedBox(width: 8.0),
            ProgressBar(isExpanded: true),
            PlaybackSpeedButton(),
            FullScreenButton(),
          ],
        ),
        builder: (context, player) {
          return BlocBuilder<VideoDetailCubit, VideoDetailState>(
            builder: (context, state) {
              if (_isFullScreen) {
                return Scaffold(
                  body: SafeArea(
                    child: Container(
                      color: Colors.black,
                      child: Center(child: player),
                    ),
                  ),
                );
              } else {
                return Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: const Text('مشاهدة الفيديو'),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          onShare(
                            context,
                            'https://www.youtube.com/watch?v=${widget.videoId}\n \n تمت المشاركة من برنامج عشاق السيارات مع عصام غنايم',
                            state.title,
                          );
                        },
                      ),
                    ],
                  ),
                  body: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: player,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: buildDetails(context, state),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget buildDetails(BuildContext context, VideoDetailState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الكارد الأول: عنوان + مشاهدات + إعجابات
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(state.viewCount, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(state.likeCount, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // الكارد الثاني: التعليقات
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Icon(Icons.comment, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    '${state.commentCount} التعليقات',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      showCommentsSheet(context, state.commentCount);
                    },
                    child: const Text('عرض التعليقات'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // الكارد الثالث: الوصف
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Linkify(
                onOpen: (link) async {
                  final uri = Uri.parse(
                      link.url.startsWith('http') ? link.url : 'https://${link.url}');
                  try {
                    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                      print('Could not launch $uri');
                    }
                  } catch (e) {
                    print('Error launching $uri: $e');
                  }
                },
                text: state.description,
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
            ),
          ),
        ],
      ),
    );
  }

  void onShare(BuildContext context, String text, String subject) async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
