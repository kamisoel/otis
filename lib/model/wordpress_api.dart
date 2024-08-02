import 'dart:io';
import 'package:meta/meta.dart';

import './model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// constants
const URL_JWT_BASE = '/wp-json/jwt-auth/v1';
const URL_WP_BASE = '/wp-json/wp/v2';
const URL_ACF_BASE = '/wp-json/acf/v3';

const URL_REGISTER_USER = '$URL_WP_BASE/users/register';
const URL_JWT_TOKEN = '$URL_JWT_BASE/token';
const URL_JWT_TOKEN_VALIDATE = '$URL_JWT_BASE/token/validate';

const AUTH_STORE_KEY = "OTIS_AUTH_TOKEN";
const LL_STORE_KEY = "OTIS_LAST_LOGIN";

class WordpressApi {
  String _baseUrl;
  FlutterSecureStorage _keyStore;

  WordpressApi({@required String baseUrl}) {
    this._baseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    this._keyStore = FlutterSecureStorage();
  }

  Future<JWTResponse> authenticate(
      {@required String username, @required String password}) async {
    final uri = Uri.https(_baseUrl, URL_JWT_TOKEN);
    final body = {
      'username': username,
      'password': password,
    };

    final response = await http.post(
      uri,
      body: body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      JWTResponse authResponse =
          JWTResponse.fromJson(json.decode(response.body));
      //_urlHeader['Authorization'] = 'Bearer ${authResponse.token}';
      return authResponse;
    } else {
      throw new http.ClientException(
          "Authentication failed! Error ${response.statusCode}");
    }
  }

  Future<bool> hasValidToken() async {
    String token = await _keyStore.read(key: AUTH_STORE_KEY);
    if(token == null) return false;
    final response = await http.post(Uri.https(_baseUrl, URL_JWT_TOKEN_VALIDATE),
        headers: {'Authorization': 'Bearer $token'});
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<bool> hasToken() async {
    return await _keyStore.read(key: AUTH_STORE_KEY) != null;
  }

  Future<void> persistToken(String token) async {
    await _keyStore.write(key: AUTH_STORE_KEY, value: token);
  }

  Future<void> deleteToken() async {
    await _keyStore.delete(key: AUTH_STORE_KEY);
  }

  Future<String> getLastLogin() async {
    return await _keyStore.read(key: LL_STORE_KEY);
  }

  Future<void> saveLogin(String username) async {
    return await _keyStore.write(key: LL_STORE_KEY, value: username);
  }

  Future<Map<String, String>> get _urlHeader async {
    String token = await _keyStore.read(key: AUTH_STORE_KEY);
    return {'Authorization': (token != null) ? 'Bearer $token' : ''};
  }

  Future<String> signUrl(String url) async {
    final token = await _keyStore.read(key: AUTH_STORE_KEY);
    if(token == null) throw Exception("No Token found!");
    return "$url?token=$token";
  }

  Future<List<Treatment>> loadTreatmentsOf(User user) async {
    final uri = Uri.https(_baseUrl, '$URL_WP_BASE/patienten', {'slug': user.slug});
    final response = await http.get(uri, headers: await _urlHeader);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(response.body) as List;
      if (list.isEmpty) return [];
      final json = list[0] as Map;
      final acf = json['acf'] as Map;
      if (acf.isEmpty || acf['behandlung'] == false) return [];
      final treatments = acf['behandlung'] as List;
      if(treatments == null) return [];
      return treatments.map((t) => Treatment.fromJson(t)).toList();
    } else {
      return [];
    }
  }

  Future<List<Treatment>> updateTreatments(User user, List<Treatment> treatments) async {
    final patientId = await getPatientId(user.slug);
    final uri = Uri.https(_baseUrl, '$URL_WP_BASE/patienten/$patientId');

    final treatmentJson = treatments.map((x) => x.toJson()).toList();

    final fieldsJson = Map<String, dynamic>();
    fieldsJson['behandlung'] = treatmentJson;

    final jsonMap = Map<String, dynamic>();
    jsonMap['title'] = '${user.slug}';
    jsonMap['fields'] = fieldsJson;

    final body = jsonEncode(jsonMap);
    final headers = await _urlHeader;
    headers["Content-Type"] = "application/json";

    final response = await http.post(uri, body: body, headers: headers);
    if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map;
        final acf = json['acf'] as Map;
        if (acf.isEmpty) return [];
        final treatments = acf['behandlung'] as List;
        return treatments.map((t) => Treatment.fromJson(t)).toList();
    } else {
      throw Exception("Error ${response.statusCode} while updating treatment: ${response.body}!");
    }
  }

  //POST https://www.physio-mz.de/wp-json/wp/v2/media
  //HEADER: Content-Disposition: form-data; filename="example.jpg"
  //POSTFIELDS: $file
  Future<Attachment> uploadAttachment(File file) async {
    final uri = Uri.https(_baseUrl, "$URL_WP_BASE/media");
    final _filename = file.path.split("/").last;
    final _contentType = _getContentType(file);

    var request = http.MultipartRequest("POST", uri);
    request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: _filename, // TODO better filename
        contentType: _contentType,
    ));
    request.headers['Authorization'] = (await _urlHeader)['Authorization'];

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final guid = responseData['guid'] as Map;

        final _id = responseData['id'];
        final _url = guid['raw'];
        final _title = _filename.split('\.').first;
        final _type = _contentType == MediaType('application', 'pdf')? AttachmentType.pdf : AttachmentType.video;

        return Attachment(type: _type, id: _id, title: _title, url: _url);
      } else {
        throw http.ClientException("Error ${response.statusCode}: ${response.reasonPhrase}");
      }
    } catch (e) {
      print(e);
      return Attachment.empty();
    }
  }

  MediaType _getContentType(File file) {
    if(file.path.endsWith("pdf")) {
      return MediaType('application', 'pdf');
    } else if (file.path.endsWith("mp4")) {
      return MediaType('video', 'mp4');
    } else {
      throw Exception("Unsupported MediaType");
    }
  }

  Future<User> addUser(
      String firstName, String lastName, String email, String password) async {

    final userName = '$firstName.$lastName';
    final userJSON = {
      'first_name': firstName,
      'last_name': lastName,
      'username': userName,
      'email': email,
      'password': password,
    };

    final _uri = Uri.https(_baseUrl, URL_REGISTER_USER);
    final response = await http.post(_uri, headers: await _urlHeader, body: userJSON);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return User.fromJson(json);
    } else {
      throw Exception("Error ${response.statusCode} while adding user: ${response.body}!");
    }
  }

  Future<int> getUserId(String slug) async {
    return loadUser(slug).then((x) => x.id);
  }

  Future<int> getPatientId(String slug) async {
    final uri = Uri.https(_baseUrl, '$URL_WP_BASE/patienten', {'slug': slug});
    final response = await http.get(uri, headers: await _urlHeader);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = jsonDecode(response.body) as List;
      if (list.isEmpty) return -1;
      final json = list[0] as Map;
      return json['id'];
    } else {
      throw Exception(
          "Error ${response.statusCode} while adding user: ${response
              .body}!");
    }
  }

  Future<List<User>> loadAllUsers() async {
    final uri = Uri.https(_baseUrl, '$URL_WP_BASE/users', {'roles': 'patient'});
    final response = await http.get(uri, headers: await _urlHeader);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonList = jsonDecode(response.body) as List;
      return jsonList.map((x) => User.fromJson(x)).toList();
    } else {
      throw new http.ClientException(
          "Error ${response.statusCode}: ${response.body}");
    }
  }

  Future<User> loadUser(String slug) async {
    assert(slug != null);
    slug = slug.replaceAll('.', ''); //name = max.muster; slug = maxmuster

    final uri = Uri.https(_baseUrl, '$URL_WP_BASE/users', {'slug': slug});
    final response = await http.get(uri, headers: await _urlHeader);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonList = jsonDecode(response.body) as List;
      return User.fromJson(jsonList[0]);
    } else {
      throw new http.ClientException(
          "Error ${response.statusCode}: ${response.body}");
    }
  }
}
