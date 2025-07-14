import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:staffsync/domain/model/notification.model.dart';
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/domain/repositories/auth.repository.dart';
import 'package:staffsync/domain/repositories/user.repository.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class UserCubit extends Cubit<User?> {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  final SecureStorage secureStorage = SecureStorage.instance;

  UserCubit({required this.authRepository, required this.userRepository}) : super(null);

  Future<void> loadUserFromStorage() async {
    try {
      final id = await authRepository.getId();
      final endpoint = await secureStorage.read("endpoint");
      if (id == null) {
        emit(null);
        return;
      }
      if (endpoint == null) {
        throw Exception('Endpoint not configured');
      }
      final user = await userRepository.getCurrUser(int.parse(id), endpoint);
      emit(user);
    } catch (e) {
      emit(null);
    }
  }

  Future<void> editProfile(int id, String fullName, String designation, String email, String employmentType, String? profilePicture) async {
    await userRepository.editProfile(id, fullName, designation, email, employmentType, profilePicture);
    final endpoint = await secureStorage.read("endpoint");
    if (endpoint != null) {
      final updated = await userRepository.getCurrUser(id, endpoint);
      emit(updated);
    }
  }

  Future<List<NotificationModel>> getNotificationMessage() async {
    return await userRepository.getNotificationMessage();
  }

  Future<void> deleteNotification() async {
    await userRepository.deleteNotification();
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final userId = await authRepository.getId();
    final token = await secureStorage.read("token");
    final endpoint = await secureStorage.read("endpoint");

    if (userId == null) {
      throw Exception('User ID not found');
    }
    if (token == null) {
      throw Exception('Authentication token not found');
    }
    if (endpoint == null) {
      throw Exception('Endpoint not configured');
    }

    await userRepository.changePassword(
      userId: int.parse(userId),
      oldPassword: oldPassword,
      newPassword: newPassword,
      token: token,
      endpoint: endpoint,
    );
  }
}
