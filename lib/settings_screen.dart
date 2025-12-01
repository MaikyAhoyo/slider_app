import 'package:flutter/material.dart';
import 'services/audio_manager.dart';

/// Pantalla para que el usuario cambie sus preferencias
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Referencia al AudioManager
  final AudioManager _audioManager = AudioManager.instance;

  // Variables de estado local para los sliders (para actualización fluida de UI)
  double _masterVolume = 1.0;
  double _musicVolume = 1.0;
  double _sfxVolume = 1.0;

  @override
  void initState() {
    super.initState();
    // Inicializar con los valores actuales del manager
    _masterVolume = _audioManager.masterVolume;
    _musicVolume = _audioManager.musicVolume;
    _sfxVolume = _audioManager.sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgrounds/menu_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay oscuro
          Container(color: Colors.black.withOpacity(0.6)),

          // Contenido
          SafeArea(
            child: Column(
              children: [
                // AppBar
                AppBar(
                  title: const Text(
                    'Configuración',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: 20),

                // Título
                const Text(
                  'Ajustes de Audio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // Sliders de Volumen
                _buildVolumeSlider("Volumen General", _masterVolume, (val) {
                  setState(() => _masterVolume = val);
                  _audioManager.setMasterVolume(val);
                }),
                _buildVolumeSlider("Música", _musicVolume, (val) {
                  setState(() => _musicVolume = val);
                  _audioManager.setMusicVolume(val);
                }),
                _buildVolumeSlider("Efectos de Sonido", _sfxVolume, (val) {
                  setState(() => _sfxVolume = val);
                  _audioManager.setSfxVolume(val);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Row(
            children: [
              const Icon(Icons.volume_mute, color: Colors.white70),
              Expanded(
                child: Slider(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.redAccent,
                  inactiveColor: Colors.white24,
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white70),
            ],
          ),
        ],
      ),
    );
  }
}
