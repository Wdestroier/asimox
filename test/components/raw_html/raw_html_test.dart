import 'package:test/test.dart';
import '../../web_browser.dart';
import '../../web_server.dart';

main() async {
  final server = await WebServer.start();

  test('render plain HTML without escaping', () async {
    final browser = WebBrowser.fromBaseUrlProvider(server);

    final page = await browser.open('/');
    final html = await page.getRootInnerHtml();

    expect(
      html,
      equals('<div><p>Raw Content</p></div>'),
    );
    await browser.close();
  });

  server.stop();
}
