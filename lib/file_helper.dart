part of 'main.dart';

class FileHelper {
  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get localCache async {
    final path = await localPath;
    return File('$path/ygo_api_cache.json');
  }

  Future<File> localImage(int id) async {
    return File('assets/images/cards/$id.jpg');
  }

  Future<File> writeDataCache(String data) async {
    final file = await localCache;
    return file.writeAsString(data);
  }

  Future<String?> readDataCache() async {
    try {
      final file = await localCache;

      if (!await file.exists()) {
        await file.writeAsString('{}');

        return '{}';
      }

      return file.readAsString();
    }
    catch (e) {
      return null;
    }
  }

  Future<Uint8List?> readImage(int id) async {
    try {
      final file = await localImage(id);

      if (!await file.exists()) {
        throw Exception();
      }

      final bytes = await file.readAsBytes();

      return bytes;
    }
    catch (e) {
      return null;
    }
  }
}