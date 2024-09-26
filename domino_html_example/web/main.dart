import 'package:domino/browser.dart';
import 'package:web/web.dart';
import 'package:domino_html/domino_html.dart';

void main() {
  runApp(App());
}

void runApp(Component component) {
  registerView(
    root: document.getElementById('root')!,
    builderFn: component,
  );
}

abstract class Component {
  DomNode build();
  void call(DomBuilder<Element, Event> builder) => builder.visit(build());
}

class App extends Component {
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
              e.view.invalidate();
            },
          },
          text: 'Click',
        ),
        span(id: 'app-count', text: 'Counter: $_counter'),
      ],
    );
  }
}
