
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class CookingTimerWidget extends StatefulWidget {
  final int initialMinutes;
  final VoidCallback? onComplete;

  const CookingTimerWidget({
    super.key,
    this.initialMinutes = 5,
    this.onComplete,
  });

  @override
  State<CookingTimerWidget> createState() => _CookingTimerWidgetState();
}

class _CookingTimerWidgetState extends State<CookingTimerWidget> {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isComplete = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialMinutes * 60;
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isComplete) {
      _resetTimer();
    }
    
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _isComplete = true;
        });
        _playAlarm();
        widget.onComplete?.call();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _audioPlayer.stop();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isComplete = false;
    });
  }

  void _addMinute() {
    setState(() {
      _remainingSeconds += 60;
      _totalSeconds += 60;
    });
  }

  Future<void> _playAlarm() async {
    HapticFeedback.vibrate();
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(
        AssetSource('sounds/timer_alarm.mp3'),
        volume: 1.0,
      );
    } catch (_) {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 500));
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _stopAlarm() {
    _audioPlayer.stop();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = _totalSeconds > 0 
        ? _remainingSeconds / _totalSeconds 
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isComplete 
            ? Colors.red.withOpacity(0.1)
            : colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: _isComplete 
            ? Border.all(color: Colors.red, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isComplete ? Icons.alarm_on : Icons.timer_outlined,
                color: _isComplete ? Colors.red : colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                _isComplete ? 'Time\'s Up!' : 'Cooking Timer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isComplete ? Colors.red : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(
                    _isComplete ? Colors.red : colorScheme.primary,
                  ),
                ),
              ),
              Text(
                _formatTime(_remainingSeconds),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: _isComplete ? Colors.red : null,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.refresh,
                label: 'Reset',
                onPressed: _resetTimer,
                colorScheme: colorScheme,
              ),
              
              const SizedBox(width: 16),
              _ControlButton(
                icon: _isRunning ? Icons.pause : Icons.play_arrow,
                label: _isRunning ? 'Pause' : 'Start',
                onPressed: _isRunning ? _pauseTimer : _startTimer,
                colorScheme: colorScheme,
                isPrimary: true,
              ),
              
              const SizedBox(width: 16),
              _ControlButton(
                icon: Icons.add,
                label: '+1 min',
                onPressed: _addMinute,
                colorScheme: colorScheme,
              ),
            ],
          ),
          
          if (_isComplete) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _stopAlarm();
                _resetTimer();
              },
              icon: const Icon(Icons.volume_off),
              label: const Text('Stop Alarm'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.colorScheme,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: isPrimary 
              ? colorScheme.primary 
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isPrimary 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
class CompactTimer extends StatefulWidget {
  final int minutes;
  final VoidCallback? onComplete;

  const CompactTimer({
    super.key,
    required this.minutes,
    this.onComplete,
  });

  @override
  State<CompactTimer> createState() => _CompactTimerState();
}

class _CompactTimerState extends State<CompactTimer> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.minutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          timer.cancel();
          setState(() => _isRunning = false);
          widget.onComplete?.call();
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: _toggleTimer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isRunning ? Colors.green : theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
