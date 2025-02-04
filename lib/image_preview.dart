import 'package:flutter/material.dart';
import 'dart:io';

class ImagePreviewScreen extends StatelessWidget {
  final File imageFile;

  ImagePreviewScreen({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Preview')),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
