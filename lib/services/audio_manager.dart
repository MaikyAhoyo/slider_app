import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  final AudioPlayer _musicPlayer = AudioPlayer();
  final List<AudioPlayer> _activeSfxPlayers = [];

  String? _currentMusicId;

  double _masterVolume = 1.0;
  double _musicVolume = 1.0;
  double _sfxVolume = 1.0;

  final Map<String, String> _soundMap = {
    'menu_theme': 'music/menu_theme.mp3',
    'forest_theme': 'music/forest_theme.mp3',
    'haunted_theme': 'music/haunted_theme.mp3',
    'snow_theme': 'music/snow_theme.mp3',
    'desert_theme': 'music/desert_theme.mp3',
    'futuristic_theme': 'music/futuristic_theme.mp3',
    'underwater_theme': 'music/underwater_theme.mp3',
    'game_over_sfx': 'sfx/game_over_sfx.wav',
    'gas_sfx': 'sfx/gas_sfx.wav',
    'coin_sfx': 'sfx/coin_sfx.wav',
    'tire_sfx': 'sfx/tire_sfx.wav',
    'crash_sfx': 'sfx/crash_sfx.wav',
    'speed_up_sfx': 'sfx/speed_up_sfx.wav',
    'combo_sfx': 'sfx/combo_sfx.wav',
  };

  AudioManager._internal() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);

    if (!kIsWeb) {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.none,
          ),
        ),
      );
    }
  }

  Future<void> loadSettings() async {
    final storage = StorageService();
    _masterVolume = storage.getMasterVolume();
    _musicVolume = storage.getMusicVolume();
    _sfxVolume = storage.getSfxVolume();
    _updateVolumes();
    debugPrint(
      "🔊 Audio cargado: Master: $_masterVolume, Music: $_musicVolume",
    );
  }

  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  void setMasterVolume(double value) {
    _masterVolume = value.clamp(0.0, 1.0);
    _updateVolumes();
    StorageService().saveMasterVolume(_masterVolume);
  }

  void setMusicVolume(double value) {
    _musicVolume = value.clamp(0.0, 1.0);
    _updateVolumes();
    StorageService().saveMusicVolume(_musicVolume);
  }

  void setSfxVolume(double value) {
    _sfxVolume = value.clamp(0.0, 1.0);
    _updateVolumes();
    StorageService().saveSfxVolume(_sfxVolume);
  }

  void _updateVolumes() {
    _musicPlayer.setVolume(_masterVolume * _musicVolume);

    for (var player in _activeSfxPlayers) {
      player.setVolume(_masterVolume * _sfxVolume);
    }
  }

  Future<void> playMusic(String soundId) async {
    final path = _soundMap[soundId];
    if (path == null) {
      debugPrint('❌ Audio Manager: Sonido no encontrado: $soundId');
      return;
    }

    try {
      if (_musicPlayer.state == PlayerState.playing &&
          _currentMusicId == soundId) {
        return;
      }

      _currentMusicId = soundId;

      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource(path));
      await _musicPlayer.setVolume(_masterVolume * _musicVolume);
      await _musicPlayer.resume();
    } catch (e) {
      debugPrint('❌ Audio Manager: Error reproduciendo música: $e');
    }
  }

  Future<void> stopMusic() async {
    _currentMusicId = null;
    await _musicPlayer.stop();
  }

  Future<void> playSfx(String soundId) async {
    final path = _soundMap[soundId];
    if (path == null) {
      debugPrint('❌ Audio Manager: Sonido no encontrado: $soundId');
      return;
    }

    try {
      final sfxPlayer = AudioPlayer();
      _activeSfxPlayers.add(sfxPlayer);

      sfxPlayer.onPlayerComplete.listen((_) {
        sfxPlayer.dispose();
        _activeSfxPlayers.remove(sfxPlayer);
      });

      await sfxPlayer.play(
        AssetSource(path),
        volume: _masterVolume * _sfxVolume,
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      debugPrint('❌ Audio Manager: Error reproduciendo SFX: $e');
    }
  }

  void registerSound(String id, String assetPath) {
    _soundMap[id] = assetPath;
  }
}
