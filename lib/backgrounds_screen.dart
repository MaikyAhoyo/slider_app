import 'package:flutter/material.dart';
import 'ui/retro_ui.dart';
import 'services/storage_service.dart';

class BackgroundOption {
  final String name;
  final String assetPath;
  BackgroundOption({required this.name, required this.assetPath});
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
      assetPath: 'assets/backgrounds/forest_bg.png',
    ),
    BackgroundOption(
      name: 'NORTH POLE',
      assetPath: 'assets/backgrounds/snow_bg.png',
    ),
    BackgroundOption(
      name: 'HAUNTED FOREST',
      assetPath: 'assets/backgrounds/haunted_forest_bg.png',
    ),
    BackgroundOption(name: 'MARS', assetPath: 'assets/backgrounds/mars_bg.png'),
    BackgroundOption(
      name: 'UNDERWATER',
      assetPath: 'assets/backgrounds/underwater_bg.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedBackground = widget.currentBackground;
    _loadInitialBackground();
  }

  Future<void> _loadInitialBackground() async {
    final storage = StorageService();
    await storage.init();

    _selectedBackground = storage.getSelectedBackground().isNotEmpty
        ? storage.getSelectedBackground()
        : widget.currentBackground;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final bgImage = isLandscape
        ? "assets/backgrounds/menu_h_bg.png"
        : "assets/backgrounds/menu_bg.png";

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(bgImage, fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // CABECERA RETRO
                    RetroBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 28,
                          ),
                          Text(
                            'FONDOS',
                            style: getRetroStyle(
                              size: 24,
                              color: Colors.yellowAccent,
                            ),
                          ),
                          // Botón cerrar "X" estilo ventana clásica
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop(_selectedBackground);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color: Colors.red,
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    RetroBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, color: Colors.greenAccent),
                          const SizedBox(width: 10),
                          Text(
                            "SELECCIONAR FONDO",
                            style: getRetroStyle(size: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: RetroBox(
                        padding: const EdgeInsets.all(8),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isLandscape ? 2 : 1,
                                childAspectRatio: 2.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _backgroundOptions.length,
                          itemBuilder: (context, index) {
                            final bg = _backgroundOptions[index];
                            final isSelected =
                                bg.assetPath == _selectedBackground;

                            return _buildRetroBackgroundSlot(bg, isSelected);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroBackgroundSlot(BackgroundOption bg, bool isSelected) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedBackground = bg.assetPath;
        });

        // Guardar en SharedPreferences
        await StorageService().saveSelectedBackground(bg.assetPath);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.3) : Colors.black54,
          border: Border.all(
            color: isSelected ? Colors.greenAccent : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(5),
              child: Image.asset(bg.assetPath, fit: BoxFit.cover),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bg.name,
                    style: getRetroStyle(
                      color: isSelected ? Colors.greenAccent : Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isSelected ? "ACTIVO" : "DISPONIBLE",
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.greenAccent),
          ],
        ),
      ),
    );
  }
}
