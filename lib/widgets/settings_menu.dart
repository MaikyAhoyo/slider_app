import 'package:flutter/material.dart';
import '../services/audio_manager.dart';
import '../ui/retro_ui.dart';

class SettingsMenu extends StatefulWidget {
  final VoidCallback onBack;

  const SettingsMenu({super.key, required this.onBack});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
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
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final menuWidth = isLandscape ? size.height * 0.7 : 320.0;

    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(0.7)),

        Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: menuWidth),
              child: RetroWindow(
                title: 'AJUSTES',
                icon: Icons.settings,
                onClose: widget.onBack,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRetroSlider(
                      label: "MASTER",
                      value: _masterVolume,
                      onChanged: (val) {
                        setState(() => _masterVolume = val);
                        _audioManager.setMasterVolume(val);
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildRetroSlider(
                      label: "MUSIC",
                      value: _musicVolume,
                      onChanged: (val) {
                        setState(() => _musicVolume = val);
                        _audioManager.setMusicVolume(val);
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildRetroSlider(
                      label: "SFX",
                      value: _sfxVolume,
                      onChanged: (val) {
                        setState(() => _sfxVolume = val);
                        _audioManager.setSfxVolume(val);
                      },
                    ),

                    const SizedBox(height: 25),

                    RetroButton(text: "VOLVER", onPressed: widget.onBack),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
          height: 24,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 12,
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.black54,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
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
