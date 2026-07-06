import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/song.dart';
import '../api/env.dart';

class PlaybackProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Song> _queue = [];
  int _currentIndex = -1;
  
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length ? _queue[_currentIndex] : null;

  bool _isPlaying = false;
  Duration _progress = Duration.zero;
  Duration _buffered = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  bool _shuffle = false;
  bool _repeat = false;

  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;

  bool get isPlaying => _isPlaying;
  Duration get progress => _progress;
  Duration get buffered => _buffered;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  bool get shuffle => _shuffle;
  bool get repeat => _repeat;

  PlaybackProvider() {
    _initListeners();
  }

  void _initListeners() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      
      if (state.processingState == ProcessingState.completed) {
        if (_repeat) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          skipToNext();
        }
      }
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _progress = position;
      notifyListeners();
    });

    _audioPlayer.bufferedPositionStream.listen((buffered) {
      _buffered = buffered;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        _totalDuration = duration;
        notifyListeners();
      }
    });
  }

  Future<void> playSong(Song song, {List<Song>? newQueue}) async {
    if (newQueue != null) {
      _queue = newQueue;
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    } else {
      if (!_queue.contains(song)) {
        _queue.add(song);
        _currentIndex = _queue.length - 1;
      } else {
        _currentIndex = _queue.indexWhere((s) => s.id == song.id);
      }
    }
    
    notifyListeners();
    await _loadAndPlayCurrent();
  }

  Future<void> _loadAndPlayCurrent() async {
    final song = currentSong;
    if (song == null) return;

    try {
      if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
        final url = song.audioUrl!.startsWith('http') 
            ? song.audioUrl! 
            : '${Env.baseUrl}${song.audioUrl}';
            
        final audioSource = AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: song.id,
            album: song.artistName, // Assuming artist name for album context
            title: song.title,
            artUri: song.coverUrl.startsWith('http') 
                ? Uri.parse(song.coverUrl)
                : null, // Local assets won't show in lockscreen easily without caching
          ),
        );
        await _audioPlayer.setAudioSource(audioSource);
        await _audioPlayer.play();
      } else {
        // Fallback for missing audio URL: use a placeholder or stop
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    
    if (_shuffle) {
      // Basic shuffle logic
      _currentIndex = (_currentIndex + 2) % _queue.length; // Just an example, replace with real random later if needed
    } else {
      _currentIndex++;
    }

    if (_currentIndex >= _queue.length) {
      _currentIndex = 0; // Loop back or stop
      _audioPlayer.stop();
      notifyListeners();
      return;
    }

    notifyListeners();
    await _loadAndPlayCurrent();
  }

  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    
    if (_progress.inSeconds > 3) {
      // Restart current song
      await _audioPlayer.seek(Duration.zero);
      return;
    }

    _currentIndex--;
    if (_currentIndex < 0) {
      _currentIndex = 0;
    }

    notifyListeners();
    await _loadAndPlayCurrent();
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _audioPlayer.setVolume(volume);
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _repeat = !_repeat;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
