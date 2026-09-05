import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/service/terms_api_service.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';

class TermsAndConditionScreen extends StatefulWidget {
  final String? type;

  const TermsAndConditionScreen({super.key, this.type});

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  bool _isLoading = true;
  String _htmlData = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      // Try the Java API first (merchant app).
      final isPrivacy = widget.type == "privacy";
      final apiContent = await TermsApiService.getContent(
        appType: TermsApiService.appTypeMerchant,
        appPolicyType: isPrivacy
            ? TermsApiService.policyTypePrivacy
            : TermsApiService.policyTypeTerms,
      );
      if (apiContent.isNotEmpty) {
        // Cache for future visits.
        if (isPrivacy) {
          Constant.privacyPolicy = apiContent;
        } else {
          Constant.termsAndConditions = apiContent;
        }
        if (mounted) {
          setState(() {
            _htmlData = apiContent;
            _isLoading = false;
          });
        }
        return;
      }

      // Try to use cached constants next
      String cachedData = isPrivacy
          ? Constant.privacyPolicy
          : Constant.termsAndConditions;

      if (cachedData.isNotEmpty) {
        setState(() {
          _htmlData = cachedData;
          _isLoading = false;
        });
        return;
      }

      // If not cached, fetch from API
      final response = await http.get(Uri.parse('${Constant.baseUrl}settings/mobile'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<String, dynamic> data = jsonData['data'] ?? {};
        final Map<String, dynamic> documents = data['documents'] ?? {};
        final Map<String, dynamic> derived = data['derived'] ?? {};

        String htmlContent = '';

        if (isPrivacy) {
          // Try derived first, then documents
          htmlContent = derived['privacyPolicy'] ?? '';
          if (htmlContent.isEmpty) {
            final privacyPolicy = documents['privacyPolicy'] ?? {};
            htmlContent = privacyPolicy['privacy_policy'] ?? '';
          }
        } else {
          // Try derived first, then documents
          htmlContent = derived['termsAndConditions'] ?? '';
          if (htmlContent.isEmpty) {
            final termsConditions = documents['termsAndConditions'] ?? {};
            htmlContent = termsConditions['termsAndConditions'] ?? '';
          }
        }

        setState(() {
          _htmlData = htmlContent;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load content: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _htmlData = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surfaceDark
          : AppThemeData.surface,
      appBar: AppBar(
        backgroundColor:
            themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.chevron_left_outlined,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
          ),
        ),
        title: Text(
          widget.type == "privacy"
              ? "Privacy Policy".tr
              : "Terms & Conditions".tr,
          style: TextStyle(
              color: themeChange.getThem()
                  ? AppThemeData.grey100
                  : AppThemeData.grey800,
              fontFamily: AppThemeData.bold,
              fontSize: 18),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: themeChange.getThem()
                ? AppThemeData.grey700
                : AppThemeData.grey200,
            height: 4.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: _isLoading
            ? Center(child: Constant.loader())
            : _htmlData.isEmpty
                ? Center(
                    child: Text(
                      "No content available".tr,
                      style: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Html(
                      shrinkWrap: true,
                      data: _htmlData,
                    ),
                  ),
      ),
    );
  }
}
