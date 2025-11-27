import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/api_constants.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
  });
  Future<void> logout();
  Future<UserModel> getCurrentUser(String userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  ///========================= Login ========================= ///
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      //Validacion
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }
      throw const ServerException('Error en el servidor');
    } on DioException catch (e) {
      //Manejo de errores
      final status = e.response?.statusCode;
      if (status == 401) {
        throw const ServerException('Credenciales inválidas');
      }
      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Error desconocido';
        throw ServerException(message);
      }
      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  ///========================= Register ========================= ///
  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }

      throw const ServerException('Error en el servidor');
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Error desconocido';
        throw ServerException(message);
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  ///========================= Logut ========================= ///
  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      debugPrint('Error en logout: ${e.message}');
    } catch (e) {
      debugPrint('Error inesperado en logout: $e');
    }
  }

  ///========================= Get Current User ========================= ///
  @override
  Future<UserModel> getCurrentUser(String userId) async {
    try {
      final response = await dio.get('${ApiConstants.currentUser}/$userId');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }

      throw const ServerException('Error al obtener usuario');
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const CacheException('Master Key inválida');
      }
      if (status == 404) {
        throw const CacheException('Usuario no encontrado');
      }

      throw const ServerException('Error en el servidor');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }
}
