// Base exception class
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message);
}

// API related exceptions
class ApiException extends AppException {
  const ApiException(super.message);
}

// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message);
}

// Server exceptions
class ServerException extends AppException {
  const ServerException(super.message);
}
