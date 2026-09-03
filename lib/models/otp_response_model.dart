class OtpResponseModel {
  final bool success;
  final String statusCode;
  final String statusMsg;

  OtpResponseModel({
    required this.success,
    required this.statusCode,
    required this.statusMsg,
  });
  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    final code = json['statusCode']?.toString().toUpperCase() ?? '';
    return OtpResponseModel(
      success: code == "SUCCESS" || code == "200",
      statusCode: code,
      statusMsg: json['statusMsg']?.toString() ?? '',
    );
  }

  factory OtpResponseModel.error(String message) {
    return OtpResponseModel(success: false, statusCode: '', statusMsg: message);
  }
}