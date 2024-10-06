import '../../asimox.dart';
import 'dom_node_adapter.dart';

class Fragment<Element, Event> extends DomNodeAdapter<Element, Event> {
  final Iterable<DomNode> nodes;

  Fragment(
    DomNode node1, [
    DomNode? node2,
    DomNode? node3,
    DomNode? node4,
    DomNode? node5,
    DomNode? node6,
    DomNode? node7,
    DomNode? node8,
    DomNode? node9,
  ]) : nodes = [
          node1,
          if (node2 != null) node2,
          if (node3 != null) node3,
          if (node4 != null) node4,
          if (node5 != null) node5,
          if (node6 != null) node6,
          if (node7 != null) node7,
          if (node8 != null) node8,
          if (node9 != null) node9,
        ];

  @override
  build(builder) => builder.visitAll(nodes);
}
