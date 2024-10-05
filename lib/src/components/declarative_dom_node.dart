import 'package:domino/domino.dart' as domino show DomNode, DomBuilder;

abstract class DomNode<Element, Event> extends domino.DomNode<Element, Event> {
  // Declaratively return a component.
  DomNode render();

  // Domino's DomNode has a method called build already and its signature can't
  // be overriden. It's an imperative API.
  @override
  void build(domino.DomBuilder<Element, Event> b) => b.visit(render());
}
