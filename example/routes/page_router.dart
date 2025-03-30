import 'package:asimox/asimox.dart';

import '../pages/app_page.dart';
import '../pages/camera_upload_page.dart';
import '../pages/home_page.dart';
import '../pages/not_found_page.dart';
import '../permissions/authorization_middleware.dart';

final router = WebRouter(
  routes: [
    Route('/', (_) => HomePage()),
    Route(
      '/counter',
      (parameters) {
        return AppPage(
          start: int.tryParse(parameters['start'] ?? '0') ?? 0,
        );
      },
    ),
    Route(
      '/counter/{name}',
      (parameters) {
        return AppPage(
          name: parameters['name'],
          start: int.tryParse(parameters['start'] ?? '0') ?? 0,
        );
      },
    ),
    Route('/camera-upload', (_) => CameraUploadPage()),
  ],
  defaultRoute: (_) => NotFoundPage(),
  middlewares: [isAuthorized],
);
