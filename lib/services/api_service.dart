import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abgbale/models/user.dart';
import 'package:abgbale/models/contact.dart';
import 'package:abgbale/models/social_media.dart';
import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/utils/token_manager.dart'; // Import TokenManager

class ApiService {
  static const String _baseUrl = 'http://localhost:8080/agbale_api_php'; // Your PHP API base URL

  // --- Authentication ---
  Future<Map<String, dynamic>> registerUser(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'nom_complet': fullName,
        'email': email,
        'mot_de_passe': password,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'mot_de_passe': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        // Extract session cookie and save it as the "token"
        String? rawCookie = response.headers['set-cookie'];
        if (rawCookie != null) {
          int index = rawCookie.indexOf(';');
          String cookie = (index == -1) ? rawCookie : rawCookie.substring(0, index);
          await TokenManager.saveToken(cookie);
          if (responseBody['user_id'] != null) {
            await TokenManager.saveUserId(responseBody['user_id']);
          }
          print('Session cookie saved as token: $cookie');
        }
      }
      return responseBody;
    } else {
      return {'success': false, 'message': 'Failed to login: ${response.statusCode}'};
    }
  }

  Future<Map<String, dynamic>> logoutUser() async {
    final String? cookie = await TokenManager.getToken(); // Get the stored session cookie
    if (cookie == null) {
      return {'success': true, 'message': 'Already logged out (no token).'};
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success']) {
        await TokenManager.deleteToken(); // Clear the token on successful logout
        await TokenManager.deleteUserId();
      }
      return responseBody;
    } else {
      return {'success': false, 'message': 'Failed to logout: ${response.statusCode}'};
    }
  }

  Future<User?> fetchUserData() async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] && responseBody['user'] != null) {
        return User.fromJson(responseBody['user']);
      }
    }
    return null;
  }

  // --- Contacts ---
  Future<List<Contact>> fetchContacts() async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/contacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] && responseBody['contacts'] != null) {
        return (responseBody['contacts'] as List)
            .map((json) => Contact.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  Future<Contact?> createContact(Contact contact) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/contacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] && responseBody['id_contact'] != null) {
        // For simplicity, we'll return a dummy contact with the new ID
        // In a real app, you might refetch or get more details from the API response
        return Contact(
          id: responseBody['id_contact'],
          userId: await TokenManager.getUserId() ?? 0,
          contactName: contact.contactName,
          importanceNote: contact.importanceNote,
          dateAdded: DateTime.now(),
          email: contact.email,
          number: contact.number,
        );
      }
    }
    return null;
  }

  Future<bool> updateContact(Contact contact) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/contacts/${contact.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(contact.toJson()),
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }

  Future<bool> deleteContact(int contactId) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/contacts/$contactId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }

  // --- Social Medias ---
  Future<List<SocialMedia>> fetchSocialMediasForContact(int contactId) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/social_medias?contact_id=$contactId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] && responseBody['social_medias'] != null) {
        return (responseBody['social_medias'] as List)
            .map((json) => SocialMedia.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  Future<SocialMedia?> createSocialMedia(SocialMedia socialMedia) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/social_medias'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(socialMedia.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] && responseBody['id_social'] != null) {
        return SocialMedia(
          id: responseBody['id_social'],
          contactId: socialMedia.contactId,
          platform: socialMedia.platform,
          link: socialMedia.link,
        );
      }
    }
    return null;
  }

  Future<bool> updateSocialMedia(SocialMedia socialMedia) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/social_medias/${socialMedia.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(socialMedia.toJson()),
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }

  Future<bool> deleteSocialMedia(int socialMediaId) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/social_medias/$socialMediaId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }

  // --- Notes/Todos ---
  Future<List<NoteTodo>> fetchNotesTodos() async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/notes_todos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] && responseBody['notes_todos'] != null) {
        return (responseBody['notes_todos'] as List)
            .map((json) => NoteTodo.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  Future<NoteTodo?> createNoteTodo(NoteTodo noteTodo, int userId) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/notes_todos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(noteTodo.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      if (responseBody['success'] && responseBody['id_note'] != null) {
        return NoteTodo(
          id: responseBody['id_note'],
          userId: await TokenManager.getUserId() ?? 0, // Get userId from TokenManager
          title: noteTodo.title,
          type: noteTodo.type,
          status: noteTodo.status,
          creationDate: DateTime.now(),
          content: noteTodo.content,
          dueDate: noteTodo.dueDate,
        );
      }
    }
    return null;
  }

  Future<bool> updateNoteTodo(NoteTodo noteTodo) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/notes_todos/${noteTodo.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(noteTodo.toJson()),
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }

  Future<bool> deleteNoteTodo(int noteTodoId) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/notes_todos/$noteTodoId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    return response.statusCode == 200 && jsonDecode(response.body)['success'];
  }
}