import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late SharedPreferences _prefs;

  static const String keyPlayerName = 'player_name';
  static const String keySelectedCar = 'selected_car';
  static const String keySelectedBackground = 'selected_bg';

  static const String keyMasterVolume = 'master_volume';
  static const String keyMusicVolume = 'music_volume';
  static const String keySfxVolume = 'sfx_volume';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getPlayerName() {
    return _prefs.getString(keyPlayerName) ?? "Jugador";
  }

  String getSelectedCar() {
    return _prefs.getString(keySelectedCar) ?? 'assets/cars/Camaro.png';
  }

  String getSelectedBackground() {
    return _prefs.getString(keySelectedBackground) ??
        'assets/backgrounds/game_bg.png';
  }

  double getMasterVolume() => _prefs.getDouble(keyMasterVolume) ?? 1.0;
  double getMusicVolume() => _prefs.getDouble(keyMusicVolume) ?? 1.0;
  double getSfxVolume() => _prefs.getDouble(keySfxVolume) ?? 1.0;

  Future<void> savePlayerName(String name) async {
    await _prefs.setString(keyPlayerName, name);
  }

  Future<void> saveSelectedCar(String assetPath) async {
    await _prefs.setString(keySelectedCar, assetPath);
  }

  Future<void> saveSelectedBackground(String assetPath) async {
    await _prefs.setString(keySelectedBackground, assetPath);
  }

  Future<void> saveMasterVolume(double value) async {
    await _prefs.setDouble(keyMasterVolume, value);
  }

  Future<void> saveMusicVolume(double value) async {
    await _prefs.setDouble(keyMusicVolume, value);
  }

  Future<void> saveSfxVolume(double value) async {
    await _prefs.setDouble(keySfxVolume, value);
  }
}
