import 'package:flutter/material.dart';
import 'package:new_app/audio/audio_player.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class AudioRecorderPage extends StatefulWidget {
  const AudioRecorderPage({super.key});

  @override
  _AudioRecorderPageState createState() => _AudioRecorderPageState();
}

class _AudioRecorderPageState extends State<AudioRecorderPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/recording.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _audioPath = path;
        });
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  void _navigateToPlayerPage() {
    if (_audioPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioPlayerPage(audioPath: _audioPath!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Recorder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isRecording
                ? Text("Recording...")
                : Text("Press the button to start recording"),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              onPressed: _isRecording ? _stopRecording : _startRecording,
              iconSize: 50,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _audioPath != null ? _navigateToPlayerPage : null,
              child: Text("Go to Player Page"),
            ),
          ],
        ),
      ),
    );
  }
}
