import 'package:asimox/src/components/_hyperscript_selector.dart';
import 'package:test/test.dart';

main() {
  group('Selector', () {
    test('parse empty selector', () {
      final selector = Selector.parse('');
      expect(selector.tagName, 'div');
      expect(selector.id, null);
      expect(selector.classes, []);
    });

    test('parse selector with id', () {
      final selector = Selector.parse('div#id');
      expect(selector.tagName, 'div');
      expect(selector.id, 'id');
      expect(selector.classes, []);
    });

    test('parse selector without tag name', () {
      final selector = Selector.parse('#id');
      expect(selector.tagName, 'div');
      expect(selector.id, 'id');
      expect(selector.classes, []);
    });

    test('parse selector with classes', () {
      final selector = Selector.parse('.class1.class2');
      expect(selector.tagName, 'div');
      expect(selector.id, null);
      expect(selector.classes, ['class1', 'class2']);
    });

    test('parse selector with id and classes', () {
      final selector = Selector.parse('div#id.class1.class2');
      expect(selector.tagName, 'div');
      expect(selector.id, 'id');
      expect(selector.classes, ['class1', 'class2']);
    });

    test('parse selector with tag name', () {
      final selector = Selector.parse('p');
      expect(selector.tagName, 'p');
      expect(selector.id, null);
      expect(selector.classes, []);
    });
  });
}
