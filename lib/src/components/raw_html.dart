import 'dom_node_adapter.dart';

class RawHtml extends DomNodeAdapter {
  final String html;

  RawHtml(this.html);

  @override
  build(builder) => builder.innerHtml(html);
}
