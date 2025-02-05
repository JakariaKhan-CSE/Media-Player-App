import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerPage extends StatefulWidget {
  final String audioPath;

  const AudioPlayerPage({super.key, required this.audioPath});

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _playAudio() async {
    try {
      await _audioPlayer.play(UrlSource(widget.audioPath));
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> _stopAudio() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Audio Player"),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: _isPlaying ? _stopAudio : _playAudio,
              iconSize: 50,
            ),
          ],
        ),
      ),
    );
  }
}
