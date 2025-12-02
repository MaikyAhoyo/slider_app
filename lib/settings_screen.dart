import 'dart:ui';
import 'package:flutter/material.dart';
import 'services/audio_manager.dart';

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
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgrounds/menu_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isLandscape ? 10 : 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: isLandscape ? 20 : 40,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isLandscape) ...[
                            const Icon(
                              Icons.equalizer_rounded,
                              size: 50,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 10),
                          ],
                          const Text(
                            'CONFIGURACIÓN',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 20,
                                  color: Colors.blueAccent,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Text(
                            "Ajustes de Audio",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),

                          SizedBox(height: isLandscape ? 20 : 40),

                          _buildNeonSlider(
                            label: "Volumen General",
                            value: _masterVolume,
                            icon: Icons.volume_up_rounded,
                            activeColor: Colors.purpleAccent,
                            onChanged: (val) {
                              setState(() => _masterVolume = val);
                              _audioManager.setMasterVolume(val);
                            },
                          ),

                          SizedBox(height: isLandscape ? 15 : 30),

                          _buildNeonSlider(
                            label: "Música",
                            value: _musicVolume,
                            icon: Icons.music_note_rounded,
                            activeColor: Colors.cyanAccent,
                            onChanged: (val) {
                              setState(() => _musicVolume = val);
                              _audioManager.setMusicVolume(val);
                            },
                          ),

                          SizedBox(height: isLandscape ? 15 : 30),

                          _buildNeonSlider(
                            label: "Efectos (SFX)",
                            value: _sfxVolume,
                            icon: Icons.graphic_eq_rounded,
                            activeColor: Colors.orangeAccent,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonSlider({
    required String label,
    required double value,
    required IconData icon,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: activeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            Text(
              "${(value * 100).toInt()}%",
              style: TextStyle(
                color: activeColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6.0,
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.grey.shade800,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10.0,
              pressedElevation: 8.0,
            ),
            thumbColor: Colors.white,
            overlayColor: activeColor.withOpacity(0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
            tickMarkShape: const RoundSliderTickMarkShape(),
            activeTickMarkColor: activeColor,
            inactiveTickMarkColor: Colors.white70,
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}
