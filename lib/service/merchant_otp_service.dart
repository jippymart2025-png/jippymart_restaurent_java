import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/otp_response_model.dart';

import '../utils/common.dart';

class MerchantOtpService {
  static  String url = '${Constant.baseUrl}fm/otp';

  static Future<OtpResponseModel> sendSignupOtp({
    required String email,
    required String mobile,
  }) {
    return _post('send-signup-otp', {"email": email, "mobile": mobile});
  }

  static Future<OtpResponseModel> verifySignupOtp({
    required String email,
    required String otp,
  }) {
    return _post('verify-signup-otp', {"email": email, "otp": otp});
  }

  static Future<OtpResponseModel> resendSignupOtp({
    required String email,
    required String mobile,
  }) {
    return _post('resend-signup-otp', {"email": email, "mobile": mobile});
  }

  static Future<OtpResponseModel> _post(String path, Map<String, dynamic> body) async {
    try {
      //final headers = await getHeaders();
      final res = await http.post(
        Uri.parse('$url/$path'),
         headers:
         {
           'Content-Type': 'application/json',
           'Accept': 'application/json',
         },
        body: json.encode(body),
      );
      return OtpResponseModel.fromJson(jsonDecode(res.body));
    } catch (e) {
      return OtpResponseModel.error(e.toString());
    }
  }
}