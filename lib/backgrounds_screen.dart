import 'package:flutter/material.dart';
import 'ui/retro_ui.dart';
import 'services/storage_service.dart';

class BackgroundOption {
  final String name;
  final String description;
  final String assetPath;

  BackgroundOption({
    required this.name,
    required this.description,
    required this.assetPath,
  });
}

class BackgroundStyles extends StatefulWidget {
  final String currentBackground;
  const BackgroundStyles({super.key, required this.currentBackground});

  @override
  State<BackgroundStyles> createState() => _BackgroundStylesState();
}

class _BackgroundStylesState extends State<BackgroundStyles> {
  late String _selectedBackground;
  bool _isLoading = true;

  final List<BackgroundOption> _backgroundOptions = [
    BackgroundOption(
      name: 'FOREST',
      description: 'Un bosque denso con curvas peligrosas y mucha vegetación.',
      assetPath: 'assets/backgrounds/forest_bg.png',
    ),
    BackgroundOption(
      name: 'NORTH POLE',
      description: 'Pista helada y resbaladiza. ¡Cuidado con los derrapes!',
      assetPath: 'assets/backgrounds/snow_bg.png',
    ),
    BackgroundOption(
      name: 'HAUNTED FOREST',
      description:
          'Un lugar tenebroso donde los fantasmas observan tu carrera.',
      assetPath: 'assets/backgrounds/haunted_forest_bg.png',
    ),
    BackgroundOption(
      name: 'MARS COLONY',
      description: 'Compite en el planeta rojo con baja gravedad y polvo rojo.',
      assetPath: 'assets/backgrounds/mars_bg.png',
    ),
    BackgroundOption(
      name: 'DEEP OCEAN',
      description: 'Una pista submarina rodeada de vida marina y burbujas.',
      assetPath: 'assets/backgrounds/underwater_bg.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _selectedBackground = widget.currentBackground;

    final bool exists = _backgroundOptions.any(
      (bg) => bg.assetPath == _selectedBackground,
    );

    if (!exists && _backgroundOptions.isNotEmpty) {
      _selectedBackground = _backgroundOptions.first.assetPath;
      await StorageService().saveSelectedBackground(_selectedBackground);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: Colors.black);
    }

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
            child: Column(
              children: [
                RetroBox(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.wallpaper,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'ESCENARIOS',
                            style: getRetroStyle(
                              size: 20,
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pop(_selectedBackground),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            color: Colors.red.shade900,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text("X", style: getRetroStyle(size: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: RetroBox(
                      padding: const EdgeInsets.all(8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int gridColumns = isLandscape ? 3 : 2;
                          if (constraints.maxWidth > 600) gridColumns = 3;

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridColumns,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: _backgroundOptions.length,
                            itemBuilder: (context, index) {
                              final bg = _backgroundOptions[index];
                              final isSelected =
                                  bg.assetPath == _selectedBackground;
                              return _buildRetroBackgroundSlot(bg, isSelected);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroBackgroundSlot(BackgroundOption bg, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border.all(
          color: isSelected ? Colors.greenAccent : Colors.white24,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
              ),
              child: Image.asset(bg.assetPath, fit: BoxFit.cover),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bg.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRetroStyle(size: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bg.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              setState(() {
                _selectedBackground = bg.assetPath;
              });
              await StorageService().saveSelectedBackground(bg.assetPath);
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00AA00)
                    : const Color(0xFF0000AA),
                border: Border.all(color: Colors.white54),
              ),
              child: Center(
                child: Text(
                  isSelected ? "ACTIVO" : "VIAJAR AQUÍ",
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
