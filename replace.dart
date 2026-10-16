import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    if (file.path == 'lib/utils/http_client.dart' || file.path == 'lib/utils/common.dart') continue;
    
    var content = file.readAsStringSync();
    if (content.contains("import 'package:http/http.dart' as http;")) {
      content = content.replaceAll(
          "import 'package:http/http.dart' as http;", 
          "import 'package:jippymart_restaurant/utils/http_client.dart' as http;");
      file.writeAsStringSync(content);
      print('Replaced in ${file.path}');
    }
  }
}
