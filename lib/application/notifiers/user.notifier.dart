import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class UserNotifier extends StateNotifier<User?> {
    final AuthRepository authRepository;
    final UserRepository userRepository;
    UserNotifier(this.authRepository, this.userRepository) : super(null);
    Future<void> loadUserFromStorage() async {
      if (state != null) return;
      final id = await authRepository.getId(); // Await the async method
      if (id == null) {
        print('No user ID found in storage.');
        state = null;
        return;
      }
      final newId = int.parse(id);
      final user = await userRepository.getCurrUser(newId);
      state = user;

       

    }
    

}