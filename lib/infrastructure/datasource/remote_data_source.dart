import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:staffsync/domain/model/user.model.dart';
import 'package:staffsync/infrastructure/storage/storage.dart';

class RemoteDataSource {
  final http.Client httpClient;

  RemoteDataSource(this.httpClient);

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.instance.read("token");
    return {"Authorization": "Bearer $token"};
  }

  Future<Map<String, dynamic>> logIn(
    
    String username,
    String password,
  ) async {
    final response = await httpClient.post(
      Uri.parse('http://localhost:3000/api/login'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}),
    );
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
   
      if (data["role"] == null || data["token"] == null || data["id"] == null) {
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
    
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
    
      
      if (data["role"] == null) {
        throw Exception('Invalid response from server: missing role field');
      }
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error["message"] ?? 'Signup failed!');
    }
  }

    Future<Map<String, dynamic>> getCurrUser(int id) async {
       final response = await httpClient.get(
      Uri.parse('http://localhost:3000/api/users/${id}'), headers: {"Content-Type": "application/json"});
      if( response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }
      else {
     
        final error = jsonDecode(response.body);
        throw Exception(error["message"] ?? 'Signup failed!');
      }
      


    }
    

  Future<void> checkIn(String token) async {
  final url = Uri.parse('http://localhost:3000/api/attendance/check-in');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 201) {
    final data = json.decode(response.body);
    
  } else {
    final error = json.decode(response.body);
    throw Exception('Check-in failed: ${error['error']}');
  }
}

  Future<List<User>> getUsers(String token) async {
  final url = Uri.parse('http://localhost:3000/api/users/employees/');

  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;
    
    return data.map((json) => User.fromJson(json)).toList();
  } else {
    final error = json.decode(response.body);
    throw Exception('Failed to retrieve');
  }
}Future<void> logout(String? token) async {
  final url = Uri.parse('http://localhost:3000/api/logout/');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      print("Successfully logged out.");
    } else {
      print("Logout failed. Status: ${response.statusCode}, Body: ${response.body}");
    }
  } catch (e) {
    print("Error occurred during logout: $e");
  }
}
}
