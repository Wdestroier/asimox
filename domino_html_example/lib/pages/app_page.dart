import 'package:domino/domino.dart';
import 'package:domino_html/domino_html.dart';

class AppPage extends DomNode {
  String? name;
  int count;

  AppPage({this.name, int start = 0}) : count = start;

  @override
  DomNode build() {
    return div(
      classes: ['counter-app'],
      children: [
        if (name != null) h1(text: '$name counter'),
        button(
          id: 'app-button',
          onClick: (e) {
            count++;
          },
          text: 'Click',
        ),
        span(id: 'app-count', text: 'Count: $count'),
      ],
    );
  }
}
