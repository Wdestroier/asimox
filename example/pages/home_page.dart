

import 'package:asimox/asimox.dart';

class HomePage extends DomNode {
  @override
  DomNode render() {
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
