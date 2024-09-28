import 'package:domino/browser.dart';
import 'package:domino_html/domino_html.dart';
import 'web_router.dart';

final router = WebRouter(
  routes: [
    Route('/', (_) => HomePage()),
    Route(
      '/counter',
      (parameters) {
        return AppPage(
          start: int.tryParse(parameters['start'] ?? '0') ?? 0,
        );
      },
    ),
    Route(
      '/counter/{name}',
      (parameters) {
        return AppPage(
          name: parameters['name'],
          start: int.tryParse(parameters['start'] ?? '0') ?? 0,
        );
      },
    ),
  ],
  defaultRoute: (_) => NotFoundPage(),
  middlewares: [isAuthenticated],
  // TODO(wfontao): Implement global errorRoute with try/catch.
);

bool isAuthenticated(parameters) {
  return true;
}

void main() {
  runApp(router);
}

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

class HomePage extends DomNode {
  @override
  DomNode build() {
    return h1(
      text: 'Found home page. Go to /counter.',
    );
  }
}

class NotFoundPage extends DomNode {
  @override
  DomNode build() {
    return h1(
      text: 'Not found.',
    );
  }
}
