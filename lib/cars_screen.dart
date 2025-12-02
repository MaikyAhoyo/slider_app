import 'package:flutter/material.dart';
import 'ui/retro_ui.dart';
import 'services/storage_service.dart';

class CarOption {
  final String name;
  final String assetPath;
  CarOption({required this.name, required this.assetPath});
}

class CarsScreen extends StatefulWidget {
  final String currentCarAsset;
  const CarsScreen({super.key, required this.currentCarAsset});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  late String _selectedCarAsset;

  final List<CarOption> _carOptions = [
    CarOption(name: 'MODEL-01 ORANGE', assetPath: 'assets/cars/orange_car.png'),
    CarOption(name: 'MODEL-02 BLUE', assetPath: 'assets/cars/blue_car.png'),
    CarOption(
      name: 'MODEL-03 HYBRID',
      assetPath: 'assets/cars/purple_green_car.png',
    ),
    CarOption(
      name: 'MODEL-04 TURBO',
      assetPath: 'assets/cars/red_lightning_car.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCarAsset = widget.currentCarAsset;
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
      appBar: AppBar(
        backgroundColor: kRetroBlueTop,
        elevation: 0,
        title: Text("GARAJE", style: getRetroStyle(size: 24)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(_selectedCarAsset);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: Colors.white, height: 2),
        ),
      ),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(bgImage, fit: BoxFit.cover),
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
                        const Icon(
                          Icons.info_outline,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "SELECCIONAR UNIDAD",
                          style: getRetroStyle(size: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LISTA GRID
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isLandscape ? 2 : 1,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _carOptions.length,
                      itemBuilder: (context, index) {
                        final car = _carOptions[index];
                        final isSelected = car.assetPath == _selectedCarAsset;
                        return _buildRetroCarSlot(car, isSelected);
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

  Widget _buildRetroCarSlot(CarOption car, bool isSelected) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _selectedCarAsset = car.assetPath;
        });
        await StorageService().saveSelectedCar(car.assetPath);
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
            // Preview del coche
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
              ),
              padding: const EdgeInsets.all(5),
              child: Image.asset(car.assetPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 15),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    car.name,
                    style: getRetroStyle(
                      color: isSelected ? Colors.greenAccent : Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    isSelected ? "EQUIPADO" : "DISPONIBLE",
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
