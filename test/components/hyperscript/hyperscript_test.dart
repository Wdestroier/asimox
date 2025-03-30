import 'package:test/test.dart';

import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test("empty selector doesn't render empty tag", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getInnerHtml('#test-empty-selector');

    expect(
      html,
      equals('<div></div>'),
    );
    await browser.close();
  });

  test("id selector renders the tag with the given id", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getInnerHtml('#test-id-selector');

    expect(
      html,
      equals('<div id="test-id-selector-id"></div>'),
    );
    await browser.close();
  });

  test("selector with tag name doesn't render div tag", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getInnerHtml('#test-tag-name-selector');

    expect(
      html,
      equals('<p></p>'),
    );
    await browser.close();
  });

  test("nested children", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getInnerHtml('#test-nested-children');

    expect(
      html,
      equals('<p class="class-a"><span class="class-b"></span></p>'),
    );
    await browser.close();
  });

  server.stop();
}
