import 'package:domino/domino.dart';
import 'package:domino_html/domino_html.dart';

import '../framework/text.dart';

class HomePage extends DomNode {
  @override
  DomNode build() {
    return div(
      children: [
        h1(
          children: [
            text('Found home page. Go to '),
            a(
              href: '/counter',
              text: 'counter',
            ),
            text('.'),
          ],
        ),
      ],
    );
  }
}
