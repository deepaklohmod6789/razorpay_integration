import 'package:universal_html/html.dart'hide Navigator;
import 'package:flutter/material.dart';
import 'package:razorpay_integration/helpers/abstract.dart';

class WebViewPayment extends StatelessWidget{
  final double price;
  final String orderId;
  final String razorKey;

  const WebViewPayment({
    Key? key,
    required this.price,
    required this.orderId,
    required this.razorKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BackgroundView().registerViewFactory("rzp-html",(int viewId) {
      IFrameElement element=IFrameElement();
      window.onMessage.forEach((element) {
        if(element.data=='MODAL_CLOSED'){
          Navigator.pop(context,null);
        }
        else if(element.data['state']=='SUCCESS'){
          Navigator.pop(context,element.data['paymentId']);
        }
      });

      element.src='assets/payments.html?price=$price&email=abc@gmail.com&phone=1234567899&id=$orderId&key=$razorKey';
      element.style.border = 'none';

      return element;
    });
    return  Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          return HtmlElementView(viewType: 'rzp-html');
        },
      ),
    );
  }
}