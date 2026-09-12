// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:jippymart_restaurant/constant/collection_name.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/models/story_model.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
//
// class AddStoryController extends GetxController {
//   RxBool isLoading = true.obs;
//
//   Rx<StoryModel> storyModel = StoryModel().obs;
//   final ImagePicker imagePicker = ImagePicker();
//
//   RxList<dynamic> mediaFiles = <dynamic>[].obs;
//   RxList<dynamic> thumbnailFile = <dynamic>[].obs;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//     getStory();
//     super.onInit();
//   }
//
//   RxDouble videoDuration = 0.0.obs;
//
//   getStory() async {
//     // Get story data
//     await FireStoreUtils.getStory(Constant.userModel!.vendorID.toString()).then(
//           (value) {
//         if (value != null) {
//           storyModel.value = value;
//           thumbnailFile.add(storyModel.value.videoThumbnail);
//           for (var element in storyModel.value.videoUrl) {
//             mediaFiles.add(element);
//           }
//         }
//       },
//     );
//
//     try {
//       final response = await http.get(
//         Uri.parse('${Constant.baseUrl}settings/getStorySettings'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         if (jsonResponse['success'] == true) {
//           final data = jsonResponse['data'];
//           videoDuration.value = double.parse(data['videoDuration'].toString());
//         } else {
//           print('API Error: ${jsonResponse['message']}');
//           videoDuration.value = 30.0; // default fallback
//         }
//       } else {
//         print('HTTP Error: ${response.statusCode}');
//         videoDuration.value = 30.0; // default fallback
//       }
//     } catch (e) {
//       print('Error fetching story settings: $e');
//       videoDuration.value = 30.0; // default fallback
//     }
//     isLoading.value = false;
//   }
// }
