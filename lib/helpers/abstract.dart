import 'view.dart' //
if (dart.library.io) 'view_io.dart'
if (dart.library.html) 'view_web.dart';
abstract class BackgroundView {
  factory BackgroundView() => getView();

  void registerViewFactory(String viewId, dynamic cb);
}