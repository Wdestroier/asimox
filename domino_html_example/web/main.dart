import 'package:domino/browser.dart';
import 'package:domino_html/domino_html.dart';

void main() {
  runApp(App());
}

class App extends DomNode {
  var _counter = 0;

  @override
  DomNode build() {
    return div(
      children: [
        button(
          id: 'app-button',
          events: {
            'click': (e) {
              _counter++;
            },
          },
          text: 'Click',
        ),
        span(id: 'app-count', text: 'Counter: $_counter'),
      ],
    );
  }
}
