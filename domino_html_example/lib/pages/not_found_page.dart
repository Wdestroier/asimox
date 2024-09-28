import 'package:domino/domino.dart';
import 'package:domino_html/domino_html.dart';

class NotFoundPage extends DomNode {
  @override
  DomNode build() {
    return h1(
      text: 'Not found.',
    );
  }
}
