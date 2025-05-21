import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class UserNotifier extends StateNotifier<User?> {
    final AuthRepository authRepository;
    UserNotifier(this.authRepository) : super(null);
    Future<void> loadUserFromStorage() async {
        // final id = await secureStorage.read(key:'id');
        // final username = await secureStorage.read(key:'username');
        // final role = await secureStorage.read(key:'role');
        final id = await authRepository.getId();
        
        final role = await authRepository.getRole();
        if (id != null && role != null) {
            int newid = int.parse(id);
            state = User(id:newid, role:role);
        }

    }

}