import 'package:test/test.dart';
import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test('fragment does not render extra HTML tag', () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getRootInnerHtml();

    expect(
      html,
      equals('<h1>Heading</h1><h2>Subheading</h2>'),
    );
    await browser.close();
  });

  server.stop();
}
