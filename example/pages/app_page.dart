

import 'package:asimox/asimox.dart';

class AppPage extends DomNode {
  String? name;
  int count;

  AppPage({this.name, int start = 0}) : count = start;

  @override
  DomNode render() {
    return div(
      classes: ['counter-app'],
      children: [
        if (name != null) h1(text: '$name counter'),
        button(
          id: 'app-button',
          text: 'Click',
          onClick: (e) {
            count++;
          },
        ),
        span(id: 'app-count', text: 'Count: $count'),
      ],
    );
  }
}
