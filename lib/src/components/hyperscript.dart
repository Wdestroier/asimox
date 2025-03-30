import 'dart:async';

import '../events/event_typedefs.dart';
import '_hyperscript_selector.dart';
import 'declarative_dom_node.dart';
import '../state_notifiers/notifiable_dom_element.dart';
import 'text.dart';

DomElement<Element, Event> h<Element, Event>(
  String selector, [
  var secondArgument,
  var thirdArgument,
]) {
  var Selector(:tagName, :id, :classes) = Selector.parse(selector);

  var attributes = (secondArgument is Map) ? secondArgument : const {};

  var children = thirdArgument ?? secondArgument;
  if (children is Map) children = null;

  var key = attributes['key'];

  var extraClasses = (attributes['class'] as String?)?.split(' ');
  if (extraClasses != null) classes = [...classes, ...extraClasses];

  // Should be taken from the style attribute.
  Map<String, String>? styles;

  // Global and standard HTML attributes, excluding event handler attributes.
  var stringAttributes = <String, String>{};
  // Event handler attributes.
  final eventHandlerAttributes =
      <String, FutureOr<void> Function(DomEvent<Element, Event>)>{};
  // Lifecycle event handler attributes, related to the incremental DOM.
  dynamic Function(DomLifecycleEvent<Element>)? onCreate, onUpdate, onRemove;

  for (var MapEntry(key: name, :value) in attributes.entries) {
    if (value is String) {
      stringAttributes[name] = value;
    } else if (value is FutureOr<void> Function(DomEvent<Element, Event>)) {
      eventHandlerAttributes[name] = value;
    } else if (value is FutureOr<void> Function(DomLifecycleEvent<Element>)) {
      switch (name.toLowerCase()) {
        case 'oncreate':
          onCreate = value;
        case 'onupdate':
          onUpdate = value;
        case 'onremove':
          onRemove = value;
      }
    }
  }

  if (id != null) stringAttributes['id'] = id;

  var childrenAsNode = (children is DomNode) ? children : null;
  var childrenAsList = (children is List)
      ? children
          .map((child) => (child is DomNode) ? child : Text(child as String))
          .toList()
      : null;
  var childrenAsString = (children is String) ? children : null;

  return DomElement<Element, Event>(
    tagName,
    key: key,
    classes: classes,
    attributes: stringAttributes,
    styles: styles,
    events: eventHandlerAttributes,
    onCreate: onCreate,
    onUpdate: onUpdate,
    onRemove: onRemove,
    children: childrenAsList,
    child: childrenAsNode,
    text: childrenAsString,
  );
}
