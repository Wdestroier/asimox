import 'dart:async';

import 'package:domino/domino.dart' as domino show DomEvent, DomLifecycleEvent;

typedef DomEventConsumer<Element, Event> = FutureOr<void> Function(
  domino.DomEvent<Element, Event> event,
);

typedef DomLifecycleEventConsumer<Element> = FutureOr<void> Function(
  domino.DomLifecycleEvent<Element> event,
);
