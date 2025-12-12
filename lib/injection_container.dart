import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/register.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'core/network/dio_client.dart';
import 'features/tickets/data/datasources/tickets_local_data_source.dart';
import 'features/tickets/data/datasources/tickets_remote_data_source.dart';
import 'features/tickets/data/repositories/tickets_repository_impl.dart';
import 'features/tickets/domain/repositories/tickets_repository.dart';
import 'features/tickets/domain/usecases/get_tickets.dart';
import 'features/tickets/domain/usecases/create_ticket.dart';
import 'features/tickets/domain/usecases/update_ticket_status.dart';
import 'features/tickets/domain/usecases/sync_tickets.dart';
import 'features/tickets/presentation/bloc/tickets_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Firebase Firestore instance
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Tickets local data source
  sl.registerLazySingleton<TicketsLocalDataSource>(
    () => TicketsLocalDataSourceImpl(),
  );

  // Tickets remote data source (Firestore)
  sl.registerLazySingleton<TicketsRemoteDataSource>(
    () => TicketsRemoteDataSourceImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getCurrentUserUseCase: sl(),
      logoutUseCase: sl(),
    ),
  );

  // Dio client
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Tickets local data source
  sl.registerLazySingleton<TicketsLocalDataSource>(
    () => TicketsLocalDataSourceImpl(),
  );

  // Tickets remote data source
  sl.registerLazySingleton<TicketsRemoteDataSource>(
    () => TicketsRemoteDataSourceImpl(firestore: sl()),
  );

  // Tickets repository
  sl.registerLazySingleton<TicketsRepository>(
    () => TicketsRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // Tickets use cases
  sl.registerLazySingleton(() => GetTickets(sl()));
  sl.registerLazySingleton(() => CreateTicket(sl()));
  sl.registerLazySingleton(() => UpdateTicketStatus(sl()));
  sl.registerLazySingleton(() => SyncTickets(sl()));

  // Tickets bloc
  sl.registerFactory(
    () => TicketsBloc(
      getTicketsUseCase: sl(),
      createTicketUseCase: sl(),
      updateTicketStatusUseCase: sl(),
      syncTicketsUseCase: sl(),
    ),
  );
}
