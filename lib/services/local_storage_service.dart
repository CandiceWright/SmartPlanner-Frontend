import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class LocalStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<String> getlocalFilePath(String filename) async {
    //final path = await _localPath;
    final directory = await getApplicationDocumentsDirectory();
    String path = directory.path;
    return '$path/$filename';
  }

  Future<Object> readFile(String filename) async {
    try {
      final file = await getlocalFilePath(filename);

      // Read the file
      //final media = file.readAsBytesSync();

      return file;
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<String> writeFile(XFile mediafile, String filename) async {
    final path = await getlocalFilePath(filename);

    // Write the file
    await mediafile.saveTo(path);
    return path;
  }
}
