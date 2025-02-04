import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:new_app/camera_screen.dart';
import 'package:new_app/image_feature.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: CameraScreen(camera: camera),
      home: CameraScreenFeature(),
    );
  }
}
