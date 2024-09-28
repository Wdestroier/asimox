import 'package:domino/domino.dart';
import 'package:domino_html/domino_html.dart';

class HomePage extends DomNode {
  @override
  DomNode build() {
    return h1(
      text: 'Found home page. Go to /counter.',
    );
  }
}
