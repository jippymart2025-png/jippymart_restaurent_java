import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/app/chat_screens/chat_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/inbox_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';

class RestaurantInboxScreen extends StatefulWidget {
  const RestaurantInboxScreen({super.key});

  @override
  State<RestaurantInboxScreen> createState() => _RestaurantInboxScreenState();
}

class _RestaurantInboxScreenState extends State<RestaurantInboxScreen> {

  Future<List<InboxModel>> fetchInboxData() async {
    final String url =
        '${Constant.baseUrl}restaurant/chat/restaurant?restaurantId=${FireStoreUtils.getCurrentUid()}';
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["success"] == true && data["data"] != null) {
        return (data["data"] as List)
            .map((e) => InboxModel.fromJson(e))
            .toList();
      }
    }
    return [];
  }
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem()
            ? AppThemeData.surfaceDark
            : AppThemeData.surface,
        title: Text("Inbox"),
      ),
      body: FutureBuilder<List<InboxModel>>(
        future: fetchInboxData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Constant.loader();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Constant.showEmptyView(message: "No Conversation found");
          }
          final inboxList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: inboxList.length,
            itemBuilder: (context, index) {
              final inbox = inboxList[index];
              return InkWell(
                onTap: () {
                  final merchant = Constant.merchantModel;
                  Get.to(const ChatScreen(), arguments: {
                    "customerName": inbox.customerName ?? '',
                    "restaurantName":
                        inbox.restaurantName ?? merchant?.merchantName ?? '',
                    "orderId": inbox.orderId,
                    "restaurantId":
                        inbox.restaurantId ?? merchant?.merchantId?.toString() ?? '',
                    "customerId": inbox.customerId,
                    "customerProfileImage": inbox.customerProfileImage,
                    "restaurantProfileImage": inbox.restaurantProfileImage,
                    "token": '',
                    "chatType": inbox.chatType,
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey100,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: NetworkImageWidget(
                          imageUrl: inbox.customerProfileImage ?? "",
                          height: Responsive.height(6, context),
                          width: Responsive.width(12, context),
                        ),
                      ),
                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(inbox.customerName ?? "",
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 16,
                                      )),
                                ),
                                Text(
                                  Constant.timestampToDate(inbox.createdAt!),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(inbox.lastMessage ?? "",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
