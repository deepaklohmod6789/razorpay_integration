import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_integration/helpers/order_api.dart';
import 'package:razorpay_integration/helpers/responsive.dart';
import 'package:razorpay_integration/models/response_model.dart';
import 'package:razorpay_integration/pages/web_view_payment.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool inProcess=false;
  double payPrice=1200.0;
  int items=3;

  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    if(!kIsWeb){
      razorpay=Razorpay();
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerPaymentError);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if(!kIsWeb){
      razorpay.clear();
    }
  }

  void openCheckOut(String orderId)
  {
    setState(() {
      inProcess=true;
    });
    var options={
      'key':'',
      'amount':payPrice*100,
      'name':"Deepak Lohmod",
      'order_id': orderId,
      'description':"Payment for your product",
      'prefill':{
        'contact':'1234567899',
        'email':'abc@gmail.com',
      },
      'theme':{
        'color': '#21BF75',
        'backdrop_color': '#DA1313',
      }
    };

    try{
      razorpay.open(options);
    }catch(e)
    {
      print(e.toString());
    }
    setState(() {
      inProcess=false;
    });
  }

  void handlerPaymentSuccess(PaymentSuccessResponse response)async
  {
    //payment is successful and here you can store your data in backend
    //which is required to save on paying the amount
    print(response.orderId);
    print(response.paymentId);
  }

  void handlerPaymentError(PaymentFailureResponse response)
  {
    print('Failed to pay!!');
  }

  void handlerExternalWallet(ExternalWalletResponse response)
  {
    print('External wallet is opened');
  }

  void openRazorPay()async{
    setState(() {
      inProcess=true;
    });
    if(kIsWeb){
      Map? data=await Http().cloudFunctionApi(payPrice);
      if(data!=null){
        ResponseModel model=data['model'];
        handlePaymentForWeb(model.id!,data['key']);
      } else{
        print('failed to create razorpay payment order');
      }
    } else {
      ResponseModel? model=await Http().orderAPI((payPrice.round()*100).toString());
      if(model!=null){
        openCheckOut(model.id!);
      } else{
        print('failed to create razorpay payment order');
      }
    }
    setState(() {
      inProcess=false;
    });
  }

  void handlePaymentForWeb(String orderId,String key)async{
    String? paymentId=await Navigator.push(context, MaterialPageRoute(builder: (context)=>WebViewPayment(price: payPrice, orderId: orderId,razorKey: key,)));
    if(paymentId!=null){
      //you can save data to backend since payment is done
    } else {
      print('User closed the payment page');
    }
  }

  Widget block(var value, String heading){
    return Expanded(
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            text: value.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 20),
            children: [
              TextSpan(
                text: "\n$heading",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> children(){
    return [
      Image.asset('assets/mobilepay.png'),
      const SizedBox(height: 20,),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Click to pay $payPrice Rs",
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 5,),
          ElevatedButton(
            onPressed: ()=>openRazorPay(),
            child: const Text("Pay",style: TextStyle(color: Colors.white,fontSize: 20),),
            style: ElevatedButton.styleFrom(
              primary: const Color(0xff21bf75),
              padding: const EdgeInsets.symmetric(horizontal: 35,vertical: 8),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text("Razorpay integration"),
        backgroundColor: const Color(0xff21bf75),
      ),
      body: Stack(
        children: [
          Responsive.isDesktop(context)?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children(),
          ):Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children(),
          ),
          inProcess?const Center(child: CircularProgressIndicator(),):const SizedBox(),
        ],
      ),
      bottomNavigationBar: Container(
        color: const Color(0xff21bf75),
        child: IntrinsicHeight(
          child: Row(
            children: [
              block(items, 'Items'),
              const VerticalDivider(
                color: Colors.white,
                width: 0,
              ),
              block(payPrice, 'Pay (Rs)'),
              const VerticalDivider(
                color: Colors.white,
                width: 0,
              ),
              block(100, 'Discount (Rs)'),
            ],
          ),
        ),
      ),
    );
  }
}
