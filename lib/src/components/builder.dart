import '../../asimox.dart';

typedef DomNodeBuilder<Element, Event> = DomNode<Element, Event> Function();

class Builder<Element, Event> extends DomNode<Element, Event> {
  final DomNodeBuilder builder;

  Builder({required this.builder});

  @override
  DomNode render() => builder();
}
