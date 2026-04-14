import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_exceptions.dart';
import '../models/role.dart';
import '../services/flask_api_service.dart';

class RoleProvider extends ChangeNotifier {
  final FlaskApiService _api;

  RoleProvider(this._api);

  bool _isLoading = false;
  String? _error;
  List<AppRole> _available = const [AppRole.user];
  AppRole _selected = AppRole.user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AppRole> get availableRoles => _available;
  AppRole get selectedRole => _selected;

  Future<void> refresh() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || email.isEmpty) {
      _available = const [AppRole.user];
      _selected = AppRole.user;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.fetchRoles(email);
      _available = result.isEmpty ? const [AppRole.user] : result;
      if (!_available.contains(_selected)) {
        _selected = _available.first;
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
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

