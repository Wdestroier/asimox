
import '../webdev_proxy.dart';

main() async {
  await WebDevProxy.serve(path: r'test\entrypoint\web');
  await Future.delayed(Duration(minutes: 5));
}
