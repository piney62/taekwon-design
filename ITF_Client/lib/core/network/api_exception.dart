sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network unavailable']);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Invalid API key']);
}

class RateLimitException extends ApiException {
  const RateLimitException([super.message = 'Rate limit exceeded']);
}

class ServerException extends ApiException {
  const ServerException(super.message);
}

class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);
}
