import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:new_app/image_preview.dart';

class CameraScreenFeature extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreenFeature> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int _selectedCameraIndex = 0;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
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

  Future<void> _captureImage() async {
    if (_cameraController!.value.isInitialized) {
      final image = await _cameraController!.takePicture();
      setState(() {
        _imageFile = File(image.path);
      });
      _navigateToImagePreview();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _navigateToImagePreview();
    }
  }

  void _navigateToImagePreview() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: Text('Camera App')),
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_cameraController!),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.switch_camera),
                onPressed: _switchCamera,
              ),
              IconButton(
                icon: Icon(Icons.camera),
                onPressed: _captureImage,
              ),
              IconButton(
                icon: Icon(Icons.photo_library),
                onPressed: _pickImageFromGallery,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
