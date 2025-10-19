class ApiConstants {
  static const String baseUrl = '';

  //Auth endpoints
  static const String masterKey = '';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String currentUser = '/auth/me';

  //Headers
  static const String masterKeyHeader = 'X-Master-Key';
  static const String authHeader = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
}
