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
  await _fetchEvents();
  await File('lib/src/components/asimox_html.dart')
      .writeAsString(_generateHtmlNodes());
  await Process.run('dart', ['format', '.']);
}

final _whitespace = RegExp(r'\s+');

Map<String, String> _elementDocs = {};
final _defaultElementDocs = {
  'html':
      'Represents the root (top-level element) of an HTML document, so it is also referred to as the root element. All other elements must be descendants of this element.',
  'base':
      'Specifies the base URL to use for all relative URLs in a document. There can be only one such element in a document.',
  'head':
      'Contains machine-readable information (metadata) about the document, like its title, scripts, and style sheets.',
  'link':
      'Specifies relationships between the current document and an external resource. This element is most commonly used to link to CSS but is also used to establish site icons (both "favicon" style icons and icons for the home screen and apps on mobile devices) among other things.',
  'meta':
      'Represents metadata that cannot be represented by other HTML meta-related elements, like <base>, <link>, <script>, <style> and <title>.',
  'style':
      'Contains style information for a document or part of a document. It contains CSS, which is applied to the contents of the document containing this element.',
  'title':
      'Defines the document\'s title that is shown in a browser\'s title bar or a page\'s tab. It only contains text; HTML tags within the element, if any, are also treated as plain text.',
  'body':
      'Represents the content of an HTML document. There can be only one such element in a document.',
  'address':
      'Indicates that the enclosed HTML provides contact information for a person or people, or for an organization.',
  'article':
      'Represents a self-contained composition in a document, page, application, or site, which is intended to be independently distributable or reusable (e.g., in syndication). Examples include a forum post, a magazine or newspaper article, a blog entry, a product card, a user-submitted comment, an interactive widget or gadget, or any other independent item of content.',
  'aside':
      'Represents a portion of a document whose content is only indirectly related to the document\'s main content. Asides are frequently presented as sidebars or call-out boxes.',
  'footer':
      'Represents a footer for its nearest ancestor sectioning content or sectioning root element. A <footer> typically contains information about the author of the section, copyright data, or links to related documents.',
  'header':
      'Represents introductory content, typically a group of introductory or navigational aids. It may contain some heading elements but also a logo, a search form, an author name, and other elements.',
  'h1':
      'Represent six levels of section headings. <h1> is the highest section level and <h6> is the lowest.',
  'h2':
      'Represent six levels of section headings. <h1> is the highest section level and <h6> is the lowest.',
  'h3':
      'Represent six levels of section headings. <h1> is the highest section level and <h6> is the lowest.',
  'h4':
      'Represent six levels of section headings. <h1> is the highest section level and <h6> is the lowest.',
  'h5':
      'Represent six levels of section headings. <h1> is the highest section level and <h6> is the lowest.',
  'h6':
      'Represent six levels of section headings. <h1> is the highest section level and <h6> is the lowest.',
  'hgroup':
      'Represents a heading grouped with any secondary content, such as subheadings, an alternative title, or a tagline.',
  'main':
      'Represents the dominant content of the body of a document. The main content area consists of content that is directly related to or expands upon the central topic of a document, or the central functionality of an application.',
  'nav':
      'Represents a section of a page whose purpose is to provide navigation links, either within the current document or to other documents. Common examples of navigation sections are menus, tables of contents, and indexes.',
  'section':
      'Represents a generic standalone section of a document, which doesn\'t have a more specific semantic element to represent it. Sections should always have a heading, with very few exceptions.',
  'search':
      'Represents a part that contains a set of form controls or other content related to performing a search or filtering operation.',
  'blockquote':
      'Indicates that the enclosed text is an extended quotation. Usually, this is rendered visually by indentation. A URL for the source of the quotation may be given using the cite attribute, while a text representation of the source can be given using the <cite> element.',
  'dd':
      'Provides the description, definition, or value for the preceding term (<dt>) in a description list (<dl>).',
  'div':
      'The generic container for flow content. It has no effect on the content or layout until styled in some way using CSS (e.g., styling is directly applied to it, or some kind of layout model like flexbox is applied to its parent element).',
  'dl':
      'Represents a description list. The element encloses a list of groups of terms (specified using the <dt> element) and descriptions (provided by <dd> elements). Common uses for this element are to implement a glossary or to display metadata (a list of key-value pairs).',
  'dt':
      'Specifies a term in a description or definition list, and as such must be used inside a <dl> element. It is usually followed by a <dd> element; however, multiple <dt> elements in a row indicate several terms that are all defined by the immediate next <dd> element.',
  'figcaption':
      'Represents a caption or legend describing the rest of the contents of its parent <figure> element.',
  'figure':
      'Represents self-contained content, potentially with an optional caption, which is specified using the <figcaption> element. The figure, its caption, and its contents are referenced as a single unit.',
  'hr':
      'Represents a thematic break between paragraph-level elements: for example, a change of scene in a story, or a shift of topic within a section.',
  'li':
      'Represents an item in a list. It must be contained in a parent element: an ordered list (<ol>), an unordered list (<ul>), or a menu (<menu>). In menus and unordered lists, list items are usually displayed using bullet points. In ordered lists, they are usually displayed with an ascending counter on the left, such as a number or letter.',
  'menu':
      'A semantic alternative to <ul>, but treated by browsers (and exposed through the accessibility tree) as no different than <ul>. It represents an unordered list of items (which are represented by <li> elements).',
  'ol':
      'Represents an ordered list of items â typically rendered as a numbered list.',
  'p':
      'Represents a paragraph. Paragraphs are usually represented in visual media as blocks of text separated from adjacent blocks by blank lines and/or first-line indentation, but HTML paragraphs can be any structural grouping of related content, such as images or form fields.',
  'pre':
      'Represents preformatted text which is to be presented exactly as written in the HTML file. The text is typically rendered using a non-proportional, or monospaced, font. Whitespace inside this element is displayed as written.',
  'ul':
      'Represents an unordered list of items, typically rendered as a bulleted list.',
  'a':
      'Together with its href attribute, creates a hyperlink to web pages, files, email addresses, locations within the current page, or anything else a URL can address.',
  'abbr': 'Represents an abbreviation or acronym.',
  'b':
      'Used to draw the reader\'s attention to the element\'s contents, which are not otherwise granted special importance. This was formerly known as the Boldface element, and most browsers still draw the text in boldface. However, you should not use <b> for styling text or granting importance. If you wish to create boldface text, you should use the CSS font-weight property. If you wish to indicate an element is of special importance, you should use the <strong> element.',
  'bdi':
      'Tells the browser\'s bidirectional algorithm to treat the text it contains in isolation from its surrounding text. It\'s particularly useful when a website dynamically inserts some text and doesn\'t know the directionality of the text being inserted.',
  'bdo':
      'Overrides the current directionality of text, so that the text within is rendered in a different direction.',
  'br':
      'Produces a line break in text (carriage-return). It is useful for writing a poem or an address, where the division of lines is significant.',
  'cite':
      'Used to mark up the title of a cited creative work. The reference may be in an abbreviated form according to context-appropriate conventions related to citation metadata.',
  'code':
      'Displays its contents styled in a fashion intended to indicate that the text is a short fragment of computer code. By default, the content text is displayed using the user agent\'s default monospace font.',
  'data':
      'Links a given piece of content with a machine-readable translation. If the content is time- or date-related, the <time> element must be used.',
  'dfn':
      'Used to indicate the term being defined within the context of a definition phrase or sentence. The ancestor <p> element, the <dt>/<dd> pairing, or the nearest section ancestor of the <dfn> element, is considered to be the definition of the term.',
  'em':
      'Marks text that has stress emphasis. The <em> element can be nested, with each nesting level indicating a greater degree of emphasis.',
  'i':
      'Represents a range of text that is set off from the normal text for some reason, such as idiomatic text, technical terms, and taxonomical designations, among others. Historically, these have been presented using italicized type, which is the original source of the <i> naming of this element.',
  'kbd':
      'Represents a span of inline text denoting textual user input from a keyboard, voice input, or any other text entry device. By convention, the user agent defaults to rendering the contents of a <kbd> element using its default monospace font, although this is not mandated by the HTML standard.',
  'mark':
      'Represents text which is marked or highlighted for reference or notation purposes due to the marked passage\'s relevance in the enclosing context.',
  'q':
      'Indicates that the enclosed text is a short inline quotation. Most modern browsers implement this by surrounding the text in quotation marks. This element is intended for short quotations that don\'t require paragraph breaks; for long quotations use the <blockquote> element.',
  'rp':
      'Used to provide fall-back parentheses for browsers that do not support the display of ruby annotations using the <ruby> element. One <rp> element should enclose each of the opening and closing parentheses that wrap the <rt> element that contains the annotation\'s text.',
  'rt':
      'Specifies the ruby text component of a ruby annotation, which is used to provide pronunciation, translation, or transliteration information for East Asian typography. The <rt> element must always be contained within a <ruby> element.',
  'ruby':
      'Represents small annotations that are rendered above, below, or next to base text, usually used for showing the pronunciation of East Asian characters. It can also be used for annotating other kinds of text, but this usage is less common.',
  's':
      'Renders text with a strikethrough, or a line through it. Use the <s> element to represent things that are no longer relevant or no longer accurate. However, <s> is not appropriate when indicating document edits; for that, use the <del> and <ins> elements, as appropriate.',
  'samp':
      'Used to enclose inline text which represents sample (or quoted) output from a computer program. Its contents are typically rendered using the browser\'s default monospaced font (such as Courier or Lucida Console).',
  'small':
      'Represents side-comments and small print, like copyright and legal text, independent of its styled presentation. By default, it renders text within it one font size smaller, such as from small to x-small.',
  'span':
      'A generic inline container for phrasing content, which does not inherently represent anything. It can be used to group elements for styling purposes (using the class or id attributes), or because they share attribute values, such as lang. It should be used only when no other semantic element is appropriate. <span> is very much like a div element, but div is a block-level element whereas a <span> is an inline-level element.',
  'strong':
      'Indicates that its contents have strong importance, seriousness, or urgency. Browsers typically render the contents in bold type.',
  'sub':
      'Specifies inline text which should be displayed as subscript for solely typographical reasons. Subscripts are typically rendered with a lowered baseline using smaller text.',
  'sup':
      'Specifies inline text which is to be displayed as superscript for solely typographical reasons. Superscripts are usually rendered with a raised baseline using smaller text.',
  'time':
      'Represents a specific period in time. It may include the datetime attribute to translate dates into machine-readable format, allowing for better search engine results or custom features such as reminders.',
  'u':
      'Represents a span of inline text which should be rendered in a way that indicates that it has a non-textual annotation. This is rendered by default as a single solid underline but may be altered using CSS.',
  'var':
      'Represents the name of a variable in a mathematical expression or a programming context. It\'s typically presented using an italicized version of the current typeface, although that behavior is browser-dependent.',
  'wbr':
      'Represents a word break opportunityâa position within text where the browser may optionally break a line, though its line-breaking rules would not otherwise create a break at that location.',
  'area':
      'Defines an area inside an image map that has predefined clickable areas. An image map allows geometric areas on an image to be associated with hyperlink.',
  'audio':
      'Used to embed sound content in documents. It may contain one or more audio sources, represented using the src attribute or the source element: the browser will choose the most suitable one. It can also be the destination for streamed media, using a MediaStream.',
  'img': 'Embeds an image into the document.',
  'map':
      'Used with <area> elements to define an image map (a clickable link area).',
  'track':
      'Used as a child of the media elements, audio and video. It lets you specify timed text tracks (or time-based data), for example to automatically handle subtitles. The tracks are formatted in WebVTT format (.vtt files)âWeb Video Text Tracks.',
  'video':
      'Embeds a media player which supports video playback into the document. You can also use <video> for audio content, but the audio element may provide a more appropriate user experience.',
  'embed':
      'Embeds external content at the specified point in the document. This content is provided by an external application or other source of interactive content such as a browser plug-in.',
  'fencedframe':
      'Represents a nested browsing context, like <iframe> but with more native privacy features built in.',
  'iframe':
      'Represents a nested browsing context, embedding another HTML page into the current one.',
  'object':
      'Represents an external resource, which can be treated as an image, a nested browsing context, or a resource to be handled by a plugin.',
  'picture':
      'Contains zero or more <source> elements and one <img> element to offer alternative versions of an image for different display/device scenarios.',
  'source':
      'Specifies multiple media resources for the picture, the audio element, or the video element. It is a void element, meaning that it has no content and does not have a closing tag. It is commonly used to offer the same media content in multiple file formats in order to provide compatibility with a broad range of browsers given their differing support for image file formats and media file formats.',
  'svg':
      'Container defining a new coordinate system and viewport. It is used as the outermost element of SVG documents, but it can also be used to embed an SVG fragment inside an SVG or HTML document.',
  'math':
      'The top-level element in MathML. Every valid MathML instance must be wrapped in it. In addition, you must not nest a second <math> element in another, but you can have an arbitrary number of other child elements in it.',
  'canvas':
      'Container element to use with either the canvas scripting API or the WebGL API to draw graphics and animations.',
  'noscript':
      'Defines a section of HTML to be inserted if a script type on the page is unsupported or if scripting is currently turned off in the browser.',
  'script':
      'Used to embed executable code or data; this is typically used to embed or refer to JavaScript code. The <script> element can also be used with other languages, such as WebGL\'s GLSL shader programming language and JSON.',
  'del':
      'Represents a range of text that has been deleted from a document. This can be used when rendering "track changes" or source code diff information, for example. The <ins> element can be used for the opposite purpose: to indicate text that has been added to the document.',
  'ins':
      'Represents a range of text that has been added to a document. You can use the <del> element to similarly represent a range of text that has been deleted from the document.',
  'caption': 'Specifies the caption (or title) of a table.',
  'col':
      'Defines one or more columns in a column group represented by its implicit or explicit parent <colgroup> element. The <col> element is only valid as a child of a <colgroup> element that has no span attribute defined.',
  'colgroup': 'Defines a group of columns within a table.',
  'table':
      'Represents tabular dataâthat is, information presented in a two-dimensional table comprised of rows and columns of cells containing data.',
  'tbody':
      'Encapsulates a set of table rows (<tr> elements), indicating that they comprise the body of a table\'s (main) data.',
  'td':
      'A child of the <tr> element, it defines a cell of a table that contains data.',
  'tfoot':
      'Encapsulates a set of table rows (<tr> elements), indicating that they comprise the foot of a table with information about the table\'s columns. This is usually a summary of the columns, e.g., a sum of the given numbers in a column.',
  'th':
      'A child of the <tr> element, it defines a cell as the header of a group of table cells. The nature of this group can be explicitly defined by the scope and headers attributes.',
  'thead':
      'Encapsulates a set of table rows (<tr> elements), indicating that they comprise the head of a table with information about the table\'s columns. This is usually in the form of column headers (<th> elements).',
  'tr':
      'Defines a row of cells in a table. The row\'s cells can then be established using a mix of <td> (data cell) and <th> (header cell) elements.',
  'button':
      'An interactive element activated by a user with a mouse, keyboard, finger, voice command, or other assistive technology. Once activated, it performs an action, such as submitting a form or opening a dialog.',
  'datalist':
      'Contains a set of <option> elements that represent the permissible or recommended options available to choose from within other controls.',
  'fieldset':
      'Used to group several controls as well as labels (<label>) within a web form.',
  'form':
      'Represents a document section containing interactive controls for submitting information.',
  'input':
      'Used to create interactive controls for web-based forms to accept data from the user; a wide variety of types of input data and control widgets are available, depending on the device and user agent. The <input> element is one of the most powerful and complex in all of HTML due to the sheer number of combinations of input types and attributes.',
  'label': 'Represents a caption for an item in a user interface.',
  'legend': 'Represents a caption for the content of its parent <fieldset>.',
  'meter':
      'Represents either a scalar value within a known range or a fractional value.',
  'optgroup': 'Creates a grouping of options within a <select> element.',
  'option':
      'Used to define an item contained in a select, an <optgroup>, or a <datalist> element. As such, <option> can represent menu items in popups and other lists of items in an HTML document.',
  'output':
      'Container element into which a site or app can inject the results of a calculation or the outcome of a user action.',
  'progress':
      'Displays an indicator showing the completion progress of a task, typically displayed as a progress bar.',
  'select': 'Represents a control that provides a menu of options.',
  'textarea':
      'Represents a multi-line plain-text editing control, useful when you want to allow users to enter a sizeable amount of free-form text, for example, a comment on a review or feedback form.',
  'details':
      'Creates a disclosure widget in which information is visible only when the widget is toggled into an "open" state. A summary or label must be provided using the <summary> element.',
  'dialog':
      'Represents a dialog box or other interactive component, such as a dismissible alert, inspector, or subwindow.',
  'summary':
      'Specifies a summary, caption, or legend for a details element\'s disclosure box. Clicking the <summary> element toggles the state of the parent <details> element open and closed.',
  'slot':
      'Part of the Web Components technology suite, this element is a placeholder inside a web component that you can fill with your own markup, which lets you create separate DOM trees and present them together.',
  'template':
      'A mechanism for holding HTML that is not to be rendered immediately when a page is loaded but may be instantiated subsequently during runtime using JavaScript.',
  'acronym':
      'Allows authors to clearly indicate a sequence of characters that compose an acronym or abbreviation for a word.',
  'big':
      'Renders the enclosed text at a font size one level larger than the surrounding text (medium becomes large, for example). The size is capped at the browser\'s maximum permitted font size.',
  'center':
      'Displays its block-level or inline contents centered horizontally within its containing element.',
  'content':
      'An obsolete part of the Web Components suite of technologiesâwas used inside of Shadow DOM as an insertion point, and wasn\'t meant to be used in ordinary HTML. It has now been replaced by the <slot> element, which creates a point in the DOM at which a shadow DOM can be inserted. Consider using <slot> instead.',
  'dir':
      'Container for a directory of files and/or folders, potentially with styles and icons applied by the user agent. Do not use this obsolete element; instead, you should use the <ul> element for lists, including lists of files.',
  'font': 'Defines the font size, color and face for its content.',
  'frame':
      'Defines a particular area in which another HTML document can be displayed. A frame should be used within a <frameset>.',
  'frameset': 'Used to contain <frame> elements.',
  'image':
      'An ancient and poorly supported precursor to the <img> element. It should not be used.',
  'marquee':
      'Used to insert a scrolling area of text. You can control what happens when the text reaches the edges of its content area using its attributes.',
  'menuitem':
      'Represents a command that a user is able to invoke through a popup menu. This includes context menus, as well as menus that might be attached to a menu button.',
  'nobr':
      'Prevents the text it contains from automatically wrapping across multiple lines, potentially resulting in the user having to scroll horizontally to see the entire width of the text.',
  'noembed':
      'An obsolete, non-standard way to provide alternative, or "fallback", content for browsers that do not support the embed element or do not support the type of embedded content an author wishes to use. This element was deprecated in HTML 4.01 and above in favor of placing fallback content between the opening and closing tags of an <object> element.',
  'noframes':
      'Provides content to be presented in browsers that don\'t support (or have disabled support for) the <frame> element. Although most commonly-used browsers support frames, there are exceptions, including certain special-use browsers including some mobile browsers, as well as text-mode browsers.',
  'param': 'Defines parameters for an <object> element.',
  'plaintext':
      'Renders everything following the start tag as raw text, ignoring any following HTML. There is no closing tag, since everything after it is considered raw text.',
  'rb':
      'Used to delimit the base text component of a ruby annotation, i.e. the text that is being annotated. One <rb> element should wrap each separate atomic segment of the base text.',
  'rtc':
      'Embraces semantic annotations of characters presented in a ruby of <rb> elements used inside of <ruby> element. <rb> elements can have both pronunciation (<rt>) and semantic (<rtc>) annotations.',
  'shadow':
      'An obsolete part of the Web Components technology suite that was intended to be used as a shadow DOM insertion point. You might have used it if you have created multiple shadow roots under a shadow host. Consider using <slot> instead.',
  'strike': 'Places a strikethrough (horizontal line) over text.',
  'tt':
      'Creates inline text which is presented using the user agent default monospace font face. This element was created for the purpose of rendering text as it would be displayed on a fixed-width display such as a teletype, text-only screen, or line printer.',
  'xmp':
      'Renders text between the start and end tags without interpreting the HTML in between and using a monospaced font. The HTML2 specification recommended that it should be rendered wide enough to allow 80 characters per line.'
};

Map<String, List<String>> _elementAttributes = {};
final _defaultAttributes = {
  'form': [
    'accept',
    'accept-charset',
    'accesskey',
    'action',
    'autocapitalize',
    'autocomplete',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'enctype',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'method',
    'name',
    'novalidate',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'target',
    'title',
    'translate'
  ],
  'input': [
    'accept',
    'accesskey',
    'alt',
    'autocapitalize',
    'autocomplete',
    'capture',
    'checked',
    'class',
    'contenteditable',
    'dir',
    'dirname',
    'disabled',
    'draggable',
    'form',
    'formaction',
    'formenctype',
    'formmethod',
    'formnovalidate',
    'formtarget',
    'height',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'list',
    'max',
    'maxlength',
    'minlength',
    'min',
    'multiple',
    'name',
    'pattern',
    'placeholder',
    'readonly',
    'required',
    'role',
    'size',
    'slot',
    'spellcheck',
    'src',
    'step',
    'style',
    'tabindex',
    'title',
    'translate',
    'type',
    'usemap',
    'value',
    'width'
  ],
  'html': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'base': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'href',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'target',
    'title',
    'translate'
  ],
  'head': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'link': [
    'accesskey',
    'as',
    'autocapitalize',
    'class',
    'contenteditable',
    'crossorigin',
    'dir',
    'draggable',
    'hidden',
    'href',
    'hreflang',
    'id',
    'integrity',
    'itemprop',
    'lang',
    'media',
    'referrerpolicy',
    'rel',
    'role',
    'sizes',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'type'
  ],
  'meta': [
    'accesskey',
    'autocapitalize',
    'charset',
    'class',
    'content',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'http-equiv',
    'id',
    'itemprop',
    'lang',
    'name',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'style': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'media',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'type'
  ],
  'title': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'body': [
    'accesskey',
    'autocapitalize',
    'background',
    'bgcolor',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'address': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'article': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'aside': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'footer': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'header': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'h1': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'h2': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'h3': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'h4': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'h5': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'h6': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'hgroup': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'main': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'nav': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'section': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'search': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'blockquote': [
    'accesskey',
    'autocapitalize',
    'cite',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'dd': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'div': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'dl': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'dt': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'figcaption': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'figure': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'hr': [
    'accesskey',
    'autocapitalize',
    'class',
    'color',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'li': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'value'
  ],
  'menu': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'type'
  ],
  'ol': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'reversed',
    'role',
    'slot',
    'spellcheck',
    'start',
    'style',
    'tabindex',
    'title',
    'translate',
    'type'
  ],
  'p': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'pre': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'ul': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'a': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'download',
    'draggable',
    'hidden',
    'href',
    'hreflang',
    'id',
    'itemprop',
    'lang',
    'media',
    'ping',
    'referrerpolicy',
    'rel',
    'role',
    'shape',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'target',
    'title',
    'translate'
  ],
  'abbr': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'b': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'bdi': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'bdo': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'br': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'cite': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'code': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'data': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'value'
  ],
  'dfn': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'em': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'i': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'kbd': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'mark': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'q': [
    'accesskey',
    'autocapitalize',
    'cite',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'rp': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'rt': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'ruby': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  's': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'samp': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'small': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'span': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'strong': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'sub': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'sup': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'time': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'datetime',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'u': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'var': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'wbr': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'area': [
    'accesskey',
    'alt',
    'autocapitalize',
    'class',
    'contenteditable',
    'coords',
    'dir',
    'download',
    'draggable',
    'hidden',
    'href',
    'id',
    'itemprop',
    'lang',
    'media',
    'ping',
    'referrerpolicy',
    'rel',
    'role',
    'shape',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'target',
    'title',
    'translate'
  ],
  'audio': [
    'accesskey',
    'autocapitalize',
    'autoplay',
    'class',
    'contenteditable',
    'controls',
    'crossorigin',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'loop',
    'muted',
    'preload',
    'role',
    'slot',
    'spellcheck',
    'src',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'img': [
    'accesskey',
    'alt',
    'autocapitalize',
    'border',
    'class',
    'contenteditable',
    'crossorigin',
    'decoding',
    'dir',
    'draggable',
    'height',
    'hidden',
    'id',
    'ismap',
    'itemprop',
    'lang',
    'loading',
    'referrerpolicy',
    'role',
    'sizes',
    'slot',
    'spellcheck',
    'src',
    'srcset',
    'style',
    'tabindex',
    'title',
    'translate',
    'usemap',
    'width'
  ],
  'map': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'name',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'track': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'default',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'kind',
    'label',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'src',
    'srclang',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'video': [
    'accesskey',
    'autocapitalize',
    'autoplay',
    'class',
    'contenteditable',
    'controls',
    'crossorigin',
    'dir',
    'draggable',
    'height',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'loop',
    'muted',
    'playsinline',
    'poster',
    'preload',
    'role',
    'slot',
    'spellcheck',
    'src',
    'style',
    'tabindex',
    'title',
    'translate',
    'width'
  ],
  'embed': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'height',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'src',
    'style',
    'tabindex',
    'title',
    'translate',
    'type',
    'width'
  ],
  'fencedframe': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'iframe': [
    'accesskey',
    'allow',
    'autocapitalize',
    'class',
    'contenteditable',
    'csp',
    'dir',
    'draggable',
    'height',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'loading',
    'name',
    'referrerpolicy',
    'role',
    'sandbox',
    'slot',
    'spellcheck',
    'src',
    'srcdoc',
    'style',
    'tabindex',
    'title',
    'translate',
    'width'
  ],
  'object': [
    'accesskey',
    'autocapitalize',
    'border',
    'class',
    'contenteditable',
    'data',
    'dir',
    'draggable',
    'form',
    'height',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'name',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'type',
    'usemap',
    'width'
  ],
  'picture': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'source': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'media',
    'role',
    'sizes',
    'slot',
    'spellcheck',
    'src',
    'srcset',
    'style',
    'tabindex',
    'title',
    'translate',
    'type'
  ],
  'svg': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'math': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'canvas': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'height',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'width'
  ],
  'noscript': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'script': [
    'accesskey',
    'async',
    'autocapitalize',
    'class',
    'contenteditable',
    'crossorigin',
    'defer',
    'dir',
    'draggable',
    'hidden',
    'id',
    'integrity',
    'itemprop',
    'lang',
    'referrerpolicy',
    'role',
    'slot',
    'spellcheck',
    'src',
    'style',
    'tabindex',
    'title',
    'translate',
    'type'
  ],
  'del': [
    'accesskey',
    'autocapitalize',
    'cite',
    'class',
    'contenteditable',
    'datetime',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'ins': [
    'accesskey',
    'autocapitalize',
    'cite',
    'class',
    'contenteditable',
    'datetime',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'caption': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'col': [
    'accesskey',
    'autocapitalize',
    'bgcolor',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'span',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'colgroup': [
    'accesskey',
    'autocapitalize',
    'bgcolor',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'span',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'table': [
    'accesskey',
    'autocapitalize',
    'background',
    'bgcolor',
    'border',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'tbody': [
    'accesskey',
    'autocapitalize',
    'bgcolor',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'td': [
    'accesskey',
    'autocapitalize',
    'background',
    'bgcolor',
    'class',
    'colspan',
    'contenteditable',
    'dir',
    'draggable',
    'headers',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'rowspan',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'tfoot': [
    'accesskey',
    'autocapitalize',
    'bgcolor',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'th': [
    'accesskey',
    'autocapitalize',
    'background',
    'bgcolor',
    'class',
    'colspan',
    'contenteditable',
    'dir',
    'draggable',
    'headers',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'rowspan',
    'scope',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'thead': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'tr': [
    'accesskey',
    'autocapitalize',
    'bgcolor',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'button': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'disabled',
    'draggable',
    'form',
    'formaction',
    'formenctype',
    'formmethod',
    'formnovalidate',
    'formtarget',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'name',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'type',
    'value'
  ],
  'datalist': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'fieldset': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'disabled',
    'draggable',
    'form',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'name',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'label': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'for',
    'form',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'legend': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'meter': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'form',
    'hidden',
    'high',
    'id',
    'itemprop',
    'lang',
    'low',
    'max',
    'min',
    'optimum',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'value'
  ],
  'optgroup': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'disabled',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'label',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'option': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'disabled',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'label',
    'lang',
    'role',
    'selected',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'value'
  ],
  'output': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'for',
    'form',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'name',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'progress': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'form',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'max',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'value'
  ],
  'select': [
    'accesskey',
    'autocapitalize',
    'autocomplete',
    'class',
    'contenteditable',
    'dir',
    'disabled',
    'draggable',
    'form',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'multiple',
    'name',
    'required',
    'role',
    'size',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'textarea': [
    'accesskey',
    'autocapitalize',
    'autocomplete',
    'class',
    'cols',
    'contenteditable',
    'dir',
    'dirname',
    'disabled',
    'draggable',
    'enterkeyhint',
    'form',
    'hidden',
    'id',
    'inputmode',
    'itemprop',
    'lang',
    'maxlength',
    'minlength',
    'name',
    'placeholder',
    'readonly',
    'required',
    'role',
    'rows',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'wrap'
  ],
  'details': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'open',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'dialog': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'open',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'summary': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'slot': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'template': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'acronym': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'big': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'center': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'content': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'dir': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'font': [
    'accesskey',
    'autocapitalize',
    'class',
    'color',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'frame': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'frameset': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'image': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'marquee': [
    'accesskey',
    'autocapitalize',
    'bgcolor',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'loop',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'menuitem': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'nobr': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'noembed': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'noframes': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'param': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'name',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate',
    'value'
  ],
  'plaintext': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'rb': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'rtc': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'shadow': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'strike': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'tt': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ],
  'xmp': [
    'accesskey',
    'autocapitalize',
    'class',
    'contenteditable',
    'dir',
    'draggable',
    'hidden',
    'id',
    'itemprop',
    'lang',
    'role',
    'slot',
    'spellcheck',
    'style',
    'tabindex',
    'title',
    'translate'
  ]
};

Map<String, String> _attributeDocs = {};
final _defaultAttributeDocs = {
  'accept': 'List of types the server accepts, typically a file type.',
  'accept-charset': 'The character set, which if provided must be "UTF-8".',
  'accesskey': 'Keyboard shortcut to activate or add focus to the element.',
  'action':
      'The URI of a program that processes the information submitted via the\n        form.',
  'allow': 'Specifies a feature-policy for the iframe.',
  'alt': 'Alternative text in case an image can\'t be displayed.',
  'as': 'Specifies the type of content being loaded by the link.',
  'async': 'Executes the script asynchronously.',
  'autocapitalize':
      'Sets whether input is automatically capitalized when entered by user',
  'autocomplete':
      'Indicates whether controls in this form can by default have their values\n        automatically completed by the browser.',
  'autoplay': 'The audio or video should play as soon as possible.',
  'background':
      'Specifies the URL of an image file.\n        \n          \n            Note: Although browsers and email clients may still\n            support this attribute, it is obsolete. Use CSS\n            background-image instead.',
  'bgcolor':
      'Background color of the element.\n        \n          \n            Note: This is a legacy attribute. Please use the\n            CSS background-color property instead.',
  'border':
      'The border width.\n        \n          \n            Note: This is a legacy attribute. Please use the\n            CSS border property instead.',
  'capture':
      'From the Media Capture specification,\n        specifies a new file can be captured.',
  'charset': 'Declares the character encoding of the page or script.',
  'checked': 'Indicates whether the element should be checked on page load.',
  'cite': 'Contains a URI which points to the source of the quote or change.',
  'class': 'Often used with CSS to style elements with common properties.',
  'color':
      'This attribute sets the text color using either a named color or a\n          color specified in the hexadecimal #RRGGBB format.\n        \n        \n          \n            Note: This is a legacy attribute. Please use the\n            CSS color property instead.',
  'cols': 'Defines the number of columns in a textarea.',
  'colspan':
      'The colspan attribute defines the number of columns a cell should span.',
  'content':
      'A value associated with http-equiv or\n        name depending on the context.',
  'contenteditable': 'Indicates whether the element\'s content is editable.',
  'controls':
      'Indicates whether the browser should show playback controls to the user.',
  'coords':
      'A set of values specifying the coordinates of the hot-spot region.',
  'crossorigin': 'How the element handles cross-origin requests',
  'csp':
      'Specifies the Content Security Policy that an embedded document must\n        agree to enforce upon itself.',
  'data': 'Specifies the URL of the resource.',
  'datetime': 'Indicates the date and time associated with the element.',
  'decoding': 'Indicates the preferred method to decode the image.',
  'default':
      'Indicates that the track should be enabled unless the user\'s preferences\n        indicate something different.',
  'defer':
      'Indicates that the script should be executed after the page has been\n        parsed.',
  'dir':
      'Defines the text direction. Allowed values are ltr (Left-To-Right) or\n        rtl (Right-To-Left)',
  'dirname': '',
  'disabled': 'Indicates whether the user can interact with the element.',
  'download':
      'Indicates that the hyperlink is to be used for downloading a resource.',
  'draggable': 'Defines whether the element can be dragged.',
  'enctype':
      'Defines the content type of the form data when the\n        method is POST.',
  'enterkeyhint':
      'The enterkeyhint\n        specifies what action label (or icon) to present for the enter key on\n        virtual keyboards. The attribute can be used with form controls (such as\n        the value of textarea elements), or in elements in an\n        editing host (e.g., using contenteditable attribute).',
  'for': 'Describes elements which belongs to this one.',
  'form': 'Indicates the form that is the owner of the element.',
  'formaction':
      'Indicates the action of the element, overriding the action defined in\n        the <form>.',
  'formenctype':
      'If the button/input is a submit button (e.g. type="submit"),\n        this attribute sets the encoding type to use during form submission. If\n        this attribute is specified, it overrides the\n        enctype attribute of the button\'s\n        form owner.',
  'formmethod':
      'If the button/input is a submit button (e.g. type="submit"),\n        this attribute sets the submission method to use during form submission\n        (GET, POST, etc.). If this attribute is\n        specified, it overrides the method attribute of the\n        button\'s form owner.',
  'formnovalidate':
      'If the button/input is a submit button (e.g. type="submit"),\n        this boolean attribute specifies that the form is not to be validated\n        when it is submitted. If this attribute is specified, it overrides the\n        novalidate attribute of the button\'s\n        form owner.',
  'formtarget':
      'If the button/input is a submit button (e.g. type="submit"),\n        this attribute specifies the browsing context (for example, tab, window,\n        or inline frame) in which to display the response that is received after\n        submitting the form. If this attribute is specified, it overrides the\n        target attribute of the button\'s\n        form owner.',
  'headers': 'IDs of the <th> elements which applies to this\n        element.',
  'height':
      'Specifies the height of elements listed here. For all other elements,\n          use the CSS height property.\n        \n        \n          \n            Note: In some instances, such as\n            <div>, this is a legacy attribute, in\n            which case the CSS height property should\n            be used instead.',
  'hidden':
      'Prevents rendering of given element, while keeping child elements, e.g.\n        script elements, active.',
  'high': 'Indicates the lower bound of the upper range.',
  'href': 'The URL of a linked resource.',
  'hreflang': 'Specifies the language of the linked resource.',
  'http-equiv': 'Defines a pragma directive.',
  'id':
      'Often used with CSS to style a specific element. The value of this\n        attribute must be unique.',
  'integrity':
      'Specifies a\n          Subresource Integrity\n          value that allows browsers to verify what they fetch.',
  'inputmode':
      'Provides a hint as to the type of data that might be entered by the user\n        while editing the element or its contents. The attribute can be used\n        with form controls (such as the value of\n        textarea elements), or in elements in an editing host\n        (e.g., using contenteditable attribute).',
  'ismap': 'Indicates that the image is part of a server-side image map.',
  'itemprop': '',
  'kind': 'Specifies the kind of text track.',
  'label': 'Specifies a user-readable title of the element.',
  'lang': 'Defines the language used in the element.',
  'loading':
      'Indicates if the element should be loaded lazily\n        (loading="lazy") or loaded immediately\n        (loading="eager").',
  'list': 'Identifies a list of pre-defined options to suggest to the user.',
  'loop':
      'Indicates whether the media should start playing from the start when\n        it\'s finished.',
  'low': 'Indicates the upper bound of the lower range.',
  'max': 'Indicates the maximum value allowed.',
  'maxlength':
      'Defines the maximum number of characters allowed in the element.',
  'minlength':
      'Defines the minimum number of characters allowed in the element.',
  'media':
      'Specifies a hint of the media for which the linked resource was\n        designed.',
  'method':
      'Defines which HTTP method to use when\n        submitting the form. Can be GET (default) or\n        POST.',
  'min': 'Indicates the minimum value allowed.',
  'multiple':
      'Indicates whether multiple values can be entered in an input of the type\n        email or file.',
  'muted':
      'Indicates whether the audio will be initially silenced on page load.',
  'name':
      'Name of the element. For example used by the server to identify the\n        fields in form submits.',
  'novalidate':
      'This attribute indicates that the form shouldn\'t be validated when\n        submitted.',
  'open':
      'Indicates whether the contents are currently visible (in the case of\n        a <details> element) or whether the dialog is active\n        and can be interacted with (in the case of a\n        <dialog> element).',
  'optimum': 'Indicates the optimal numeric value.',
  'pattern':
      'Defines a regular expression which the element\'s value will be validated\n        against.',
  'ping':
      'The ping attribute specifies a space-separated list of URLs\n        to be notified if a user follows the hyperlink.',
  'placeholder':
      'Provides a hint to the user of what can be entered in the field.',
  'playsinline':
      'A Boolean attribute indicating that the video is to be played "inline"; that is, within the element\'s playback area. Note that the absence of this attribute does not imply that the video will always be played in fullscreen.',
  'poster':
      'A URL indicating a poster frame to show until the user plays or seeks.',
  'preload':
      'Indicates whether the whole resource, parts of it or nothing should be\n        preloaded.',
  'readonly': 'Indicates whether the element can be edited.',
  'referrerpolicy':
      'Specifies which referrer is sent when fetching the resource.',
  'rel': 'Specifies the relationship of the target object to the link object.',
  'required': 'Indicates whether this element is required to fill out or not.',
  'reversed':
      'Indicates whether the list should be displayed in a descending order\n        instead of an ascending order.',
  'role':
      'Defines an explicit role for an element for use by assistive technologies.',
  'rows': 'Defines the number of rows in a text area.',
  'rowspan': 'Defines the number of rows a table cell should span over.',
  'sandbox':
      'Stops a document loaded in an iframe from using certain features (such\n        as submitting forms or opening new windows).',
  'scope':
      'Defines the cells that the header test (defined in the\n        th element) relates to.',
  'selected': 'Defines a value which will be selected on page load.',
  'shape': '',
  'size':
      'Defines the width of the element (in pixels). If the element\'s\n        type attribute is text or\n        password then it\'s the number of characters.',
  'sizes': '',
  'slot': 'Assigns a slot in a shadow DOM shadow tree to an element.',
  'span': '',
  'spellcheck': 'Indicates whether spell checking is allowed for the element.',
  'src': 'The URL of the embeddable content.',
  'srcdoc': '',
  'srclang': '',
  'srcset': 'One or more responsive image candidates.',
  'start': 'Defines the first number if other than 1.',
  'step': '',
  'style': 'Defines CSS styles which will override styles previously set.',
  'tabindex':
      'Overrides the browser\'s default tab order and follows the one specified\n        instead.',
  'target':
      'Specifies where to open the linked document (in the case of an\n        <a> element) or where to display the response received\n        (in the case of a <form> element)',
  'title': 'Text to be displayed in a tooltip when hovering over the element.',
  'translate':
      'Specify whether an element\'s attribute values and the values of its\n        Text node\n        children are to be translated when the page is localized, or whether to\n        leave them unchanged.',
  'type': 'Defines the type of the element.',
  'usemap': '',
  'value':
      'Defines a default value which will be displayed in the element on page\n        load.',
  'width':
      'For the elements listed here, this establishes the element\'s width.\n        \n        \n          \n            Note: For all other instances, such as\n            <div>, this is a legacy attribute, in\n            which case the CSS width property should be\n            used instead.',
  'wrap': 'Indicates whether the text should be wrapped.'
};

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

List<(String, String)> _events = [];
final _defaultEvents = [
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

// TODO(wfontao): Add event descriptions as Dart documentation.
Future<void> _fetchEvents() async {
  final response = await http.get(Uri.parse(
      'https://html.spec.whatwg.org/multipage/indices.html#events-2'));
  if (response.statusCode != 200) {
    throw Exception('Unexpected status code: ${response.statusCode}');
  }
  await _savePage('data/events.html', response.body);
  _events = _defaultEvents;
}

Future<void> _fetchElements() async {
  final rs = await http.get(
      Uri.parse('https://developer.mozilla.org/en-US/docs/Web/HTML/Element'));
  if (rs.statusCode != 200) {
    throw Exception('Unexpected status code: ${rs.statusCode}');
  }

  try {
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
    await _savePage('data/elements.html', rs.body);
    // print('---Default elements---');
    // print(_getMapAsDartCode(_elementDocs));
    // print('---Default elements---');
  } catch (e) {
    _elementDocs = _defaultElementDocs;
    print(e);
  }
}

Future<void> _fetchAttributes() async {
  final rs = await http.get(Uri.parse(
      'https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes'));
  if (rs.statusCode != 200) {
    throw Exception('Unexpected status code: ${rs.statusCode}');
  }
  try {
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
    await _savePage('data/attributes.html', rs.body);

    // print('---Default attributes---');
    // print(_getMapAsDartCode(_elementAttributes));
    // print('---Default attributes---');

    // print('---Default attribute docs---');
    // print(_getMapAsDartCode(_attributeDocs));
    // print('---Default attribute docs---');
  } catch (e) {
    _elementAttributes = _defaultAttributes;
    _attributeDocs = _defaultAttributeDocs;
    print(e);
  }
}

String _getMapAsDartCode(Map<String, dynamic> map) {
  final buffer = StringBuffer('{');

  var first = true;
  map.forEach((key, value) {
    if (first) {
      first = false;
    } else {
      buffer.write(', ');
    }

    buffer.write("'$key': ");

    if (value is List<String>) {
      buffer.write("[${value.map((v) => "'${_escapeString(v)}'").join(', ')}]");
    } else if (value is String) {
      buffer.write("'${_escapeString(value)}'");
    } else {
      throw UnimplementedError('Unsupported value type: ${value.runtimeType}.');
    }
  });

  buffer.write('}');
  return buffer.toString();
}

String _escapeString(String input) {
  return input
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r')
      .replaceAll('\t', r'\t');
}

Future<void> _savePage(String filePath, String pageContent) async {
  final file = File(filePath)..parent.createSync(recursive: true);
  await file.writeAsString(pageContent);
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
    for (var event in _events) {
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
    for (final event in _events) {
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
