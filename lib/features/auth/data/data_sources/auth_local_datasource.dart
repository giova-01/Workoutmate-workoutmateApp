import 'package:flutter/foundation.dart';
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
    debugPrint('[LocalDataSource] Guardando usuario: ${user.email}');
    await storage.write(key: _userKey, value: user.toJsonString());
    debugPrint('[LocalDataSource] Usuario guardado');
  }

  @override
  Future<UserModel?> getUser() async {
    debugPrint('[LocalDataSource] Buscando usuario en storage');
    final userJson = await storage.read(key: _userKey);
    if (userJson != null) {
      debugPrint('[LocalDataSource] Usuario encontrado en storage');
      return UserModel.fromJsonString(userJson);
    }
    debugPrint('[LocalDataSource] No hay usuario en storage');
    return null;
  }

  @override
  Future<void> deleteUser() async {
    debugPrint('[LocalDataSource] Eliminando usuario del storage');
    await storage.delete(key: _userKey);
    debugPrint('[LocalDataSource] Usuario eliminado');
  }
}