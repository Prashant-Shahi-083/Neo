import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import '../models/song.dart';
import '../repositories/player_repository.dart';
import 'audio_service.dart';
import '../api/env.dart';

enum PlayerRepeatMode { off, one, all }

class PlayerProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();
  final PlayerRepository _repository = PlayerRepository();
  
  List<Song> _queue = [];
  List<Song> _shuffledQueue = [];
  int _currentIndex = -1;
  
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  
  bool _shuffleEnabled = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;

  // Getters
  Song? get currentTrack => _currentIndex >= 0 && _currentIndex < _activeQueue.length ? _activeQueue[_currentIndex] : null;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  bool get shuffleEnabled => _shuffleEnabled;
  PlayerRepeatMode get repeatMode => _repeatMode;

  List<Song> get _activeQueue => _shuffleEnabled ? _shuffledQueue : _queue;

  PlayerProvider() {
    _initListeners();
  }

  void _initListeners() {
    _audioService.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering || state.processingState == ProcessingState.loading;
      
      if (state.processingState == ProcessingState.completed) {
        if (_repeatMode == PlayerRepeatMode.one) {
          _audioService.seek(Duration.zero);
          _audioService.play();
        } else {
          playNext();
        }
      }
      notifyListeners();
    });

    _audioService.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _audioService.durationStream.listen((dur) {
      if (dur != null) {
        _duration = dur;
        notifyListeners();
      }
    });
  }

  Future<void> setQueue(List<Song> newQueue, {int initialIndex = 0}) async {
    _queue = newQueue;
    _generateShuffledQueue(initialIndex);
    _currentIndex = _shuffleEnabled ? 0 : initialIndex;
    notifyListeners();
    await _loadAndPlayCurrent();
  }

  Future<void> playTrack(Song song) async {
    if (!_queue.contains(song)) {
      _queue.add(song);
    }
    _generateShuffledQueue(_queue.indexOf(song));
    
    if (_shuffleEnabled) {
      _currentIndex = _shuffledQueue.indexOf(song);
    } else {
      _currentIndex = _queue.indexOf(song);
    }
    notifyListeners();
    await _loadAndPlayCurrent();
  }

  Future<void> _loadAndPlayCurrent() async {
    final song = currentTrack;
    if (song == null) return;

    try {
      final metadata = await _repository.fetchMetadata(song.id);
      final streamUrl = metadata['streamUrl'];
      
      if (streamUrl != null && streamUrl.toString().isNotEmpty) {
        final url = streamUrl.toString().startsWith('http') ? streamUrl : '${Env.baseUrl}$streamUrl';
        
        await _audioService.setAudioSource(
          url,
          id: song.id,
          title: song.title,
          artist: song.artist,
          artUri: song.coverUrl.startsWith('http') ? song.coverUrl : null,
        );
        await _audioService.play();
      } else {
        await _audioService.stop();
      }
    } catch (e) {
      debugPrint('Playback error: $e');
      playNext(); // skip broken track
    }
  }

  Future<void> pause() => _audioService.pause();
  Future<void> resume() => _audioService.play();
  Future<void> togglePlayPause() => _isPlaying ? pause() : resume();
  Future<void> stop() => _audioService.stop();
  Future<void> seek(Duration pos) => _audioService.seek(pos);
  Future<void> setVolumeLevel(double vol) async {
    _volume = vol;
    await _audioService.setVolume(vol);
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_activeQueue.isEmpty) return;

    _currentIndex++;
    if (_currentIndex >= _activeQueue.length) {
      if (_repeatMode == PlayerRepeatMode.all) {
        _currentIndex = 0;
      } else {
        _currentIndex = _activeQueue.length - 1;
        await stop();
        notifyListeners();
        return;
      }
    }
    
    notifyListeners();
    await _loadAndPlayCurrent();
  }

  Future<void> playPrevious() async {
    if (_activeQueue.isEmpty) return;

    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    _currentIndex--;
    if (_currentIndex < 0) {
      if (_repeatMode == PlayerRepeatMode.all) {
        _currentIndex = _activeQueue.length - 1;
      } else {
        _currentIndex = 0;
      }
    }
    
    notifyListeners();
    await _loadAndPlayCurrent();
  }

  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    if (_activeQueue.isNotEmpty && currentTrack != null) {
      final current = currentTrack!;
      if (_shuffleEnabled) {
        _generateShuffledQueue(_queue.indexOf(current));
        _currentIndex = 0; // The current track is always first in the new shuffled queue
      } else {
        _currentIndex = _queue.indexOf(current);
      }
    }
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case PlayerRepeatMode.off:
        _repeatMode = PlayerRepeatMode.all;
        break;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
        break;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.off;
        break;
    }
    notifyListeners();
  }

  void _generateShuffledQueue(int currentIndexToKeepFirst) {
    if (_queue.isEmpty) return;
    
    final current = _queue[currentIndexToKeepFirst];
    final remaining = List<Song>.from(_queue)..removeAt(currentIndexToKeepFirst);
    remaining.shuffle(Random());
    
    _shuffledQueue = [current, ...remaining];
  }

  void addToQueue(Song song) {
    if (!_queue.contains(song)) {
      _queue.add(song);
      _shuffledQueue.add(song); // just append to shuffled queue for simplicity
      notifyListeners();
    }
  }

  void clearQueue() {
    _queue.clear();
    _shuffledQueue.clear();
    _currentIndex = -1;
    stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
