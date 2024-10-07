import 'package:test/test.dart';

import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test('click event is not ignored', () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    await page.click('#button-with-event');
    final text = await page.getInnerHtml('#state-container');

    expect(text, equals('updated'));
    await browser.close();
  });

  server.stop();
}
