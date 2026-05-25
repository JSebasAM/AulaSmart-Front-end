import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionEntry {
  final String sessionId;
  final String aesKeyBase64;

  SessionEntry({required this.sessionId, required this.aesKeyBase64});

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'aesKey': aesKeyBase64,
      };

  factory SessionEntry.fromJson(Map<String, dynamic> json) => SessionEntry(
        sessionId: json['sessionId'] as String,
        aesKeyBase64: json['aesKey'] as String,
      );
}

class SessionManager {
  static const _storage = FlutterSecureStorage();
  static const _sessionsKey = 'crypto_sessions';

  static Future<Map<String, SessionEntry>> loadSessions() async {
    final jsonStr = await _storage.read(key: _sessionsKey);
    if (jsonStr == null) return {};
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return map.map(
      (k, v) => MapEntry(k, SessionEntry.fromJson(v as Map<String, dynamic>)),
    );
  }

  static Future<void> saveSession(String host, SessionEntry entry) async {
    final sessions = await loadSessions();
    sessions[host] = entry;
    await _storage.write(
      key: _sessionsKey,
      value: jsonEncode(sessions.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  static Future<SessionEntry?> getSession(String host) async {
    final sessions = await loadSessions();
    return sessions[host];
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _sessionsKey);
  }
}
