class ApiConstants {
  static const String baseUrl = 'http://192.168.0.16/workoutmate';

  //Auth endpoints
  static const String masterKey = 'workoutmate_masterkey_XD';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String currentUser = '/auth/me';

  //Headers
  static const String masterKeyHeader = 'master-key';
  static const String authHeader = 'Authorization';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
}
