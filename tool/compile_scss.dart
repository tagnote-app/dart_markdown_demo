import 'package:path/path.dart' as p;
import 'package:sass/sass.dart' as sass;
import 'dart:io';

void main() {
  compileScss();
}

void compileScss() {
  final inputFile = p.absolute('scss/styles.scss');
  final outputFile = p.absolute('web/styles.css');
  final result = sass.compileToResult(inputFile);

  File(outputFile).writeAsStringSync(result.css);
}
