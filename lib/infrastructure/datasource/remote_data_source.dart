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
    
    print('Login Response Status: ${response.statusCode}');
    print('Login Response Body: ${response.body}');
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('Decoded Data: $data');
      print('Role Type: ${data["role"].runtimeType}');
      print('UserId Type: ${data["userId"].runtimeType}');
      
      if (data["role"] == null || data["access_token"] == null || data["userId"] == null) {
        throw Exception('Invalid response from server: missing required fields');
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? 'Invalid credentials!');
    }
  }

  Future<Map<String, dynamic>> signup(
    String endpoint,
    String username,
    String password,
    String email,
    String fullName,
    String gender,
    String employmentType,
    String designation,
    String dateOfBirth,
    String role,
  ) async {
    final response = await httpClient.post(
      Uri.parse('http://localhost:3000/api/signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": username,
        "password": password,
        "email": email,
        "fullName": fullName,
        "gender": gender,
        "employmentType": employmentType,
        "designation": designation,
        "dateOfBirth": dateOfBirth,
        "role": role,
      }),
    );
    
    print('Signup Response Status: ${response.statusCode}');
    print('Signup Response Body: ${response.body}');
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print('Decoded Data: $data');
      print('Role Type: ${data["role"].runtimeType}');
      
      if (data["role"] == null) {
        throw Exception('Invalid response from server: missing role field');
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? 'Signup failed!');
    }
  }
}
