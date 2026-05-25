import 'package:flutter_riverpod/legacy.dart';

/// Se activa cuando el refresh token también expira y la sesión debe reiniciarse.
final sessionExpiredProvider = StateProvider<bool>((ref) => false);
