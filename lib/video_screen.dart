import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:new_app/main.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class VideoScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<VideoScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  String? _videoPath;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      print('No cameras found.');
      return;
    }

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _startRecording() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/${currentTime}.mp4';

    if (_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      // await _controller!.startVideoRecording(filePath);
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopRecording() async {
    if (!_controller!.value.isRecordingVideo) {
      return;
    }

    try {
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _videoPath = file.path;
      });

      _videoPlayerController = VideoPlayerController.file(File(_videoPath!))
        ..initialize().then((_) {
          setState(() {});
        });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Recorder'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller!),
                ),
                _videoPlayerController != null &&
                        _videoPlayerController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoPlayerController!.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController!),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isRecording
                          ? IconButton(
                              icon: Icon(Icons.stop, color: Colors.red),
                              onPressed: _stopRecording,
                            )
                          : IconButton(
                              icon: Icon(Icons.videocam, color: Colors.blue),
                              onPressed: _startRecording,
                            ),
                      if (_videoPlayerController != null)
                        IconButton(
                          icon: Icon(Icons.play_arrow, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              _videoPlayerController!.play();
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
