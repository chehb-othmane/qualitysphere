import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'injection_container.dart' as di;
import 'features/auth/data/datasources/auth_local_data_source.dart';

import 'features/tickets/data/datasources/tickets_local_data_source.dart';

Future<void> _seedAdminUser() async {
  final box = Hive.box(AuthLocalDataSourceImpl.usersBoxName);

  const adminEmail = 'admin@qualitysphere.com';

  if (!box.containsKey(adminEmail)) {
    await box.put(adminEmail, {
      'id': 'admin',
      'name': 'Admin User',
      'email': adminEmail,
      'password': 'admin123', // juste pour test / démo
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Open users box
  await Hive.openBox(AuthLocalDataSourceImpl.usersBoxName);
  await Hive.openBox(TicketsLocalDataSourceImpl.ticketsBoxName);

  await _seedAdminUser();

  await di.init();

  runApp(const QualitySphereApp());
}
