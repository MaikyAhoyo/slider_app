import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio centralizado para gestionar todas las interacciones con Supabase.
///
/// Encapsula autenticación, consultas y operaciones CRUD en la tabla 'players'.
class SupabaseService {
  final SupabaseClient _client;

  /// Constructor. Recibe el cliente de Supabase (por defecto usa Supabase.instance.client).
  SupabaseService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Obtiene el cliente de Supabase (útil si necesitas acceso directo en casos especiales).
  SupabaseClient get client => _client;

  /// Obtiene el usuario actualmente autenticado.
  User? get currentUser => _client.auth.currentUser;

  /// Obtiene la sesión actual.
  Session? get currentSession => _client.auth.currentSession;

  /// Stream que emite cambios en el estado de autenticación.
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  // ============================================================================
  // AUTENTICACIÓN
  // ============================================================================

  /// Inicia sesión con email y contraseña.
  ///
  /// Retorna `true` si la autenticación fue exitosa, `false` en caso contrario.
  Future<bool> signIn({required String email, required String password}) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        debugPrint('❌ Error signing in: No session returned');
        return false;
      } else {
        debugPrint('✅ User signed in: ${response.user?.email}');
        return true;
      }
    } catch (error) {
      debugPrint('❌ Error inesperado al hacer sign in: $error');
      return false;
    }
  }

  /// Cierra la sesión actual.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('✅ Usuario deslogueado.');
    } catch (error) {
      debugPrint('❌ Error al hacer sign out: $error');
    }
  }

  // ============================================================================
  // OPERACIONES EN LA TABLA 'players'
  // ============================================================================

  /// Inserta un nuevo jugador en la tabla 'players'.
  ///
  /// Si no hay sesión activa, intenta hacer sign-in primero usando credenciales del .env.
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador.
  /// - [points]: Puntos iniciales del jugador.
  /// - [userId]: ID del usuario propietario (opcional, por defecto usa un ID fijo).
  Future<void> insertPlayer({
    required String playerName,
    required int points,
    String? userId,
  }) async {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;

    debugPrint('session: $session');
    debugPrint('user id: ${user?.id}');

    if (session == null || user == null) {
      // Intenta autenticarse si no hay sesión usando credenciales del .env
      debugPrint('⚠️ No hay sesión activa. Intentando autenticar...');
      final email = dotenv.env['AUTH_EMAIL'];
      final password = dotenv.env['AUTH_PASSWORD'];

      if (email != null && password != null) {
        await signIn(email: email, password: password);
      } else {
        debugPrint('❌ No se encontraron credenciales en .env');
        return;
      }
    }

    try {
      final newPlayer = {
        'player_name': playerName,
        'points': points,
        'user_id': userId ?? '3843a525-e9d5-414c-9994-dbb81aa4f633',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('players').insert(newPlayer);

      debugPrint('✅ Jugador insertado exitosamente: $playerName');
    } on PostgrestException catch (error) {
      debugPrint('❌ Error al insertar jugador: ${error.message}');
    } catch (error) {
      debugPrint('❌ Error inesperado al insertar: $error');
    }
  }

  /// Actualiza los puntos de un jugador existente en la tabla 'players'.
  ///
  /// Filtra por el nombre del jugador.
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador a actualizar.
  /// - [points]: Nuevos puntos del jugador.
  Future<void> updatePlayer({
    required String playerName,
    required int points,
  }) async {
    try {
      final updatedData = {
        'player_name': playerName,
        'points': points,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('players')
          .update(updatedData)
          .eq('player_name', playerName);

      debugPrint('✅ Jugador con nombre $playerName actualizado exitosamente.');
    } on PostgrestException catch (error) {
      debugPrint('❌ Error al actualizar jugador: ${error.message}');
    } catch (error) {
      debugPrint('❌ Error inesperado al actualizar: $error');
    }
  }

  /// Verifica si un jugador existe. Si existe, lo actualiza; si no, lo inserta (UPSERT).
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador.
  /// - [score]: Puntos a asignar o actualizar.
  Future<bool> checkAndUpsertPlayer({
    required String playerName,
    required int score,
  }) async {
    try {
      final response = await _client
          .from('players')
          .select('id, player_name, points')
          .eq('player_name', playerName)
          .limit(1);

      if (response.isNotEmpty) {
        // Jugador existe
        final existingPlayer = response.first;
        final existingPoints = existingPlayer['points'] as int;

        // SOLO actualizamos si el nuevo score es mayor
        if (score > existingPoints) {
          debugPrint('🚀 ¡NUEVO HIGH SCORE! ($score > $existingPoints)');
          await updatePlayer(playerName: playerName, points: score);
          return true; // Es record
        } else {
          debugPrint('📉 No superó el record ($score <= $existingPoints)');
          return false; // No es record
        }
      } else {
        // Jugador nuevo -> Es su primer record
        await insertPlayer(playerName: playerName, points: score);
        return true;
      }
    } catch (error) {
      debugPrint('❌ Error upsert: $error');
      return false;
    }
  }

  /// Recupera los puntos de un jugador desde la tabla 'players'.
  ///
  /// Retorna los puntos si el jugador existe, o `null` si no se encuentra.
  ///
  /// Parámetros:
  /// - [playerName]: Nombre del jugador a buscar.
  Future<int?> retrievePoints({required String playerName}) async {
    try {
      final response = await _client
          .from('players')
          .select('points')
          .eq('player_name', playerName)
          .limit(1);

      if (response.isNotEmpty) {
        final playerData = response.first;
        final points = playerData['points'] as int;
        debugPrint('✅ Puntos recuperados para $playerName: $points');
        return points;
      } else {
        debugPrint('⚠️ Jugador $playerName no encontrado.');
        return null;
      }
    } catch (error) {
      debugPrint('❌ Error inesperado al recuperar puntos: $error');
      return null;
    }
  }

  // ============================================================================
  // LEADERBOARD & RANKING
  // ============================================================================

  /// Obtiene el Top de jugadores ordenados por puntos.
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 5}) async {
    try {
      final response = await _client
          .from('players')
          .select('player_name, points')
          .order('points', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('❌ Error obteniendo leaderboard: $error');
      return [];
    }
  }

  /// Calcula el ranking global del jugador basado en sus puntos actuales.
  /// (Cuántos jugadores tienen más puntos que tú + 1)
  Future<int> getPlayerRank(int playerPoints) async {
    try {
      final count = await _client
          .from('players')
          .count(CountOption.exact)
          .gt('points', playerPoints);

      return count + 1;
    } catch (error) {
      debugPrint('❌ Error calculando ranking: $error');
      return 0;
    }
  }
}
