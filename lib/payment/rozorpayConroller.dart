import 'dart:convert';
import 'package:jippymart_restaurant/utils/http_client.dart' as http;
import 'package:jippymart_restaurant/models/payment_model/razorpay_model.dart';
import 'package:jippymart_restaurant/payment/createRazorPayOrderModel.dart';

import '../constant/constant.dart';

class RazorPayController {
  Future<CreateRazorPayOrderModel?> createOrderRazorPay({required int amount, required RazorPayModel? razorpayModel}) async {
    final String orderId = DateTime.now().millisecondsSinceEpoch.toString();
    RazorPayModel razorPayData = razorpayModel!;
    print(razorPayData.razorpayKey);
    print("we Enter In");

    // Hit the web domain backend (same as jippymart.in).
    // Example: https://jippymart.in/payments/razorpay/createorder
    final String url = "${Constant.globalUrl}payments/razorpay/createorder";
    print(orderId);
    final response = await http.post(
      Uri.parse(url),
      body: {
        "amount": (amount * 100).toString(),
        "receipt_id": orderId,
        "currency": "INR",
        "razorpaykey": razorPayData.razorpayKey,
        "razorPaySecret": razorPayData.razorpaySecret,
        "isSandBoxEnabled": razorPayData.isSandboxEnabled.toString(),
      },
    );

    // Defensive: backend might return HTML or error text; only parse JSON when expected.
    if (response.statusCode != 200) {
      print('Razorpay createorder failed: ${response.statusCode} ${response.body}');
      return null;
    }

    final body = response.body.trim();
    if (body.isEmpty || body.startsWith('<')) {
      // HTML/error page or empty
      print('Razorpay createorder returned non‑JSON body: $body');
      return null;
    }

    final data = jsonDecode(body);
    print(data);
    return CreateRazorPayOrderModel.fromJson(data);
  }
}
