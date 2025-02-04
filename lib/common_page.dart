import 'dart:io';

import 'package:flutter/material.dart';

class CommonPage extends StatelessWidget {
  final String filePath;
  final String type;

  const CommonPage({Key? key, required this.filePath, required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview')),
      body: Center(
        child: type == 'image'
            ? Image.file(File(filePath))
            : type == 'video'
                ? Text(
                    'Video: $filePath') // Use a video player package to play the video
                : Text(
                    'Audio: $filePath'), // Use an audio player package to play the audio
      ),
    );
  }
}
