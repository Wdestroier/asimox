import 'package:asimox/asimox.dart';

main() {
  runApp(
    WebRouter(
      routes: [
        Route('/', (_) => IndexPage()),
        Route(
          '/query-parameter-test',
          (parameters) {
            final value = parameters['key'];
            return ParameterPage(value: value);
          },
        ),
        Route(
          '/path-parameter-test/{key}',
          (parameters) {
            final value = parameters['key'];
            return ParameterPage(value: value);
          },
        ),
        Route(
          '/url-fragment-test',
          (parameters) {
            final value = parameters['keyA'];
            return ParameterPage(value: value);
          },
        ),
        // A request to this route should not match the route above.
        Route(
          '/url-fragment-test#fragment',
          (parameters) {
            final value = parameters['keyB'];
            return ParameterPage(value: value);
          },
        ),
        Route(
          '/unauthorized',
          (_) => UnauthorizedPage(),
          middlewares: [isAuthorized],
        ),
      ],
      defaultRoute: (_) => NotFoundPage(),
    ),
  );
}

class IndexPage extends DomNode {
  @override
  DomNode render() {
    return h1(text: 'Home Page');
  }
}

class ParameterPage extends DomNode {
  String? value;

  ParameterPage({this.value});

  @override
  DomNode render() {
    return (value == null) ? text('null') : p(text: value);
  }
}

class UnauthorizedPage extends DomNode {
  @override
  DomNode render() {
    return h1(text: 'Authorized Access');
  }
}

bool isAuthorized(parameters) => false;

class NotFoundPage extends DomNode {
  @override
  DomNode render() {
    return h1(text: 'Not Found');
  }
}
