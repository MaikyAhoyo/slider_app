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

  const BackgroundStyles({
    super.key,
    required this.currentBackground,
  });

  @override
  State<BackgroundStyles> createState() => _BackgroundStylesState();
}

class _BackgroundStylesState extends State<BackgroundStyles> {
  late String _selectedBackground;

  final List<BackgroundOption> _backgroundOptions = [
    BackgroundOption(
      name: 'CITY NIGHT',
      assetPath: 'assets/backgrounds/city_night.png',
    ),
    BackgroundOption(
      name: 'RETRO GRID',
      assetPath: 'assets/backgrounds/retro_grid.png',
    ),
    BackgroundOption(
      name: 'SUNSET ROAD',
      assetPath: 'assets/backgrounds/sunset_road.png',
    ),
    BackgroundOption(
      name: 'NEON TUNNEL',
      assetPath: 'assets/backgrounds/neon_tunnel.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedBackground = widget.currentBackground;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: kRetroBlueTop,
        elevation: 0,
        title: Text("FONDOS", style: getRetroStyle(size: 24)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(_selectedBackground);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.white, height: 2),
        ),
      ),

      body: Stack(
        children: [
          // Fondo del menú
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                "assets/backgrounds/menu_bg.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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

                  // GRID
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroBackgroundSlot(
      BackgroundOption bg, bool isSelected) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedBackground = bg.assetPath;
        });

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
            // Preview del fondo
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

            // Info
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
