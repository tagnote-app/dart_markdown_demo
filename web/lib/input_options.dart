import 'dart:html';

import 'definition.dart';

const _options = {
  SimpleOption('enableAtxHeading', 'ATX heading', true),
  SimpleOption('enableSetextHeading', 'setext heading', true),
  SimpleOption('enableHeadingId', 'heading id', false),
  SimpleOption('enableBlockquote', 'blockquote', true),
  SimpleOption('enableFencedBlockquote', 'fenced blockquote', true),
  SimpleOption('enableCodeSpan', 'code span(inline code)', true),
  SimpleOption('enableFencedCodeBlock', 'fenced code block', true),
  SimpleOption('enableIndentedCodeBlock', 'indented code block', true),
  SimpleOption('enableList', 'list', true),
  SimpleOption('enableParagraph', 'paragraph', true),
  SimpleOption('enableTable', 'table', true),
  SimpleOption(
      'enableLinkReferenceDefinition', 'link reference definition', true),
  SimpleOption('enableThematicBreak', 'thematic break', true),
  SimpleOption('enableImage', 'image', true),
  SimpleOption('enableLink', 'link', true),
  SimpleOption('enableAutolink', 'autolink', true),
  SimpleOption('enableAutolinkExtension', 'autolink extension', true),
  SimpleOption('enableBackslashEscape', 'backslash escape', true),
  SimpleOption('enableEmoji', 'emoji', true),
  SimpleOption('enableEmphasis', 'emphasis', true),
  SimpleOption('enableHardLineBreak', 'hard line break', true),
  SimpleOption('enableRawHtml', 'raw html(inline html)', true),
  SimpleOption('enableHtmlBlock', 'html block', true),
  SimpleOption('enableStrikethrough', 'strikethrough', true),
  SimpleOption('enableHighlight', 'highlight', true),
  SimpleOption('enableFootnote', 'footnote', false),
  SimpleOption('enableTaskList', 'task list', false),
  SimpleOption('enableSubscript', 'subscript', false),
  SimpleOption('enableSuperscript', 'supscript', false),
  SimpleOption('enableKbd', 'kbd', false),
};

class InputOptions {
  final value = <String>[];

  final DivElement container;
  final void Function(List<String> value) onChange;

  final _storage = window.localStorage;
  final _storageKey = 'inputOptions';

  InputOptions({
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
          value.add(option.name);
        }
      }
    } else {
      value.addAll(savedValue.split(','));
    }
  }

  void _saveValue() {
    _storage[_storageKey] = value.join(',');
  }

  _buildOptions() {
    for (final option in _options) {
      final input = InputElement(type: 'checkbox');
      final label = LabelElement()
        ..append(input)
        ..appendText(option.label);
      container.append(label);

      final checked = value.contains(option.name);
      if (checked) {
        label.className = 'checked';
      }

      input
        ..checked = checked
        ..onChange.listen((e) {
          final checked = (e.currentTarget as InputElement).checked;
          value.remove(option.name);
          label.removeAttribute('class');
          if (checked == true) {
            value.add(option.name);
            label.className = 'checked';
          }
          _saveValue();
          onChange(value);
        });
    }
  }
}
