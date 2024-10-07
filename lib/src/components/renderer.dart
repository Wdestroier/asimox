import '../../asimox.dart';

typedef DomNodeRenderer<Element, Event> = DomNode<Element, Event> Function();

class Renderer<Element, Event> extends DomNode<Element, Event> {
  final DomNodeRenderer renderer;

  Renderer({required this.renderer});

  @override
  DomNode render() => renderer();
}
