import 'package:dartz/dartz.dart';
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

      await localDataSource.saveUser(userModel); // Guardado de usuario en local

      return Right(userModel.toEntity());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on NetworkException catch (error) {
      return Left(NetworkFailure(error.message));
    }
    catch (e) {
      return Left(ServerFailure('[AuthRepository] - Error inesperado: $e'));
    }
  }

  ///========================= Register ========================= ///
  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final userModel = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      await localDataSource.saveUser(userModel);

      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[AuthRepository] - Error inesperado: $e'));
    }
  }

  ///========================= Logout ========================= ///
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.deleteUser();
      return const Right(null);
    } catch(e) {
      return Left(ServerFailure('[AuthRepository] - Error inesperado: $e'));
    }
  }

  ///========================= Get Current User/IsAuth ========================= ///
  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Primero intentar obtener del cache
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        // Validar con el servidor que el usuario aún existe
        try {
          final userModel = await remoteDataSource.getCurrentUser(cachedUser.id);
          await localDataSource.saveUser(userModel);
          return Right(userModel.toEntity());
        } catch (e) {
          // Si falla la validación, usar el cache
          return Right(cachedUser.toEntity());
        }
      }

      // Si no hay cache, no hay usuario autenticado
      return const Left(CacheFailure('[AuthRepository] - No hay usuario autenticado'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[AuthRepository] - Error al obtener usuario: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    final cachedUser = await localDataSource.getUser();
    return Right(cachedUser != null);
  }
}