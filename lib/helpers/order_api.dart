import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:razorpay_integration/models/response_model.dart';

class Http {
  Future orderAPI(String price) async {
    String url = 'https://api.razorpay.com/v1/orders';
    String username = '';
    String password = '';
    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
    final response = await http.post(
      Uri.parse(url),
      body: {'amount': price, 'currency': 'INR'},
      headers: <String, String>{'authorization': basicAuth},
    );

    if (response.statusCode == 200) {
      return ResponseModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }
  Future cloudFunctionApi(double price)async{
    HttpsCallable callable = FirebaseFunctions.instanceFor(region: "asia-south1").httpsCallable('orderApi',);
    try {
      final HttpsCallableResult result = await callable.call(
        <String, dynamic>{
          'message': price*100,
        },
      );
      Map data=jsonDecode(result.data['data'].toString());
      if(data['status']=="success"){
        ResponseModel responseModel=ResponseModel.fromJson(data['order']);
        return {
          'model': responseModel,
          'key': data['key'],
        };
      } else{
        return null;
      }
    } catch (e) {
      print(e.toString());
    }
  }
}