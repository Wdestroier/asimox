import 'dom_node_adapter.dart';

Text<Element, Event> text<Element, Event>(String text) =>
    Text<Element, Event>(text);

class Text<Element, Event> extends DomNodeAdapter<Element, Event> {
  final String text;

  Text(this.text);

  @override
  build(builder) => builder.text(text);
}
