import 'package:esam_yout_tube/video_details/data/models/comment_model.dart';
import 'package:esam_yout_tube/video_details/presentation/cubits/video_details/video_detail_cubit.dart';
import 'package:esam_yout_tube/video_details/presentation/cubits/video_details/video_detail_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentsBottomSheet extends StatefulWidget {
  final int commentCount;
  final ScrollController scrollController;

  const CommentsBottomSheet({
    super.key,
    required this.commentCount,
    required this.scrollController,
  });

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.scrollController.position.pixels >=
        widget.scrollController.position.maxScrollExtent - 100) {
      context.read<VideoDetailCubit>().fetchComments();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoDetailCubit, VideoDetailState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding:
          const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'التعليقات',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.commentCount}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: widget.scrollController,
                  itemCount: state.comments.length +
                      (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < state.comments.length) {
                      final comment = state.comments[index];
                      return buildCommentItem(comment);
                    } else {
                      // Load More Indicator
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCommentItem(CommentsModel  comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            backgroundImage: NetworkImage(comment.userImage),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line with name and time
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.userName.replaceAll('@', ''),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("•",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text(
                      comment.timeAgo,
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Icon(Icons.favorite_border, color: Colors.grey[700]),
              Text('${comment.likes}',
                  style:
                  TextStyle(color: Colors.grey[700], fontSize: 14))
            ],
          ),
        ],
      ),
    );
  }
}
