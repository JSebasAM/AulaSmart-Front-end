import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/services/auth/auth_state.dart';
import 'package:aulasmart_front_end/services/auth/auth_notifier.dart';
import 'package:aulasmart_front_end/services/storage_service.dart';

final currentUserRoleProvider = FutureProvider<String>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState is AuthSuccess) {
    return (authState.userInfo['rol'] ?? '').toString().toLowerCase();
  }
  final storage = ref.read(storageServiceProvider);
  final userInfo = await storage.getUserInfo();
  final rol = (userInfo?['rol'] ?? '').toString().toLowerCase();
  if (rol.isNotEmpty) return rol;
  return '';
});

final currentUserIdProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState is AuthSuccess) {
    final id = authState.userInfo['id'];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? '0') ?? 0;
  }
  final storage = ref.read(storageServiceProvider);
  final userInfo = await storage.getUserInfo();
  final id = userInfo?['id'];
  if (id is int) return id;
  return int.tryParse(id?.toString() ?? '0') ?? 0;
});
