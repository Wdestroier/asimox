// ignore_for_file: avoid_renaming_method_parameters

import 'package:domino/domino.dart' as domino show DomBuilder;

import '../../asimox.dart';

/// This class is a fix to not require domino imports to use RawHtml or text.
abstract class DomNodeAdapter<Element, Event> extends DomNode<Element, Event> {
  @override
  void build(domino.DomBuilder<Element, Event> builder);

  @override
  DomNode render() => throw StateError(
      'render is never called, because build overrides the original implementation.');
}
