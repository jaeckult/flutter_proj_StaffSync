import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';

class BulkUserCubit extends Cubit<List<User>> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  BulkUserCubit({required this.authRepository, required this.userRepository}) : super(const []);

  Future<void> getEmployees() async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final employees = await userRepository.getEmployees(token);
    emit(employees);
  }

  Future<void> deleteEmployee(int id) async {
    final token = await authRepository.getToken();
    if (token == null) {
      throw Exception('No token found');
    }
    await userRepository.deleteEmployee(id, token);
    emit(state.where((u) => u.id != id).toList());
  }
}
