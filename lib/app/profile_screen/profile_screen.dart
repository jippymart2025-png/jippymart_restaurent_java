import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:jippymart_restaurant/controller/login_controller.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/add_advertisement_screen/advertisement_list_screen.dart';
import 'package:jippymart_restaurant/app/add_story_screen/add_story_screen.dart';
import 'package:jippymart_restaurant/app/change%20langauge/change_language_screen.dart';
import 'package:jippymart_restaurant/app/edit_profile_screen/edit_profile_screen.dart';
import 'package:jippymart_restaurant/app/special_discount_screen/special_discount_screen.dart';

import 'package:jippymart_restaurant/app/terms_and_condition/terms_and_condition_screen.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/app/withdraw_method_setup_screens/withdraw_method_setup_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';
import 'package:jippymart_restaurant/controller/profile_controller.dart';

import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/custom_dialog_box.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/const/image_const.dart';
import '../promotions/promotion_plan_types_screen.dart';
import '../subscriptions/subscription_plans_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final loginController = Get.find<LoginController>(); // Finds existing instance
    return GetX(
        init: ProfileController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme:
                  const IconThemeData(color: AppThemeData.grey50, size: 20),
              title: Text(
                "Outlet Profile".tr,
                style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemeData.grey50
                        : AppThemeData.grey50,
                    fontSize: 18,
                    fontFamily: AppThemeData.medium),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              children: [
                                ClipOval(
                                  child: controller.isOutletContext.value
                                      ? (controller.outletModel.value.outletPicUrl != null &&
                                          controller.outletModel.value.outletPicUrl.toString().isNotEmpty)
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(60),
                                              child: NetworkImageWidget(
                                                imageUrl: controller.outletModel.value.outletPicUrl.toString(),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(60),
                                              child: Image.asset(
                                                Constant.userPlaceHolder,
                                                height: 80,
                                                width: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                      : controller.userModel.value.profilePictureURL != null &&
                                          controller.userModel.value.profilePictureURL.toString().isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(60),
                                              child: NetworkImageWidget(
                                                imageUrl: controller.userModel.value.profilePictureURL.toString(),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius: BorderRadius.circular(60),
                                              child: Image.asset(
                                                Constant.userPlaceHolder,
                                                height: 80,
                                                width: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Text(
                                      //   //"${controller.userModel.value.fullName()}",
                                      //   controller.isOutletContext.value
                                      //       ? (controller.outletModel.value.outletName ?? '')
                                      //       : "${controller.userModel.value.fullName()}",
                                      //   style: TextStyle(
                                      //       color: themeChange.getThem()
                                      //           ? AppThemeData.grey50
                                      //           : AppThemeData.grey900,
                                      //       fontFamily: AppThemeData.semiBold,
                                      //       fontWeight: FontWeight.w500,
                                      //       fontSize: 18),
                                      // ),
                                      Text(
                                        //controller.userModel.value.email ?? '',
                                        controller.isOutletContext.value
                                            ? (controller.outletModel.value.outletEmail ?? '')
                                            : (controller.userModel.value.email ?? ''),

                                        style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey400
                                                : AppThemeData.grey500,
                                            fontFamily: AppThemeData.regular,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      RoundedButtonFill(
                                        title: "Edit Profile".tr,
                                        color: ColorConst.orange,
                                        textColor: AppThemeData.grey50,
                                        width: 24,
                                        height: 4,
                                        onPress: () async {
                                          Get.to(const EditProfileScreen())!
                                              .then(
                                            (value) {
                                              if (value == true) {
                                                controller.getUserProfile();
                                                if (Get
                                                    .isRegistered<HomeController>()) {
                                                  Get.find<HomeController>()
                                                      .refreshOutletProfile();
                                                }
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: false,
                            child:
                            cardDecoration(
                              themeChange,
                              controller,
                              Container(
                                width: 44,
                                height: 44,
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.secondary600
                                      : AppThemeData.secondary50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset("assets/icons/ic_story.svg"),
                                ),
                              ),
                              "Add Story",
                              () {
                                Get.to(const AddStoryScreen());
                              },
                            ),
                          ),
                          // Advertisement Section
                          Visibility(
                            visible: false,
                            child: cardDecoration(
                              themeChange,
                              controller,
                              Container(
                                width: 44,
                                height: 44,
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.secondary600
                                      : AppThemeData.secondary50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(120),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: SvgPicture.asset("assets/icons/ic_advertisement.svg"),
                                ),
                              ),
                              "Advertisement",
                              () {
                                Get.to(const AdvertisementListScreen());
                              },
                            ),
                          ),
                          // Delivery Man Information Section
                          // Visibility(
                          //   visible: false,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       const SizedBox(height: 20),
                          //       Text(
                          //         "Delivery Man Information".tr,
                          //         style: TextStyle(
                          //           color: themeChange.getThem()
                          //               ? AppThemeData.grey400
                          //               : AppThemeData.grey500,
                          //           fontFamily: AppThemeData.semiBold,
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 10),
                          //       Container(
                          //         width: Responsive.width(100, context),
                          //         decoration: ShapeDecoration(
                          //           color: themeChange.getThem()
                          //               ? AppThemeData.grey900
                          //               : AppThemeData.grey50,
                          //           shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(12)),
                          //         ),
                          //         child: Padding(
                          //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          //           child: Column(children: [
                          //             cardDecoration(
                          //               themeChange,
                          //               controller,
                          //               Container(
                          //                 width: 44,
                          //                 height: 44,
                          //                 decoration: ShapeDecoration(
                          //                   color: themeChange.getThem()
                          //                       ? AppThemeData.secondary600
                          //                       : AppThemeData.goldenrodDark.withAlpha(30),
                          //                   shape: RoundedRectangleBorder(
                          //                     borderRadius: BorderRadius.circular(120),
                          //                   ),
                          //                 ),
                          //                 child: Padding(
                          //                   padding: const EdgeInsets.all(12),
                          //                   child: SvgPicture.asset(
                          //                     "assets/icons/ic_manage_delivery_man.svg",
                          //                     colorFilter: ColorFilter.mode(AppThemeData.goldenrodDark, BlendMode.srcIn),
                          //                   ),
                          //                 ),
                          //               ),
                          //               "Manage Delivery Man",
                          //               // () {
                          //               //   Get.to(DriverListScreen());
                          //               // },
                          //             )
                          //           ]),
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          // Offers & Discounts Section
                          // Visibility(
                          //   visible: true,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       const SizedBox(height: 20),
                          //       Text(
                          //         "Offers & Discounts".tr,
                          //         style: TextStyle(
                          //           color: themeChange.getThem()
                          //               ? AppThemeData.grey400
                          //               : AppThemeData.grey500,
                          //           fontFamily: AppThemeData.semiBold,
                          //           fontWeight: FontWeight.w500,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 10),
                          //       Container(
                          //         width: Responsive.width(100, context),
                          //         decoration: ShapeDecoration(
                          //           color: themeChange.getThem()
                          //               ? AppThemeData.grey900
                          //               : AppThemeData.grey50,
                          //           shape: RoundedRectangleBorder(
                          //               borderRadius: BorderRadius.circular(12)),
                          //         ),
                          //         child: Padding(
                          //           padding: const EdgeInsets.symmetric(
                          //               horizontal: 10, vertical: 8),
                          //           child: Column(
                          //             children: [
                          //               cardDecoration(
                          //                 themeChange,
                          //                 controller,
                          //                 Container(
                          //                   width: 44,
                          //                   height: 44,
                          //                   decoration: ShapeDecoration(
                          //                     color: themeChange.getThem()
                          //                         ? AppThemeData.success600
                          //                         : AppThemeData.success50,
                          //                     shape: RoundedRectangleBorder(
                          //                       borderRadius: BorderRadius.circular(120),
                          //                     ),
                          //                   ),
                          //                   child: Padding(
                          //                     padding: const EdgeInsets.all(10),
                          //                     child: SvgPicture.asset(
                          //                         "assets/icons/ic_gift_box.svg"),
                          //                   ),
                          //                 ),
                          //                 "Offers",
                          //                 () {
                          //                   Get.to(const OfferScreen());
                          //                 },
                          //               ),
                          //               Constant.specialDiscountOfferEnable == false
                          //                   ? const SizedBox()
                          //                   : cardDecoration(
                          //                       themeChange,
                          //                       controller,
                          //                       Container(
                          //                         width: 44,
                          //                         height: 44,
                          //                         decoration: ShapeDecoration(
                          //                           color: themeChange.getThem()
                          //                               ? AppThemeData.success600
                          //                               : AppThemeData.success50,
                          //                           shape: RoundedRectangleBorder(
                          //                             borderRadius: BorderRadius.circular(120),
                          //                           ),
                          //                         ),
                          //                         child: Padding(
                          //                           padding: const EdgeInsets.all(10),
                          //                           child: SvgPicture.asset(
                          //                             "assets/icons/ic_coupon.svg",
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       "Special Discounts",
                          //                       () {
                          //                         Get.to(
                          //                             const SpecialDiscountScreen());
                          //                       },
                          //                     ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // cardDecoration(
                          //   themeChange,
                          //   controller,
                          //   Container(
                          //     width: 44,
                          //     height: 44,
                          //     decoration: ShapeDecoration(
                          //       color: themeChange.getThem()
                          //           ? AppThemeData.secondary600
                          //           : AppThemeData.driverApp50,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius:
                          //         BorderRadius.circular(120),
                          //       ),
                          //     ),
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(10),
                          //       child: SvgPicture.asset(
                          //           "assets/icons/ic_subscription.svg"),
                          //     ),
                          //   ),
                          //   "Promotion Plans",
                          //       () {
                          //     Get.to(const SubscriptionPlansScreen());
                          //   },
                          // ),
                          Text(
                            "Outlet Information".tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey400
                                  : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  Constant.isRestaurantVerification == true &&
                                          controller.userModel.value
                                                  .isDocumentVerify ==
                                              false
                                      ? const SizedBox()
                                      : Constant.storyEnable == false
                                          ? const SizedBox()
                                          :
                                  // cardDecoration(
                                  //             themeChange,
                                  //             controller,
                                  //             Container(
                                  //               width: 44,
                                  //               height: 44,
                                  //               decoration: ShapeDecoration(
                                  //                 color: themeChange.getThem()
                                  //                     ? AppThemeData
                                  //                         .secondary600
                                  //                     : AppThemeData
                                  //                         .secondary50,
                                  //                 shape: RoundedRectangleBorder(
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(
                                  //                           120),
                                  //                 ),
                                  //               ),
                                  //               child: Padding(
                                  //                 padding:
                                  //                     const EdgeInsets.all(10),
                                  //                 child: SvgPicture.asset(
                                  //                     "assets/icons/ic_building_two.svg",
                                  //                     colorFilter: ColorFilter.mode(
                                  //                         AppThemeData.secondary300,
                                  //                         BlendMode.srcIn),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //               "Outlet Information's",
                                  //               () {
                                  //                 Get.to(const AddRestaurantScreen())
                                  //                     ?.then((v) {
                                  //                   if (v == true) {
                                  //                     controller.getUserProfile();
                                  //                   }
                                  //                 });
                                  //               },
                                  //             ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.secondary600
                                            : AppThemeData.secondary50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: SvgPicture.asset(
                                            "assets/icons/ic_manage_product.svg"),
                                      ),
                                    ),
                                    "Manage Products",
                                    () {
                                      DashBoardController
                                          dashBoardController =
                                          Get.find<DashBoardController>();
                                      dashBoardController
                                          .selectedIndex.value = Constant
                                                  .isDineInEnable
                                          ? 2
                                          : 1;
                                    },
                                  ),
                                  // cardDecoration(
                                  //   themeChange,
                                  //   controller,
                                  //   Container(
                                  //     width: 44,
                                  //     height: 44,
                                  //     decoration: ShapeDecoration(
                                  //       color: themeChange.getThem()
                                  //           ? AppThemeData.secondary600
                                  //           : AppThemeData.secondary50,
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius:
                                  //             BorderRadius.circular(120),
                                  //       ),
                                  //     ),
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.all(10),
                                  //       child: SvgPicture.asset(
                                  //           "assets/icons/ic_alarm-clock.svg"),
                                  //     ),
                                  //   ),
                                  //   "Working Hours",
                                  //   () {
                                  //     Get.to(const WorkingHoursScreen());
                                  //   },
                                  // ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.secondary600
                                            : AppThemeData.secondary50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_wallet.svg",
                                          colorFilter: ColorFilter.mode(
                                              AppThemeData.secondary300,
                                              BlendMode.srcIn),
                                        ),
                                      ),
                                    ),
                                    "Withdraw Method",
                                    () {
                                      Get.to(const WithdrawMethodSetupScreen());
                                    },
                                  ),


                                ],
                              ),
                            ),
                          ),

                          Visibility(
                            visible: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  "Offers & Discounts".tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: Responsive.width(100, context),
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: Column(
                                      children: [
                                        cardDecoration(
                                          themeChange,
                                          controller,
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.success600
                                                  : AppThemeData.success50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                  "assets/icons/ic_gift_box.svg"),
                                            ),
                                          ),
                                          "Promotion Plans",
                                              () {
                                            Get.to(const PromotionPlanTypesScreen());
                                          },
                                        ),
                                        cardDecoration(
                                          themeChange,
                                          controller,
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.secondary600
                                                  : AppThemeData.driverApp50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                  "assets/icons/ic_subscription.svg"),
                                            ),
                                          ),
                                          "Subscription Plans",
                                              () {
                                            Get.to(const SubscriptionPlansScreen());
                                          },
                                        ),

                                        cardDecoration(
                                          themeChange,
                                          controller,
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.secondary600
                                                  : AppThemeData.secondary50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                ImageConst.whatsApp,
                                                colorFilter: ColorFilter.mode(
                                                  AppThemeData.secondary300,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                          ),
                                          "Boost my orders",
                                              () async {
                                            const String phoneNumber = '+918106625666';
                                            const String message =
                                                "Hi, I want to boost my restaurant orders. Please contact me with details.";
                                            final Uri whatsappUrl = Uri.parse(
                                              'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
                                            );
                                            try {
                                              if (await canLaunchUrl(whatsappUrl)) {
                                                await launchUrl(
                                                  whatsappUrl,
                                                  mode: LaunchMode.externalApplication,
                                                );
                                              } else {
                                                final Uri phoneUrl =
                                                Uri.parse('tel:$phoneNumber');
                                                if (await canLaunchUrl(phoneUrl)) {
                                                  await launchUrl(
                                                    phoneUrl,
                                                    mode: LaunchMode.externalApplication,
                                                  );
                                                }
                                              }
                                            } catch (e) {
                                              debugPrint(
                                                  'Error launching WhatsApp from Boost my orders: $e');
                                            }
                                          },
                                        ),
                                        Constant.specialDiscountOfferEnable == false
                                            ? const SizedBox()
                                            : cardDecoration(
                                          themeChange,
                                          controller,
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.success600
                                                  : AppThemeData.success50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                "assets/icons/ic_coupon.svg",
                                              ),
                                            ),
                                          ),
                                          "Special Discounts",
                                              () {
                                            Get.to(
                                                const SpecialDiscountScreen());
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          (Constant.isRestaurantVerification == true &&
                                      controller.userModel.value
                                              .isDocumentVerify ==
                                          false) ||
                                    (controller.userModel.value.vendorID ==
                                            null ||
                                        controller
                                            .userModel.value.vendorID!.isEmpty)
                                ? const SizedBox()
                                : Constant.isDineInEnable
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "Dine-in Information".tr,
                                            style: TextStyle(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey400
                                                  : AppThemeData.grey500,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: Responsive.width(100, context),
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey900
                                                  : AppThemeData.grey50,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 8),
                                              child: Column(
                                                // children: [
                                                //   cardDecoration(
                                                //     themeChange,
                                                //     controller,
                                                //     Container(
                                                //       width: 44,
                                                //       height: 44,
                                                //       decoration: ShapeDecoration(
                                                //         color:
                                                //             themeChange.getThem()
                                                //                 ? AppThemeData
                                                //                     .primary600
                                                //                 : AppThemeData
                                                //                     .primary50,
                                                //         shape:
                                                //             RoundedRectangleBorder(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .circular(120),
                                                //         ),
                                                //       ),
                                                //       child: Padding(
                                                //         padding:
                                                //             const EdgeInsets.all(
                                                //                 10),
                                                //         child: SvgPicture.asset(
                                                //             "assets/icons/ic_knife_fork.svg"),
                                                //       ),
                                                //     ),
                                                //     "Dine in Restaurant",
                                                //     // ()
                                                //     // {
                                                //     //   Get.to(
                                                //     //       const DineInCreateScreen());
                                                //     // },
                                                //   ),
                                                //   cardDecoration(
                                                //     themeChange,
                                                //     controller,
                                                //     Container(
                                                //       width: 44,
                                                //       height: 44,
                                                //       decoration: ShapeDecoration(
                                                //         color:
                                                //             themeChange.getThem()
                                                //                 ? AppThemeData
                                                //                     .primary600
                                                //                 : AppThemeData
                                                //                     .primary50,
                                                //         shape:
                                                //             RoundedRectangleBorder(
                                                //           borderRadius:
                                                //               BorderRadius
                                                //                   .circular(120),
                                                //         ),
                                                //       ),
                                                //       child: Padding(
                                                //         padding:
                                                //             const EdgeInsets.all(
                                                //                 10),
                                                //         child: SvgPicture.asset(
                                                //           "assets/icons/ic_people-unknown.svg",
                                                //         ),
                                                //       ),
                                                //     ),
                                                //     "Dine in Requests",
                                                //     () {
                                                //       DashBoardController
                                                //           dashBoardController =
                                                //           Get.find<
                                                //               DashBoardController>();
                                                //       dashBoardController
                                                //           .selectedIndex
                                                //           .value = 1;
                                                //     },
                                                //   ),
                                                // ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                          Visibility(
                            visible: false,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Subscription Management".tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                // Container(
                                //   width: Responsive.width(100, context),
                                //   decoration: ShapeDecoration(
                                //     color: themeChange.getThem()
                                //         ? AppThemeData.grey900
                                //         : AppThemeData.grey50,
                                //     shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(12)),
                                //   ),
                                //   child: Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //         horizontal: 10, vertical: 8),
                                //     child: Column(
                                //       children: [
                                //         (Constant.isSubscriptionModelApplied ==
                                //                     true ||
                                //                 Constant.adminCommission
                                //                         ?.isEnabled ==
                                //                     true)
                                //             ? cardDecoration(
                                //                 themeChange,
                                //                 controller,
                                //                 Container(
                                //                   width: 44,
                                //                   height: 44,
                                //                   decoration: ShapeDecoration(
                                //                     color: themeChange.getThem()
                                //                         ? AppThemeData.driverApp50
                                //                             .withAlpha(20)
                                //                         : AppThemeData
                                //                             .driverApp50,
                                //                     shape: RoundedRectangleBorder(
                                //                       borderRadius:
                                //                           BorderRadius.circular(
                                //                               120),
                                //                     ),
                                //                   ),
                                //                   child: Padding(
                                //                     padding:
                                //                         const EdgeInsets.all(10),
                                //                     child: SvgPicture.asset(
                                //                         "assets/icons/ic_subscription.svg"),
                                //                   ),
                                //                 ),
                                //                 "Subscription Packages",
                                //                 () {
                                //                   Get.to(
                                //                       const SubscriptionPlanScreen(),
                                //                       arguments: {
                                //                         'isProfile': true
                                //                       })?.then((value) {
                                //                     if (value == true) {
                                //                       controller.getUserProfile();
                                //                     }
                                //                   });
                                //                 },
                                //               )
                                //             : SizedBox(),
                                //         cardDecoration(
                                //           themeChange,
                                //           controller,
                                //           Container(
                                //             width: 44,
                                //             height: 44,
                                //             decoration: ShapeDecoration(
                                //               color: themeChange.getThem()
                                //                   ? AppThemeData.driverApp50
                                //                       .withAlpha(20)
                                //                   : AppThemeData.driverApp50,
                                //               shape: RoundedRectangleBorder(
                                //                 borderRadius:
                                //                     BorderRadius.circular(120),
                                //               ),
                                //             ),
                                //             child: Padding(
                                //               padding: const EdgeInsets.all(10),
                                //               child: SvgPicture.asset(
                                //                 "assets/icons/ic_history.svg",
                                //               ),
                                //             ),
                                //           ),
                                //           "Subscription History",
                                //           () {
                                //             Get.to(
                                //                 const SubscriptionHistoryScreen());
                                //           },
                                //         ),
                                //       ],
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Preferences".tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey400
                                  : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  // Language Setting Section
                                  Visibility(
                                    visible: false,
                                    child: cardDecoration(
                                      themeChange,
                                      controller,
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.secondary600
                                              : AppThemeData.secondary50,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(120),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: SvgPicture.asset(
                                              "assets/icons/ic_language.svg"),
                                        ),
                                      ),
                                      "Change Language",
                                      () {
                                        Get.to(const ChangeLanguageScreen());
                                      },
                                    ),
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.warning600
                                            : AppThemeData.warning50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_darkmode.svg",
                                        ),
                                      ),
                                    ),
                                    "Dark Mode",
                                    () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Social".tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey400
                                  : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.info600
                                            : AppThemeData.info50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                            "assets/icons/ic_share.svg"),
                                      ),
                                    ),
                                    "Share app",
                                    () {
                                      Share.share(
                                          '${"Check out Jippymart, your ultimate food delivery application! \n\nGoogle Play:".tr} ${Constant.googlePlayLink} ${"\n\nApp Store:".tr} ${Constant.appStoreLink}',
                                          subject: 'Look what I made!'.tr);
                                    },
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.info600
                                            : AppThemeData.info50,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_rate.svg",
                                        ),
                                      ),
                                    ),
                                    "Rate the app",
                                    () async {
                                      final InAppReview inAppReview =
                                          InAppReview.instance;

                                      try {
                                        // Open store listing directly - this is more reliable
                                        // than requestReview() which has strict quotas and may not show
                                        // For Android: automatically uses packageName from the app
                                        // For iOS: uses appStoreId if provided
                                        await inAppReview.openStoreListing(
                                          appStoreId: Constant.appStoreId.isEmpty
                                              ? null
                                              : Constant.appStoreId,
                                        );
                                      } catch (e) {
                                        print('Error opening store listing: $e');
                                        // Fallback: Use url_launcher to open Play Store/App Store
                                        try {
                                          if (Constant.googlePlayLink.isNotEmpty) {
                                            await launchUrl(
                                              Uri.parse(Constant.googlePlayLink),
                                              mode: LaunchMode.externalApplication,
                                            );
                                          } else if (Constant.appStoreLink.isNotEmpty) {
                                            await launchUrl(
                                              Uri.parse(Constant.appStoreLink),
                                              mode: LaunchMode.externalApplication,
                                            );
                                          } else {
                                            // Last resort: Use package name for Android
                                            await launchUrl(
                                              Uri.parse('https://play.google.com/store/apps/details?id=${Constant.packageName}'),
                                              mode: LaunchMode.externalApplication,
                                            );
                                          }
                                        } catch (fallbackError) {
                                          print('Error with fallback URL launcher: $fallbackError');
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Legal".tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey400
                                  : AppThemeData.grey500,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Column(
                                children: [
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                            "assets/icons/ic_documention.svg"),
                                      ),
                                    ),
                                    "Document Verifications",
                                    () {
                                      Get.to(const VerificationScreen());
                                    },
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_terms_condition.svg",
                                        ),
                                      ),
                                    ),
                                    "Terms and Conditions",
                                    () {
                                      Get.to(const TermsAndConditionScreen(
                                        type: "termAndCondition",
                                      ));
                                    },
                                  ),
                                  cardDecoration(
                                    themeChange,
                                    controller,
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey800
                                            : AppThemeData.grey100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          "assets/icons/ic_privacyPolicy.svg",
                                        ),
                                      ),
                                    ),
                                    "Privacy Policy",
                                    () {
                                      Get.to(const TermsAndConditionScreen(
                                        type: "privacy",
                                      ));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: Responsive.width(100, context),
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Column(
                                children: [
                                  cardDecoration(
                                      themeChange,
                                      controller,
                                      SvgPicture.asset(
                                          "assets/icons/ic_logout.svg"),
                                      "Log out", () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Log out".tr,
                                            descriptions:
                                                "Are you sure you want to log out? You will need to enter your credentials to log back in."
                                                    .tr,
                                            positiveString: "Log out".tr,
                                            negativeString: "Cancel".tr,
                                            positiveClick: () async {
                                              loginController.logoutFunction();
                                              // await AudioPlayerService
                                              //     .playSound(false);
                                              // Constant.userModel!.fcmToken = "";
                                              // await FireStoreUtils.updateUser(
                                              //     Constant.userModel!);
                                              // Constant.userModel = null;
                                              // await FirebaseAuth.instance
                                              //     .signOut();
                                              // Get.offAll(const LoginScreen());
                                            },
                                            negativeClick: () {
                                              Get.back();
                                            },
                                            img: Image.asset(
                                              'assets/images/ic_logout.gif',
                                              height: 50,
                                              width: 50,
                                            ),
                                          );
                                        });
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialogBox(
                                        title: "Delete Account".tr,
                                        descriptions:
                                            "Are you sure you want to delete your account? This action is irreversible and will permanently remove all your data."
                                                .tr,
                                        positiveString: "Delete".tr,
                                        negativeString: "Cancel".tr,
                                        positiveClick: () async {
                                          ShowToastDialog.showLoader(
                                              "Please wait".tr);
                                          await controller
                                              .deleteUserFromServer();
                                          await FireStoreUtils().deleteUser()
                                              .then((value) {
                                            ShowToastDialog.closeLoader();
                                            // if (value == true) {
                                            //   ShowToastDialog.showToast(
                                            //       "Account deleted successfully"
                                            //           .tr);
                                            //   Get.offAll(const LoginScreen());
                                            // } else {
                                            //   ShowToastDialog.showToast(
                                            //       "Contact Administrator".tr);
                                            // }
                                          });
                                        },
                                        negativeClick: () {
                                          Get.back();
                                        },
                                        img: Image.asset(
                                          'assets/icons/delete_dialog.gif',
                                          height: 50,
                                          width: 50,
                                        ),
                                      );
                                    });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                      "assets/icons/ic_delete.svg"),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Delete Account".tr,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.medium,
                                      fontSize: 16,
                                      color: themeChange.getThem()
                                          ? AppThemeData.danger300
                                          : AppThemeData.danger300,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          // Version and Update Check
                          Column(
                            children: [
                              Center(
                                child: Text(
                                  "V : ${Constant.appVersion}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.medium,
                                    fontSize: 14,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  cardDecoration(themeChange, ProfileController controller, Widget image,
      String title, Function()? onPress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          if (onPress != null) {
            final result = onPress();
            // If the function returns a Future, await it
            if (result is Future) {
              try {
                await result;
              } catch (error) {
                // Handle any errors silently or log them
                print('Error in onPress callback: $error');
              }
            }
          }
        },
        child: Row(
          children: [
            image,
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                title.tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: title == "Log out"
                      ? AppThemeData.danger300
                      : themeChange.getThem()
                          ? AppThemeData.grey100
                          : AppThemeData.grey800,
                ),
              ),
            ),
            title == "Dark Mode"
                ? Transform.scale(
                    scale: 0.8,
                    child: CupertinoSwitch(
                      value: controller.isDarkModeSwitch.value,
                      activeColor: AppThemeData.primary300,
                      onChanged: (value) {
                        controller.isDarkModeSwitch.value = value;
                        if (controller.isDarkModeSwitch.value == true) {
                          Preferences.setString(Preferences.themKey, "Dark");
                          themeChange.darkTheme = 0;
                        } else if (controller.isDarkMode.value == "Light") {
                          Preferences.setString(Preferences.themKey, "Light");
                          themeChange.darkTheme = 1;
                        } else {
                          Preferences.setString(Preferences.themKey, "");
                          themeChange.darkTheme = 2;
                        }
                      },
                    ),
                  )
                : const Icon(Icons.keyboard_arrow_right)
          ],
        ),
      ),
    );
  }
}


