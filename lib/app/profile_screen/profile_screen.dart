import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jippymart_restaurant/app/edit_profile_screen/screens/edit_profile_screen.dart';
import 'package:jippymart_restaurant/app/promotions/promotion_plan_types_screen.dart';
import 'package:jippymart_restaurant/app/special_discount_screen/special_discount_screen.dart';
import 'package:jippymart_restaurant/app/subscriptions/screens/subscription_plans_screen.dart';
import 'package:jippymart_restaurant/app/terms_and_condition/terms_and_condition_screen.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/app/withdraw_method_setup_screens/withdraw_method_setup_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';
import 'package:jippymart_restaurant/controller/login_controller.dart';
import 'package:jippymart_restaurant/app/profile_screen/controller/profile_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/custom_dialog_box.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/const/image_const.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final loginController = Get.find<LoginController>();

    return GetX<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppThemeData.secondary300,
            centerTitle: false,
            iconTheme:
            const IconThemeData(color: AppThemeData.grey50, size: 20),
            title: Obx(
                  () => Text(
                controller.isOutletContext.value
                    ? 'Outlet Profile'.tr
                    : 'Merchant Profile'.tr,
                style: const TextStyle(
                  color: AppThemeData.grey50,
                  fontSize: 18,
                  fontFamily: AppThemeData.medium,
                ),
              ),
            ),
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(controller: controller),
                const SizedBox(height: 20),
                _OutletInformationSection(
                    controller: controller,
                    themeChange: themeChange),
                const SizedBox(height: 20),
                _OffersSection(
                    controller: controller,
                    themeChange: themeChange),
                const SizedBox(height: 20),
                _PreferencesSection(
                    controller: controller,
                    themeChange: themeChange),
                const SizedBox(height: 20),
                _SocialSection(
                    controller: controller,
                    themeChange: themeChange),
                const SizedBox(height: 20),
                _LegalSection(
                    controller: controller,
                    themeChange: themeChange),
                const SizedBox(height: 10),
                _LogoutButton(
                    loginController: loginController,
                    themeChange: themeChange),
                const SizedBox(height: 10),
                _DeleteAccountButton(
                    controller: controller,
                    themeChange: themeChange),
                const SizedBox(height: 10),
                _VersionFooter(themeChange: themeChange),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Header — avatar + email + Edit Profile button
// ═══════════════════════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          _ProfileAvatar(controller: controller),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name (Outlet name or Merchant name) ──
                Obx(() {
                  final name = controller.isOutletContext.value
                      ? (controller.outletModel.value.outletName ?? '')
                      : (controller.merchantModel.value?.merchantName ??
                      controller.userModel.value.fullName());

                  if (name.isEmpty) return const SizedBox.shrink();

                  return Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                      fontFamily: AppThemeData.semiBold,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  );
                }),
                const SizedBox(height: 6),

                // ── Email ──
                Obx(() {
                  final email = controller.isOutletContext.value
                      ? (controller.outletModel.value.outletEmail ?? '')
                      : (controller.userModel.value.email ?? '');

                  if (email.isEmpty) return const SizedBox.shrink();

                  return Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemeData.grey400
                          : AppThemeData.grey500,
                      fontFamily: AppThemeData.regular,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // ── Edit Profile button ──
                RoundedButtonFill(
                  title: 'Edit Profile'.tr,
                  color: ColorConst.orange,
                  textColor: AppThemeData.grey50,
                  width: 24,
                  height: 4,
                  onPress: () async {
                    final result = await Get.to(const EditProfileScreen());
                    if (result == true) {
                      controller.getUserProfile();
                      if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().refreshOutletProfile();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = controller.isOutletContext.value
          ? controller.outletModel.value.outletPicUrl?.toString()
          : controller.userModel.value.profilePictureURL?.toString();

      final hasImage = url != null && url.isNotEmpty;

      return ClipOval(
        child: hasImage
            ? NetworkImageWidget(
          imageUrl: url,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        )
            : Image.asset(
          Constant.userPlaceHolder,
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable section title
// ═══════════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Text(
      title.tr,
      style: TextStyle(
        color: themeChange.getThem()
            ? AppThemeData.grey400
            : AppThemeData.grey500,
        fontFamily: AppThemeData.semiBold,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable section card (list wrapper)
// ═══════════════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Container(
      width: Responsive.width(100, context),
      decoration: ShapeDecoration(
        color: themeChange.getThem()
            ? AppThemeData.grey900
            : AppThemeData.grey50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(children: children),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable list row
// ═══════════════════════════════════════════════════════════════════════
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.controller,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
    this.danger = false,
  });

  final ProfileController controller;
  final Widget icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () async {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap!.call();
        },
        child: Row(
          children: [
            icon,
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title.tr,
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 16,
                  color: danger
                      ? AppThemeData.danger300
                      : themeChange.getThem()
                      ? AppThemeData.grey100
                      : AppThemeData.grey800,
                ),
              ),
            ),
            trailing ?? const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Reusable icon container
// ═══════════════════════════════════════════════════════════════════════
class _IconBubble extends StatelessWidget {
  const _IconBubble({
    required this.asset,
    required this.bgColor,
    this.padding = const EdgeInsets.all(10),
    this.colorFilter,
    this.size = 44,
  });

  final String asset;
  final Color bgColor;
  final EdgeInsets padding;
  final ColorFilter? colorFilter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(120),
        ),
      ),
      child: Padding(
        padding: padding,
        child: SvgPicture.asset(asset, colorFilter: colorFilter),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Outlet Information section
// ═══════════════════════════════════════════════════════════════════════
class _OutletInformationSection extends StatelessWidget {
  const _OutletInformationSection({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    final showSection = !(Constant.isRestaurantVerification == true &&
        controller.userModel.value.isDocumentVerify == false) &&
        Constant.storyEnable != false;

    if (!showSection) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Outlet Information'),
        const SizedBox(height: 10),
        _SectionCard(
          children: [
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_manage_product.svg',
                bgColor: themeChange.getThem()
                    ? AppThemeData.secondary600
                    : AppThemeData.secondary50,
                padding: const EdgeInsets.all(12),
              ),
              title: 'Manage Products',
              onTap: () {
                final dashBoard = Get.find<DashBoardController>();
                dashBoard.selectedIndex.value =
                Constant.isDineInEnable ? 2 : 1;
              },
            ),
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_wallet.svg',
                bgColor: themeChange.getThem()
                    ? AppThemeData.secondary600
                    : AppThemeData.secondary50,
                colorFilter: ColorFilter.mode(
                  AppThemeData.secondary300,
                  BlendMode.srcIn,
                ),
              ),
              title: 'Withdraw Method',
              onTap: () => Get.to(const WithdrawMethodSetupScreen()),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Offers & Discounts section
// ═══════════════════════════════════════════════════════════════════════
class _OffersSection extends StatelessWidget {
  const _OffersSection({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Offers & Discounts'),
        const SizedBox(height: 10),
        _SectionCard(
          children: [
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_gift_box.svg',
                bgColor: themeChange.getThem()
                    ? AppThemeData.success600
                    : AppThemeData.success50,
              ),
              title: 'Promotion Plans',
              onTap: () => Get.to(const PromotionPlanTypesScreen()),
            ),
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_subscription.svg',
                bgColor: themeChange.getThem()
                    ? AppThemeData.secondary600
                    : AppThemeData.driverApp50,
              ),
              title: 'Subscription Plans',
              onTap: () => Get.to(const SubscriptionPlansScreen()),
            ),
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: ImageConst.whatsApp,
                bgColor: themeChange.getThem()
                    ? AppThemeData.secondary600
                    : AppThemeData.secondary50,
                colorFilter: ColorFilter.mode(
                  AppThemeData.secondary300,
                  BlendMode.srcIn,
                ),
              ),
              title: 'Boost my orders',
              onTap: _openBoostWhatsApp,
            ),
            if (Constant.specialDiscountOfferEnable != false)
              _ProfileRow(
                controller: controller,
                icon: _IconBubble(
                  asset: 'assets/icons/ic_coupon.svg',
                  bgColor: themeChange.getThem()
                      ? AppThemeData.success600
                      : AppThemeData.success50,
                ),
                title: 'Special Discounts',
                onTap: () => Get.to(const SpecialDiscountScreen()),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _openBoostWhatsApp() async {
    const phoneNumber = '+918106625666';
    const message =
        'Hi, I want to boost my restaurant orders. Please contact me with details.';

    final whatsappUrl = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return;
      }
      final phoneUrl = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Boost my orders launch error: $e');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Preferences section (Dark Mode switch)
// ═══════════════════════════════════════════════════════════════════════
class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Preferences'),
        const SizedBox(height: 10),
        _SectionCard(
          children: [
            Obx(
                  () => _ProfileRow(
                controller: controller,
                icon: _IconBubble(
                  asset: 'assets/icons/ic_darkmode.svg',
                  bgColor: themeChange.getThem()
                      ? AppThemeData.warning600
                      : AppThemeData.warning50,
                ),
                title: 'Dark Mode',
                onTap: () {},
                trailing: Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: controller.isDarkModeSwitch.value,
                    activeColor: AppThemeData.primary300,
                    onChanged: (value) {
                      controller.onDarkModeToggled(value);
                      if (value) {
                        themeChange.darkTheme = 0;
                      } else if (controller.isDarkMode.value == 'Light') {
                        themeChange.darkTheme = 1;
                      } else {
                        themeChange.darkTheme = 2;
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Social section (Share app / Rate app)
// ═══════════════════════════════════════════════════════════════════════
class _SocialSection extends StatelessWidget {
  const _SocialSection({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Social'),
        const SizedBox(height: 10),
        _SectionCard(
          children: [
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_share.svg',
                bgColor: themeChange.getThem()
                    ? AppThemeData.info600
                    : AppThemeData.info50,
              ),
              title: 'Share app',
              onTap: () {
                Share.share(
                  '${'Check out Jippymart, your ultimate food delivery application! \n\nGoogle Play:'.tr} '
                      '${Constant.googlePlayLink} '
                      '${'\n\nApp Store:'.tr} '
                      '${Constant.appStoreLink}',
                  subject: 'Look what I made!'.tr,
                );
              },
            ),
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_rate.svg',
                bgColor: themeChange.getThem()
                    ? AppThemeData.info600
                    : AppThemeData.info50,
              ),
              title: 'Rate the app',
              onTap: _rateApp,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _rateApp() async {
    final inAppReview = InAppReview.instance;
    try {
      await inAppReview.openStoreListing(
        appStoreId:
        Constant.appStoreId.isEmpty ? null : Constant.appStoreId,
      );
      return;
    } catch (e) {
      debugPrint('Rate the app error: $e');
    }

    // Fallback: url_launcher
    try {
      final fallbackUri = Constant.googlePlayLink.isNotEmpty
          ? Uri.parse(Constant.googlePlayLink)
          : Constant.appStoreLink.isNotEmpty
          ? Uri.parse(Constant.appStoreLink)
          : Uri.parse(
        'https://play.google.com/store/apps/details?id=${Constant.packageName}',
      );
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Rate the app fallback error: $e');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Legal section
// ═══════════════════════════════════════════════════════════════════════
class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    final bg = themeChange.getThem()
        ? AppThemeData.grey800
        : AppThemeData.grey100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Legal'),
        const SizedBox(height: 10),
        _SectionCard(
          children: [
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_documention.svg',
                bgColor: bg,
              ),
              title: 'Document Verifications',
              onTap: () => Get.to(const VerificationScreen()),
            ),
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_terms_condition.svg',
                bgColor: bg,
              ),
              title: 'Terms and Conditions',
              onTap: () => Get.to(
                const TermsAndConditionScreen(type: 'termAndCondition'),
              ),
            ),
            _ProfileRow(
              controller: controller,
              icon: _IconBubble(
                asset: 'assets/icons/ic_privacyPolicy.svg',
                bgColor: bg,
              ),
              title: 'Privacy Policy',
              onTap: () => Get.to(
                const TermsAndConditionScreen(type: 'privacy'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Logout
// ═══════════════════════════════════════════════════════════════════════
class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.loginController,
    required this.themeChange,
  });

  final LoginController loginController;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: themeChange.getThem()
            ? AppThemeData.grey900
            : AppThemeData.grey50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: _ProfileRow(
        controller: Get.find<ProfileController>(),
        icon: SvgPicture.asset('assets/icons/ic_logout.svg'),
        title: 'Log out',
        danger: true,
        onTap: () => _confirmLogout(context),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomDialogBox(
        title: 'Log out'.tr,
        descriptions:
        'Are you sure you want to log out? You will need to enter your credentials to log back in.'
            .tr,
        positiveString: 'Log out'.tr,
        negativeString: 'Cancel'.tr,
        positiveClick: () => loginController.logoutFunction(),
        negativeClick: () => Get.back(),
        img: Image.asset(
          'assets/images/ic_logout.gif',
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Delete account
// ═══════════════════════════════════════════════════════════════════════
class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({
    required this.controller,
    required this.themeChange,
  });

  final ProfileController controller;
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: InkWell(
        onTap: () => _confirmDelete(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/ic_delete.svg'),
            const SizedBox(width: 10),
            Text(
              'Delete Account'.tr,
              style: const TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 16,
                color: AppThemeData.danger300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomDialogBox(
        title: 'Delete Account'.tr,
        descriptions:
        'Are you sure you want to delete your account? This action is irreversible and will permanently remove all your data.'
            .tr,
        positiveString: 'Delete'.tr,
        negativeString: 'Cancel'.tr,
        positiveClick: () async {
          ShowToastDialog.showLoader('Please wait'.tr);
          await controller.deleteUserFromServer();
          await FireStoreUtils().deleteUser();
          ShowToastDialog.closeLoader();
        },
        negativeClick: () => Get.back(),
        img: Image.asset(
          'assets/icons/delete_dialog.gif',
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Version footer
// ═══════════════════════════════════════════════════════════════════════
class _VersionFooter extends StatelessWidget {
  const _VersionFooter({required this.themeChange});
  final DarkThemeProvider themeChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'V : ${Constant.appVersion}',
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
    );
  }
}