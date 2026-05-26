import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionEntry {
  final String sessionId;
  final String aesKeyBase64;
  final DateTime createdAt;

  SessionEntry({
    required this.sessionId,
    required this.aesKeyBase64,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'aesKey': aesKeyBase64,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SessionEntry.fromJson(Map<String, dynamic> json) => SessionEntry(
        sessionId: json['sessionId'] as String,
        aesKeyBase64: json['aesKey'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}

class SessionManager {
  static const _storage = FlutterSecureStorage();
  static const _sessionsKey = 'crypto_sessions';

  static const _sessionTtl = Duration(minutes: 20);

  static Future<Map<String, SessionEntry>> loadSessions() async {
    final jsonStr = await _storage.read(key: _sessionsKey);
    if (jsonStr == null) return {};
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    final sessions = map.map(
      (k, v) => MapEntry(k, SessionEntry.fromJson(v as Map<String, dynamic>)),
    );

    final now = DateTime.now();
    sessions.removeWhere((_, entry) {
      final expired = now.difference(entry.createdAt) > _sessionTtl;
      if (expired) {
        debugPrint('[CryptoSession] Sesion expirada localmente para host (TTL > 20min)');
      }
      return expired;
    });

    return sessions;
  }

  static Future<void> saveSession(String host, SessionEntry entry) async {
    final sessions = await loadSessions();
    sessions[host] = entry;
    debugPrint('[CryptoSession] Sesion guardada para $host | sessionId=${entry.sessionId}');
    await _saveSessions(sessions);
  }

  static Future<SessionEntry?> getSession(String host) async {
    final sessions = await loadSessions();
    final entry = sessions[host];
    if (entry == null) {
      debugPrint('[CryptoSession] No hay sesion para $host');
    } else {
      debugPrint('[CryptoSession] Sesion recuperada para $host | sessionId=${entry.sessionId}');
    }
    return entry;
  }

  static Future<void> removeSession(String host) async {
    final sessions = await loadSessions();
    sessions.remove(host);
    debugPrint('[CryptoSession] Sesion eliminada para $host');
    await _saveSessions(sessions);
  }

  static Future<void> clearAll() async {
    debugPrint('[CryptoSession] Todas las sesiones limpiadas');
    await _storage.delete(key: _sessionsKey);
  }

  static Future<void> _saveSessions(Map<String, SessionEntry> sessions) async {
    await _storage.write(
      key: _sessionsKey,
      value: jsonEncode(sessions.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }
}
