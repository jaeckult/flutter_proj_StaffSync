
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';
class BulkUserNotifier extends StateNotifier<List<User>> {
  final AuthRepository authRepository;
    final UserRepository userRepository;
    BulkUserNotifier(this.authRepository, this.userRepository) : super([]);

   Future<List<User>> getEmployees() async {
    try {
      final token = await authRepository.getToken();

      final users = await userRepository.getEmployees(token!);
      state = users;
      return users;
    } catch (e) {
      print('Error fetching employees: $e');
      return [];
     
    }
}


}