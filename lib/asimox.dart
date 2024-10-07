/// Support for doing something awesome.
library asimox;

export 'src/entrypoint.dart' show runApp;

export 'src/components/declarative_dom_node.dart' show DomNode;
export 'src/components/asimox_html.dart';

export 'src/events/event_typedefs.dart' show DomEvent, DomLifecycleEvent;
export 'src/events/event_consumers.dart'
    show DomEventConsumer, DomLifecycleEventConsumer;

export 'src/state_notifiers/change_detection.dart'
    show changeDetection, ChangeDetection;

export 'src/routes/web_router.dart' show WebRouter;
export 'src/routes/route.dart' show Route, RouteHandler;
export 'src/routes/route_middleware.dart' show Middleware;

export 'src/components/text.dart' show text, Text;
export 'src/components/raw_html.dart' show RawHtml;
export 'src/components/fragment.dart' show Fragment;
export 'src/components/builder.dart' show Builder, DomNodeBuilder;
