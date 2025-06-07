import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';

class BulkUserNotifier extends StateNotifier<List<User>> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  BulkUserNotifier(this.authRepository, this.userRepository) : super([]);

  Future<List<User>> getEmployees() async {
    try {
      final token = await authRepository.getToken();
      if (token == null) {
        throw Exception('No token found');
      }
      final employees = await userRepository.getEmployees(token);
      state = employees;
      return employees;
    } catch (e) {
      print('Error fetching employees: $e');
      rethrow;
    }
  }

  Future<void> deleteEmployee(int id, String token) async {
    try {
      await userRepository.deleteEmployee(id, token);
      // Remove the deleted employee from the state
      state = state.where((user) => user.id != id).toList();
    } catch (e) {
      print('Error deleting employee: $e');
      rethrow;
    }
  }
}