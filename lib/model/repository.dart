import 'package:meta/meta.dart';
import 'wordpress_api.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'model.dart';
import 'dart:io';

class Repository {
  final WordpressApi wp;
  final FileStore fileStore;

  Repository({@required this.wp, @required this.fileStore});

  Future<JWTResponse> authenticate(
      {String username="", String password=""}) async {
    final response = await wp.authenticate(username: username, password: password);
    wp.saveLogin(response.userDisplayName);
    return response;
  }

  Future<void> saveUserData(String user, String pw) async {
    throw Exception("Not yet supported!");
  }

  Future<User> getLastUser() async {
    return fetchUser(await wp.getLastLogin());
  }

  Future<String> getLastLogin() async {
    return wp.getLastLogin();
  }

  Future<bool> hasToken() async {
    return wp.hasToken();
  }

  Future<bool> hasValidToken() async {
    return wp.hasValidToken();
  }

  Future<void> persistToken(String token) async {
    return wp.persistToken(token);
  }

  Future<void> deleteToken() async {
    return wp.deleteToken();
  }

  Future<String> signUrl(String url) async {
    return wp.signUrl(url);
  }

  Future<File> downloadPdf(String url) async {
    final signedUrl =  await wp.signUrl(url);
    /*
    final fileName = url.split("/").last;
    final tempFile = await fileStore.createTempFile(fileName);

    final pdf = await fileStore.downloadToFile(signedUrl, tempFile);
    if(pdf == null || !(await pdf.exists()))
      throw Exception("Could not download file!");

    return pdf;
    // */
    return await DefaultCacheManager().getSingleFile(signedUrl);
  }

  Future<User> fetchUser(String userName) async {
    return wp.loadUser(userName);
  }

  Future<List<User>> fetchAllUsers() async {
    return wp.loadAllUsers();
  }

  Future<User> addUser(
      String firstName, String lastName, String email, String password) async {
    return wp.addUser(firstName, lastName, email, password);
  }

  Future<void> deleteUser(User user) async {
    throw Exception("Not supported!");
  }

  Future<Attachment> uploadAttachment(File attachment) async {
    return wp.uploadAttachment(attachment);
  }

  Future<void> updateTreatments(User user, List<Treatment> treatments) async {
    return wp.updateTreatments(user, treatments);
  }

  Future<List<Treatment>> loadTreatmentsOf(User user) async {
    return wp.loadTreatmentsOf(user);
  }
}
