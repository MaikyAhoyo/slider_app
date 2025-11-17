import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_screen.dart'; // La pantalla a la que iremos

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia el proceso de carga tan pronto como la pantalla se construye
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // 1. Carga las variables de entorno
      await dotenv.load(fileName: ".env");

      // 2. Inicializa Supabase
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );

      // 3. Si todo salió bien, navega a MenuScreen
      // Usamos pushReplacement para que el usuario no pueda "volver"
      // a la pantalla de carga.
      if (mounted) {
        // Comprueba si el widget sigue en pantalla
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      }
    } catch (e) {
      // Si algo falla (p.ej. no hay internet o .env falta)
      // Muestra un error en la misma pantalla de carga
      debugPrint('Error al inicializar: $e');
      if (mounted) {
        setState(() {
          // Puedes mostrar un mensaje de error al usuario aquí
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo (la imagen de carga que me pediste)
          Image.asset(
            "assets/backgrounds/menu_bg.png", // Asegúrate de tener esta imagen
            fit: BoxFit.cover,
            // Manejo de error si la imagen de fondo no carga
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black); // Fondo negro si falla
            },
          ),

          // Overlay oscuro
          Container(color: Colors.black.withOpacity(0.5)),

          // Contenido centrado
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'Cargando datos del circuito...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
