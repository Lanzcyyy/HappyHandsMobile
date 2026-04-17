import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/role.dart';

class RoleProvider extends ChangeNotifier {
  RoleProvider();

  bool _isLoading = false;
  String? _error;
  List<AppRole> _available = const [AppRole.user];
  AppRole _selected = AppRole.user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AppRole> get availableRoles => _available;
  AppRole get selectedRole => _selected;

  Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _available = const [AppRole.user];
      _selected = AppRole.user;
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('users/${user.uid}')
          .get();
      final value = snapshot.value;
      final data = value is Map ? value : null;
      final storedRole = data?['role']?.toString().trim().toLowerCase();
      final role = storedRole == null ? null : AppRoleX.fromKey(storedRole);

      _available = role == null ? const [AppRole.user] : [role];
      _selected = _available.first;

      if (role == null) {
        _error = 'Account setup incomplete';
      }
    } catch (e) {
      _error = e.toString();
      _available = const [AppRole.user];
      _selected = AppRole.user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void select(AppRole role) {
    _selected = role;
    notifyListeners();
  }
}
