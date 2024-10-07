import 'package:test/test.dart';
import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test('anchor tag renders correctly with href and text', () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getRootInnerHtml();

    expect(
      html,
      equals('<a href="/page">Page</a>'),
    );
    await browser.close();
  });

  server.stop();
}