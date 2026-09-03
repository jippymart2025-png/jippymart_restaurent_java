// import 'package:flutter/material.dart';

// import 'package:flutter_svg/svg.dart';

// import 'package:get/get.dart';

// import 'package:provider/provider.dart';

// import 'package:url_launcher/url_launcher.dart';

//

// import 'package:jippymart_restaurant/constant/constant.dart';

// import 'package:jippymart_restaurant/controller/subscription_payment_controller.dart';

// import 'package:jippymart_restaurant/controller/subscription_plans_controller.dart';

// import 'package:jippymart_restaurant/models/subscription_plan_model.dart';

// import 'package:jippymart_restaurant/themes/app_them_data.dart';

// import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';

// import 'package:jippymart_restaurant/utils/network_image_widget.dart';

//

// import '../../controller/dash_board_controller.dart';

// //

// // /// Small plan card: plan name + Buy now button. Tap card to see details.

// // class _PlanCard extends StatelessWidget {

// //   const _PlanCard({

// //     required this.plan,

// //     required this.onTap,

// //     required this.onBuyNow,

// //   });

// //

// //   final SubscriptionPlanModel plan;

// //   final VoidCallback onTap;

// //   final VoidCallback onBuyNow;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);

// //     final isDark = themeChange.getThem();

// //     final cardBg = isDark ? AppThemeData.grey800 : AppThemeData.grey50;

// //     final surfaceColor = isDark ? AppThemeData.grey700 : AppThemeData.grey200;

// //     final textPrimary = isDark ? AppThemeData.grey50 : AppThemeData.grey900;

// //     final textSecondary = isDark ? AppThemeData.grey400 : AppThemeData.grey500;

// //

// //     const double thumbSize = 56;

// //

// //     return Padding(

// //       padding: const EdgeInsets.only(bottom: 10),

// //       child: Material(

// //         color: cardBg,

// //         borderRadius: BorderRadius.circular(12),

// //         elevation: isDark ? 0 : 1,

// //         shadowColor: Colors.black.withValues(alpha: 0.06),

// //         child: InkWell(

// //           onTap: onTap,

// //           borderRadius: BorderRadius.circular(12),

// //           child: Padding(

// //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

// //             child: Row(

// //               children: [

// //                 ClipRRect(

// //                   borderRadius: BorderRadius.circular(10),

// //                   child: plan.image != null && plan.image!.isNotEmpty

// //                       ? SizedBox(

// //                           width: thumbSize,

// //                           height: thumbSize,

// //                           child: NetworkImageWidget(

// //                             imageUrl: plan.image!,

// //                             fit: BoxFit.cover,

// //                             width: thumbSize,

// //                             height: thumbSize,

// //                             errorWidget: _planThumbPlaceholder(thumbSize, surfaceColor),

// //                           ),

// //                         )

// //                       : _planThumbPlaceholder(thumbSize, surfaceColor),

// //                 ),

// //                 const SizedBox(width: 12),

// //                 Expanded(

// //                   child: Column(

// //                     crossAxisAlignment: CrossAxisAlignment.start,

// //                     mainAxisSize: MainAxisSize.min,

// //                     children: [

// //                       Text(

// //                         plan.name,

// //                         style: TextStyle(

// //                           fontFamily: AppThemeData.semiBold,

// //                           fontSize: 16,

// //                           color: textPrimary,

// //                         ),

// //                       ),

// //                       const SizedBox(height: 2),

// //                       Text(

// //                         Constant.amountShow(amount: plan.price),

// //                         style: TextStyle(

// //                           fontFamily: AppThemeData.regular,

// //                           fontSize: 13,

// //                           color: textSecondary,

// //                         ),

// //                       ),

// //                     ],

// //                   ),

// //                 ),

// //                 const SizedBox(width: 8),

// //                 _BuyNowButton(onPressed: onBuyNow),

// //               ],

// //             ),

// //           ),

// //         ),

// //       ),

// //     );

// //   }

// //

// //   Widget _planThumbPlaceholder(double size, Color color) {

// //     return Container(

// //       width: size,

// //       height: size,

// //       color: color,

// //       child: Icon(

// //         Icons.card_membership_rounded,

// //         size: 28,

// //         color: AppThemeData.grey400,

// //       ),

// //     );

// //   }

// // }

// //

// // class _BuyNowButton extends StatelessWidget {

// //   const _BuyNowButton({required this.onPressed, this.fullWidth = false});

// //

// //   final VoidCallback onPressed;

// //   final bool fullWidth;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     final child = Padding(

// //       padding: EdgeInsets.symmetric(

// //         horizontal: fullWidth ? 24 : 16,

// //         vertical: fullWidth ? 14 : 10,

// //       ),

// //       child: Center(

// //         child: Text(

// //           "Buy now".tr,

// //           style: TextStyle(

// //             fontFamily: AppThemeData.semiBold,

// //             fontSize: fullWidth ? 16 : 14,

// //             color: AppThemeData.grey50,

// //           ),

// //         ),

// //       ),

// //     );

// //     final content = Material(

// //       color: AppThemeData.secondary300,

// //       borderRadius: BorderRadius.circular(fullWidth ? 12 : 8),

// //       child: InkWell(

// //         onTap: onPressed,

// //         borderRadius: BorderRadius.circular(fullWidth ? 12 : 8),

// //         child: child,

// //       ),

// //     );

// //     if (fullWidth) {

// //       return SizedBox(width: double.infinity, child: content);

// //     }

// //     return content;

// //   }

// // }

// //

// // class _PlanTypeChip extends StatelessWidget {

// //   const _PlanTypeChip({required this.plan});

// //

// //   final SubscriptionPlanModel plan;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     final isCommission = plan.isCommission;

// //     return Container(

// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

// //       decoration: BoxDecoration(

// //         color: isCommission

// //             ? AppThemeData.info600.withValues(alpha: 0.95)

// //             : AppThemeData.success600.withValues(alpha: 0.95),

// //         borderRadius: BorderRadius.circular(20),

// //         boxShadow: [

// //           BoxShadow(

// //             color: Colors.black.withValues(alpha: 0.2),

// //             blurRadius: 6,

// //             offset: const Offset(0, 2),

// //           ),

// //         ],

// //       ),

// //       child: Text(

// //         plan.planType == 'commission' ? 'Commission'.tr : 'Subscription'.tr,

// //         style: const TextStyle(

// //           fontFamily: AppThemeData.semiBold,

// //           fontSize: 12,

// //           color: AppThemeData.grey50,

// //         ),

// //       ),

// //     );

// //   }

// // }

// //

// // /// Full-screen detail view for a single subscription plan.

// // class SubscriptionPlanDetailScreen extends StatelessWidget {

// //   const SubscriptionPlanDetailScreen({super.key, required this.plan});

// //

// //   final SubscriptionPlanModel plan;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);

// //     final isDark = themeChange.getThem();

// //     final bgColor = isDark ? AppThemeData.grey900 : AppThemeData.grey100;

// //     final cardBg = isDark ? AppThemeData.grey800 : AppThemeData.grey50;

// //     final textPrimary = isDark ? AppThemeData.grey50 : AppThemeData.grey900;

// //     final textSecondary = isDark ? AppThemeData.grey400 : AppThemeData.grey500;

// //

// //     return Scaffold(

// //       backgroundColor: bgColor,

// //       body: CustomScrollView(

// //         slivers: [

// //           SliverAppBar(

// //             expandedHeight: 220,

// //             pinned: true,

// //             backgroundColor: AppThemeData.secondary300,

// //             leading: IconButton(

// //               icon: const Icon(Icons.arrow_back_rounded, color: AppThemeData.grey50),

// //               onPressed: () => Navigator.of(context).pop(),

// //             ),

// //             flexibleSpace: FlexibleSpaceBar(

// //               background: plan.image != null && plan.image!.isNotEmpty

// //                   ? Stack(

// //                       fit: StackFit.expand,

// //                       children: [

// //                         NetworkImageWidget(

// //                           imageUrl: plan.image!,

// //                           fit: BoxFit.cover,

// //                           errorWidget: _detailImagePlaceholder(),

// //                         ),

// //                         Container(

// //                           decoration: BoxDecoration(

// //                             gradient: LinearGradient(

// //                               begin: Alignment.topCenter,

// //                               end: Alignment.bottomCenter,

// //                               colors: [

// //                                 Colors.transparent,

// //                                 AppThemeData.grey900.withValues(alpha: 0.7),

// //                               ],

// //                             ),

// //                           ),

// //                         ),

// //                       ],

// //                     )

// //                   : _detailImagePlaceholder(),

// //             ),

// //           ),

// //           SliverToBoxAdapter(

// //             child: Padding(

// //               padding: const EdgeInsets.all(20),

// //               child: Column(

// //                 crossAxisAlignment: CrossAxisAlignment.start,

// //                 children: [

// //                   Row(

// //                     children: [

// //                       Expanded(

// //                         child: Text(

// //                           plan.name,

// //                           style: TextStyle(

// //                             fontFamily: AppThemeData.semiBold,

// //                             fontSize: 24,

// //                             color: textPrimary,

// //                           ),

// //                         ),

// //                       ),

// //                       _PlanTypeChip(plan: plan),

// //                     ],

// //                   ),

// //                   const SizedBox(height: 8),

// //                   Text(

// //                     Constant.amountShow(amount: plan.price),

// //                     style: const TextStyle(

// //                       fontFamily: AppThemeData.semiBold,

// //                       fontSize: 26,

// //                       color: AppThemeData.secondary400,

// //                     ),

// //                   ),

// //                   if (plan.expiryDay.isNotEmpty && plan.expiryDay != '0') ...[

// //                     const SizedBox(height: 4),

// //                     Text(

// //                       "Valid for ${plan.expiryDay} days".tr,

// //                       style: TextStyle(

// //                         fontFamily: AppThemeData.regular,

// //                         fontSize: 14,

// //                         color: textSecondary,

// //                       ),

// //                     ),

// //                   ],

// //                   if (plan.description.isNotEmpty) ...[

// //                     const SizedBox(height: 20),

// //                     Text(

// //                       "About this plan".tr,

// //                       style: TextStyle(

// //                         fontFamily: AppThemeData.semiBold,

// //                         fontSize: 16,

// //                         color: textPrimary,

// //                       ),

// //                     ),

// //                     const SizedBox(height: 8),

// //                     Text(

// //                       plan.description,

// //                       style: TextStyle(

// //                         fontFamily: AppThemeData.regular,

// //                         fontSize: 15,

// //                         color: textSecondary,

// //                         height: 1.5,

// //                       ),

// //                     ),

// //                   ],

// //                   const SizedBox(height: 24),

// //                   Text(

// //                     "Plan details".tr,

// //                     style: TextStyle(

// //                       fontFamily: AppThemeData.semiBold,

// //                       fontSize: 16,

// //                       color: textPrimary,

// //                     ),

// //                   ),

// //                   const SizedBox(height: 12),

// //                   _DetailCard(

// //                     cardBg: cardBg,

// //                     textPrimary: textPrimary,

// //                     textSecondary: textSecondary,

// //                     children: [

// //                       _DetailRow(

// //                         label: "Plan type".tr,

// //                         value: plan.planType == 'commission'

// //                             ? 'Commission'.tr

// //                             : 'Subscription'.tr,

// //                         textPrimary: textPrimary,

// //                         textSecondary: textSecondary,

// //                         showDivider: false,

// //                       ),

// //                       if (plan.expiryDay.isNotEmpty)

// //                         _DetailRow(

// //                           label: "Validity".tr,

// //                           value: plan.expiryDay == '0'

// //                               ? "Unlimited".tr

// //                               : "${plan.expiryDay} days",

// //                           textPrimary: textPrimary,

// //                           textSecondary: textSecondary,

// //                         ),

// //                       if (plan.itemLimit.isNotEmpty && plan.itemLimit != 'null')

// //                         _DetailRow(

// //                           label: "Item limit".tr,

// //                           value: plan.itemLimit == '0'

// //                               ? "Unlimited".tr

// //                               : plan.itemLimit,

// //                           textPrimary: textPrimary,

// //                           textSecondary: textSecondary,

// //                         ),

// //                       if (plan.orderLimit.isNotEmpty && plan.orderLimit != 'null')

// //                         _DetailRow(

// //                           label: "Order limit".tr,

// //                           value: plan.orderLimit == '0'

// //                               ? "Unlimited".tr

// //                               : plan.orderLimit,

// //                           textPrimary: textPrimary,

// //                           textSecondary: textSecondary,

// //                         ),

// //                       if (plan.place.isNotEmpty && plan.place != '0')

// //                         _DetailRow(

// //                           label: "Place".tr,

// //                           value: plan.place,

// //                           textPrimary: textPrimary,

// //                           textSecondary: textSecondary,

// //                         ),

// //                     ],

// //                   ),

// //                   const SizedBox(height: 24),

// //                   _BuyNowButton(

// //                     fullWidth: true,

// //                     onPressed: () {

// //                       // TODO: Wire to payment / subscribe API

// //                       Navigator.of(context).pop();

// //                     },

// //                   ),

// //                   const SizedBox(height: 32),

// //                 ],

// //               ),

// //             ),

// //           ),

// //         ],

// //       ),

// //     );

// //   }

// //

// //   Widget _detailImagePlaceholder() {

// //     return Container(

// //       color: AppThemeData.grey800,

// //       child: Center(

// //         child: Icon(

// //           Icons.card_membership_rounded,

// //           size: 72,

// //           color: AppThemeData.grey500,

// //         ),

// //       ),

// //     );

// //   }

// // }

// //

// // class _DetailCard extends StatelessWidget {

// //   const _DetailCard({

// //     required this.cardBg,

// //     required this.textPrimary,

// //     required this.textSecondary,

// //     required this.children,

// //   });

// //

// //   final Color cardBg;

// //   final Color textPrimary;

// //   final Color textSecondary;

// //   final List<Widget> children;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     return Container(

// //       width: double.infinity,

// //       padding: const EdgeInsets.all(16),

// //       decoration: BoxDecoration(

// //         color: cardBg,

// //         borderRadius: BorderRadius.circular(14),

// //         border: Border.all(

// //           color: AppThemeData.grey300.withValues(alpha: 0.5),

// //           width: 1,

// //         ),

// //       ),

// //       child: Column(

// //         crossAxisAlignment: CrossAxisAlignment.start,

// //         children: children,

// //       ),

// //     );

// //   }

// // }

// //

// // class _DetailRow extends StatelessWidget {

// //   const _DetailRow({

// //     required this.label,

// //     required this.value,

// //     required this.textPrimary,

// //     required this.textSecondary,

// //     this.showDivider = true,

// //   });

// //

// //   final String label;

// //   final String value;

// //   final Color textPrimary;

// //   final Color textSecondary;

// //   final bool showDivider;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     return Column(

// //       mainAxisSize: MainAxisSize.min,

// //       children: [

// //         if (showDivider)

// //           Divider(

// //             height: 1,

// //             thickness: 1,

// //             color: AppThemeData.grey300.withValues(alpha: 0.4),

// //           ),

// //         Padding(

// //           padding: const EdgeInsets.symmetric(vertical: 12),

// //           child: Row(

// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,

// //             crossAxisAlignment: CrossAxisAlignment.start,

// //             children: [

// //               Expanded(

// //                 child: Text(

// //                   label,

// //                   style: TextStyle(

// //                     fontFamily: AppThemeData.regular,

// //                     fontSize: 14,

// //                     color: textSecondary,

// //                   ),

// //                 ),

// //               ),

// //               const SizedBox(width: 16),

// //               Flexible(

// //                 child: Text(

// //                   value,

// //                   textAlign: TextAlign.right,

// //                   style: TextStyle(

// //                     fontFamily: AppThemeData.semiBold,

// //                     fontSize: 14,

// //                     color: textPrimary,

// //                   ),

// //                 ),

// //               ),

// //             ],

// //           ),

// //         ),

// //       ],

// //     );

// //   }

// // }

// //

// // class _ErrorView extends StatelessWidget {

// //   const _ErrorView({required this.message, required this.onRetry});

// //

// //   final String message;

// //   final VoidCallback onRetry;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     return Center(

// //       child: Padding(

// //         padding: const EdgeInsets.symmetric(horizontal: 24),

// //         child: Column(

// //           mainAxisAlignment: MainAxisAlignment.center,

// //           children: [

// //             Icon(

// //               Icons.error_outline_rounded,

// //               size: 56,

// //               color: AppThemeData.danger300,

// //             ),

// //             const SizedBox(height: 16),

// //             Text(

// //               message,

// //               textAlign: TextAlign.center,

// //               style: const TextStyle(

// //                 fontFamily: AppThemeData.medium,

// //                 fontSize: 16,

// //                 color: AppThemeData.grey600,

// //               ),

// //             ),

// //             const SizedBox(height: 20),

// //             TextButton.icon(

// //               onPressed: onRetry,

// //               icon: Icon(Icons.refresh_rounded, color: AppThemeData.secondary300),

// //               label: Text("Retry".tr),

// //               style: TextButton.styleFrom(

// //                 foregroundColor: AppThemeData.secondary400,

// //               ),

// //             ),

// //           ],

// //         ),

// //       ),

// //     );

// //   }

// // }

// //

// // class _EmptyView extends StatelessWidget {

// //   const _EmptyView({required this.onRetry});

// //

// //   final VoidCallback onRetry;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     return Center(

// //       child: Padding(

// //         padding: const EdgeInsets.symmetric(horizontal: 24),

// //         child: Column(

// //           mainAxisAlignment: MainAxisAlignment.center,

// //           children: [

// //             Icon(

// //               Icons.inbox_rounded,

// //               size: 56,

// //               color: AppThemeData.grey400,

// //             ),

// //             const SizedBox(height: 16),

// //             Text(

// //               "No subscription plans available.".tr,

// //               textAlign: TextAlign.center,

// //               style: const TextStyle(

// //                 fontFamily: AppThemeData.medium,

// //                 fontSize: 16,

// //                 color: AppThemeData.grey500,

// //               ),

// //             ),

// //             const SizedBox(height: 20),

// //             TextButton.icon(

// //               onPressed: onRetry,

// //               icon: Icon(Icons.refresh_rounded, color: AppThemeData.secondary300),

// //               label: Text("Refresh".tr),

// //               style: TextButton.styleFrom(

// //                 foregroundColor: AppThemeData.secondary400,

// //               ),

// //             ),

// //           ],

// //         ),

// //       ),

// //     );

// //   }

// // }

//

//

//

// // ─────────────────────────────────────────────

// // DESIGN TOKENS

// // ─────────────────────────────────────────────

// class _Tok {

//   // Spacing

//   static const double s2 = 2, s4 = 4, s6 = 6, s8 = 8, s10 = 10, s12 = 12,

//       s14 = 14, s16 = 16, s20 = 20, s24 = 24, s28 = 28, s32 = 32, s48 = 48;

//

//   // Border radii

//   static const double r8 = 8, r12 = 12, r16 = 16, r20 = 20, r24 = 24, r99 = 99;

//

//   // Font sizes

//   static const double f11 = 11, f12 = 12, f13 = 13, f14 = 14, f15 = 15,

//       f16 = 16, f18 = 18, f22 = 22, f26 = 26, f28 = 28;

//

//   // Icon sizes

//   static const double i18 = 18, i22 = 22, i28 = 28, i32 = 32, i48 = 48, i64 = 64;

//

//   // Gradients

//   static const LinearGradient heroGrad = LinearGradient(

//     begin: Alignment.topLeft,

//     end: Alignment.bottomRight,

//     colors: [Color(0xFF1A1F3C), Color(0xFF2D3561)],

//   );

//   static const LinearGradient accentGrad = LinearGradient(

//     begin: Alignment.topLeft,

//     end: Alignment.bottomRight,

//     colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],

//   );

//   static const LinearGradient commissionGrad = LinearGradient(

//     begin: Alignment.topLeft,

//     end: Alignment.bottomRight,

//     colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],

//   );

//   static const LinearGradient subGrad = LinearGradient(

//     begin: Alignment.topLeft,

//     end: Alignment.bottomRight,

//     colors: [Color(0xFF11998E), Color(0xFF38EF7D)],

//   );

// }

//

// // ─────────────────────────────────────────────

// // MAIN SCREEN

// // ─────────────────────────────────────────────

// class SubscriptionPlansScreen extends StatelessWidget {

//   const SubscriptionPlansScreen({super.key});

//

//   @override

//   Widget build(BuildContext context) {

//     // Make sure payment controller exists for Buy Now actions.

//     final SubscriptionPaymentController paymentController =

//         Get.put(SubscriptionPaymentController());

//     return GetBuilder<SubscriptionPlansController>(

//       init: SubscriptionPlansController(),

//       builder: (controller) {

//         return Scaffold(

//           backgroundColor: _bg(context),

//           floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

//           floatingActionButton: Padding(

//             padding: const EdgeInsets.symmetric(horizontal: 16.0),

//             child: SizedBox(

//               width: double.infinity,

//               child: ElevatedButton(

//                 style: ElevatedButton.styleFrom(

//                   backgroundColor: const Color(0xFF25D366), // WhatsApp green

//                   padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),

//                   shape: RoundedRectangleBorder(

//                     borderRadius: BorderRadius.circular(40),

//                   ),

//                   elevation: 8,

//                   shadowColor: const Color(0xFF25D366).withValues(alpha: 0.45),

//                 ),

//                 onPressed: () async {

//                   const String phoneNumber = '+918106625666';

//                   const String message =

//                       "I'm interested in more information about your subscription plans";

//                   final Uri whatsappUrl = Uri.parse(

//                     'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',

//                   );

//                   try {

//                     if (await canLaunchUrl(whatsappUrl)) {

//                       await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);

//                     } else {

//                       final Uri phoneUrl = Uri.parse('tel:$phoneNumber');

//                       if (await canLaunchUrl(phoneUrl)) {

//                         await launchUrl(phoneUrl, mode: LaunchMode.externalApplication);

//                       }

//                     }

//                   } catch (e) {

//                     debugPrint('Error launching WhatsApp: $e');

//                   }

//                 },

//                 child: Row(

//                   mainAxisAlignment: MainAxisAlignment.center,

//                   children: [

//                     // WhatsApp SVG Icon

//                     SizedBox(

//                       width: 26,

//                       height: 26,

//                       child: SvgPicture.string(

//                         '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="white">

//                 <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347z"/>

//                 <path d="M12 0C5.373 0 0 5.373 0 12c0 2.135.563 4.14 1.54 5.875L0 24l6.31-1.516A11.944 11.944 0 0012 24c6.627 0 12-5.373 12-12S18.627 0 12 0zm0 21.818a9.818 9.818 0 01-5.006-1.371l-.36-.214-3.727.896.933-3.625-.234-.373A9.818 9.818 0 1112 21.818z"/>

//               </svg>''',

//                       ),

//                     ),

//                     const SizedBox(width: 10),

//                     const Flexible(

//                       child: Text(

//                         'Need more info about plans? Chat on WhatsApp',

//                         textAlign: TextAlign.center,

//                         style: TextStyle(

//                           fontFamily: AppThemeData.semiBold,

//                           fontSize: 14,

//                           color: Colors.white,

//                           letterSpacing: 0.2,

//                         ),

//                       ),

//                     ),

//                   ],

//                 ),

//               ),

//             ),

//           ),

//           body: Obx(() {

//             // Build current active plan (if any) from dashboard vendor snapshot.

//             SubscriptionPlanModel? currentPlan;

//             try {

//               if (Get.isRegistered<DashBoardController>()) {

//                 final dash = Get.find<DashBoardController>();

//                 final raw = dash.vendorModel.value.subscriptionPlan;

//                 if (raw is Map && raw!.isNotEmpty) {

//                   currentPlan = SubscriptionPlanModel.fromJson(

//                       Map<String, dynamic>.from(raw as Map<dynamic, dynamic>));

//                 }

//               }

//             } catch (_) {}

//

//             final List<Widget> slivers = [

//               _PlansAppBar(planCount: controller.plans.length),

//               if (currentPlan != null)

//                 SliverToBoxAdapter(

//                   child: Padding(

//                     padding: const EdgeInsets.fromLTRB(

//                         _Tok.s16, _Tok.s20, _Tok.s16, _Tok.s10),

//                     child: _CurrentPlanCard(plan: currentPlan),

//                   ),

//                 ),

//             ];

//

//             // Keep current plan visible while loading/error/empty states

//             // only affect the content below it.

//             if (controller.isLoading.value && controller.plans.isEmpty) {

//               slivers.add(

//                 const SliverFillRemaining(

//                   hasScrollBody: false,

//                   child: _LoadingView(),

//                 ),

//               );

//             } else if (controller.hasError && controller.plans.isEmpty) {

//               slivers.add(

//                 SliverFillRemaining(

//                   hasScrollBody: false,

//                   child: _ErrorView(

//                     message: controller.errorMessage.value,

//                     onRetry: controller.fetchPlans,

//                   ),

//                 ),

//               );

//             } else if (!controller.hasPlans) {

//               slivers.add(

//                 SliverFillRemaining(

//                   hasScrollBody: false,

//                   child: _EmptyView(onRetry: controller.fetchPlans),

//                 ),

//               );

//             } else {

//               slivers.add(

//                 SliverPadding(

//                   padding: const EdgeInsets.fromLTRB(

//                       _Tok.s16, _Tok.s20, _Tok.s16, 0),

//                   sliver: SliverList(

//                     delegate: SliverChildBuilderDelegate(

//                       (context, index) {

//                         final plan = controller.plans[index];

//                         return _PlanCard(

//                           plan: plan,

//                           index: index,

//                           onTap: () => _openDetail(context, plan),

//                           onBuyNow: () =>

//                               paymentController.startRazorpayPayment(plan),

//                         );

//                       },

//                       childCount: controller.plans.length,

//                     ),

//                   ),

//                 ),

//               );

//             }

//

//             return CustomScrollView(

//               physics: const BouncingScrollPhysics(),

//               slivers: slivers,

//             );

//           }),

//         );

//       },

//     );

//   }

//

//   void _openDetail(BuildContext context, SubscriptionPlanModel plan) {

//     Navigator.of(context).push(

//       PageRouteBuilder<void>(

//         pageBuilder: (_, animation, __) =>

//             FadeTransition(

//               opacity: animation,

//               child: SubscriptionPlanDetailScreen(plan: plan),

//             ),

//         transitionDuration: const Duration(milliseconds: 300),

//       ),

//     );

//   }

//

//   static Color _bg(BuildContext context) {

//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);

//   }

// }

//

// // ─────────────────────────────────────────────

// // APP BAR

// // ─────────────────────────────────────────────

// class _PlansAppBar extends StatelessWidget {

//   const _PlansAppBar({required this.planCount});

//   final int planCount;

//

//   @override

//   Widget build(BuildContext context) {

//     return SliverAppBar(

//       pinned: true,

//       backgroundColor: AppThemeData.secondary300,

//       elevation: 0,

//       leading: IconButton(

//         onPressed: () => Navigator.of(context).pop(),

//         icon: const Icon(Icons.arrow_back_rounded,

//             color: AppThemeData.grey50, size: _Tok.i22),

//       ),

//       title: Text(

//         "Subscription Plans".tr,

//         style: const TextStyle(

//           fontFamily: AppThemeData.semiBold,

//           fontSize: _Tok.f18,

//           color: AppThemeData.grey50,

//         ),

//       ),

//       actions: [

//         Container(

//           margin: const EdgeInsets.only(right: _Tok.s16),

//           padding: const EdgeInsets.symmetric(

//               horizontal: _Tok.s12, vertical: _Tok.s6),

//           decoration: BoxDecoration(

//             color: Colors.white.withValues(alpha: 0.2),

//             borderRadius: BorderRadius.circular(_Tok.r99),

//           ),

//           child: Text(

//             "$planCount plans",

//             style: const TextStyle(

//               fontFamily: AppThemeData.semiBold,

//               fontSize: _Tok.f12,

//               color: Colors.white,

//             ),

//           ),

//         ),

//       ],

//     );

//   }

// }

//

// /// Highlight card for the vendor's currently active subscription plan.

// class _CurrentPlanCard extends StatelessWidget {

//   const _CurrentPlanCard({required this.plan});

//   final SubscriptionPlanModel plan;

//

//   @override

//   Widget build(BuildContext context) {

//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     final bg = isDark ? const Color(0xFF111827) : const Color(0xFFFFFBEB);

//     final border = isDark ? const Color(0xFF92400E) : const Color(0xFFF59E0B);

//     final text = isDark ? Colors.white : const Color(0xFF78350F);

//

//     final expiryDay = plan.expiryDay;

//     final validityText = expiryDay.isEmpty || expiryDay == '0'

//         ? 'Unlimited'

//         : '${expiryDay} days';

//

//     return Container(

//       padding: const EdgeInsets.all(_Tok.s14),

//       decoration: BoxDecoration(

//         color: bg,

//         borderRadius: BorderRadius.circular(_Tok.r16),

//         border: Border.all(color: border.withOpacity(0.6), width: 1.1),

//       ),

//       child: Row(

//         children: [

//           Container(

//             padding: const EdgeInsets.all(_Tok.s8),

//             decoration: BoxDecoration(

//               color: border.withOpacity(0.15),

//               borderRadius: BorderRadius.circular(_Tok.r12),

//             ),

//             child: const Icon(

//               Icons.workspace_premium_rounded,

//               size: _Tok.i22,

//               color: Color(0xFFEA580C),

//             ),

//           ),

//           const SizedBox(width: _Tok.s10),

//           Expanded(

//             child: Column(

//               crossAxisAlignment: CrossAxisAlignment.start,

//               mainAxisSize: MainAxisSize.min,

//               children: [

//                 Text(

//                   'Current plan'.tr,

//                   style: TextStyle(

//                     fontFamily: AppThemeData.semiBold,

//                     fontSize: _Tok.f12,

//                     color: text.withOpacity(0.85),

//                   ),

//                 ),

//                 const SizedBox(height: _Tok.s2),

//                 Text(

//                   plan.name,

//                   maxLines: 1,

//                   overflow: TextOverflow.ellipsis,

//                   style: TextStyle(

//                     fontFamily: AppThemeData.semiBold,

//                     fontSize: _Tok.f15,

//                     color: text,

//                   ),

//                 ),

//                 const SizedBox(height: _Tok.s2),

//                 Row(

//                   children: [

//                     Text(

//                       Constant.amountShow(amount: plan.price),

//                       style: TextStyle(

//                         fontFamily: AppThemeData.semiBold,

//                         fontSize: _Tok.f13,

//                         color: text.withOpacity(0.9),

//                       ),

//                     ),

//                     const SizedBox(width: _Tok.s6),

//                     Text(

//                       '• $validityText',

//                       style: TextStyle(

//                         fontFamily: AppThemeData.regular,

//                         fontSize: _Tok.f12,

//                         color: text.withOpacity(0.75),

//                       ),

//                     ),

//                   ],

//                 ),

//               ],

//             ),

//           ),

//         ],

//       ),

//     );

//   }

// }

//

// // ─────────────────────────────────────────────

// // PLAN CARD

// // ─────────────────────────────────────────────

// class _PlanCard extends StatelessWidget {

//   const _PlanCard({

//     required this.plan,

//     this.index,

//     required this.onTap,

//     this.onBuyNow,

//   });

//

//   final SubscriptionPlanModel plan;

//   final int? index;

//   final VoidCallback onTap;

//   final VoidCallback? onBuyNow;

//

//   @override

//   Widget build(BuildContext context) {

//     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);

//     final isDark = themeChange.getThem();

//     final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;

//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F3C);

//     final textSub = isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);

//     final isCommission = plan.isCommission;

//     final planGrad = isCommission ? _Tok.commissionGrad : _Tok.subGrad;

//

//     // Fixed card height — single row layout

//     const double cardH = 88.0;

//     const double imgSize = 58.0;

//

//     return Padding(

//       padding: const EdgeInsets.only(bottom: _Tok.s10),

//       child: SizedBox(

//         height: cardH,

//         child: Material(

//           color: Colors.transparent,

//           child: InkWell(

//             onTap: onTap,

//             borderRadius: BorderRadius.circular(_Tok.r16),

//             child: Container(

//               decoration: BoxDecoration(

//                 color: cardBg,

//                 borderRadius: BorderRadius.circular(_Tok.r16),

//                 boxShadow: [

//                   BoxShadow(

//                     color: isDark

//                         ? Colors.black.withValues(alpha: 0.25)

//                         : Colors.black.withValues(alpha: 0.06),

//                     blurRadius: 12,

//                     offset: const Offset(0, 3),

//                   ),

//                 ],

//               ),

//               padding: const EdgeInsets.symmetric(

//                   horizontal: _Tok.s12, vertical: _Tok.s12),

//               child: Row(

//                 children: [

//                   // ── left: small square image ──

//                   ClipRRect(

//                     borderRadius: BorderRadius.circular(_Tok.r12),

//                     child: SizedBox(

//                       width: imgSize,

//                       height: imgSize,

//                       child: plan.image != null && plan.image!.isNotEmpty

//                           ? NetworkImageWidget(

//                         imageUrl: plan.image!,

//                         fit: BoxFit.cover,

//                         width: imgSize,

//                         height: imgSize,

//                         errorWidget: _SmallPlaceholder(

//                             grad: planGrad, size: imgSize),

//                       )

//                           : _SmallPlaceholder(grad: planGrad, size: imgSize),

//                     ),

//                   ),

//                   const SizedBox(width: _Tok.s12),

//

//                   // ── middle: name + meta ──

//                   Expanded(

//                     child: Column(

//                       mainAxisAlignment: MainAxisAlignment.center,

//                       crossAxisAlignment: CrossAxisAlignment.start,

//                       children: [

//                         Text(

//                           plan.name,

//                           maxLines: 1,

//                           overflow: TextOverflow.ellipsis,

//                           style: TextStyle(

//                             fontFamily: AppThemeData.semiBold,

//                             fontSize: _Tok.f15,

//                             color: textPrimary,

//                             letterSpacing: -0.2,

//                           ),

//                         ),

//                         const SizedBox(height: _Tok.s4),

//                         Text(

//                           Constant.amountShow(amount: plan.price),

//                           style: TextStyle(

//                             fontFamily: AppThemeData.semiBold,

//                             fontSize: _Tok.f14,

//                             color: AppThemeData.secondary300,

//                           ),

//                         ),

//                         const SizedBox(height: _Tok.s2),

//                         Row(

//                           children: [

//                             Icon(Icons.access_time_rounded,

//                                 size: 11, color: textSub),

//                             const SizedBox(width: 3),

//                             Text(

//                               plan.expiryDay.isEmpty || plan.expiryDay == '0'

//                                   ? "Unlimited"

//                                   : "${plan.expiryDay} days",

//                               style: TextStyle(

//                                 fontFamily: AppThemeData.regular,

//                                 fontSize: _Tok.f11,

//                                 color: textSub,

//                               ),

//                             ),

//                             const SizedBox(width: _Tok.s8),

//                             _TypeBadgeInline(isCommission: isCommission),

//                           ],

//                         ),

//                       ],

//                     ),

//                   ),

//                   const SizedBox(width: _Tok.s10),

//

//                   // ── right: buy button ──

//                   _PillButton(

//                     label: "Buy Now".tr,

//                     gradient: planGrad,

//                     onPressed: onBuyNow ?? onTap,

//                   ),

//                 ],

//               ),

//             ),

//           ),

//         ),

//       ),

//     );

//   }

//

//

// }

//

// // ─────────────────────────────────────────────

// // PILL BUTTON

// // ─────────────────────────────────────────────

// class _PillButton extends StatelessWidget {

//   const _PillButton({

//     required this.label,

//     required this.gradient,

//     required this.onPressed,

//     this.fullWidth = false,

//   });

//   final String label;

//   final Gradient gradient;

//   final VoidCallback onPressed;

//   final bool fullWidth;

//

//   @override

//   Widget build(BuildContext context) {

//     final inner = Material(

//       color: Colors.transparent,

//       child: InkWell(

//         onTap: onPressed,

//         borderRadius: BorderRadius.circular(_Tok.r99),

//         child: Container(

//           padding: EdgeInsets.symmetric(

//             horizontal: fullWidth ? 0 : _Tok.s20,

//             vertical: fullWidth ? _Tok.s16 : _Tok.s10,

//           ),

//           alignment: fullWidth ? Alignment.center : null,

//           decoration: BoxDecoration(

//             gradient: gradient,

//             borderRadius: BorderRadius.circular(_Tok.r99),

//             boxShadow: [

//               BoxShadow(

//                 color: _gradFirstColor(gradient).withValues(alpha: 0.35),

//                 blurRadius: 12,

//                 offset: const Offset(0, 4),

//               ),

//             ],

//           ),

//           child: Text(

//             label,

//             style: TextStyle(

//               fontFamily: AppThemeData.semiBold,

//               fontSize: fullWidth ? _Tok.f16 : _Tok.f13,

//               color: Colors.white,

//               letterSpacing: 0.2,

//             ),

//           ),

//         ),

//       ),

//     );

//     if (fullWidth) {

//       return SizedBox(width: double.infinity, child: inner);

//     }

//     return inner;

//   }

//

//   Color _gradFirstColor(Gradient g) {

//     if (g is LinearGradient && g.colors.isNotEmpty) return g.colors.first;

//     return AppThemeData.secondary300;

//   }

// }

//

// // ─────────────────────────────────────────────

// // TYPE BADGE

// // ─────────────────────────────────────────────

// class _TypeBadge extends StatelessWidget {

//   const _TypeBadge({required this.isCommission});

//   final bool isCommission;

//

//   @override

//   Widget build(BuildContext context) {

//     return Container(

//       padding: const EdgeInsets.symmetric(

//           horizontal: _Tok.s10, vertical: _Tok.s4),

//       decoration: BoxDecoration(

//         color: Colors.black.withValues(alpha: 0.35),

//         borderRadius: BorderRadius.circular(_Tok.r99),

//         border: Border.all(

//             color: Colors.white.withValues(alpha: 0.25), width: 0.8),

//       ),

//       child: Row(

//         mainAxisSize: MainAxisSize.min,

//         children: [

//           Icon(

//             isCommission ? Icons.percent_rounded : Icons.star_rounded,

//             size: 11,

//             color: Colors.white,

//           ),

//           const SizedBox(width: 4),

//           Text(

//             isCommission ? 'Commission'.tr : 'Subscription'.tr,

//             style: const TextStyle(

//               fontFamily: AppThemeData.semiBold,

//               fontSize: _Tok.f11,

//               color: Colors.white,

//             ),

//           ),

//         ],

//       ),

//     );

//   }

// }

//

// // // ─────────────────────────────────────────────

// // // PLACEHOLDER

// // // ─────────────────────────────────────────────

// // class _PlanIconPlaceholder extends StatelessWidget {

// //   const _PlanIconPlaceholder({required this.grad});

// //   final LinearGradient grad;

// //

// //   @override

// //   Widget build(BuildContext context) {

// //     return Container(

// //       decoration: BoxDecoration(gradient: grad),

// //       child: const Center(

// //         child: Icon(

// //           Icons.card_membership_rounded,

// //           size: _Tok.i48,

// //           color: Colors.white54,

// //         ),

// //       ),

// //     );

// //   }

// // }

//

// class _SmallPlaceholder extends StatelessWidget {

//   const _SmallPlaceholder({required this.grad, required this.size});

//   final LinearGradient grad;

//   final double size;

//

//   @override

//   Widget build(BuildContext context) {

//     return Container(

//       width: size,

//       height: size,

//       decoration: BoxDecoration(gradient: grad),

//       child: const Center(

//         child: Icon(Icons.card_membership_rounded,

//             size: 24, color: Colors.white60),

//       ),

//     );

//   }

// }

//

// /// Tiny inline badge used inside the horizontal card row

// class _TypeBadgeInline extends StatelessWidget {

//   const _TypeBadgeInline({required this.isCommission});

//   final bool isCommission;

//

//   @override

//   Widget build(BuildContext context) {

//     return Container(

//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

//       decoration: BoxDecoration(

//         color: isCommission

//             ? const Color(0xFF4776E6).withValues(alpha: 0.12)

//             : const Color(0xFF11998E).withValues(alpha: 0.12),

//         borderRadius: BorderRadius.circular(_Tok.r99),

//       ),

//       child: Text(

//         isCommission ? 'Commission'.tr : 'Subscription'.tr,

//         style: TextStyle(

//           fontFamily: AppThemeData.semiBold,

//           fontSize: 9,

//           color: isCommission

//               ? const Color(0xFF4776E6)

//               : const Color(0xFF11998E),

//         ),

//       ),

//     );

//   }

// }

//

// // ─────────────────────────────────────────────

// // DOT PATTERN PAINTER

// // ─────────────────────────────────────────────

// class _DotPatternPainter extends CustomPainter {

//   @override

//   void paint(Canvas canvas, Size size) {

//     final paint = Paint()..color = Colors.white;

//     const spacing = 14.0;

//     for (double x = 0; x < size.width; x += spacing) {

//       for (double y = 0; y < size.height; y += spacing) {

//         canvas.drawCircle(Offset(x, y), 1.5, paint);

//       }

//     }

//   }

//

//   @override

//   bool shouldRepaint(_DotPatternPainter old) => false;

// }

//

// // ─────────────────────────────────────────────

// // DETAIL SCREEN

// // ─────────────────────────────────────────────

// class SubscriptionPlanDetailScreen extends StatelessWidget {

//   const SubscriptionPlanDetailScreen({super.key, required this.plan});

//   final SubscriptionPlanModel plan;

//

//   @override

//   Widget build(BuildContext context) {

//     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);

//     final isDark = themeChange.getThem();

//     final bgColor = isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);

//     final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;

//     final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F3C);

//     final textSub = isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);

//     final divider = isDark ? const Color(0xFF2A2F50) : const Color(0xFFE8EDF5);

//     final isCommission = plan.isCommission;

//     final planGrad = isCommission ? _Tok.commissionGrad : _Tok.subGrad;

//

//     return Scaffold(

//       backgroundColor: bgColor,

//       body: CustomScrollView(

//         physics: const BouncingScrollPhysics(),

//         slivers: [

//           // ── hero app bar ──

//           SliverAppBar(

//             expandedHeight: 260,

//             pinned: true,

//             stretch: true,

//             backgroundColor: Colors.transparent,

//             elevation: 0,

//             leading: Padding(

//               padding: const EdgeInsets.only(left: _Tok.s8),

//               child: IconButton(

//                 icon: Container(

//                   padding: const EdgeInsets.all(_Tok.s8),

//                   decoration: BoxDecoration(

//                     color: Colors.black.withValues(alpha: 0.3),

//                     borderRadius: BorderRadius.circular(_Tok.r12),

//                     border: Border.all(

//                         color: Colors.white.withValues(alpha: 0.15)),

//                   ),

//                   child: const Icon(Icons.arrow_back_rounded,

//                       color: Colors.white, size: _Tok.i22),

//                 ),

//                 onPressed: () => Navigator.of(context).pop(),

//               ),

//             ),

//             flexibleSpace: FlexibleSpaceBar(

//               stretchModes: const [StretchMode.blurBackground],

//               background: Stack(

//                 fit: StackFit.expand,

//                 children: [

//                   // base gradient

//                   Container(decoration: BoxDecoration(gradient: planGrad)),

//                   // dot pattern

//                   Opacity(

//                     opacity: 0.06,

//                     child: CustomPaint(painter: _DotPatternPainter()),

//                   ),

//                   // plan image

//                   if (plan.image != null && plan.image!.isNotEmpty)

//                     NetworkImageWidget(

//                       imageUrl: plan.image!,

//                       fit: BoxFit.cover,

//                       errorWidget: const SizedBox.shrink(),

//                     ),

//                   // bottom scrim

//                   Container(

//                     decoration: BoxDecoration(

//                       gradient: LinearGradient(

//                         begin: Alignment.topCenter,

//                         end: Alignment.bottomCenter,

//                         stops: const [0.4, 1.0],

//                         colors: [

//                           Colors.transparent,

//                           bgColor,

//                         ],

//                       ),

//                     ),

//                   ),

//                   // bottom content

//                   Positioned(

//                     left: _Tok.s20,

//                     right: _Tok.s20,

//                     bottom: _Tok.s20,

//                     child: Column(

//                       crossAxisAlignment: CrossAxisAlignment.start,

//                       children: [

//                         _TypeBadge(isCommission: isCommission),

//                         const SizedBox(height: _Tok.s8),

//                         Text(

//                           plan.name,

//                           style: const TextStyle(

//                             fontFamily: AppThemeData.semiBold,

//                             fontSize: _Tok.f26,

//                             color: Colors.white,

//                             letterSpacing: -0.5,

//                             shadows: [

//                               Shadow(blurRadius: 12, color: Colors.black38),

//                             ],

//                           ),

//                         ),

//                       ],

//                     ),

//                   ),

//                 ],

//               ),

//             ),

//           ),

//

//           // ── body ──

//           SliverToBoxAdapter(

//             child: Padding(

//               padding: const EdgeInsets.fromLTRB(

//                   _Tok.s16, _Tok.s4, _Tok.s16, _Tok.s48),

//               child: Column(

//                 crossAxisAlignment: CrossAxisAlignment.start,

//                 children: [

//                   // price + validity row

//                   _PriceCard(

//                     plan: plan,

//                     cardBg: cardBg,

//                     textPrimary: textPrimary,

//                     textSub: textSub,

//                     planGrad: planGrad,

//                     divider: divider,

//                   ),

//                   const SizedBox(height: _Tok.s16),

//

//                   // description

//                   if (plan.description.isNotEmpty) ...[

//                     _SectionLabel(label: "About this plan".tr, textColor: textPrimary),

//                     const SizedBox(height: _Tok.s8),

//                     Container(

//                       width: double.infinity,

//                       padding: const EdgeInsets.all(_Tok.s16),

//                       decoration: BoxDecoration(

//                         color: cardBg,

//                         borderRadius: BorderRadius.circular(_Tok.r16),

//                         boxShadow: [

//                           BoxShadow(

//                             color: Colors.black.withValues(alpha: 0.04),

//                             blurRadius: 12,

//                             offset: const Offset(0, 2),

//                           ),

//                         ],

//                       ),

//                       child: Text(

//                         plan.description,

//                         style: TextStyle(

//                           fontFamily: AppThemeData.regular,

//                           fontSize: _Tok.f15,

//                           color: textSub,

//                           height: 1.6,

//                         ),

//                       ),

//                     ),

//                     const SizedBox(height: _Tok.s20),

//                   ],

//

//                   // details

//                   _SectionLabel(label: "Plan details".tr, textColor: textPrimary),

//                   const SizedBox(height: _Tok.s8),

//                   _DetailCard(

//                     cardBg: cardBg,

//                     divider: divider,

//                     rows: _buildRows(plan, textPrimary, textSub),

//                   ),

//

//                   const SizedBox(height: _Tok.s28),

//

//                   // CTA

//                   _PillButton(

//                     label: "Buy Now".tr,

//                     gradient: planGrad,

//                     fullWidth: true,

//                     onPressed: () {

//                       final ctrl =

//                           Get.find<SubscriptionPaymentController>();

//                       ctrl.startRazorpayPayment(plan);

//                     },

//                   ),

//

//                   const SizedBox(height: _Tok.s12),

//                   Center(

//                     child: Text(

//                       "Secure payment · Cancel anytime",

//                       style: TextStyle(

//                         fontFamily: AppThemeData.regular,

//                         fontSize: _Tok.f12,

//                         color: textSub,

//                       ),

//                     ),

//                   ),

//                 ],

//               ),

//             ),

//           ),

//         ],

//       ),

//     );

//   }

//

//   List<_RowData> _buildRows(

//       SubscriptionPlanModel p, Color primary, Color sub) {

//     final rows = <_RowData>[];

//     rows.add(_RowData(

//       icon: Icons.category_rounded,

//       label: "Plan type".tr,

//       value: p.planType == 'commission' ? 'Commission'.tr : 'Subscription'.tr,

//     ));

//     if (p.expiryDay.isNotEmpty) {

//       rows.add(_RowData(

//         icon: Icons.calendar_today_rounded,

//         label: "Validity".tr,

//         value: p.expiryDay == '0' ? "Unlimited".tr : "${p.expiryDay} days",

//       ));

//     }

//     if (p.itemLimit.isNotEmpty && p.itemLimit != 'null') {

//       rows.add(_RowData(

//         icon: Icons.inventory_2_rounded,

//         label: "Item limit".tr,

//         value: p.itemLimit == '0' ? "Unlimited".tr : p.itemLimit,

//       ));

//     }

//     // if (p.orderLimit.isNotEmpty && p.orderLimit != 'null') {

//     //   rows.add(_RowData(

//     //     icon: Icons.receipt_long_rounded,

//     //     label: "Order limit".tr,

//     //     value: p.orderLimit == '0' ? "Unlimited".tr : p.orderLimit,

//     //   ));

//     // }

//     if (p.place.isNotEmpty && p.place != '0') {

//       rows.add(_RowData(

//         icon: Icons.percent,

//         label: "commission".tr,

//         value: p.place,

//       ));

//     }

//     return rows;

//   }

// }

//

// class _RowData {

//   const _RowData({required this.icon, required this.label, required this.value});

//   final IconData icon;

//   final String label;

//   final String value;

// }

//

// // ─────────────────────────────────────────────

// // PRICE CARD

// // ─────────────────────────────────────────────

// class _PriceCard extends StatelessWidget {

//   const _PriceCard({

//     required this.plan,

//     required this.cardBg,

//     required this.textPrimary,

//     required this.textSub,

//     required this.planGrad,

//     required this.divider,

//   });

//   final SubscriptionPlanModel plan;

//   final Color cardBg, textPrimary, textSub, divider;

//   final LinearGradient planGrad;

//

//   @override

//   Widget build(BuildContext context) {

//     return Container(

//       padding: const EdgeInsets.all(_Tok.s20),

//       decoration: BoxDecoration(

//         color: cardBg,

//         borderRadius: BorderRadius.circular(_Tok.r20),

//         boxShadow: [

//           BoxShadow(

//             color: Colors.black.withValues(alpha: 0.05),

//             blurRadius: 16,

//             offset: const Offset(0, 4),

//           ),

//         ],

//       ),

//       child: Row(

//         children: [

//           // price

//           Expanded(

//             child: Column(

//               crossAxisAlignment: CrossAxisAlignment.start,

//               children: [

//                 Text(

//                   "Price",

//                   style: TextStyle(

//                     fontFamily: AppThemeData.regular,

//                     fontSize: _Tok.f12,

//                     color: textSub,

//                   ),

//                 ),

//                 const SizedBox(height: 2),

//                 ShaderMask(

//                   shaderCallback: (bounds) =>

//                       planGrad.createShader(bounds),

//                   blendMode: BlendMode.srcIn,

//                   child: Text(

//                     Constant.amountShow(amount: plan.price),

//                     style: const TextStyle(

//                       fontFamily: AppThemeData.semiBold,

//                       fontSize: _Tok.f28,

//                       color: Colors.white,

//                       letterSpacing: -0.5,

//                     ),

//                   ),

//                 ),

//               ],

//             ),

//           ),

//           // divider

//           Container(width: 1, height: 48, color: divider),

//           const SizedBox(width: _Tok.s20),

//           // validity

//           Column(

//             crossAxisAlignment: CrossAxisAlignment.start,

//             children: [

//               Text(

//                 "Validity",

//                 style: TextStyle(

//                   fontFamily: AppThemeData.regular,

//                   fontSize: _Tok.f12,

//                   color: textSub,

//                 ),

//               ),

//               const SizedBox(height: 2),

//               Row(

//                 children: [

//                   Icon(Icons.access_time_rounded,

//                       size: 16, color: textPrimary),

//                   const SizedBox(width: 4),

//                   Text(

//                     plan.expiryDay.isEmpty || plan.expiryDay == '0'

//                         ? "Unlimited"

//                         : "${plan.expiryDay} days",

//                     style: TextStyle(

//                       fontFamily: AppThemeData.semiBold,

//                       fontSize: _Tok.f18,

//                       color: textPrimary,

//                     ),

//                   ),

//                 ],

//               ),

//             ],

//           ),

//         ],

//       ),

//     );

//   }

// }

//

// // ─────────────────────────────────────────────

// // SECTION LABEL

// // ─────────────────────────────────────────────

// class _SectionLabel extends StatelessWidget {

//   const _SectionLabel({required this.label, required this.textColor});

//   final String label;

//   final Color textColor;

//

//   @override

//   Widget build(BuildContext context) {

//     return Text(

//       label,

//       style: TextStyle(

//         fontFamily: AppThemeData.semiBold,

//         fontSize: _Tok.f16,

//         color: textColor,

//         letterSpacing: -0.2,

//       ),

//     );

//   }

// }

//

// // ─────────────────────────────────────────────

// // DETAIL CARD

// // ─────────────────────────────────────────────

// class _DetailCard extends StatelessWidget {

//   const _DetailCard({

//     required this.cardBg,

//     required this.divider,

//     required this.rows,

//   });

//   final Color cardBg, divider;

//   final List<_RowData> rows;

//

//   @override

//   Widget build(BuildContext context) {

//     return Container(

//       decoration: BoxDecoration(

//         color: cardBg,

//         borderRadius: BorderRadius.circular(_Tok.r16),

//         boxShadow: [

//           BoxShadow(

//             color: Colors.black.withValues(alpha: 0.04),

//             blurRadius: 12,

//             offset: const Offset(0, 2),

//           ),

//         ],

//       ),

//       child: ListView.separated(

//         shrinkWrap: true,

//         physics: const NeverScrollableScrollPhysics(),

//         itemCount: rows.length,

//         separatorBuilder: (_, __) =>

//             Divider(height: 1, color: divider, indent: 48, endIndent: 16),

//         itemBuilder: (_, i) {

//           final row = rows[i];

//           return Padding(

//             padding: const EdgeInsets.symmetric(

//                 horizontal: _Tok.s16, vertical: _Tok.s14),

//             child: Row(

//               children: [

//                 Container(

//                   width: 32,

//                   height: 32,

//                   decoration: BoxDecoration(

//                     color: AppThemeData.secondary300.withValues(alpha: 0.1),

//                     borderRadius: BorderRadius.circular(_Tok.r8),

//                   ),

//                   child: Icon(row.icon,

//                       size: 16, color: AppThemeData.secondary300),

//                 ),

//                 const SizedBox(width: _Tok.s12),

//                 Expanded(

//                   child: Text(

//                     row.label,

//                     style: const TextStyle(

//                       fontFamily: AppThemeData.regular,

//                       fontSize: _Tok.f14,

//                       color: AppThemeData.grey500,

//                     ),

//                   ),

//                 ),

//                 Text(

//                   row.value,

//                   style: const TextStyle(

//                     fontFamily: AppThemeData.semiBold,

//                     fontSize: _Tok.f14,

//                     color: AppThemeData.grey900,

//                   ),

//                 ),

//               ],

//             ),

//           );

//         },

//       ),

//     );

//   }

// }

//

// // ─────────────────────────────────────────────

// // LOADING VIEW

// // ─────────────────────────────────────────────

// class _LoadingView extends StatelessWidget {

//   const _LoadingView();

//

//   @override

//   Widget build(BuildContext context) {

//     return Center(

//       child: Column(

//         mainAxisAlignment: MainAxisAlignment.center,

//         children: [

//           SizedBox(

//             width: 40,

//             height: 40,

//             child: CircularProgressIndicator(

//               strokeWidth: 3,

//               valueColor: AlwaysStoppedAnimation<Color>(

//                 AppThemeData.secondary300,

//               ),

//             ),

//           ),

//           const SizedBox(height: _Tok.s16),

//           Text(

//             "Loading plans…",

//             style: TextStyle(

//               fontFamily: AppThemeData.regular,

//               fontSize: _Tok.f14,

//               color: AppThemeData.grey500,

//             ),

//           ),

//         ],

//       ),

//     );

//   }

// }

//

// // ─────────────────────────────────────────────

// // ERROR VIEW

// // ─────────────────────────────────────────────

// class _ErrorView extends StatelessWidget {

//   const _ErrorView({required this.message, required this.onRetry});

//   final String message;

//   final VoidCallback onRetry;

//

//   @override

//   Widget build(BuildContext context) {

//     return Center(

//       child: Padding(

//         padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),

//         child: Column(

//           mainAxisAlignment: MainAxisAlignment.center,

//           children: [

//             Container(

//               width: 80,

//               height: 80,

//               decoration: BoxDecoration(

//                 color: const Color(0xFFFF4757).withValues(alpha: 0.1),

//                 shape: BoxShape.circle,

//               ),

//               child: const Icon(Icons.error_outline_rounded,

//                   size: _Tok.i48, color: Color(0xFFFF4757)),

//             ),

//             const SizedBox(height: _Tok.s20),

//             Text(

//               "Something went wrong",

//               style: const TextStyle(

//                 fontFamily: AppThemeData.semiBold,

//                 fontSize: _Tok.f18,

//                 color: AppThemeData.grey900,

//               ),

//             ),

//             const SizedBox(height: _Tok.s8),

//             Text(

//               message,

//               textAlign: TextAlign.center,

//               style: const TextStyle(

//                 fontFamily: AppThemeData.regular,

//                 fontSize: _Tok.f14,

//                 color: AppThemeData.grey500,

//               ),

//             ),

//             const SizedBox(height: _Tok.s24),

//             _PillButton(

//               label: "Retry".tr,

//               gradient: _Tok.accentGrad,

//               onPressed: onRetry,

//             ),

//           ],

//         ),

//       ),

//     );

//   }

// }

//

// // ─────────────────────────────────────────────

// // EMPTY VIEW

// // ─────────────────────────────────────────────

// class _EmptyView extends StatelessWidget {

//   const _EmptyView({required this.onRetry});

//   final VoidCallback onRetry;

//

//   @override

//   Widget build(BuildContext context) {

//     return Center(

//       child: Padding(

//         padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),

//         child: Column(

//           mainAxisAlignment: MainAxisAlignment.center,

//           children: [

//             Container(

//               width: 100,

//               height: 100,

//               decoration: BoxDecoration(

//                 gradient: _Tok.heroGrad,

//                 shape: BoxShape.circle,

//                 boxShadow: [

//                   BoxShadow(

//                     color: const Color(0xFF2D3561).withValues(alpha: 0.3),

//                     blurRadius: 24,

//                     offset: const Offset(0, 8),

//                   ),

//                 ],

//               ),

//               child: const Icon(Icons.card_membership_rounded,

//                   size: _Tok.i48, color: Colors.white),

//             ),

//             const SizedBox(height: _Tok.s24),

//             const Text(

//               "No plans yet",

//               style: TextStyle(

//                 fontFamily: AppThemeData.semiBold,

//                 fontSize: _Tok.f22,

//                 color: AppThemeData.grey900,

//                 letterSpacing: -0.3,

//               ),

//             ),

//             const SizedBox(height: _Tok.s8),

//             Text(

//               "No subscription plans available for your zone right now.".tr,

//               textAlign: TextAlign.center,

//               style: const TextStyle(

//                 fontFamily: AppThemeData.regular,

//                 fontSize: _Tok.f14,

//                 color: AppThemeData.grey500,

//                 height: 1.5,

//               ),

//             ),

//             const SizedBox(height: _Tok.s24),

//             _PillButton(

//               label: "Refresh".tr,

//               gradient: _Tok.heroGrad,

//               onPressed: onRetry,

//             ),

//           ],

//         ),

//       ),

//     );

//   }

// }

//

//





import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/subscription_payment_controller.dart';
import 'package:jippymart_restaurant/controller/subscription_plans_controller.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import '../../../controller/dash_board_controller.dart';
import '../../../models/location_model.dart';
import 'promotion_action_forms.dart';
import 'promotion_quick_action.dart';

// ─────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────
class _Tok {
  static const double s2 = 2, s4 = 4, s6 = 6, s8 = 8, s10 = 10, s12 = 12,
      s14 = 14, s16 = 16, s20 = 20, s24 = 24, s28 = 28, s32 = 32, s48 = 48;

  static const double r8 = 8, r12 = 12, r16 = 16, r20 = 20, r24 = 24, r99 = 99;

  static const double f11 = 11, f12 = 12, f13 = 13, f14 = 14, f15 = 15,
      f16 = 16, f18 = 18, f22 = 22, f26 = 26, f28 = 28;

  static const double i18 = 18, i22 = 22, i28 = 28, i32 = 32, i48 = 48, i64 = 64;

  static const LinearGradient heroGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F3C), Color(0xFF2D3561)],
  );
  static const LinearGradient accentGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
  );
  static const LinearGradient commissionGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
  );
  static const LinearGradient subGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );
}

// ─────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────
class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key,this.showBackButton = true,});
  final bool showBackButton;

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  // Holds the current plan fetched fresh from Firestore on screen open.
  final Rx<SubscriptionPlanModel?> _currentPlan = Rx<SubscriptionPlanModel?>(null);
  final RxBool _currentPlanLoading = true.obs;

  late final SubscriptionPaymentController _paymentController;
  late final SubscriptionPlansController _plansController;
  PromotionQuickAction? _selectedAction;
  Worker? _promotionsTabResetWorker;

  @override
  void initState() {
    super.initState();
    _paymentController = Get.put(SubscriptionPaymentController());
    _plansController = Get.put(SubscriptionPlansController());

    if (!widget.showBackButton && Get.isRegistered<DashBoardController>()) {
      final dash = Get.find<DashBoardController>();
      _promotionsTabResetWorker =
          ever(dash.promotionsTabResetToken, (_) {
            if (mounted) {
              _plansController.resetSlotBookingSelections();
              setState(() => _selectedAction = null);
            }
          });
    }

    // Fetch everything fresh when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  @override
  void dispose() {
    _promotionsTabResetWorker?.dispose();
    super.dispose();
  }

  /// Refresh plans list AND current plan simultaneously.
  Future<void> _refreshAll() async {
    _currentPlanLoading.value = true;
    await Future.wait([
      _plansController.loadStates(),
      _loadCurrentPlan(),
    ]);
  }

  /// Loads the vendor's active subscription plan directly from Firestore
  /// so it's always up-to-date even on cold start.
  Future<void> _loadCurrentPlan() async {
    try {
      _currentPlanLoading.value = true;

      // 1. Try dashboard (fastest if already loaded)
      if (Get.isRegistered<DashBoardController>()) {
        final dash = Get.find<DashBoardController>();
        final raw = dash.vendorModel.value.subscriptionPlan;
        if (raw is Map && (raw as Map).isNotEmpty) {
          _currentPlan.value = SubscriptionPlanModel.fromJson(
              Map<String, dynamic>.from(raw as Map<dynamic, dynamic>));
          _currentPlanLoading.value = false;
          return;
        }
      }

      // 2. Force-fetch vendor from Firestore for accurate data on restart
      final vendorId = Constant.userModel?.vendorID?.toString().trim();
      if (vendorId != null && vendorId.isNotEmpty) {
        final vendor = await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
        if (vendor != null) {
          // Sync dashboard with fresh data
          if (Get.isRegistered<DashBoardController>()) {
            Get.find<DashBoardController>().vendorModel.value = vendor;
          }
          final raw = vendor.subscriptionPlan;
          if (raw is Map && (raw as Map).isNotEmpty) {
            _currentPlan.value = SubscriptionPlanModel.fromJson(
                Map<String, dynamic>.from(raw as Map<dynamic, dynamic>));
          } else {
            _currentPlan.value = null;
          }
        }
      }
    } catch (e) {
      debugPrint('_loadCurrentPlan error: $e');
      _currentPlan.value = null;
    } finally {
      _currentPlanLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionPlansController>(
      init: _plansController,
      builder: (controller) {
        return Scaffold(
          backgroundColor: _bg(context),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                _PromotionsTopBar(showBackButton: widget.showBackButton),
                PromotionQuickActionsGrid(
                  selected: _selectedAction,
                  onSelected: (action) {
                    if (_selectedAction == PromotionQuickAction.slotBooking ||
                        action == PromotionQuickAction.slotBooking) {
                      _plansController.resetSlotBookingSelections();
                    }
                    setState(() {
                      _selectedAction =
                      _selectedAction == action ? null : action;
                    });
                  },
                ),
                Expanded(
                  child: _selectedAction == null
                      ? const PromotionPlansStatusPanel()
                      : _buildActionContent(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionContent(SubscriptionPlansController controller) {
    final action = _selectedAction;
    if (action == null) return const SizedBox.shrink();

    switch (action) {
      case PromotionQuickAction.slotBooking:
        return Obx(() {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_currentPlanLoading.value)
                  _CurrentPlanSkeleton()
                else if (_currentPlan.value != null)
                  _CurrentPlanCard(
                    plan: _currentPlan.value!,
                    onRefresh: _loadCurrentPlan,
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: _LocationFilterSection(
                    controller: controller,
                    onBuyNow: (plan) =>
                        _paymentController.startRazorpayPayment(plan),
                  ),
                ),
              ],
            ),
          );
        });
    }
  }

  void _openDetail(BuildContext context, SubscriptionPlanModel plan) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: SubscriptionPlanDetailScreen(plan: plan),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      // Refresh current plan when returning from detail (user may have bought)
      _loadCurrentPlan();
    });
  }

  static Color _bg(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);
  }
}

class _LocationFilterSection extends StatelessWidget {
  const _LocationFilterSection({
    required this.controller,
    required this.onBuyNow,
  });

  final SubscriptionPlansController controller;
  final void Function(SubscriptionPlanModel plan) onBuyNow;

  SubscriptionPlanModel? _selectedPlanInList() {
    final selected = controller.selectedPlan.value;
    if (selected == null) return null;
    for (final plan in controller.plans) {
      if (plan.subscriptionPlanId == selected.subscriptionPlanId) {
        return plan;
      }
    }
    return null;
  }

  SubscriptionPlanModel? _visiblePlanDetails() {
    final details = controller.selectedPlanDetails.value;
    if (details != null) return details;

    return _selectedPlanInList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final borderColor =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);
    final textPrimary =
    isDark ? Colors.white : const Color(0xFF1A1F3C);
    final textSecondary =
    isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);

    return Obx(() {
      final planDetails = _visiblePlanDetails();
      final plansLoading = controller.isPlansLoading.value;

      return Container(
          padding: const EdgeInsets.all(_Tok.s12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(_Tok.r12),
            border: Border.all(color: borderColor),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Subscription Plans",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _Tok.f14,
                  fontFamily: AppThemeData.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: _Tok.s8),
              Divider(color: borderColor, height: 1),
              const SizedBox(height: _Tok.s10),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SubscriptionDropdown<StateModel>(
                        label: 'State',
                        value: controller.states.contains(controller.selectedState.value)
                            ? controller.selectedState.value
                            : null,
                        hint: 'Select state',
                        items: controller.states
                            .map(
                              (state) => DropdownMenuItem<StateModel>(
                            value: state,
                            child: Text(state.stateName),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          controller.selectedState.value = value;
                          controller.selectedPlan.value = null;
                          controller.selectedPlanDetails.value = null;
                          controller.loadCities(value.stateId);
                        },
                      ),
                      const SizedBox(height: _Tok.s8),
                      _SubscriptionDropdown<CityModel>(
                        label: 'City',
                        value: controller.cities.contains(controller.selectedCity.value)
                            ? controller.selectedCity.value
                            : null,
                        hint: 'Select city',
                        items: controller.cities
                            .map(
                              (city) => DropdownMenuItem<CityModel>(
                            value: city,
                            child: Text(city.cityName),
                          ),
                        )
                            .toList(),
                        onChanged: controller.selectedState.value == null
                            ? null
                            : (value) {
                          if (value == null) return;
                          controller.selectedCity.value = value;
                          controller.selectedPlan.value = null;
                          controller.selectedPlanDetails.value = null;
                          controller.loadAreas(value.cityId);
                        },
                      ),
                      const SizedBox(height: _Tok.s8),
                      _SubscriptionDropdown<AreaModel>(
                        label: 'Area',
                        value: controller.areas.contains(controller.selectedArea.value)
                            ? controller.selectedArea.value
                            : null,
                        hint: 'Select area',
                        items: controller.areas
                            .map(
                              (area) => DropdownMenuItem<AreaModel>(
                            value: area,
                            child: Text(area.areaName),
                          ),
                        )
                            .toList(),
                        onChanged: controller.selectedCity.value == null
                            ? null
                            : (value) async {
                          if (value == null) return;
                          controller.selectedArea.value = value;
                          controller.selectedPlan.value = null;
                          controller.selectedPlanDetails.value = null;
                          await controller.loadPlans(value.areaId);
                        },
                      ),
                      const SizedBox(height: _Tok.s8),
                      _SubscriptionDropdown<SubscriptionPlanModel>(
                        label: 'Available Plans',
                        value: _selectedPlanInList(),
                        hint: controller.selectedArea.value == null
                            ? 'Select area first'
                            : plansLoading
                            ? 'Loading plans...'
                            : 'Select plan',
                        items: controller.plans
                            .map(
                              (plan) => DropdownMenuItem<SubscriptionPlanModel>(
                            value: plan,
                            child: Text(plan.planName),
                          ),
                        )
                            .toList(),
                        onChanged: controller.selectedArea.value == null ||
                            plansLoading ||
                            controller.plans.isEmpty
                            ? null
                            : (value) {
                          if (value == null) return;
                          controller.selectPlan(value);
                        },
                      ),
                      if (plansLoading) ...[
                        const SizedBox(height: _Tok.s10),
                        const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ] else if (!controller.hasPlans && controller.hasError) ...[
                        const SizedBox(height: _Tok.s10),
                        _InlineMessage(
                          message: controller.errorMessage.value,
                          isError: true,
                        ),
                      ],
                      if (planDetails != null) ...[
                        const SizedBox(height: _Tok.s10),
                        Container(
                          padding: const EdgeInsets.all(_Tok.s12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF111827)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(_Tok.r12),
                            border: Border.all(color: borderColor),
                          ),
                          child: controller.isPlanDetailsLoading.value
                              ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      planDetails.planName,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.bold,
                                        fontSize: _Tok.f14,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: _Tok.s8),
                                  Text(
                                    Constant.amountShow(
                                      amount: planDetails.price.toString(),
                                    ),
                                    style: TextStyle(
                                      fontFamily: AppThemeData.bold,
                                      fontSize: _Tok.f15,
                                      color: AppThemeData.secondary300,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: _Tok.s6),
                              _PlanAttributesGrid(
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                items: [
                                  _PlanAttributeItem(
                                    label: 'Duration',
                                    value: '${planDetails.durationInDays} Days',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Banner Duration',
                                    value:
                                    '${planDetails.bannerDurationInDays} Days',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Radius',
                                    value: '${planDetails.radiusInKms} KM',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Banner Slot',
                                    value: '${planDetails.bannerSlot}',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Best Restaurant',
                                    value: '${planDetails.bestRestaurantSlot}',
                                  ),
                                  _PlanAttributeItem(
                                    label: 'Deals Slot',
                                    value: '${planDetails.dealsSlot}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: _Tok.s8),
                              _PillButton(
                                label: 'Buy Now'.tr,
                                gradient: _Tok.subGrad,
                                fullWidth: true,
                                compact: true,
                                onPressed: () => onBuyNow(planDetails),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          )
      );
    });
  }
}

class _SubscriptionDropdown<T> extends StatelessWidget {
  const _SubscriptionDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final border =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE2E8F0);

    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label.tr,
        hintText: hint.tr,
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _Tok.s12,
          vertical: _Tok.s10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Tok.r12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Tok.r12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_Tok.r12),
          borderSide: BorderSide(
            color: AppThemeData.secondary300,
            width: 1.5,
          ),
        ),
      ),
      hint: Text(hint.tr),
      isExpanded: true,
      items: items,
      onChanged: onChanged,
    );
  }
}

class _PlanAttributeItem {
  const _PlanAttributeItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _PlanAttributesGrid extends StatelessWidget {
  const _PlanAttributesGrid({
    required this.items,
    required this.textPrimary,
    required this.textSecondary,
  });

  final List<_PlanAttributeItem> items;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg =
    isDark ? const Color(0xFF1A1E38) : Colors.white;
    final tileBorder =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 6.0;
        final tileWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map(
                (item) => SizedBox(
              width: tileWidth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tileBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: tileBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 11,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
        );
      },
    );
  }
}

class _PlanAttributeRow extends StatelessWidget {
  const _PlanAttributeRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _Tok.s4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.tr,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: _Tok.f12,
                color: textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: _Tok.f12,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isError
        ? (isDark ? const Color(0xFF3B1F1F) : const Color(0xFFFFF1F2))
        : (isDark ? const Color(0xFF1A1E38) : const Color(0xFFF8FAFC));
    final color = isError ? const Color(0xFFDC2626) : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(_Tok.s14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_Tok.r12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppThemeData.medium,
          fontSize: _Tok.f13,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────

class _PromotionsTopBar extends StatelessWidget {
  const _PromotionsTopBar({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppThemeData.new_primary,
      padding: const EdgeInsets.fromLTRB(4, 2, 8, 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: showBackButton
                ? IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppThemeData.grey50,
                size: 20,
              ),
            )
                : null,
          ),
          Expanded(
            child: Text(
              'Subscription Plans'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: 15,
                color: AppThemeData.grey50,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CURRENT PLAN SKELETON (loading placeholder)
// ─────────────────────────────────────────────
class _CurrentPlanSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmer = isDark ? const Color(0xFF1E2235) : const Color(0xFFE8ECF5);
    return Container(
      height: 76,
      padding: const EdgeInsets.all(_Tok.s14),
      decoration: BoxDecoration(
        color: shimmer,
        borderRadius: BorderRadius.circular(_Tok.r16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: shimmer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(_Tok.r12),
            ),
          ),
          const SizedBox(width: _Tok.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                        color: shimmer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(
                    height: 13,
                    width: 140,
                    decoration: BoxDecoration(
                        color: shimmer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CURRENT PLAN CARD
// ─────────────────────────────────────────────
class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.plan, this.onRefresh});
  final SubscriptionPlanModel plan;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFFFFBEB);
    final border = isDark ? const Color(0xFF92400E) : const Color(0xFFF59E0B);
    final text = isDark ? Colors.white : const Color(0xFF78350F);

    final validityText = '${plan.durationInDays} Days';
    return Container(
      padding: const EdgeInsets.all(_Tok.s14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_Tok.r16),
        border: Border.all(color: border.withOpacity(0.6), width: 1.1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(_Tok.s8),
            decoration: BoxDecoration(
              color: border.withOpacity(0.15),
              borderRadius: BorderRadius.circular(_Tok.r12),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              size: _Tok.i22,
              color: Color(0xFFEA580C),
            ),
          ),
          const SizedBox(width: _Tok.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current plan'.tr,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: _Tok.f12,
                    color: text.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: _Tok.s2),
                Text(
                  plan.planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: _Tok.f15,
                    color: text,
                  ),
                ),
                const SizedBox(height: _Tok.s2),
                Row(
                  children: [
                    Text(
                      Constant.amountShow(amount: '${plan.price}'),
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: _Tok.f13,
                        color: text.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: _Tok.s6),
                    Text(
                      '• $validityText',
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: _Tok.f12,
                        color: text.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Active badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withOpacity(0.12),
              borderRadius: BorderRadius.circular(_Tok.r99),
              border: Border.all(
                  color: const Color(0xFF16A34A).withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Active',
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 10,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PLAN CARD
// ─────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    this.index,
    required this.onTap,
    this.onBuyNow,
  });

  final SubscriptionPlanModel plan;
  final int? index;
  final VoidCallback onTap;
  final VoidCallback? onBuyNow;

  @override
  Widget build(BuildContext context) {
    final themeChange =
    Provider.of<DarkThemeProvider>(context, listen: false);

    final isDark = themeChange.getThem();

    final cardBg =
    isDark ? const Color(0xFF1A1E38) : Colors.white;

    final textPrimary =
    isDark ? Colors.white : const Color(0xFF1A1F3C);

    final textSub =
    isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);

    final planGrad = _Tok.subGrad;

    const double cardH = 88.0;
    const double imgSize = 58.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: _Tok.s10),
      child: SizedBox(
        height: cardH,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(_Tok.r16),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(_Tok.r16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: _Tok.s12,
                vertical: _Tok.s12,
              ),
              child: Row(
                children: [
                  /// Plan Icon
                  ClipRRect(
                    borderRadius:
                    BorderRadius.circular(_Tok.r12),
                    child: SizedBox(
                      width: imgSize,
                      height: imgSize,
                      child: _SmallPlaceholder(
                        grad: planGrad,
                        size: imgSize,
                      ),
                    ),
                  ),

                  const SizedBox(width: _Tok.s12),

                  /// Plan Details
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.planName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily:
                            AppThemeData.semiBold,
                            fontSize: _Tok.f15,
                            color: textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: _Tok.s4),

                        Text(
                          '₹${plan.price}',
                          style:  TextStyle(
                            fontFamily:
                            AppThemeData.semiBold,
                            fontSize: _Tok.f14,
                            color:
                            AppThemeData.secondary300,
                          ),
                        ),

                        const SizedBox(height: _Tok.s2),

                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: textSub,
                            ),

                            const SizedBox(width: 3),

                            Text(
                              '${plan.durationInDays} Days',
                              style: TextStyle(
                                fontFamily:
                                AppThemeData.regular,
                                fontSize: _Tok.f11,
                                color: textSub,
                              ),
                            ),

                            const SizedBox(width: _Tok.s8),

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppThemeData
                                    .secondary300
                                    .withValues(
                                    alpha: 0.15),
                                borderRadius:
                                BorderRadius.circular(
                                    20),
                              ),
                              child: const Text(
                                'Subscription',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: _Tok.s10),

                  /// Buy Button
                  _PillButton(
                    label: "Buy Now".tr,
                    gradient: planGrad,
                    onPressed: onBuyNow ?? onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────
// PILL BUTTON
// ─────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.gradient,
    required this.onPressed,
    this.fullWidth = false,
    this.compact = false,
  });
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;
  final bool fullWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_Tok.r99),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 0 : _Tok.s20,
            vertical: fullWidth
                ? (compact ? _Tok.s10 : _Tok.s16)
                : _Tok.s10,
          ),
          alignment: fullWidth ? Alignment.center : null,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(_Tok.r99),
            boxShadow: [
              BoxShadow(
                color: _gradFirstColor(gradient).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: fullWidth ? (compact ? _Tok.f13 : _Tok.f16) : _Tok.f13,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: inner);
    }
    return inner;
  }

  Color _gradFirstColor(Gradient g) {
    if (g is LinearGradient && g.colors.isNotEmpty) return g.colors.first;
    return AppThemeData.secondary300;
  }
}

// ─────────────────────────────────────────────
// TYPE BADGE (used in detail hero)
// ─────────────────────────────────────────────
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isCommission});
  final bool isCommission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: _Tok.s10, vertical: _Tok.s4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(_Tok.r99),
        border:
        Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCommission ? Icons.percent_rounded : Icons.star_rounded,
            size: 11,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isCommission ? 'Commission'.tr : 'Subscription'.tr,
            style: const TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: _Tok.f11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SMALL PLACEHOLDER
// ─────────────────────────────────────────────
class _SmallPlaceholder extends StatelessWidget {
  const _SmallPlaceholder({required this.grad, required this.size});
  final LinearGradient grad;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: grad),
      child: const Center(
        child: Icon(Icons.card_membership_rounded,
            size: 24, color: Colors.white60),
      ),
    );
  }
}

/// Tiny inline badge used inside the horizontal card row
class _TypeBadgeInline extends StatelessWidget {
  const _TypeBadgeInline({required this.isCommission});
  final bool isCommission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCommission
            ? const Color(0xFF4776E6).withValues(alpha: 0.12)
            : const Color(0xFF11998E).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_Tok.r99),
      ),
      child: Text(
        isCommission ? 'Commission'.tr : 'Subscription'.tr,
        style: TextStyle(
          fontFamily: AppThemeData.semiBold,
          fontSize: 9,
          color: isCommission
              ? const Color(0xFF4776E6)
              : const Color(0xFF11998E),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DOT PATTERN PAINTER
// ─────────────────────────────────────────────
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 14.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter old) => false;
}

// ─────────────────────────────────────────────
// DETAIL SCREEN
// ─────────────────────────────────────────────
class SubscriptionPlanDetailScreen extends StatelessWidget {
  const SubscriptionPlanDetailScreen({super.key, required this.plan});
  final SubscriptionPlanModel plan;

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final isDark = themeChange.getThem();
    final bgColor =
    isDark ? const Color(0xFF0F1120) : const Color(0xFFF2F4FA);
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1F3C);
    final textSub =
    isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B);
    final divider =
    isDark ? const Color(0xFF2A2F50) : const Color(0xFFE8EDF5);
    final planGrad = _Tok.subGrad;
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: _Tok.s8),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(_Tok.s8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(_Tok.r12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: _Tok.i22),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(decoration: BoxDecoration(gradient: planGrad)),
                  Opacity(
                    opacity: 0.06,
                    child: CustomPaint(painter: _DotPatternPainter()),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0],
                        colors: [Colors.transparent, bgColor],
                      ),
                    ),
                  ),
                  Positioned(
                    left: _Tok.s20,
                    right: _Tok.s20,
                    bottom: _Tok.s20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Subscription Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: _Tok.s8),
                        Text(
                          plan.planName,
                          style: const TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: _Tok.f26,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(blurRadius: 12, color: Colors.black38),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  _Tok.s16, _Tok.s4, _Tok.s16, _Tok.s48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PriceCard(
                    plan: plan,
                    cardBg: cardBg,
                    textPrimary: textPrimary,
                    textSub: textSub,
                    planGrad: planGrad,
                    divider: divider,
                  ),
                  const SizedBox(height: _Tok.s16),
                  _SectionLabel(
                      label: "Plan details".tr, textColor: textPrimary),
                  const SizedBox(height: _Tok.s8),
                  _DetailCard(
                    cardBg: cardBg,
                    divider: divider,
                    rows: _buildRows(plan, textPrimary, textSub),
                  ),
                  const SizedBox(height: _Tok.s28),
                  _PillButton(
                    label: "Buy Now".tr,
                    gradient: planGrad,
                    fullWidth: true,
                    onPressed: () {
                      final ctrl = Get.find<SubscriptionPaymentController>();
                      ctrl.startRazorpayPayment(plan);
                    },
                  ),
                  const SizedBox(height: _Tok.s12),
                  Center(
                    child: Text(
                      "Secure payment · Cancel anytime",
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: _Tok.f12,
                        color: textSub,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_RowData> _buildRows(
      SubscriptionPlanModel p,
      Color primary,
      Color sub,
      ) {
    return [
      _RowData(
        icon: Icons.currency_rupee,
        label: "Price".tr,
        value: "₹${p.price}",
      ),
      _RowData(
        icon: Icons.calendar_today_rounded,
        label: "Duration".tr,
        value: "${p.durationInDays} Days",
      ),
      _RowData(
        icon: Icons.image_rounded,
        label: "Banner Duration".tr,
        value: "${p.bannerDurationInDays} Days",
      ),
      _RowData(
        icon: Icons.location_on_outlined,
        label: "Radius".tr,
        value: "${p.radiusInKms} Km",
      ),
      _RowData(
        icon: Icons.view_carousel_outlined,
        label: "Banner Slot".tr,
        value: "${p.bannerSlot}",
      ),
      _RowData(
        icon: Icons.star_outline,
        label: "Best Restaurant Slot".tr,
        value: "${p.bestRestaurantSlot}",
      ),
      _RowData(
        icon: Icons.local_offer_outlined,
        label: "Deals Slot".tr,
        value: "${p.dealsSlot}",
      ),
      _RowData(
        icon: Icons.chat_outlined,
        label: "WhatsApp Broadcast".tr,
        value: p.whatsappBroadcast ?? "-",
      ),
      _RowData(
        icon: Icons.video_collection_outlined,
        label: "Video Credits".tr,
        value: p.videoCredits ?? "-",
      ),
    ];
  }
}

class _RowData {
  const _RowData(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
}

// ─────────────────────────────────────────────
// PRICE CARD
// ─────────────────────────────────────────────
class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.plan,
    required this.cardBg,
    required this.textPrimary,
    required this.textSub,
    required this.planGrad,
    required this.divider,
  });
  final SubscriptionPlanModel plan;
  final Color cardBg, textPrimary, textSub, divider;
  final LinearGradient planGrad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_Tok.s20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_Tok.r20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price",
                  style: TextStyle(
                    fontFamily: AppThemeData.regular,
                    fontSize: _Tok.f12,
                    color: textSub,
                  ),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) => planGrad.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    '₹${plan.price}',
                    style: const TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: _Tok.f28,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 48, color: divider),
          const SizedBox(width: _Tok.s20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Validity",
                style: TextStyle(
                  fontFamily: AppThemeData.regular,
                  fontSize: _Tok.f12,
                  color: textSub,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 16, color: textPrimary),
                  const SizedBox(width: 4),
                  Text(
                    "${plan.durationInDays} Days",
                    style: TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      fontSize: _Tok.f18,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textColor});
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppThemeData.semiBold,
        fontSize: _Tok.f16,
        color: textColor,
        letterSpacing: -0.2,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DETAIL CARD
// ─────────────────────────────────────────────
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.cardBg,
    required this.divider,
    required this.rows,
  });
  final Color cardBg, divider;
  final List<_RowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_Tok.r16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rows.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: divider, indent: 48, endIndent: 16),
        itemBuilder: (_, i) {
          final row = rows[i];
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: _Tok.s16, vertical: _Tok.s14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                    AppThemeData.secondary300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(_Tok.r8),
                  ),
                  child: Icon(row.icon,
                      size: 16, color: AppThemeData.secondary300),
                ),
                const SizedBox(width: _Tok.s12),
                Expanded(
                  child: Text(
                    row.label,
                    style: const TextStyle(
                      fontFamily: AppThemeData.regular,
                      fontSize: _Tok.f14,
                      color: AppThemeData.grey500,
                    ),
                  ),
                ),
                Text(
                  row.value,
                  style: const TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: _Tok.f14,
                    color: AppThemeData.grey900,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOADING VIEW
// ─────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemeData.secondary300,
              ),
            ),
          ),
          const SizedBox(height: _Tok.s16),
          Text(
            "Loading plans…",
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              fontSize: _Tok.f14,
              color: AppThemeData.grey500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ERROR VIEW
// ─────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                const Color(0xFFFF4757).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: _Tok.i48, color: Color(0xFFFF4757)),
            ),
            const SizedBox(height: _Tok.s20),
            const Text(
              "Something went wrong",
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: _Tok.f18,
                color: AppThemeData.grey900,
              ),
            ),
            const SizedBox(height: _Tok.s8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: _Tok.f14,
                color: AppThemeData.grey500,
              ),
            ),
            const SizedBox(height: _Tok.s24),
            _PillButton(
              label: "Retry".tr,
              gradient: _Tok.accentGrad,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// EMPTY VIEW
// ─────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _Tok.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: _Tok.heroGrad,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D3561).withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.card_membership_rounded,
                  size: _Tok.i48, color: Colors.white),
            ),
            const SizedBox(height: _Tok.s24),
            const Text(
              "No plans yet",
              style: TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: _Tok.f22,
                color: AppThemeData.grey900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: _Tok.s8),
            Text(
              "No subscription plans available for your zone right now.".tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppThemeData.regular,
                fontSize: _Tok.f14,
                color: AppThemeData.grey500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: _Tok.s24),
            _PillButton(
              label: "Refresh".tr,
              gradient: _Tok.heroGrad,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}