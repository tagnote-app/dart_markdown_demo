import 'dart:convert';
import 'dart:html';
import 'package:dart_markdown/dart_markdown.dart' as md;

import 'lib/input_options.dart';
import 'lib/output_options.dart';
import 'lib/highlight.dart';

final input = querySelector('#markdown') as TextAreaElement;
final htmlOutput = querySelector('#html_output') as Element;
final codeOutput = querySelector('#code_output') as Element;
final astOptions = querySelector('#ast_options') as Element;

late InputOptions inputOptions;
late OutputOptions outputOptions;

bool hideMarkers = window.localStorage['hideMarkers'] == 'true';
bool hideLocation = window.localStorage['hideLocation'] == 'true';

void main() {
  inputOptions = InputOptions(
    container: querySelector('#input_options') as DivElement,
    onChange: (List<String> value) {
      _renderMarkdown();
    },
  );

  outputOptions = OutputOptions(
    container: querySelector('#output_options') as DivElement,
    onChange: (String value) {
      htmlOutput.setInnerHtml('');
      codeOutput.innerText = '';
      _toggleAstOptions();
      _renderMarkdown();
    },
  );

  _initInput();
  _renderMarkdown();
  _toggleAstOptions();
}

void _toggleAstOptions() {
  if (outputOptions.value == 'markdownAst') {
    astOptions.style.display = 'block';
    final hideMarkersElement = querySelector('#hide_markers') as InputElement;
    final hideLocationElement = querySelector('#hide_location') as InputElement;

    hideMarkersElement
      ..onChange.listen((event) {
        hideMarkers = hideMarkersElement.checked == true;
        window.localStorage['hideMarkers'] = hideMarkers.toString();
        _renderMarkdown();
      })
      ..checked = hideMarkers;

    hideLocationElement
      ..onChange.listen((event) {
        hideLocation = hideLocationElement.checked == true;
        window.localStorage['hideLocation'] = hideLocation.toString();
        _renderMarkdown();
      })
      ..checked = hideLocation;
  } else {
    astOptions.style.display = 'none';
  }
}

void _initInput() {
  const storageKey = 'markdown';
  final storage = window.localStorage;
  var value = storage[storageKey] ?? '';
  if (value.isEmpty) {
    value = 'Hello **Markdown**!';
  }

  input
    ..value = value
    ..focus()
    ..onKeyUp.listen((event) {
      storage[storageKey] = input.value ?? '';
      _renderMarkdown();
    });
}

_renderMarkdown() {
  final selectedInput = inputOptions.value;
  final selectedOutput = outputOptions.value;
  final data = input.value!;

  final document = md.Document(
    enableAtxHeading: selectedInput.contains('enableAtxHeading'),
    enableSetextHeading: selectedInput.contains('enableSetextHeading'),
    enableHeadingId: selectedInput.contains('enableHeadingId'),
    enableBlockquote: selectedInput.contains('enableBlockquote'),
    enableFencedBlockquote: selectedInput.contains('enableFencedBlockquote'),
    enableIndentedCodeBlock: selectedInput.contains('enableIndentedCodeBlock'),
    enableFencedCodeBlock: selectedInput.contains('enableFencedCodeBlock'),
    enableList: selectedInput.contains('enableList'),
    enableParagraph: selectedInput.contains('enableParagraph'),
    enableTable: selectedInput.contains('enableTable'),
    enableHtmlBlock: selectedInput.contains('enableHtmlBlock'),
    enableLinkReferenceDefinition:
        selectedInput.contains('enableLinkReferenceDefinition'),
    enableThematicBreak: selectedInput.contains('enableThematicBreak'),
    enableAutolinkExtension: selectedInput.contains('enableAutolinkExtension'),
    enableAutolink: selectedInput.contains('enableAutolink'),
    enableBackslashEscape: selectedInput.contains('enableBackslashEscape'),
    enableCodeSpan: selectedInput.contains('enableCodeSpan'),
    enableEmoji: selectedInput.contains('enableEmoji'),
    enableEmphasis: selectedInput.contains('enableEmphasis'),
    enableHardLineBreak: selectedInput.contains('enableHardLineBreak'),
    enableImage: selectedInput.contains('enableImage'),
    enableLink: selectedInput.contains('enableLink'),
    enableRawHtml: selectedInput.contains('enableRawHtml'),
    enableStrikethrough: selectedInput.contains('enableStrikethrough'),
    enableHighlight: selectedInput.contains('enableHighlight'),
    enableFootnote: selectedInput.contains('enableFootnote'),
    enableTaskList: selectedInput.contains('enableTaskList'),
    enableSuperscript: selectedInput.contains('enableSuperscript'),
    enableSubscript: selectedInput.contains('enableSubscript'),
    enableKbd: selectedInput.contains('enableKbd'),
  );

  final nodes = document.parseLines(data);

  switch (selectedOutput) {
    case 'rawHtml':
      final html = md.renderToHtml(nodes, encodeHtml: true);
      codeOutput.innerHtml = highlight(
        html,
        HljsOptions(language: 'html'),
      ).value;
      break;

    case 'markdownAst':
      final map = nodes.map((e) => e.toMap()).toList();
      _removeMeta(map);

      final json = JsonEncoder.withIndent("  ").convert(map);

      codeOutput.innerHtml = highlight(
        json,
        HljsOptions(language: 'json'),
      ).value;
      break;

    default:
      final html = md.renderToHtml(nodes, encodeHtml: true);
      htmlOutput.setInnerHtml(html, treeSanitizer: NullTreeSanitizer());
      _syntaxHighlight(htmlOutput);
  }
}

void _syntaxHighlight(Element container) {
  final supported = [
    'php',
    'javascript',
    'typescript',
    'c',
    'c++',
    'c#',
    'go',
    'bash',
    'css',
    'json',
    'markdown',
    'less',
    'scss',
    'objective-c',
    'python',
    'java',
    'swift',
    'ymal',
    'perl',
    'r',
    'sql',
    'diff',
    'ruby',
  ];
  for (final block in container.querySelectorAll('pre code')) {
    // Set dart as default language
    final language =
        (block.className.split('-')..removeAt(0)).join('-').toLowerCase();
    if (!supported.contains(language)) {
      block.className = 'language-dart';
    }

    try {
      highlightElement(block);
    } catch (_) {}
  }
}

_removeMeta(List<Map<String, dynamic>> nodes) {
  if (!hideMarkers && !hideLocation) {
    return;
  }
  for (var i = 0; i < nodes.length; i++) {
    final node = nodes[i];
    if (hideLocation) {
      node.remove('start');
      node.remove('end');
      if (node['markers'] != null && node['markers'].isNotEmpty) {
        for (final marker in node['markers']) {
          marker.remove('start');
          marker.remove('end');
        }
      }
    }

    if (hideMarkers) {
      node.remove('markers');
    }

    if (node['children'] != null) {
      _removeMeta(node['children']);
    }
  }
}

class NullTreeSanitizer implements NodeTreeSanitizer {
  @override
  void sanitizeTree(Node node) {}
}
