import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:new_app/video/video_player.dart';

class VideoRecorderScreen extends StatefulWidget {
  final CameraDescription camera;

  const VideoRecorderScreen({
    super.key,
    required this.camera,
  });

  @override
  State<VideoRecorderScreen> createState() => _VideoRecorderScreenState();
}

class _VideoRecorderScreenState extends State<VideoRecorderScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video recorder screen')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            if (!mounted) {
              return;
            }

            if (_isRecording) {
              final video = await _controller.stopVideoRecording();

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoPath: video.path,
                  ),
                ),
              );
            } else {
              await _controller.prepareForVideoRecording();
              await _controller.startVideoRecording();
            }

            setState(() {
              _isRecording = !_isRecording;
            });
          } catch (e) {
            print(e);
          }
        },
        child: Icon(_isRecording ? Icons.stop : Icons.circle),
      ),
    );
  }
}
