import '../../asimox.dart';
import 'dom_node_adapter.dart';

class Fragment<Element, Event> extends DomNodeAdapter<Element, Event> {
  final List<DomNode> children;

  Fragment({required this.children});

  @override
  build(builder) => builder.visitAll(children);
}
