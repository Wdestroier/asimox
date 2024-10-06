import 'package:test/test.dart';

import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test("text doesn't render extra tags", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getInnerHtml('test-extra-tags');

    expect(
      html,
      equals('Plaintext <a href="/hyperlink">Anchor text</a>'),
    );
    await browser.close();
  });

  test("text doesn't render unescaped html", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getInnerHtml('test-unescaped-html');

    expect(
      html,
      equals('&lt;script&gt;alert("Injected!")&lt;/script&gt;'),
    );
    await browser.close();
  });

  server.stop();
}
