import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:new_app/image_preview.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // late CameraController _controller;
  // late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  int _selectedIndex = 1;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int _selectedCameraIndex = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // _controller = CameraController(
    //   widget.camera,
    //   ResolutionPreset.medium,
    // );
    // _initializeControllerFuture = _controller.initialize();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![_selectedCameraIndex],
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
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
    // _controller.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create a moment',
          style: TextStyle(letterSpacing: 1.5),
        ),
        centerTitle: true,
        backgroundColor: Color(0x44000000),
        elevation: 0,
      ),
      body: _selectedIndex == 1
          ? Stack(
              children: [
                Expanded(
                  child: CameraPreview(_cameraController!),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: () {
                          // Voice record functionality
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(Icons.photo_library),
                            onPressed: () {
                              _pickImageFromGallery(context);
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              _captureImage(context);
                            },
                            onLongPressStart: (_) async {
                              setState(() {
                                _isRecording = true;
                              });
                              final path = join(
                                (await getTemporaryDirectory()).path,
                                '${DateTime.now()}.mp4',
                              );
                              await _cameraController?.startVideoRecording();
                            },
                            onLongPressEnd: (_) async {
                              await _cameraController!
                                  .stopVideoRecording()
                                  .then((XFile file) {
                                setState(() {
                                  _isRecording = false;
                                });
                                print('Video saved to: ${file.path}');
                              });
                            },
                            child: Container(
                              width: 70.0,
                              height: 70.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isRecording ? Colors.red : Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.switch_camera),
                            onPressed: _switchCamera,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Text('Page ${_selectedIndex == 0 ? 'Feed' : 'Timeline'}'),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_outlined),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
