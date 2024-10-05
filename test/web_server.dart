import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:webdev_proxy/src/executable.dart' as webdev_proxy;
// import 'package:webdev_proxy/src/port_utils.dart' as webdev_proxy;

class WebServer {
  String path;
  int port;

  WebServer._({required this.path, required this.port});

  static Future<WebServer> start({String? path}) async {
    path ??= p.join('test', _getCallerFileName(), 'web');

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
      // 'web',
      // path, // Doesn't work, webdev only works in the web or test directories.
    ]);
    await server._checkServerRunning();

    return server;
  }

  @pragma("vm:entry-point")
  static String _getCallerFileName({int skipCount = 2}) {
    final stackTrace = StackTrace.current.toString().split('\n');
    final line = stackTrace.skip(skipCount).first.toString();
    // For some reason it's '/' on Windows too.
    return line.substring(
        line.lastIndexOf('/') + 1, line.lastIndexOf('.dart:'));
  }

  // TODO(wfontao): Make this work in any OS.
  Future<void> _linkTestFiles() =>
      io.Process.run('cmd', ['/c', 'mklink', '/d', 'web', path]);

  Future<void> _deleteWebDirectory() =>
      io.Process.run('cmd', ['/c', 'rmdir', 'web']);

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
