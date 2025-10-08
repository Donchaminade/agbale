import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abgbale/models/user.dart';
import 'package:abgbale/models/contact.dart';
import 'package:abgbale/models/mynet.dart';
import 'package:abgbale/models/social_media.dart';
import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/utils/token_manager.dart'; // Import TokenManager

class ApiService {
  static const String _baseUrl =
      'http://192.168.1.86/agbale_api_php'; // Your PHP API base URL

  // --- Authentication ---
  Future<Map<String, dynamic>> registerUser(
    String fullName,
    String email,
    String password,
  ) async {
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
          String cookie = (index == -1)
              ? rawCookie
              : rawCookie.substring(0, index);
          await TokenManager.saveToken(cookie);
          if (responseBody['user_id'] != null) {
            await TokenManager.saveUserId(responseBody['user_id']);
          }
          print('Session cookie saved as token: $cookie');
        }
      }
      return responseBody;
    } else {
      return {
        'success': false,
        'message': 'Failed to login: ${response.statusCode}',
      };
    }
  }

  Future<Map<String, dynamic>> logoutUser() async {
    final String? cookie =
        await TokenManager.getToken(); // Get the stored session cookie
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
      return {
        'success': false,
        'message': 'Failed to logout: ${response.statusCode}',
      };
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

  // --- OTP Simulation ---
  Future<Map<String, dynamic>> requestOtp(String email) async {
    // This simulates making a request to your backend to send an OTP.
    // In a real app, this would trigger an email or SMS.
    print('Requesting OTP for $email (simulated).');
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulate network latency
    return {'success': true, 'message': 'OTP sent successfully (simulated).'};
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    // This simulates verifying the OTP with your backend.
    print('Verifying OTP $otp for $email (simulated).');
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulate network latency
    if (otp == '123456') {
      return {
        'success': true,
        'message': 'OTP verified successfully (simulated).',
      };
    } else {
      return {'success': false, 'message': 'Invalid OTP (simulated).'};
    }
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
      print('API Response Body for fetchContacts: ${response.body}'); // Debug print
      try {
        final cleanJson = _extractJson(response.body);
        print('Cleaned JSON for fetchContacts: $cleanJson'); // Debug print
        final Map<String, dynamic> responseBody = jsonDecode(cleanJson);
        print('Decoded Response Body for fetchContacts: $responseBody'); // Debug print
        if (responseBody['success'] && responseBody['contacts'] != null) {
          final contacts = (responseBody['contacts'] as List)
              .map((json) => Contact.fromJson(json))
              .toList();
          print('Fetched contacts count: ${contacts.length}'); // Debug print
          return contacts;
        }
      } catch (e) {
        print('Error decoding JSON for fetchContacts: $e');
        // Return empty list if JSON is malformed
        return [];
      }
    }
    return [];
  }

  Future<Contact?> createContact(Contact contact) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return null;

    final requestBody = jsonEncode(contact.toJson());
    print('Create Contact Body: $requestBody'); // Debug print

    final response = await http.post(
      Uri.parse('$_baseUrl/contacts'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: requestBody,
    );

    print('Create Contact Response: ${response.statusCode} ${response.body}'); // Debug print

    if (response.statusCode == 200) {
      try {
        final cleanJson = _extractJson(response.body);
        final Map<String, dynamic> responseBody = jsonDecode(cleanJson);
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
      } catch (e) {
        print('Error decoding JSON for createContact: $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> updateContact(Contact contact) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final requestBody = jsonEncode(contact.toJson());
    print('Update Contact Body: $requestBody'); // Debug print

    final response = await http.put(
      Uri.parse('$_baseUrl/contacts/${contact.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: requestBody,
    );

    print('Update Contact Response: ${response.statusCode} ${response.body}'); // Debug print

    if (response.statusCode == 200) {
      try {
        final cleanJson = _extractJson(response.body);
        return jsonDecode(cleanJson)['success'];
      } catch (e) {
        print('Error decoding JSON for updateContact: $e');
        return false;
      }
    }
    return false;
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

    print('Delete Contact Response: ${response.statusCode} ${response.body}'); // Debug print

    if (response.statusCode == 200) {
      try {
        final cleanJson = _extractJson(response.body);
        return jsonDecode(cleanJson)['success'];
      } catch (e) {
        print('Error decoding JSON for deleteContact: $e');
        return false;
      }
    }
    return false;
  }

  // --- MyNets ---
  Future<List<MyNet>> fetchMyNets() async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/mynets'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      try {
        final String cleanJson = _extractJson(response.body);
        final Map<String, dynamic> responseBody = jsonDecode(cleanJson);

        if (responseBody['success'] == true && responseBody['mynets'] != null) {
          final List<dynamic> mynetsData = responseBody['mynets'];
          final List<MyNet> mynetsList = [];
          for (final item in mynetsData) {
            mynetsList.add(MyNet.fromJson(item as Map<String, dynamic>));
          }
          return mynetsList;
        }
      } catch (e) {
        print('Error decoding JSON for fetchMyNets: $e');
        return [];
      }
    }
    return [];
  }

  Future<MyNet?> createMyNet(MyNet myNet) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return null;

    final response = await http.post(
      Uri.parse('$_baseUrl/mynets'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(myNet.toJson()),
    );

    if (response.statusCode == 201) {
      try {
        final String cleanJson = _extractJson(response.body);
        final Map<String, dynamic> responseBody = jsonDecode(cleanJson);
        if (responseBody['success'] == true && responseBody['id_mynet'] != null) {
          return myNet.copyWith(id: responseBody['id_mynet']);
        }
      } catch (e) {
        print('Error decoding JSON for createMyNet: $e');
        return null;
      }
    }
    return null;
  }

  Future<bool> updateMyNet(MyNet myNet) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/mynets/${myNet.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
      body: jsonEncode(myNet.toJson()),
    );

    if (response.statusCode == 200) {
      try {
        final String cleanJson = _extractJson(response.body);
        final Map<String, dynamic> responseBody = jsonDecode(cleanJson);
        return responseBody['success'] ?? false;
      } catch (e) {
        print('Error decoding JSON for updateMyNet: $e');
        return false;
      }
    }
    return false;
  }

  Future<bool> deleteMyNet(int myNetId) async {
    final String? cookie = await TokenManager.getToken();
    if (cookie == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/mynets/$myNetId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Cookie': cookie,
      },
    );

    if (response.statusCode == 200) {
      try {
        final String cleanJson = _extractJson(response.body);
        final Map<String, dynamic> responseBody = jsonDecode(cleanJson);
        return responseBody['success'] ?? false;
      } catch (e) {
        print('Error decoding JSON for deleteMyNet: $e');
        return false;
      }
    }
    return false;
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
      print('API Response Body for fetchNotesTodos: ${response.body}'); // Debug print
      try {
        final cleanJson = _extractJson(response.body);
        print('Cleaned JSON for fetchNotesTodos: $cleanJson'); // Debug print
        final Map<String, dynamic> responseBody = jsonDecode(cleanJson);
        print('Decoded Response Body for fetchNotesTodos: $responseBody'); // Debug print
        if (responseBody['success'] && responseBody['notes_todos'] != null) {
          final notesTodos = (responseBody['notes_todos'] as List)
              .map((json) => NoteTodo.fromJson(json))
              .toList();
          print('Fetched notes/todos count: ${notesTodos.length}'); // Debug print
          return notesTodos;
        }
      } catch (e) {
        print('Error decoding JSON for fetchNotesTodos: $e');
        // Return empty list if JSON is malformed
        return [];
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
          userId:
              await TokenManager.getUserId() ??
              0, // Get userId from TokenManager
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

  // --- Dashboard ---
  Future<Map<String, dynamic>> getDashboardData() async {
    // Use Future.wait to fetch user data and stats in parallel for efficiency
    final results = await Future.wait([
      fetchUserData(),
      getDashboardStats(),
    ]);

    final user = results[0] as User?;
    final stats = results[1] as Map<String, int>;

    if (user == null) {
      print('User data is null in getDashboardData.'); // Debug print
      throw Exception('Failed to load user data for dashboard.');
    }

    print('User data in getDashboardData: ${user.toJson()}'); // Debug print
    print('Stats data in getDashboardData: $stats'); // Debug print

    return {
      'user': user,
      'stats': stats,
    };
  }

  Future<Map<String, int>> getDashboardStats() async {
    // In a real-world scenario, the backend should provide a dedicated endpoint for this.
    // Here, we simulate it by fetching all items and getting their length.
    try {
      final contacts = await fetchContacts();
      final notes = await fetchNotesTodos();

      // You can add more stats here as needed
      final pendingTodos = notes.where((item) => item.type == 'todo' && item.status != 'terminé').length;

      return {
        'totalContacts': contacts.length,
        'activeNotes': notes.length,
        'pendingTodos': pendingTodos,
      };
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return {
        'totalContacts': 0,
        'activeNotes': 0,
        'pendingTodos': 0,
      };
    }
  }

  // Helper function to extract valid JSON from a malformed response
  String _extractJson(String malformedJson) {
    final startIndex = malformedJson.indexOf('{');
    final endIndex = malformedJson.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return malformedJson.substring(startIndex, endIndex + 1);
    }
    // If valid JSON cannot be extracted, return an empty JSON object or throw an error
    return '{}'; 
  }
}
