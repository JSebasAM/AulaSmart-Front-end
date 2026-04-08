import 'dart:async';

import 'package:aulasmart_front_end/models/user.dart';

class AuthService {
  Future<bool> login(User user) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return true;
  }
}
