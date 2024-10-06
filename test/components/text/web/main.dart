import 'package:asimox/asimox.dart';

main() {
  runApp(
    Fragment(
      div(
        id: 'test-extra-tags',
        children: [
          text('Plaintext '),
          a(
            href: '/hyperlink',
            text: 'Anchor text',
          ),
        ],
      ),
      div(
        id: 'test-unescaped-html',
        children: [
          text('<script>alert("Injected!")</script>'),
        ],
      ),
    ),
  );
}
