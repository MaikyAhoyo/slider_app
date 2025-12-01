import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Volúmenes (0.0 a 1.0)
  double _masterVolume = 1.0;
  double _musicVolume = 1.0;
  double _sfxVolume = 1.0;

  // Mapa de identificadores de sonido a rutas de assets
  final Map<String, String> _soundMap = {
    'menu_theme': 'music/menu_theme.mp3',
    'game_theme': 'music/game_theme.mp3',
    'click': 'sfx/click.mp3',
    'game_over': 'sfx/game_over.mp3',
  };

  AudioManager._internal() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  // Getters para los volúmenes
  double get masterVolume => _masterVolume;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  // Setters para los volúmenes
  void setMasterVolume(double value) {
    _masterVolume = value.clamp(0.0, 1.0);
    _updateVolumes();
  }

  void setMusicVolume(double value) {
    _musicVolume = value.clamp(0.0, 1.0);
    _updateVolumes();
  }

  void setSfxVolume(double value) {
    _sfxVolume = value.clamp(0.0, 1.0);
    _updateVolumes();
  }

  void _updateVolumes() {
    _musicPlayer.setVolume(_masterVolume * _musicVolume);
    _sfxPlayer.setVolume(_masterVolume * _sfxVolume);
  }

  // Reproducir música
  Future<void> playMusic(String soundId) async {
    final path = _soundMap[soundId];
    if (path == null) {
      debugPrint('❌ Audio Manager: Sonido no encontrado: $soundId');
      return;
    }

    try {
      await _musicPlayer.stop();
      await _musicPlayer.setSource(AssetSource(path));
      await _musicPlayer.setVolume(_masterVolume * _musicVolume);
      await _musicPlayer.resume();
    } catch (e) {
      debugPrint('❌ Audio Manager: Error reproduciendo música: $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // Reproducir efecto de sonido
  Future<void> playSfx(String soundId) async {
    final path = _soundMap[soundId];
    if (path == null) {
      debugPrint('❌ Audio Manager: Sonido no encontrado: $soundId');
      return;
    }

    try {
      // Para SFX, a veces queremos solapamiento, así que creamos un player temporal o usamos uno dedicado si es simple
      // Para este ejemplo simple, usamos _sfxPlayer. Si necesitas polifonía, crea uno nuevo.
      await _sfxPlayer.stop();
      await _sfxPlayer.setSource(AssetSource(path));
      await _sfxPlayer.setVolume(_masterVolume * _sfxVolume);
      await _sfxPlayer.resume();
    } catch (e) {
      debugPrint('❌ Audio Manager: Error reproduciendo SFX: $e');
    }
  }

  // Método para registrar nuevos sonidos dinámicamente si es necesario
  void registerSound(String id, String assetPath) {
    _soundMap[id] = assetPath;
  }
}
