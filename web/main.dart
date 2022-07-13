import 'dart:convert';
import 'dart:html';
import 'package:dart_markdown/dart_markdown.dart' as md;

import 'lib/input_options.dart';
import 'lib/output_options.dart';
import 'lib/highlight.dart';

final input = querySelector('#markdown') as TextAreaElement;
final htmlOutput = querySelector('#html_output') as Element;
final codeOutput = querySelector('#code_output') as Element;

late InputOptions inputOptions;
late OutputOptions outputOptions;

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
      _renderMarkdown();
    },
  );

  _initInput();
  _renderMarkdown();
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
      final json = JsonEncoder.withIndent("  ")
          .convert(nodes.map((e) => e.toMap()).toList());

      codeOutput.innerHtml = highlight(
        json,
        HljsOptions(language: 'json'),
      ).value;
      break;

    default:
      final html = md.renderToHtml(nodes, encodeHtml: true);
      htmlOutput.setInnerHtml(html, treeSanitizer: NullTreeSanitizer());

      for (final block in htmlOutput.querySelectorAll('pre code')) {
        try {
          highlightElement(block);
        } catch (e) {
          window.console.error('Error highlighting markdown:');
          window.console.error(e);
        }
      }
  }
}

class NullTreeSanitizer implements NodeTreeSanitizer {
  @override
  void sanitizeTree(Node node) {}
}
