import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> deleteUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  static const String _userKey = 'user_data';

  @override
  Future<void> saveUser(UserModel user) async {
    await storage.write(key: _userKey, value: user.toJsonString());
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await storage.read(key: _userKey);
    if (userJson != null) {
      return UserModel.fromJsonString(userJson);
    }
    return null;
  }

  @override
  Future<void> deleteUser() async {
    await storage.delete(key: _userKey);
  }
}