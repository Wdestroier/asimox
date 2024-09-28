import 'dart:html';

import 'package:domino/domino.dart';

typedef RouteHandler = DomNode Function(Map<String, String> params);

class WebRouter extends DomNode {
  final List<Route> routes;
  final RouteHandler defaultRoute;
  DomNode? _currentRouteNode;

  WebRouter({required this.routes, required this.defaultRoute}) {
    _init();
  }

  void _handleRoute() {
    String path = window.location.pathname!;
    String? queryString = window.location.search;

    Map<String, String> queryParams = {};
    if (queryString != null && queryString.isNotEmpty) {
      // Remove the leading '?' and parse.
      queryParams = Uri.splitQueryString(queryString.substring(1));
    }

    for (var route in routes) {
      final match = route.match(path);
      if (match != null) {
        // Combine path parameters and query parameters.
        _currentRouteNode = route.handler({...match, ...queryParams});
        return;
      }
    }
    _currentRouteNode = defaultRoute(queryParams);
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

  Route(this.routePattern, this.handler)
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
