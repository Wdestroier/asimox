import 'package:domino/browser.dart';

Text text(String text) => Text(text);

class Text extends DomNode {
  final String text;

  Text(this.text);

  @override
  DomNode build() =>
      throw StateError('Text.build() is never called in Text.call().');

  @override
  void call(DomBuilder b) => b.text(text);
}
