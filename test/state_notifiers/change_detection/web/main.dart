import 'package:asimox/asimox.dart';

main() => runApp(ChangeDetectionApp());

class ChangeDetectionApp extends DomNode {
  var count = 0;

  @override
  DomNode render() {
    return Fragment(
      children: [
        button(
          id: 'increment-button',
          type: 'button',
          text: 'Increment',
          onClick: (event) {
            count++;
          },
        ),
        p(
          id: 'count-display',
          text: '$count',
        ),
      ],
    );
  }
}
