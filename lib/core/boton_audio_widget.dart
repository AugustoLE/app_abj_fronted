import 'package:flutter/material.dart';
import 'audio_controller.dart';

class BotonAudioWidget extends StatefulWidget {
  const BotonAudioWidget({super.key});

  @override
  State<BotonAudioWidget> createState() => _BotonAudioWidgetState();
}

class _BotonAudioWidgetState extends State<BotonAudioWidget> {
  final audioController = AudioController();

  @override
  void initState() {
    super.initState();
    audioController.init(); // solo inicia una vez
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          setState(() {
            audioController.toggleMute();
          });
        },
        child: Icon(audioController.isMuted ? Icons.volume_off : Icons.volume_up),
      ),
    );
  }
}
