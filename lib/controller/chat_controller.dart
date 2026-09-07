import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/conversation_model.dart';
import 'package:jippymart_restaurant/models/inbox_model.dart';
class ChatController extends GetxController {
  Rx<TextEditingController> messageController = TextEditingController().obs;
  final ScrollController scrollController = ScrollController();

  // API Configuration
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;
  RxBool isLoading = false.obs;
  RxList<ConversationModel> messages = <ConversationModel>[].obs;

  @override
  void onInit() {
    getArgument().then((_) {
      fetchMessages();
    });
    super.onInit();
  }

  RxString orderId = "".obs;
  RxString customerId = "".obs;
  RxString customerName = "".obs;
  RxString customerProfileImage = "".obs;
  RxString restaurantId = "".obs;
  RxString restaurantName = "".obs;
  RxString restaurantProfileImage = "".obs;
  RxString token = "".obs;
  RxString chatType = "".obs;

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderId.value = argumentData['orderId'];
      customerId.value = argumentData['customerId'];
      customerName.value = argumentData['customerName'];
      customerProfileImage.value = argumentData['customerProfileImage'] ?? "";
      restaurantId.value = argumentData['restaurantId'];
      restaurantName.value = argumentData['restaurantName'];
      restaurantProfileImage.value =
          argumentData['restaurantProfileImage'] ?? "";
      token.value = argumentData['token'];
      chatType.value = argumentData['chatType'];
    }
  }

  // Fetch messages from API
  Future<void> fetchMessages({bool isRefresh = false}) async {
    if (isLoading.value) return;

    if (isRefresh) {
      currentPage.value = 1;
      hasMore.value = true;
      messages.clear();
    }

    if (!hasMore.value) return;

    isLoading.value = true;

    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}chat/${orderId.value}/messages?chat_type=${chatType.value}&page=${currentPage.value}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          final data = jsonResponse['data'];
          final List<dynamic> messageData = data['data'];
          final List<ConversationModel> newMessages = messageData.map((json) {
            return ConversationModel.fromJsonApi(json);
          }).toList();

          if (isRefresh) {
            messages.value = newMessages;
          } else {
            messages.addAll(newMessages);
          }

          // Update pagination info
          currentPage.value = data['current_page'] + 1;
          hasMore.value = currentPage.value <= data['last_page'];

          // Scroll to bottom after loading messages
          if (messages.isNotEmpty && scrollController.hasClients) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollController.jumpTo(scrollController.position.maxScrollExtent);
            });
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to load messages');
      }
    } catch (e) {
      log('Error fetching messages: $e');
      Get.snackbar('Error', 'Failed to load messages');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more messages for pagination
  void loadMoreMessages() {
    if (!isLoading.value && hasMore.value) {
      fetchMessages();
    }
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    await fetchMessages(isRefresh: true);
  }

  // Send message (keep your existing sendMessage implementation)
  sendMessage(String message, Url? url, String videoThumbnail,
      String messageType) async {
    InboxModel inboxModel = InboxModel(
        lastSenderId: restaurantId.value,
        customerId: customerId.value,
        customerName: customerName.value,
        restaurantId: restaurantId.value,
        restaurantName: restaurantName.value,
        createdAt: Timestamp.now(),
        orderId: orderId.value,
        customerProfileImage: customerProfileImage.value,
        restaurantProfileImage: restaurantProfileImage.value,
        lastMessage: messageController.value.text,
        chatType: chatType.value);

    // Your existing send message logic here...
    // This part remains the same as your original implementation

    // After sending message, refresh the messages list
    await refreshMessages();
  }

  @override
  void onClose() {
    messageController.value.dispose();
    scrollController.dispose();
    super.onClose();
  }

  final ImagePicker imagePicker = ImagePicker();
}