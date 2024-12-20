// This file contains modifications of a class originally developed in the
// domino project.
// Copyright 2017, domino_html project authors. All rights reserved.
//
// Modifications have been made to this file.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted under the terms of the original license.
// See the LICENSE file for more details.
// https://github.com/agilord/domino/blob/8a84a84912400d4aa3b8b6dbed364fcc8f7f5c2a/domino_html/LICENSE

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

Future<void> main() async {
  await _fetchElements();
  await _fetchAttributes();
  await File('lib/src/components/asimox_html.dart')
      .writeAsString(_generateHtmlNodes());
  await Process.run('dart', ['format', '.']);
}

final _whitespace = RegExp(r'\s+');
final _elementDocs = <String, String>{};
final _elementAttributes = <String, List<String>>{};
final _attributeDocs = <String, String>{};

final _symbols = {
  'default',
  'for',
  'var',
};
final _boolAttributes = {
  'allowfullscreen',
  'async',
  'autofocus',
  'autoplay',
  'checked',
  'controls',
  'default',
  'defer',
  'disabled',
  'formnovalidate',
  'ismap',
  'itemscope',
  'loop',
  'multiple',
  'muted',
  'nomodule',
  'novalidate',
  'open',
  'playsinline',
  'readonly',
  'required',
  'reversed',
  'selected',
  'truespeed',
};

/// Extracted from: https://html.spec.whatwg.org/multipage/indices.html#events-2.
// TODO(wfontao): Add event descriptions as Dart documentation.
final events = [
  // Event(dartName, htmlName).
  ('onAfterPrint', 'afterprint'),
  ('onBeforePrint', 'beforeprint'),
  ('onBeforeMatch', 'beforematch'),
  ('onBeforeToggle', 'beforetoggle'),
  ('onBeforeUnload', 'beforeunload'),
  ('onBlur', 'blur'),
  ('onCancel', 'cancel'),
  ('onChange', 'change'),
  ('onClick', 'click'),
  ('onClose', 'close'),
  ('onConnect', 'connect'),
  ('onContextLost', 'contextlost'),
  ('onContextRestored', 'contextrestored'),
  ('onCurrentEntryChange', 'currententrychange'),
  ('onDispose', 'dispose'),
  ('onDomContentLoaded', 'DOMContentLoaded'),
  ('onError', 'error'),
  ('onFocus', 'focus'),
  ('onFormData', 'formdata'),
  ('onHashChange', 'hashchange'),
  ('onInput', 'input'),
  ('onInvalid', 'invalid'),
  ('onLanguageChange', 'languagechange'),
  ('onLoad', 'load'),
  ('onMessage', 'message'),
  ('onMessageError', 'messageerror'),
  ('onNavigate', 'navigate'),
  ('onNavigateError', 'navigateerror'),
  ('onNavigateSuccess', 'navigatesuccess'),
  ('onOffline', 'offline'),
  ('onOnline', 'online'),
  ('onOpen', 'open'),
  ('onPageSwap', 'pageswap'),
  ('onPageHide', 'pagehide'),
  ('onPageReveal', 'pagereveal'),
  ('onPageShow', 'pageshow'),
  ('onPointerCancel', 'pointercancel'),
  ('onPopState', 'popstate'),
  ('onReadyStateChange', 'readystatechange'),
  ('onRejectionHandled', 'rejectionhandled'),
  ('onReset', 'reset'),
  ('onSelect', 'select'),
  ('onStorage', 'storage'),
  ('onSubmit', 'submit'),
  ('onToggle', 'toggle'),
  ('onUnhandledRejection', 'unhandledrejection'),
  ('onUnload', 'unload'),
  ('onVisibilityChange', 'visibilitychange')
];

Future<void> _fetchElements() async {
  final rs = await http.get(
      Uri.parse('https://developer.mozilla.org/en-US/docs/Web/HTML/Element'));
  if (rs.statusCode != 200) {
    throw Exception('Unexpected status code: ${rs.statusCode}');
  }
  final doc = html_parser.parse(rs.body);
  final main = doc.body!.querySelector('main')!;
  for (final table in main.querySelectorAll('table')) {
    for (final row in table.querySelectorAll('tr')) {
      final cols = row.children
          .where((e) => e.localName!.toLowerCase() == 'td')
          .toList();
      if (cols.length != 2) continue;
      final parts =
          cols[0].text.trim().split(',').map((e) => e.trim()).toList();
      for (final part in parts) {
        final elem = part.substring(1, part.length - 1).trim();
        _elementDocs[elem] = cols[1].text.trim();
      }
    }
  }
}

Future<void> _fetchAttributes() async {
  final rs = await http.get(Uri.parse(
      'https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes'));
  if (rs.statusCode != 200) {
    throw Exception('Unexpected status code: ${rs.statusCode}');
  }
  final doc = html_parser.parse(rs.body);
  final main = doc.body!.querySelector('main')!;
  for (final table in main.querySelectorAll('table')) {
    for (final row in table.querySelectorAll('tr')) {
      final cols = row.children
          .where((e) => e.localName!.toLowerCase() == 'td')
          .toList();
      if (cols.length != 3) continue;
      var attr = cols[0].text.trim();
      if (attr.contains('Deprecated')) continue;
      if (attr.startsWith('data-')) continue;
      attr = attr.split(_whitespace).first.trim();
      final elements = cols[1].text.trim();
      final description = cols[2].text.trim();
      _attributeDocs[attr] = description;
      if (elements.toLowerCase().contains('global attribute')) {
        for (final elem in _elementDocs.keys) {
          _elementAttributes.putIfAbsent(elem, () => []).add(attr);
        }
      } else {
        final parts = elements
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.startsWith('<') && e.endsWith('>'))
            .map((e) => e.substring(1, e.length - 1).trim())
            .where((e) => e.isNotEmpty)
            .toList();
        for (final elem in parts) {
          _elementAttributes.putIfAbsent(elem, () => []).add(attr);
        }
      }
    }
  }
}

String _generateHtmlNodes() {
  final sb = StringBuffer();
  sb.writeln("import '../../asimox.dart';");
  sb.writeln("import '../state_notifiers/notifiable_dom_element.dart';");
  final elems = {
    ..._elementDocs.keys,
    ..._elementAttributes.keys,
  }.toList()
    ..sort();
  for (final elem in elems) {
    final events2 = (_elementAttributes[elem] ?? <String>[])
      ..remove('class')
      ..remove('style')
      ..sort();

    final doc = _splitDoc(_elementDocs[elem] ?? '', 70);
    sb.writeln(doc.map((e) => '/// $e').join('\n'));
    sb.writeln('DomElement<Element, Event> ${_name(elem)}<Element, Event>(');
    sb.writeln('{');
    sb.writeln('  String? key,');
    sb.writeln('  List<String>? classes,');
    sb.writeln('  Map<String, String>? attributes,');
    sb.writeln('  Map<String, String>? styles,');
    for (final attr in events2) {
      final isBool = _boolAttributes.contains(attr);
      final attrDoc = _splitDoc(_attributeDocs[attr] ?? '', 70);
      sb.writeln(attrDoc.map((e) => '/// $e').join('\n'));
      sb.writeln('  ${isBool ? 'bool' : 'String'}? ${_name(attr)},');
    }
    sb.writeln('  Map<String, DomEventConsumer<Element, Event>>? events,');
    for (var event in events) {
      final (dartName, _) = event;
      sb.writeln('  DomEventConsumer<Element, Event>? $dartName,');
    }
    sb.writeln('  DomLifecycleEventConsumer<Element>? onCreate,');
    sb.writeln('  DomLifecycleEventConsumer<Element>? onUpdate,');
    sb.writeln('  DomLifecycleEventConsumer<Element>? onRemove,');
    sb.writeln('  Iterable<DomNode<Element, Event>>? children,');
    sb.writeln('  DomNode<Element, Event>? child,');
    sb.writeln('  String? text,');
    sb.writeln('}');
    sb.writeln(') {');
    sb.writeln('  return DomElement<Element, Event>(\'$elem\',');
    sb.writeln('key: key,');
    sb.writeln('classes: classes,');
    sb.writeln('attributes: <String, String>{');
    for (final attr in events2) {
      final isBool = _boolAttributes.contains(attr);
      final name = _name(attr);
      if (isBool) {
        sb.writeln('if ($name ?? false) \'$attr\': \'$attr\',');
      } else {
        sb.writeln('if ($name != null) \'$attr\': $name,');
      }
    }
    sb.writeln('...?attributes,');
    sb.writeln('},');

    sb.writeln('styles: styles,');

    sb.writeln('events: <String, dynamic Function(DomEvent<Element, Event>)>{');
    for (final event in events) {
      final (dartName, htmlName) = event;
      sb.writeln('if ($dartName != null) \'$htmlName\': $dartName,');
    }
    sb.writeln('...?events,');
    sb.writeln('},');

    sb.writeln('onCreate: onCreate,');
    sb.writeln('onUpdate: onUpdate,');
    sb.writeln('onRemove: onRemove,');
    sb.writeln('children: children,');
    sb.writeln('child: child,');
    sb.writeln('text: text,');
    sb.writeln('  );');
    sb.writeln('}');
    sb.writeln('');
  }
  return sb.toString();
}

String _name(String name) {
  final parts = name.split('-');
  for (var i = 1; i < parts.length; i++) {
    parts[i] = parts[i].substring(0, 1).toUpperCase() + parts[i].substring(1);
  }
  final joined = parts.join('');
  if (_symbols.contains(joined)) {
    return '$joined\$';
  } else {
    return joined;
  }
}

List<String> _splitDoc(String value, int width) {
  final origLines = value.split('\n');
  return origLines.expand((line) {
    final parts = line.split(_whitespace);
    final sb = StringBuffer();
    var lastWidth = 0;
    for (final part in parts) {
      if (lastWidth > width) {
        sb.writeln();
        lastWidth = 0;
      }
      if (lastWidth > 0) {
        sb.write(' ');
        lastWidth++;
      }
      sb.write(part);
      lastWidth += part.length;
    }
    return sb.toString().split('\n');
  }).toList();
}
