abstract class AuthRepository {
  Future<String> logIn(String email, String password);
  Future<String> signup(
    String username,
    String password,
    String email,
    String fullname,
    String gender,
    String employmentType,
    String designation,
    String dateOfBirth,
    String role,
  );
  Future<String?> getToken();
  Future<String?> getRole();
  Future<void> clearData();
}
