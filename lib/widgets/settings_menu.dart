import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/audio_manager.dart';

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
    final orientation = MediaQuery.of(context).orientation;

    // En landscape, usar altura como referencia para el ancho
    final menuWidth = orientation == Orientation.landscape
        ? size.height *
              0.6 // 60% de la altura en horizontal
        : 340.0; // Ancho fijo en vertical

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),

        Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: menuWidth,
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.9,
                    maxHeight: size.height * 0.85,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: orientation == Orientation.landscape ? 20 : 35,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AJUSTES',
                        style: TextStyle(
                          fontSize: orientation == Orientation.landscape
                              ? 22
                              : 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3,
                          shadows: const [
                            Shadow(
                              blurRadius: 15,
                              color: Colors.purpleAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 20 : 30,
                      ),

                      _buildNeonSlider(
                        label: "Volumen Maestro",
                        value: _masterVolume,
                        icon: Icons.volume_up_rounded,
                        activeColor: Colors.purpleAccent,
                        onChanged: (val) {
                          setState(() => _masterVolume = val);
                          _audioManager.setMasterVolume(val);
                        },
                        isLandscape: orientation == Orientation.landscape,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 12 : 20,
                      ),

                      _buildNeonSlider(
                        label: "Música",
                        value: _musicVolume,
                        icon: Icons.music_note_rounded,
                        activeColor: Colors.cyanAccent,
                        onChanged: (val) {
                          setState(() => _musicVolume = val);
                          _audioManager.setMusicVolume(val);
                        },
                        isLandscape: orientation == Orientation.landscape,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 12 : 20,
                      ),

                      _buildNeonSlider(
                        label: "Efectos (SFX)",
                        value: _sfxVolume,
                        icon: Icons.graphic_eq_rounded,
                        activeColor: Colors.orangeAccent,
                        onChanged: (val) {
                          setState(() => _sfxVolume = val);
                          _audioManager.setSfxVolume(val);
                        },
                        isLandscape: orientation == Orientation.landscape,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 20 : 35,
                      ),

                      Divider(
                        color: Colors.white.withOpacity(0.1),
                        thickness: 1,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 10 : 15,
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: widget.onBack,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'VOLVER',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.05),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: orientation == Orientation.landscape
                                  ? 12
                                  : 16,
                            ),
                            elevation: 0,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
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
    );
  }

  Widget _buildNeonSlider({
    required String label,
    required double value,
    required IconData icon,
    required Color activeColor,
    required ValueChanged<double> onChanged,
    bool isLandscape = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: isLandscape ? 16 : 18),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: isLandscape ? 11 : 12,
                fontWeight: FontWeight.bold,
                color: activeColor.withOpacity(0.9),
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              "${(value * 100).toInt()}%",
              style: TextStyle(
                fontSize: isLandscape ? 11 : 12,
                color: Colors.white54,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        SizedBox(
          height: isLandscape ? 25 : 30,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4.0,
              activeTrackColor: activeColor,
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: isLandscape ? 6.0 : 8.0,
              ),
              overlayColor: activeColor.withOpacity(0.2),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: isLandscape ? 12.0 : 16.0,
              ),
            ),
            child: Slider(value: value, onChanged: onChanged),
          ),
        ),
      ],
    );
  }
}
