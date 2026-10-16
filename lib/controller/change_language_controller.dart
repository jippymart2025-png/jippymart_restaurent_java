import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/language_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

import '../constant/collection_name.dart';

import 'dart:convert';
import 'package:jippymart_restaurant/utils/http_client.dart' as http;

class ChangeLanguageController extends GetxController {
  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;
  RxList<LanguageModel> languageList = <LanguageModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getLanguage();

    super.onInit();
  }

  getLanguage() async {
    try {
      final response = await http.get(Uri.parse("${Constant.baseUrl}settings/languages"));

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["success"] == true) {
          List languageListTemp = jsonData["data"];
          languageList.clear();
          for (var element in languageListTemp) {
            LanguageModel languageModel = LanguageModel.fromJson(element);
            languageList.add(languageModel);
          }
          /// Set selected language from local preference
          String prefCode = Preferences.getString(Preferences.languageCodeKey).toString();
          if (prefCode.isNotEmpty) {
            LanguageModel pref = Constant.getLanguage();
            for (var element in languageList) {
              if (element.slug == pref.slug) {
                selectedLanguage.value = element;
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching languages: $e");
    }

    isLoading.value = false;
  }

}
