import 'package:test/test.dart';
import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test('page updates after event modifies variable', () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    await page.click('#increment-button');
    final countText = await page.getInnerHtml('#count-display');

    expect(countText, equals('1'));
    await browser.close();
  });

  server.stop();
}
