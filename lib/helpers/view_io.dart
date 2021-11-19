import 'package:razorpay_integration/helpers/abstract.dart';

BackgroundView getWorker() => BackgroundViewIo();

class BackgroundViewIo implements BackgroundView {
  @override
  void registerViewFactory(String viewId, dynamic cb) {
  }
}