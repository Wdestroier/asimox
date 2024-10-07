import 'dart:io' as io;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:webdev_proxy/src/executable.dart' as webdev_proxy;
// import 'package:webdev_proxy/src/port_utils.dart' as webdev_proxy;

class WebServer {
  static const _webPath = 'web';

  String path;
  int port;

  WebServer._({required this.path, required this.port});

  static Future<WebServer> start({String? path}) async {
    path ??= p.join(_getCallerRelativeDirectoryPath(), _webPath);

    // TODO(wfontao): The tests will timeout if the port is already in use.
    // _port = await webdev_proxy.findUnusedPort();
    final server = WebServer._(path: path, port: 8080);

    await server._deleteWebDirectory();
    await server._linkTestFiles();

    webdev_proxy.run([
      'serve',
      // The underlying webdev serve process is configured by passing the
      // command-line arguments after the -- separator.
      // '--',
      // '--chrome-debug-port', // Setting the port throws an error.
      // '$port',
      // '--no-build-web-compilers',
      // _webPath,
      // path, // Doesn't work, webdev only works in the web or test directories.
    ]);
    await server._checkServerRunning();

    return server;
  }

  Future<void> stop() async {
    // Finding a way to stop the webdev_proxy would be nice, but the process
    // will terminate when the test finishes anyway.

    // The stop method is called before all async tests finish. Uncommenting
    // the line below would make the tests not pass.
    // await _deleteWebDirectory();
  }

  @pragma("vm:entry-point")
  static String _getCallerRelativeDirectoryPath({int skipCount = 2}) {
    final stackTrace = StackTrace.current.toString().split('\n');
    final line = stackTrace.skip(skipCount).first.toString();
    final workingDirectoryPath =
        File('').absolute.path.replaceAll(p.separator, '/');

    return line
        .substring(
          line.indexOf(workingDirectoryPath) + workingDirectoryPath.length,
          line.lastIndexOf('/'), // For some reason it's '/' on Windows too.
        )
        .replaceAll('/', p.separator);
  }

  Future<void> _deleteWebDirectory() async {
    if (await Directory(_webPath).exists() &&
        !await FileSystemEntity.isLink(_webPath)) {
      throw StateError('The web directory must not be in use.');
    }

    await Link(_webPath).delete();
  }

  Future<void> _linkTestFiles() async {
    final link = Link(_webPath);
    await link.create(path);

    if (!await link.exists()) {
      throw StateError('Created symbolic link must not be broken.');
    }
  }

  Future<void> _checkServerRunning() async {
    const retryLimit = 10;
    const retryDelay = Duration(seconds: 2);

    for (var attempt = 0; attempt < retryLimit; attempt++) {
      try {
        // The check could use a socket only, but it's better to avoid problems
        // by making sure the HTTP server is listening and returning the page.
        final response = await http.get(Uri.parse('http://localhost:$port'));

        if (response.statusCode == io.HttpStatus.ok) {
          print('Server is running on localhost:$port.');
          return;
        } else {
          print('Server responded with status code: ${response.statusCode}.');
        }
      } catch (e) {
        // Server is not running yet or couldn't connect.
        print('Attempt $attempt: Server is not running yet, retrying...');
      }

      await Future.delayed(retryDelay);
    }

    throw Exception(
        'Server did not start on localhost after $retryLimit attempts.');
  }
}
