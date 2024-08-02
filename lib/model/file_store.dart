import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileStore {

  Future<File> createTempFile(String name) async {
    final dir = (await getTemporaryDirectory()).path;
    final tempFile = new File('$dir/$name');
    return tempFile;
  }

  Future<void> deleteTempFile(String name) async {
    final dir = (await getTemporaryDirectory()).path;
    final tempFile = new File('$dir/$name');
    if(await tempFile.exists())
      await tempFile.delete();
  }

  Future<void> clearTempDir() async {
    final dir = await getTemporaryDirectory();
    await dir.list().forEach((FileSystemEntity f) async => await f.delete(recursive: true));
  }

  Future<File> downloadToFile(String url, File file) async {
    final client = HttpClient();
    client.getUrl(Uri.parse(url)).then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      response.pipe(file.openWrite());
    });
    return file;
  }

  Future<File> downloadToTemp(String url) async {
    print(url);
    final fileName = url.split("?").first.split("/").last;
    print(fileName);
    final tempFile = await createTempFile(fileName);
    return await downloadToFile(url, tempFile);
  }
}