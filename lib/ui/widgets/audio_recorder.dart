import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AudioRecorder extends StatefulWidget {
  final bool isRecording;
  final bool isPlayEnabled;
  final Future<void> Function() onStart;
  final Future<Uint8List> Function() onStop;
  final Future<void> Function() onPlay;
  final Future<void> Function() onStopPlay;
  final Future<void> Function() deleteRecording;

  const AudioRecorder({
    super.key,
    required this.isRecording,
    required this.isPlayEnabled,
    required this.onStart,
    required this.onStop,
    required this.onPlay,
    required this.onStopPlay,
    required this.deleteRecording,
  });

  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder>
    with SingleTickerProviderStateMixin {
  late bool _recording;
  late bool _playing;
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _recording = widget.isRecording;
    _playing = false;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (s == AnimationStatus.dismissed)
        _pulseController.forward();
    });
    if (_recording) _pulseController.forward();
  }

  @override
  void didUpdateWidget(covariant AudioRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep internal recording flag in sync if parent toggles it
    if (oldWidget.isRecording != widget.isRecording) {
      _recording = widget.isRecording;
      if (_recording) {
        _startTimer();
        _pulseController.forward();
      } else {
        _stopTimer();
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      // stop recording
      await widget.onStop();
      if (mounted) setState(() => _recording = false);
      _stopTimer();
      _pulseController.stop();
      _pulseController.reset();
    } else {
      // start recording
      await widget.onStart();
      if (mounted) setState(() => _recording = true);
      _startTimer();
      _pulseController.forward();
    }
  }

  Future<void> _handlePlayStop() async {
    if (_playing) {
      await widget.onStopPlay();
      if (mounted) setState(() => _playing = false);
    } else {
      await widget.onPlay();
      if (mounted) setState(() => _playing = true);
      // keep playing state until user stops or playback finishes (AudioService should stop on end)
    }
  }

  Widget _buildRecordButton(BuildContext context) {
    final color = _recording ? Colors.redAccent : Colors.indigo;
    final icon = _recording ? Icons.stop_circle : Icons.mic;
    final label = _recording ? 'Stop' : 'Record';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Padded pulsing circular button
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1 + (_pulseController.value * 0.18);
            return Transform.scale(scale: scale, child: child);
          },
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: _toggleRecord,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _recording
                      ? [color.withOpacity(0.95), color]
                      : [Colors.indigo.shade400, Colors.indigo.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(child: Icon(icon, size: 40, color: Colors.white)),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Time / hint text
        if (_recording)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fiber_manual_record,
                size: 12,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDuration(_seconds),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          )
        else
          Text(
            'Tap to $label',
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  static String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Buttons row: Play, Stop, Delete (compact and responsive)
    final actionButtons = Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        // Play / Pause button (toggles)
        ElevatedButton.icon(
          onPressed: widget.isPlayEnabled ? _handlePlayStop : null,
          icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
          label: Text(_playing ? 'Stop' : 'Play'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPlayEnabled
                ? Colors.indigo.shade600
                : Colors.grey.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Stop playback (explicit)
        OutlinedButton.icon(
          onPressed: widget.isPlayEnabled ? widget.onStopPlay : null,
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('Stop Play'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Delete
        TextButton.icon(
          onPressed: widget.isPlayEnabled ? widget.deleteRecording : null,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
          style: TextButton.styleFrom(
            foregroundColor: widget.isPlayEnabled
                ? Colors.red.shade700
                : Colors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // center record button and message
        Center(child: _buildRecordButton(context)),
        const SizedBox(height: 14),

        // actions row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: actionButtons,
        ),

        // small hint
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            _recording
                ? 'Recording — tap stop when done'
                : 'You can record, play and delete your answer here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
