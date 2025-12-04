import 'package:flutter/material.dart';
import 'services/audio_manager.dart';
import 'ui/retro_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioManager _audioManager = AudioManager.instance;

  double _masterVolume = 1.0;
  double _musicVolume = 1.0;
  double _sfxVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _masterVolume = _audioManager.masterVolume;
    _musicVolume = _audioManager.musicVolume;
    _sfxVolume = _audioManager.sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final bgImage = isLandscape
        ? "assets/backgrounds/menu_h_bg.png"
        : "assets/backgrounds/menu_bg.png";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(bgImage, fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(16),
                child: RetroWindow(
                  title: 'AJUSTES',
                  icon: Icons.settings,
                  onClose: () => Navigator.of(context).pop(),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RetroBox(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.equalizer,
                                    color: Colors.greenAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "AUDIO SYSTEM",
                                    style: getRetroStyle(size: 16),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.white24,
                                thickness: 1,
                                height: 20,
                              ),
                              const SizedBox(height: 10),

                              _buildRetroSlider(
                                label: "MASTER",
                                value: _masterVolume,
                                onChanged: (val) {
                                  setState(() => _masterVolume = val);
                                  _audioManager.setMasterVolume(val);
                                },
                              ),

                              const SizedBox(height: 20),

                              _buildRetroSlider(
                                label: "MUSICA",
                                value: _musicVolume,
                                onChanged: (val) {
                                  setState(() => _musicVolume = val);
                                  _audioManager.setMusicVolume(val);
                                },
                              ),

                              const SizedBox(height: 20),

                              _buildRetroSlider(
                                label: "SFX",
                                value: _sfxVolume,
                                onChanged: (val) {
                                  setState(() => _sfxVolume = val);
                                  _audioManager.setSfxVolume(val);
                                },
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: getRetroStyle(size: 14)),
            Text(
              "${(value * 100).toInt()}%",
              style: getRetroStyle(color: Colors.greenAccent, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 35,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.black,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: SliderComponentShape.noOverlay,
              trackShape: const RectangularSliderTrackShape(),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}
