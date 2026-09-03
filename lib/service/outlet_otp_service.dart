import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/otp_response_model.dart';

import '../utils/common.dart';

class OutletOtpService {
  static  String url = '${Constant.baseUrl}fm/otp';

  static Future<OtpResponseModel> sendCreateOutletOtp({
    required int merchantId,
  }) {
    return _post('send-create-outlet-otp', {"merchantId": merchantId});
  }

  static Future<OtpResponseModel> verifyCreateOutletOtp({
    required String email,
    required String otp,
  }) {
    return _post('verify-create-outlet-otp', {"email": email, "otp": otp});
  }

  static Future<OtpResponseModel> resendCreateOutletOtp({
    required int merchantId,
  }) {
    return _post('resend-create-outlet-otp', {"merchantId": merchantId});
  }

  static Future<OtpResponseModel> _post(String path, Map<String, dynamic> body) async {
    try {
      final headers = await getHeaders();
      final res = await http.post(
        Uri.parse('$url/$path'),
        headers: headers,
        body: json.encode(body),
      );
      return OtpResponseModel.fromJson(jsonDecode(res.body));
    } catch (e) {
      return OtpResponseModel.error(e.toString());
    }
  }
}