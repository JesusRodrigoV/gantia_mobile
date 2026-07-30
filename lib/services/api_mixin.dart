import 'package:flutter/foundation.dart';
import '../utils/error_message_mapper.dart';
import 'api_service.dart';

mixin ApiServiceMixin on ChangeNotifier {
  bool _disposed = false;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<T?> execute<T>(
    Future<T?> Function() call, {
    String unauthorizedMessage = 'No autorizado',
    String networkMessage = 'No se pudo conectar al servidor',
  }) async {
    if (_disposed) return null;
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
    } catch (e, stack) {
      debugPrint('[API] $e');
      debugPrint('[API] $stack');
      _error = mapErrorToMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
