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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: kRetroBlueTop,
        title: Text("CONFIGURACIÓN", style: getRetroStyle()),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.white, height: 2),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                "assets/backgrounds/menu_bg.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: RetroBox(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "AUDIO SYSTEM",
                        style: getRetroStyle(color: Colors.yellow, size: 18),
                      ),
                      const Divider(
                        color: Colors.white24,
                        thickness: 1,
                        height: 30,
                      ),

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
                        label: "MUSIC",
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
                    ],
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
            Text(label, style: getRetroStyle()),
            Text(
              "${(value * 100).toInt()}%",
              style: getRetroStyle(color: Colors.greenAccent),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 30, // Altura del slider
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 10,
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.black,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: SliderComponentShape.noOverlay,
              trackShape:
                  const RectangularSliderTrackShape(), // Forma rectangular dura
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}
