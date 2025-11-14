import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../data_sources/auth_local_datasource.dart';
import '../data_sources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  ///========================= Login ========================= ///
  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      await localDataSource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  ///========================= Register ========================= ///
  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
      );

      await localDataSource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  ///========================= Logout ========================= ///
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();

      await localDataSource.deleteUser();

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  ///========================= Get Current User/IsAuth ========================= ///
  @override
  Future<Either<Failure, User>> getCurrentUser() async {

    try {
      debugPrint('[AuthRepository] Buscando usuario en cache...');
      final cachedUser = await localDataSource.getUser();

      if (cachedUser != null) {
        debugPrint(
          '[AuthRepository] Usuario encontrado en cache: ${cachedUser.email}',
        );

        // Validar con el servidor que el usuario aún existe
        try {
          debugPrint('[AuthRepository] Validando usuario con servidor...');
          final userModel = await remoteDataSource.getCurrentUser(
            cachedUser.id,
          );
          await localDataSource.saveUser(userModel);
          debugPrint('[AuthRepository] Usuario validado con servidor');
          return Right(userModel.toEntity());
        } catch (e) {
          debugPrint('[AuthRepository] Error validando con servidor: $e');
          debugPrint('[AuthRepository] Usando cache como fallback');
          return Right(cachedUser.toEntity());
        }
      }

      debugPrint('[AuthRepository] No hay usuario en cache');
      return const Left(CacheFailure('No hay usuario autenticado'));
    } on CacheException catch (e) {
      debugPrint('[AuthRepository] CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      debugPrint('[AuthRepository] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      debugPrint('[AuthRepository] Error inesperado: $e');
      return Left(ServerFailure('Error al obtener usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    debugPrint('[AuthRepository] Verificando autenticación');
    final cachedUser = await localDataSource.getUser();
    final isAuth = cachedUser != null;
    debugPrint('[AuthRepository] isAuthenticated: $isAuth');
    return Right(isAuth);
  }
}
