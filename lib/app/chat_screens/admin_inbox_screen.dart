import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/utils/http_client.dart' as http;
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/chat_screens/chat_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/inbox_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';

class AdminInboxScreen extends StatelessWidget {
  const AdminInboxScreen({super.key});

  Future<List<InboxModel>> _fetchInbox() async {
    String restaurantId = await FireStoreUtils.getCurrentUid();
    final url = Uri.parse("${Constant.baseUrl}restaurant/chat/admin?restaurantId=$restaurantId");
    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List data = jsonData['data'];
      return data.map((e) => InboxModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load inbox");
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Chat Inbox".tr),
        backgroundColor: themeChange.getThem()
            ? AppThemeData.surfaceDark
            : AppThemeData.surface,
      ),
      body: FutureBuilder<List<InboxModel>>(
        future: _fetchInbox(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Constant.loader();
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return Constant.showEmptyView(message: "No Conversation found".tr);
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final inboxModel = items[index];

              return InkWell(
                onTap: () async {
                  ShowToastDialog.showLoader("Please wait".tr);
                  VendorModel? vendorModel = await FireStoreUtils.getVendorById(
                      Constant.userModel!.vendorID.toString());
                  ShowToastDialog.closeLoader();

                  Get.to(const ChatScreen(), arguments: {
                    "customerName": 'Admin',
                    "restaurantName": vendorModel!.title,
                    "orderId": inboxModel.orderId,
                    "restaurantId": Constant.userModel?.id,
                    "customerId": 'admin',
                    "customerProfileImage": inboxModel.customerProfileImage ?? "",
                    "restaurantProfileImage": vendorModel.photo,
                    "token": Constant.userModel?.fcmToken,
                    "chatType": 'admin',
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: themeChange.getThem()
                          ? AppThemeData.grey900
                          : AppThemeData.grey100,
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetworkImageWidget(
                          imageUrl: inboxModel.restaurantProfileImage.toString(),
                          height: Responsive.height(6, context),
                          width: Responsive.width(12, context),
                        ),
                      ),
                      title: Text(
                        inboxModel.restaurantName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                        ),
                      ),
                      subtitle: Text(
                        inboxModel.lastMessage ?? '',
                        maxLines: 1,
                        style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                        ),
                      ),
                      trailing: Text(
                        Constant.timestampToDate(inboxModel.createdAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: themeChange.getThem()
                              ? AppThemeData.grey400
                              : AppThemeData.grey500,
                        ),
                      ),
                    ),
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
