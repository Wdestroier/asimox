import 'package:test/test.dart';

import '../web_server.dart';
import '../web_browser.dart';

main() async {
  final server = await WebServer.start();

  test('render basic component', () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getRootInnerHtml();

    expect(html, equals('<h1>Hello, World!</h1>'));
    await browser.close();
  });

  server.stop();
}
