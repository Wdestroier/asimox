import 'package:domino/browser.dart' as domino show registerView;
import 'package:web/web.dart';

import '../asimox.dart';

void runApp(
  DomNode<Element, Event> root, {
  String rootElementId = 'root',
}) {
  final rootView = domino.registerView(
    root: document.getElementById(rootElementId)!,
    builderFn: root.build,
  );
  changeDetection.addListener(rootView);
}
