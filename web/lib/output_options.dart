import 'dart:html';

import 'definition.dart';

const _options = {
  SimpleOption('html', 'HTML', true),
  SimpleOption('rawHtml', 'Raw HTML', false),
  SimpleOption('markdownAst', 'Markdown AST', false),
};

class OutputOptions {
  late String value;

  final DivElement container;
  final void Function(String value) onChange;

  final _storage = window.localStorage;
  final _storageKey = 'outputOption';

  OutputOptions({
    required this.container,
    required this.onChange,
  }) {
    _initValue();
    _buildOptions();
  }

  void _initValue() {
    final savedValue = _storage[_storageKey];
    if (savedValue == null) {
      for (final option in _options) {
        if (option.checked) {
          value = option.name;
        }
      }
    } else {
      value = savedValue;
    }
  }

  void _saveValue() {
    _storage[_storageKey] = value;
  }

  _buildOptions() {
    for (final option in _options) {
      final input = InputElement(type: 'radio');
      final label = LabelElement()
        ..append(input)
        ..appendText(option.label);
      container.append(label);

      final checked = value == option.name;
      if (checked) {
        label.className = 'checked';
      }

      input
        ..checked = checked
        ..name = 'output-option'
        ..onChange.listen((e) {
          final element = e.currentTarget as InputElement;
          for (final item in container.children) {
            item.removeAttribute('class');
          }
          element.parent?.className = 'checked';
          value = option.name;
          _saveValue();
          onChange(value);
        });
    }
  }
}
