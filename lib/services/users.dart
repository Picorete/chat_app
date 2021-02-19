import 'package:chat_app/global/enviroments.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/models/users_response.dart';
import 'package:chat_app/services/auth.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<List<User>> getUsers() async {
    try {
      final resp = await http.get('${Enviroment.apiUrl}/users', headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken()
      });

      final usersResponse = userResponseFromJson(resp.body);

      return usersResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}
