import 'package:web/web.dart';
import 'package:asimox/asimox.dart';

class CameraUploadPage extends DomNode {
  String? _imageSrc;

  @override
  DomNode render() {
    return h('div', {
      'class': 'camera-upload'
    }, [
      h('input', {
        'type': 'file',
        'accept': 'image/*',
        'capture': 'environment',
        'class': 'camera-upload__input',
        'change': _onFileChange,
      }),
      h('button', {
        'class': 'camera-upload__button',
        'click': _onButtonClick,
      }, [
        h('span', {'class': 'camera-upload__icon'}, ''),
        h('span', {'class': 'camera-upload__text'}, 'Add photo'),
      ]),
      if (_imageSrc != null)
        h('img', {
          'class': 'camera-upload__image',
          'src': _imageSrc!,
          'alt': 'Uploaded photo'
        }),
    ]);
  }

  _onButtonClick(e) {
    e.event.preventDefault();
    dynamic input = document.querySelector('.camera-upload__input');
    input.click();
  }

  _onFileChange(e) {
    var input = e.event.target;
    if (input.files != null && input.files.length > 0) {
      var file = input.files[0];
      var reader = FileReader();
      reader.onLoadEnd.listen((event) {
        _imageSrc = reader.result as String;
        changeDetection.trigger();
      });
      reader.readAsDataURL(file);
    }
  }
}
