import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:staffsync/infrastructure/storage/storage.dart';

class RemoteDataSource {
  final http.Client httpClient;

  RemoteDataSource(this.httpClient);

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.instance.read("token");
    return {"Authorization": "Bearer $token"};
  }

  Future<Map<String, dynamic>> logIn(
    String endpoint,
    String username,
    String password,
  ) async {
    final response = await httpClient.post(
      Uri.parse('http://$endpoint:3000/api/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Invalid credentials!');
    }
  }

  Future<void> signUpCustomer(
    String endpoint,
    String email,
    String password,
    String phone,
    String fullName,
  ) async {
    final response = await httpClient.post(
      Uri.parse('http://$endpoint:3000/api/signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "role": "customer",
        "email": email,
        "password": password,
        "phone": phone,
        "fullName": fullName,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Error signing up');
    }
  }

  Future<void> signUpTechnician(
    String endpoint,
    String email,
    String password,
    String phone,
    String fullName,
    String skills,
    String experience,
    String educationLevel,
    String availableLocation,
    String additionalBio,
  ) async {
    final response = await httpClient.post(
      Uri.parse('http://$endpoint:9000/trader/signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "role": "technician",
        "email": email,
        "password": password,
        "phone": phone,
        "fullName": fullName,
        "skills": skills,
        "experience": experience,
        "educationLevel": educationLevel,
        "availableLocation": availableLocation,
        "additionalBio": additionalBio,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Error signing up');
    }
  }

  Future<void> deleteAccount(String endpoint, String id, String role) async {
    final headers = await _getHeaders();

    final response = await httpClient.delete(
      Uri.parse('http://$endpoint:9000/trader/delete-profile/$id?role=$role'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Error deleting account');
    }
  }
}
