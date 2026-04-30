import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? controller;
  YoutubePlayerController? _youtubeController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final raw = widget.url.trim();
    final uri = Uri.tryParse(raw);
    final path = uri?.path.toLowerCase() ?? '';
    final isMp4 = path.endsWith('.mp4');
    final youtubeId = _extractYoutubeId(raw);

    if (youtubeId != null) {
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: youtubeId,
        autoPlay: false,
        params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true),
      );
      if (!mounted) return;
      setState(() {});
      return;
    }

    if (!isMp4) {
      setState(
        () => _error =
            "Unsupported video URL. Use a YouTube link or direct MP4 URL.",
      );
      return;
    }

    controller = VideoPlayerController.networkUrl(uri!);
    try {
      await controller!.initialize();
      if (!mounted) return;
      setState(() {});
      await controller!.play();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = "Could not load this video URL.");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) {
      return const Text("No video URL");
    }

    if (_youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        aspectRatio: 16 / 9,
      );
    }

    if (controller == null) {
      return Text(_error ?? "Loading video...");
    }

    if (!controller!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: controller!.value.aspectRatio,
      child: Stack(
        children: [
          Positioned.fill(child: VideoPlayer(controller!)),
          Positioned(
            bottom: 8,
            left: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(999),
              ),
              child: IconButton(
                onPressed: () {
                  if (controller!.value.isPlaying) {
                    controller!.pause();
                  } else {
                    controller!.play();
                  }
                  setState(() {});
                },
                icon: Icon(
                  controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _youtubeController?.close();
    super.dispose();
  }

  String? _extractYoutubeId(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      final segment = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      return segment.isEmpty ? null : segment;
    }

    if (uri.host.contains('youtube.com')) {
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;

      final segments = uri.pathSegments;
      if (segments.length >= 2 && segments.first == 'embed') {
        return segments[1];
      }
    }

    return null;
  }
}
