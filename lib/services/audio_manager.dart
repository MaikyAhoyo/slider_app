import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _masterVolume = 1.0;
  double _musicVolume = 1.0;
  double _sfxVolume = 1.0;

  final Map<String, String> _soundMap = {
    'menu_theme': 'music/menu_theme.mp3',
    'game_theme': 'music/game_theme.mp3',
    'game_over': 'sfx/game_over.mp3',
    'gas_fx': 'sfx/gas_fx.mp3',
    'coin_fx': 'sfx/coin_fx.mp3',
    'tire_fx': 'sfx/tire_fx.mp3',
    'crash_fx': 'sfx/crash_fx.mp3',
  };

  AudioManager._internal() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Carga los ajustes del almacenamiento
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

  /// Actualiza el volumen general
  void _updateVolumes() {
    /// Multiplicamos por el Master para que baje todo junto si bajas el general
    _musicPlayer.setVolume(_masterVolume * _musicVolume);
    _sfxPlayer.setVolume(_masterVolume * _sfxVolume);
  }

  /// Reproduce música
  Future<void> playMusic(String soundId) async {
    final path = _soundMap[soundId];
    if (path == null) {
      debugPrint('❌ Audio Manager: Sonido no encontrado: $soundId');
      return;
    }

    try {
      /// No detenemos si ya está sonando la misma canción
      if (_musicPlayer.state == PlayerState.playing) {
        return;
      }

      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource(path));
      await _musicPlayer.setVolume(_masterVolume * _musicVolume);
      await _musicPlayer.resume();
    } catch (e) {
      debugPrint('❌ Audio Manager: Error reproduciendo música: $e');
    }
  }

  /// Detiene la música
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  /// Reproduce un efecto de sonido
  Future<void> playSfx(String soundId) async {
    final path = _soundMap[soundId];
    if (path == null) {
      debugPrint('❌ Audio Manager: Sonido no encontrado: $soundId');
      return;
    }

    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.setSource(AssetSource(path));
      await _sfxPlayer.setVolume(_masterVolume * _sfxVolume);
      await _sfxPlayer.resume();
    } catch (e) {
      debugPrint('❌ Audio Manager: Error reproduciendo SFX: $e');
    }
  }

  void registerSound(String id, String assetPath) {
    _soundMap[id] = assetPath;
  }
}
