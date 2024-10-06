import 'dom_node_adapter.dart';

class RawHtml<Element, Event> extends DomNodeAdapter<Element, Event> {
  final String html;

  RawHtml(this.html);

  @override
  build(builder) => builder.innerHtml(html);
}
