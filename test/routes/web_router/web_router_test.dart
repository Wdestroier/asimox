import 'package:test/test.dart';
import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test('index page is found', () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getRootInnerHtml();

    expect(html, equals('<h1>Home Page</h1>'));
    await browser.close();
  });

  test("query parameters aren't missing", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/query-parameter-test?key=123');
    final html = await page.getRootInnerHtml();

    expect(html, equals('<p>123</p>'));
    await browser.close();
  });

  test("path parameters aren't missing", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/path-parameter-test/123');
    final html = await page.getRootInnerHtml();

    expect(html, equals('<p>123</p>'));
    await browser.close();
  });

  test("can't access page redirected by middleware", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/unauthorized');
    final html = await page.getRootInnerHtml();

    expect(html, equals('<h1>Not Found</h1>'));
    await browser.close();
  });

  test("can't access non-existent page", () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/non-existent');
    final html = await page.getRootInnerHtml();

    expect(html, equals('<h1>Not Found</h1>'));
    await browser.close();
  });

  server.stop();
}
