import 'package:domino/browser.dart';
import 'package:web/web.dart';

void main() {
  EventStreamProvider<Event>('load').forTarget(window).listen((_) => _main());
}

void _main() {
  final root = document.getElementById('root')!;
  final app = _App();
  registerView(root: root, builderFn: app.call);
}

class _App extends DomNode {
  var _showSpan = true;

  @override
  DomNode build() =>
      throw Exception('_App.build() is never called in _App.call().');

  @override
  void call(DomBuilder b) {
    b.open(
      'p',
      onCreate: (e) {
        print("CREATED P");
      },
      onUpdate: (e) {
        print("UPDATED P");
      },
      onRemove: (e) {
        print("REMOVED P");
      },
    );
    b.close();

    if (_showSpan) {
      b.visit(DomElement(
        'span',
        onCreate: (e) {
          print("CREATED SPAN");
        },
        onUpdate: (e) {
          print("UPDATED SPAN");
        },
        onRemove: (e) {
          print("REMOVED SPAN");
        },
      ));
    }

    b.visit(DomElement(
      'button',
      id: 'app-button',
      events: {
        'click': (e) {
          _showSpan = false;
          e.view.invalidate();
        },
      },
    ));
  }
}
