@JS('hljs')
library hljs;

import 'package:js/js.dart';

@JS()
class HljsResult {
  String value = '';
}

@JS()
external HljsResult highlight(String code, HljsOptions options);

@JS()
@anonymous
class HljsOptions {
  external String get language;

  external factory HljsOptions({String language});
}

@JS()
external void highlightElement(Object block);
