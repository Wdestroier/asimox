import 'package:asimox/asimox.dart';

main() => runApp(EventTestsApp());

var state = 'initial';

class EventTestsApp extends DomNode {
  @override
  DomNode render() {
    return Fragment(
      children: [
        button(
          id: 'button-with-event',
          type: 'button',
          text: 'Click me',
          onClick: (event) {
            state = 'updated';
          },
        ),
        p(
          id: 'state-container',
          text: state,
        ),
      ],
    );
  }
}
