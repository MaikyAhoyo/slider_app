import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'menu_screen.dart';

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
      await dotenv.load(fileName: ".env");
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error al inicializar: $e');
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/backgrounds/menu_bg.png",
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black);
            },
          ),

          Container(color: Colors.black.withOpacity(0.5)),

          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Cargando datos del circuito...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
