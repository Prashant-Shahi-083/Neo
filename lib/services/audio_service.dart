import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  Future<void> setAudioSource(
    String url, {
    required String id,
    required String title,
    String? artist,
    String? artUri,
  }) async {
    final mediaItem = MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: artUri != null ? Uri.tryParse(artUri) : null,
    );
    
    final audioSource = AudioSource.uri(
      Uri.parse(url),
      tag: mediaItem,
    );
    await _player.setAudioSource(audioSource);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  void dispose() {
    _player.dispose();
  }
}
