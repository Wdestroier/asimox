import 'dart:html' show window;

import '../components/declarative_dom_node.dart';
import 'route.dart';
import 'route_middleware.dart';

class WebRouter extends DomNode {
  final List<Route> routes;
  final RouteHandler defaultRoute;
  // TODO(wfontao): Global errorRoute with zones or try/catch.
  final List<Middleware> middlewares;
  DomNode? _currentRouteNode;

  WebRouter({
    required this.routes,
    required this.defaultRoute,
    this.middlewares = const [],
  }) {
    _listenNavigationEvents();
  }

  void _listenNavigationEvents() {
    window.onPopState.listen((_) => _handleRoute());
    _handleRoute();
  }

  void _handleRoute() {
    final (:pathWithHash, :queryString) = _getPathAndQuery();
    final queryParams = queryString.isEmpty
        ? <String, String>{}
        : Uri.splitQueryString(queryString);

    for (var route in routes) {
      final match = route.match(pathWithHash);
      if (match != null) {
        final routeParams = {...match, ...queryParams};

        // Check global middleware.
        if (!_runMiddleware(middlewares, routeParams)) {
          _currentRouteNode = defaultRoute(routeParams);
          return;
        }

        // Check route-specific middlewares.
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

  ({String pathWithHash, String queryString}) _getPathAndQuery() {
    final path = window.location.pathname;
    final search = window.location.search;
    final hash = window.location.hash;

    if (hash.contains('?')) {
      final parts = hash.split('?');
      final fragment = parts.first;
      final hashQuery = parts.skip(1).join('?');
      return (pathWithHash: '$path$fragment', queryString: hashQuery);
    } else {
      final query =
          (search == null || search.isEmpty) ? '' : search.substring(1);
      return (pathWithHash: '$path$hash', queryString: query);
    }
  }

  bool _runMiddleware(
    List<Middleware> middlewares,
    Map<String, String> params,
  ) {
    for (var middleware in middlewares) {
      if (!middleware(params)) {
        return false;
      }
    }
    return true;
  }

  void navigateTo(String path) {
    window.history.pushState(null, '', path);
    _handleRoute();
  }

  @override
  DomNode render() {
    return _currentRouteNode ??
        (throw StateError('Router is not initialized.'));
  }
}
