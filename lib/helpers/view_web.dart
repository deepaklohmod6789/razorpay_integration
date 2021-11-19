import 'package:razorpay_integration/helpers/abstract.dart';
import 'package:flutter/material.dart' if (dart.library.html)'dart:ui' as ui;

BackgroundView getWorker() => BackgroundViewWeb();

class BackgroundViewWeb implements BackgroundView {
  @override
  void registerViewFactory(String viewId, dynamic cb) {
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}