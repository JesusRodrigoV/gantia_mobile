import 'package:flutter/foundation.dart';
import 'api_service.dart';

mixin ApiServiceMixin on ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<T?> execute<T>(
    Future<T?> Function() call, {
    String unauthorizedMessage = 'No autorizado',
    String networkMessage = 'No se pudo conectar al servidor',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await call();
      _isLoading = false;
      notifyListeners();
      return result;
    } on UnauthorizedException {
      _error = unauthorizedMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    } on NetworkException {
      _error = networkMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
