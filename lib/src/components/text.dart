import 'dom_node_adapter.dart';

Text text(String text) => Text(text);

class Text extends DomNodeAdapter {
  final String text;

  Text(this.text);

  @override
  build(builder) => builder.text(text);
}
