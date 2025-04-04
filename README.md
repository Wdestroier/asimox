# Asimox

## Overview
Asimox is a Dart web framework designed to create interactive web applications with modern features such as incremental DOM, change detection, class-based HTML components and declarative UI.

## Try the example
Steps to run the provided example:
1. Clone the repository:
   ```bash
   $ git clone https://github.com/wdestroier/asimox
   ```
2. Navigate to the example directory:
   ```bash
   $ cd asimox/example
   ```
3. Install `webdev_proxy`:
   ```bash
   $ dart pub global activate webdev_proxy
   ```
4. Run the example with `webdev_proxy`:
   ```bash
   $ webdev_proxy serve -- example
   ```
5. Access the running website at [http://localhost:8080](http://localhost:8080) and after that check [http://localhost:8080/counter/click?start=10](http://localhost:8080/counter/click?start=10).

## Getting Started

1. Add the package to your `pubspec.yaml`:
```yaml
dependencies:
  asimox: ^1.0.0
```
2. Import the package:
```dart
import 'package:asimox/asimox.dart';
```

## Building for Production

1. Install `webdev`:
   ```bash
   $ dart pub global activate webdev
   ```
2. Run the build command:
   ```bash
   $ webdev build
   ```
3. Publish the files in the `your_project/build` directory.

## License
This project is licensed under the MIT License. See the LICENSE file for more information.