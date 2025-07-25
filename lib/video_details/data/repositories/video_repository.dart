import 'dart:convert';
import 'package:esam_yout_tube/video_details/data/models/playlist_model.dart';
import 'package:http/http.dart' as http;

class VideoRepository  {
  final String apiKey;

  VideoRepository({required this.apiKey});


  Future<List<PlaylistModel>> fetchPlaylists(String channelId) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=$channelId&maxResults=50&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> items = data['items'] ?? [];
      return items.map((item) => PlaylistModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch playlists: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> fetchVideos({
    required String channelId,
    String? playlistId,
    String? pageToken,
    int maxResults = 30,
  }) async {
    Map<String, String> queryParameters = {
      'key': apiKey,
      'part': 'snippet',
      'maxResults': '$maxResults',
    };

    Uri url;

    if (playlistId == null) {
      // جميع الفيديوهات (باستخدام search)
      queryParameters.addAll({
        'channelId': channelId,
        'order': 'date',
        'type': 'video', // التأكد من جلب الفيديوهات فقط
      });
      if (pageToken != null && pageToken.isNotEmpty) {
        queryParameters['pageToken'] = pageToken;
      }
      url = Uri.https('www.googleapis.com', '/youtube/v3/search', queryParameters);
    } else {
      // فيديوهات قائمة تشغيل معينة
      queryParameters.addAll({
        'playlistId': playlistId,
        'type': 'video', // التأكد من جلب الفيديوهات فقط
      });
      if (pageToken != null && pageToken.isNotEmpty) {
        queryParameters['pageToken'] = pageToken;
      }
      url = Uri.https('www.googleapis.com', '/youtube/v3/playlistItems', queryParameters);
    }

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // محاولة قراءة الرسالة من الاستجابة لمعرفة السبب
      String errorMsg = 'Failed to fetch videos: ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['error'] != null && errorData['error']['message'] != null) {
          errorMsg += ' - ${errorData['error']['message']}';
        }
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  Future<Map<String, dynamic>?> fetchVideoDetails(String videoId) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&id=$videoId&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if ((data['items'] as List).isNotEmpty) {
        return data['items'][0];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> fetchComments(String videoId, String? pageToken) async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/commentThreads'
          '?part=snippet,replies'
          '&videoId=$videoId'
          '&maxResults=15'
          '${pageToken != null ? '&pageToken=$pageToken' : ''}'
          '&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error fetching comments: ${response.statusCode}');
    }
  }
}
