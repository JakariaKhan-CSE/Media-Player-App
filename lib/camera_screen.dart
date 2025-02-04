import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isRecording = false;
  int _selectedIndex = 1;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller),
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
                                  onPressed: () async {
                                    final picker = ImagePicker();
                                    final XFile? pickedFile = await picker
                                        .pickImage(source: ImageSource.gallery);
                                    if (pickedFile != null) {
                                      // Handle the picked image
                                      print('Image picked: ${pickedFile.path}');
                                    }
                                  },
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    try {
                                      await _initializeControllerFuture;
                                      final path = join(
                                        (await getTemporaryDirectory()).path,
                                        '${DateTime.now()}.png',
                                      );
                                      await _controller
                                          .takePicture()
                                          .then((XFile file) {
                                        print('Image saved to: ${file.path}');
                                      });
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  onLongPressStart: (_) async {
                                    setState(() {
                                      _isRecording = true;
                                    });
                                    final path = join(
                                      (await getTemporaryDirectory()).path,
                                      '${DateTime.now()}.mp4',
                                    );
                                    await _controller.startVideoRecording();
                                  },
                                  onLongPressEnd: (_) async {
                                    await _controller
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
                                      color: _isRecording
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.switch_camera),
                                  onPressed: () async {
                                    final cameras = await availableCameras();
                                    final newCamera = cameras.firstWhere(
                                      (camera) =>
                                          camera.lensDirection !=
                                          widget.camera.lensDirection,
                                    );
                                    setState(() {
                                      _controller = CameraController(
                                        newCamera,
                                        ResolutionPreset.medium,
                                      );
                                      _initializeControllerFuture =
                                          _controller.initialize();
                                    });
                                  },
                                ),
                              ],
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
            )
          : Center(
              child: Text('Page ${_selectedIndex == 0 ? 'Feed' : 'Timeline'}'),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_outlined),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_sharp),
            label: 'Timeline',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}
