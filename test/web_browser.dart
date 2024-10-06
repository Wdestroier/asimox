import 'dart:async';
import 'package:puppeteer/puppeteer.dart';
import 'web_server.dart';

class WebBrowser {
  int port;
  Browser? browser;

  WebBrowser.fromBaseUrlProvider(WebServer server) : port = server.port;

  WebBrowser.fromLocalhostPort({required this.port});

  Future<WebPage> open(String path) async {
    browser ??= await puppeteer.launch(headless: true);

    final page = await browser!.newPage();
    await page.goto(_buildUrl(path), wait: Until.networkAlmostIdle);
    return WebPage(page);
  }

  String _buildUrl(String path) => 'http://localhost:$port$path';

  FutureOr<void> close() => browser?.close();
}

class WebPage {
  final Page _page;

  WebPage(this._page);

  Future<String> getRootInnerHtml() => getInnerHtml('root');

  Future<String> getInnerHtml(String elementId) {
    return _page.evaluate<String>(
        '() => document.getElementById("$elementId").innerHTML');
  }
}
