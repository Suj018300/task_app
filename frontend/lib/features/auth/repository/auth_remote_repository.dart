import 'dart:convert';
import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/sp_services.dart';
import 'package:frontend/features/models/user_model.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';

import 'package:http/http.dart' as http;

class AuthRemoteRepository {
  final spServices = SpServices();
  final authLocalRepository = AuthLocalRepository();

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }

      return UserModel.fromMap(jsonDecode(res.body));
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }
      return UserModel.fromMap(jsonDecode(res.body));
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await spServices.getToken();
      if (token == null) {
        throw "No token found";
      }
      final res = await http.post(
        Uri.parse("${Constants.backendUri}/auth/isTokenValid"),
        headers: {"Content-Type": "application/json", "x-auth-token": token},
      );
      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse("${Constants.backendUri}/auth"),
        headers: {"Content-Type": "application/json", "x-auth-token": token},
      );
      if (userResponse.statusCode != 200) {
        throw jsonDecode(userResponse.body)['error'];
      }
      return UserModel.fromMap(jsonDecode(res.body));
    } catch (e) {
      final user = await authLocalRepository.getUser();
      return user;
    }
  }
}
