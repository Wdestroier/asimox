import 'package:domino/domino.dart' as domino show DomElement;

import '../../asimox.dart';

class DomElement<Element, Event> extends domino.DomElement<Element, Event> {
  DomElement(
    super.tag, {
    super.key,
    super.id,
    super.classes,
    super.styles,
    super.attributes,
    Map<String, DomEventConsumer<Element, Event>>? events,
    super.onCreate,
    super.onUpdate,
    super.onRemove,
    super.children,
    super.child,
    super.text,
  }) : super(events: _attachNotifyChangesCallback(events));

  static Map<String, DomEventConsumer<Element, Event>>?
      _attachNotifyChangesCallback<Element, Event>(
          Map<String, DomEventConsumer<Element, Event>>? events) {
    return events?.map((name, originalHandler) => MapEntry(name, (event) {
          final result = originalHandler(event);

          if (result is Future) {
            result.then((_) => changeDetection.postEvent(event));
          } else {
            changeDetection.postEvent(event);
          }
        }));
  }
}
