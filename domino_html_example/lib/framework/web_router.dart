import 'dart:html';
import 'package:domino/domino.dart';

typedef RouteHandler = DomNode Function(Map<String, String> parameters);
typedef Middleware = bool Function(Map<String, String> parameters);

class WebRouter extends DomNode {
  final List<Route> routes;
  final RouteHandler defaultRoute;
  final List<Middleware> middlewares;
  DomNode? _currentRouteNode;

  WebRouter({
    required this.routes,
    required this.defaultRoute,
    this.middlewares = const [],
  }) {
    _init();
  }

  void _handleRoute() {
    String path = window.location.pathname!;
    String? queryString = window.location.search;

    Map<String, String> queryParams = {};
    if (queryString != null && queryString.isNotEmpty) {
      queryParams = Uri.splitQueryString(queryString.substring(1));
    }

    for (var route in routes) {
      final match = route.match(path);
      if (match != null) {
        final routeParams = {...match, ...queryParams};

        // Check global middleware
        if (!_runMiddleware(middlewares, routeParams)) {
          _currentRouteNode = defaultRoute(routeParams);
          return;
        }

        // Check route-specific middleware
        if (!_runMiddleware(route.middlewares, routeParams)) {
          _currentRouteNode = defaultRoute(routeParams);
          return;
        }

        // Combine path parameters and query parameters.
        _currentRouteNode = route.handler(routeParams);
        return;
      }
    }

    _currentRouteNode = defaultRoute(queryParams);
  }

  bool _runMiddleware(
      List<Middleware> middlewares, Map<String, String> params) {
    for (var middleware in middlewares) {
      if (!middleware(params)) {
        return false;
      }
    }
    return true;
  }

  void _init() {
    window.onPopState.listen((_) => _handleRoute());
    _handleRoute();
  }

  void navigateTo(String path) {
    window.history.pushState(null, '', path);
    _handleRoute();
  }

  @override
  DomNode build() {
    return _currentRouteNode ??
        (throw StateError('Router is not initialized.'));
  }
}

class Route {
  final RegExp pattern;
  final RouteHandler handler;
  final String routePattern;
  final List<Middleware> middlewares;

  Route(this.routePattern, this.handler, {this.middlewares = const []})
      : pattern = _createRegExp(routePattern);

  static RegExp _createRegExp(String routePattern) {
    final pattern = routePattern.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (match) => r'([^/]+)',
    );
    return RegExp('^$pattern\$');
  }

  Map<String, String>? match(String path) {
    final match = pattern.firstMatch(path);
    if (match != null) {
      final params = <String, String>{};

      final paramNames = RegExp(r'\{(\w+)\}')
          .allMatches(routePattern)
          .map((m) => m.group(1))
          .toList();

      for (int i = 0; i < paramNames.length; i++) {
        params[paramNames[i]!] = match.group(i + 1)!;
      }

      return params;
    }
    return null;
  }
}
