import 'dart:io';

import 'package:webdev_proxy/src/executable.dart' as webdev_proxy;
// import 'package:webdev_proxy/src/port_utils.dart' as webdev_proxy;

class WebDevProxy {
  String path;
  int port;

  WebDevProxy._({required this.path, required this.port});

  static Future<WebDevProxy> serve({required String path}) async {
    // _port = await webdev_proxy.findUnusedPort();
    final webDev = WebDevProxy._(path: path, port: 8080);

    await webDev._deleteSymbolicLink();
    await webDev._createSymbolicLink();

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
    await webDev._checkServerRunning();

    return webDev;
  }

  // TODO(wfontao): Make this work in any OS.
  Future<void> _createSymbolicLink() =>
      Process.run('cmd', ['/c', 'mklink', '/D', 'web', path]);

  Future<void> _deleteSymbolicLink() =>
      Process.run('cmd', ['/c', 'rmdir', 'web']);

  Future<void> _checkServerRunning() async {
    const retryCount = 40;
    const retryDelay = Duration(milliseconds: 250);

    for (var attempt = 0; attempt < retryCount; attempt++) {
      try {
        final socket = await Socket.connect('localhost', port,
            timeout: Duration(seconds: 2));
        // Server is running.
        print('Server is running on localhost:$port.');
        socket.destroy();
        return;
      } catch (_) {
        // Server is not running yet.
        print('Attempt $attempt: Server is not running yet, retrying...');
        await Future.delayed(retryDelay);
      }
    }

    throw Exception(
        'Server did not start on localhost after $retryCount attempts.');
  }
}
