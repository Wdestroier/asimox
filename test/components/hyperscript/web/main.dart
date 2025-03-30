import 'package:asimox/asimox.dart';

main() {
  runApp(
    Fragment(
      children: [
        div(
          id: 'test-empty-selector',
          children: [
            h(''),
          ],
        ),
        div(
          id: 'test-id-selector',
          children: [
            h('#test-id-selector-id'),
          ],
        ),
        div(
          id: 'test-tag-name-selector',
          children: [
            h('p'),
          ],
        ),
        h('#test-nested-children', [
          h('p.class-a', [
            h('span.class-b'),
          ]),
        ]),
      ],
    ),
  );
}
