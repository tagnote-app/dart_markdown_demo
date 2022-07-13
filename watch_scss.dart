import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import 'tool/compile_scss.dart';

void main() {
  final watcher = DirectoryWatcher(p.absolute('scss'));
  watcher.events.listen((event) {
    compileScss();
  });
}
