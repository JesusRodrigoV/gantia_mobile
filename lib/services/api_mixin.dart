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
    debugPrint('[API_MIXIN] execute: start');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await call();
      debugPrint('[API_MIXIN] execute: success, result isNull=${result == null}');
      _isLoading = false;
      _isLoading = false;
      notifyListeners();
      return result;
    } on UnauthorizedException {
      debugPrint('[API_MIXIN] execute: UnauthorizedException');
      _error = unauthorizedMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    } on NetworkException {
      debugPrint('[API_MIXIN] execute: NetworkException');
      _error = networkMessage;
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e, st) {
      debugPrint('[API_MIXIN] execute caught: $e');
      debugPrint('[API_MIXIN] stack: $st');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
