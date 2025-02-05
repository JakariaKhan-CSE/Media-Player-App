import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_app/audio/audio_recorder.dart';
import 'package:new_app/image_preview.dart';
import 'package:new_app/video/video_player.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  bool _isRecording = false;
  int _selectedIndex = 1;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int _selectedCameraIndex = 0;
  File? _imageFile;
  CameraDescription? firstCamera;

  // for counter
  int _recordingDuration = 0;
  Timer? _timer;

  void _startTimer() {
    print('Start Timer Trigger');
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
      print(_recordingDuration);
    });
  }

  void _stopTimer() {
    print('Stop Timer Trigger');
    _timer?.cancel();
    _timer = null;
    setState(() {
      _recordingDuration = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

// // for video (i using rear camera)
//     firstCamera = cameras?.firstWhere((camera) {
//       return camera.lensDirection == CameraLensDirection.back;
//     });

    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![_selectedCameraIndex],
        ResolutionPreset.medium,
      );
      // await _cameraController!.initialize();
      _initializeControllerFuture = _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (cameras!.length > 1) {
      _selectedCameraIndex = _selectedCameraIndex == 0 ? 1 : 0;
      await _cameraController!.dispose();
      _cameraController = CameraController(
        cameras![_selectedCameraIndex],
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _captureImage(BuildContext context) async {
    if (_cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      setState(() {
        _imageFile = File(image.path);
      });
      _navigateToImagePreview(context);
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _navigateToImagePreview(context);
    }
  }

  void _navigateToImagePreview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(imageFile: _imageFile!),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
        'Building widget. _isRecording: $_isRecording, _recordingDuration: $_recordingDuration');
    final height = MediaQuery.of(context).size.height;

// this is required if i not use futurebuilder
    // if (_cameraController == null || !_cameraController!.value.isInitialized) {
    //   return Center(child: CircularProgressIndicator());
    // }
    // futurebuilder is very important otherwise get screen hold error
    return Scaffold(
      body: _selectedIndex == 1
          ? FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // return SizedBox(height: height, child: CameraPreview(_controller));
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                          height: height,
                          child: CameraPreview(_cameraController!)),
                      Positioned(
                        bottom: 20.0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AudioRecorderPage(),
                                ));
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  // icon: Icon(Icons.photo_library),
                                  icon: Image.asset(
                                    'Assets/icon/gallery.png',
                                    color: Colors.white,
                                    height: 25,
                                    width: 25,
                                  ),
                                  onPressed: () {
                                    _pickImageFromGallery(context);
                                  },
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _captureImage(context);
                                  },
                                  // onLongPress: () {
                                  //   Navigator.of(context)
                                  //       .push(MaterialPageRoute(
                                  //     builder: (context) => VideoRecorderScreen(
                                  //         camera: firstCamera!),
                                  //   ));
                                  // },
                                  onLongPressStart: (details) async {
                                    try {
                                      await _initializeControllerFuture;
                                      if (!mounted) {
                                        return;
                                      }

                                      await _cameraController!
                                          .prepareForVideoRecording();
                                      await _cameraController
                                          ?.startVideoRecording();

                                      setState(() {
                                        _isRecording = true;
                                      });

                                      _startTimer();
                                    } catch (e) {}
                                  },
                                  onLongPressEnd: (details) async {
                                    try {
                                      final video = await _cameraController!
                                          .stopVideoRecording();

                                      _stopTimer();

                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPlayerScreen(
                                            videoPath: video.path,
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        _isRecording = false;
                                      });
                                    } catch (e) {}
                                  },
                                  child: Container(
                                    width: 70.0,
                                    height: 70.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isRecording
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                IconButton(
                                  // icon: Icon(Icons.switch_camera),
                                  icon: Image.asset(
                                    'Assets/icon/camera exchange.png',
                                    color: Colors.white,
                                    height: 28,
                                    width: 28,
                                  ),
                                  onPressed: _switchCamera,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 90,
                        child: Text(
                          'Capture a moment',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      // Timer Text (Positioned at the top center)
                      // this code not work
                      if (_isRecording)
                        Positioned(
                          top: 45, // Adjust this value to position the timer

                          right: 10,
                          child: Text(
                            '$_recordingDuration seconds',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.pink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : Center(
              child: Text('Page ${_selectedIndex == 0 ? 'Feed' : 'Timeline'}'),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // icon: Icon(Icons.feed_outlined),
            icon: Image.asset('Assets/icon/feed.png',
                height: 22, width: 22, color: Colors.white38),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            // icon: Icon(Icons.view_timeline),
            icon: Image.asset('Assets/icon/timeline.png',
                height: 22, width: 22, color: Colors.white38),
            label: 'Timeline',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
        backgroundColor: Colors.black87.withAlpha(200),
        onTap: _onItemTapped,
      ),
    );
  }
}
