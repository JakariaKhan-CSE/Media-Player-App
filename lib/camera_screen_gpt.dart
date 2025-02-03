import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreenGpt extends StatefulWidget {
  final List<CameraDescription> cameras;
  CameraScreenGpt({required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreenGpt> {
  CameraController? _controller;
  bool isRecording = false;
  int selectedIndex = 1;
  final picker = ImagePicker();
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _toggleCamera() {
    final newIndex =
        widget.cameras.indexOf(_controller!.description) == 0 ? 1 : 0;
    _controller =
        CameraController(widget.cameras[newIndex], ResolutionPreset.medium);
    _controller!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final image = await _controller!.takePicture();
      print("Image captured: ${image.path}");
    }
  }

  void _recordVideo() async {
    if (isRecording) {
      final video = await _controller!.stopVideoRecording();
      print("Video saved: ${video.path}");
      setState(() => isRecording = false);
    } else {
      await _controller!.startVideoRecording();
      setState(() => isRecording = true);
    }
  }

  void _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print("Selected image: ${pickedFile.path}");
    }
  }

  void _startVoiceRecord() {
    player.play(AssetSource('click.mp3'));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _controller != null && _controller!.value.isInitialized
              ? CameraPreview(_controller!)
              : Center(child: CircularProgressIndicator()),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.mic, size: 30, color: Colors.white),
              onPressed: _startVoiceRecord,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.photo, color: Colors.white, size: 40),
                    onPressed: _pickImage,
                  ),
                  GestureDetector(
                    onTap: _captureImage,
                    onLongPress: _recordVideo,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: isRecording ? Colors.red : Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.switch_camera,
                        color: Colors.white, size: 40),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: selectedIndex,
        onItemSelected: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  BottomNavBar({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: "Feed"),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
          BottomNavigationBarItem(
              icon: Icon(Icons.timeline), label: "Timeline"),
        ],
      ),
    );
  }
}
