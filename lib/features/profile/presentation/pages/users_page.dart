import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../auth/data/datasources/auth_local_data_source.dart';
import '../../../auth/data/models/user_model.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(AuthLocalDataSourceImpl.usersBoxName);

    return Scaffold(
      appBar: AppBar(title: const Text('Hive Users')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box usersBox, _) {
          if (usersBox.isEmpty) {
            return const Center(child: Text('No users in Hive'));
          }

          final entries = usersBox.toMap().entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final emailKey = entry.key.toString();
              final map = (entry.value as Map).cast<dynamic, dynamic>();

              final user = UserModel.fromMap(map);

              return Card(
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user.email}'),
                      Text('Password: ${user.password}'),
                    ],
                  ),
                  trailing: Text(
                    emailKey == 'admin@qualitysphere.com' ? 'ADMIN' : '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
