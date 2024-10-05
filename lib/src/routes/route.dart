import '../../asimox.dart';

typedef RouteHandler = DomNode Function(Map<String, String> parameters);

class Route {
  // A regular expression that matches placeholders in curly braces, where the
  // placeholder contains one or more word characters (alphanumeric or underscore).
  static final _placeholderPattern = RegExp(r'\{(\w+)\}');
  // A pattern that matches any sequence of characters except the forward slash.
  static const _pathSegmentPattern = r'([^/]+)';

  final RegExp pattern;
  final RouteHandler handler;
  final String routePattern;
  final List<Middleware> middlewares;

  Route(this.routePattern, this.handler, {this.middlewares = const []})
      : pattern = _createRegExp(routePattern);

  static RegExp _createRegExp(String routePattern) {
    final pattern = routePattern.replaceAllMapped(
      _placeholderPattern,
      (match) => _pathSegmentPattern,
    );
    return RegExp('^$pattern\$');
  }

  Map<String, String>? match(String path) {
    final match = pattern.firstMatch(path);

    if (match != null) {
      final params = <String, String>{};

      final paramNames = _placeholderPattern
          .allMatches(routePattern)
          .map((m) => m.group(1))
          .toList();

      for (var i = 0; i < paramNames.length; i++) {
        params[paramNames[i]!] = match.group(i + 1)!;
      }

      return params;
    }

    return null;
  }
}
