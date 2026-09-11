// import 'package:flutter/material.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/themes/app_them_data.dart';
//
// enum AppliesOnOption { allItems, selectedCategories, selectedItems }
//
// class PromotionActionForms {
//   static void showComingSoon() {
//     ShowToastDialog.showToast('This feature will be available soon');
//   }
// }
//
// // ─────────────────────────────────────────────
// // Shared form widgets
// // ─────────────────────────────────────────────
//
// class PromotionFormScaffold extends StatelessWidget {
//   const PromotionFormScaffold({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.children,
//     this.submitLabel = 'Submit',
//   });
//
//   final String title;
//   final String subtitle;
//   final List<Widget> children;
//   final String submitLabel;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
//     final borderColor =
//         isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
//       physics: const BouncingScrollPhysics(),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: cardBg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: borderColor),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontFamily: AppThemeData.semiBold,
//                 fontSize: 14,
//                 color: isDark ? Colors.white : const Color(0xFF1A1F3C),
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 fontFamily: AppThemeData.regular,
//                 fontSize: 11,
//                 color: isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B),
//               ),
//             ),
//             const SizedBox(height: 16),
//             ...children,
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 48,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                       isDark ? AppThemeData.grey700 : AppThemeData.grey800,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   elevation: 0,
//                 ),
//                 onPressed: PromotionActionForms.showComingSoon,
//                 child: Text(
//                   submitLabel,
//                   style: const TextStyle(
//                     fontFamily: AppThemeData.semiBold,
//                     fontSize: 15,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class PromotionFieldLabel extends StatelessWidget {
//   const PromotionFieldLabel(this.text, {super.key});
//
//   final String text;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontFamily: AppThemeData.medium,
//           fontSize: 13,
//           color: isDark ? Colors.white : const Color(0xFF1A1F3C),
//         ),
//       ),
//     );
//   }
// }
//
// class PromotionTextField extends StatelessWidget {
//   const PromotionTextField({
//     super.key,
//     required this.controller,
//     this.hint,
//     this.prefixText,
//     this.keyboardType,
//     this.readOnly = false,
//   });
//
//   final TextEditingController controller;
//   final String? hint;
//   final String? prefixText;
//   final TextInputType? keyboardType;
//   final bool readOnly;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       readOnly: readOnly,
//       style: TextStyle(
//         fontFamily: AppThemeData.regular,
//         fontSize: 14,
//         color: isDark ? Colors.white : const Color(0xFF1A1F3C),
//       ),
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixText: prefixText,
//         filled: true,
//         fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(
//             color: isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5),
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(
//             color: isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class PromotionDropdownField extends StatelessWidget {
//   const PromotionDropdownField({
//     super.key,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//     this.hint,
//   });
//
//   final String? value;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;
//   final String? hint;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return DropdownButtonFormField<String>(
//       value: value,
//       hint: Text(hint ?? 'Select'),
//       items: items
//           .map(
//             (e) => DropdownMenuItem<String>(
//               value: e,
//               child: Text(e),
//             ),
//           )
//           .toList(),
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(
//             color: isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5),
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide(
//             color: isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class AppliesOnRadioGroup extends StatelessWidget {
//   const AppliesOnRadioGroup({
//     super.key,
//     required this.value,
//     required this.onChanged,
//   });
//
//   final AppliesOnOption value;
//   final ValueChanged<AppliesOnOption> onChanged;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Column(
//       children: [
//         _radio(
//           context,
//           isDark: isDark,
//           label: 'All Items',
//           option: AppliesOnOption.allItems,
//         ),
//         _radio(
//           context,
//           isDark: isDark,
//           label: 'Selected Categories',
//           option: AppliesOnOption.selectedCategories,
//         ),
//         _radio(
//           context,
//           isDark: isDark,
//           label: 'Selected Items',
//           option: AppliesOnOption.selectedItems,
//         ),
//       ],
//     );
//   }
//
//   Widget _radio(
//     BuildContext context, {
//     required bool isDark,
//     required String label,
//     required AppliesOnOption option,
//   }) {
//     return RadioListTile<AppliesOnOption>(
//       value: option,
//       groupValue: value,
//       onChanged: (v) {
//         if (v != null) onChanged(v);
//       },
//       dense: true,
//       contentPadding: EdgeInsets.zero,
//       activeColor: AppThemeData.secondary300,
//       title: Text(
//         label,
//         style: TextStyle(
//           fontFamily: AppThemeData.regular,
//           fontSize: 13,
//           color: isDark ? Colors.white : const Color(0xFF1A1F3C),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Individual action forms (UI only — no API)
// // ─────────────────────────────────────────────
//
// class PercentOffPlanForm extends StatefulWidget {
//   const PercentOffPlanForm({super.key});
//
//   @override
//   State<PercentOffPlanForm> createState() => _PercentOffPlanFormState();
// }
//
// class _PercentOffPlanFormState extends State<PercentOffPlanForm> {
//   String? _discountType = 'Percentage';
//   final _discountCtrl = TextEditingController(text: '15');
//   final _minOrderCtrl = TextEditingController(text: '200');
//   final _offerNameCtrl = TextEditingController(text: 'Weekend Special');
//   AppliesOnOption _appliesOn = AppliesOnOption.allItems;
//
//   @override
//   void dispose() {
//     _discountCtrl.dispose();
//     _minOrderCtrl.dispose();
//     _offerNameCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PromotionFormScaffold(
//       title: '% Off Plan',
//       subtitle: 'Offer a percentage discount on orders.',
//       children: [
//         const PromotionFieldLabel('Discount Type'),
//         PromotionDropdownField(
//           value: _discountType,
//           items: const ['Percentage', 'Fixed Amount'],
//           onChanged: (v) => setState(() => _discountType = v),
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Discount Value (%)'),
//         PromotionTextField(
//           controller: _discountCtrl,
//           hint: 'Enter percentage',
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Applies On'),
//         AppliesOnRadioGroup(
//           value: _appliesOn,
//           onChanged: (v) => setState(() => _appliesOn = v),
//         ),
//         const SizedBox(height: 8),
//         const PromotionFieldLabel('Minimum Order Value (Optional)'),
//         PromotionTextField(
//           controller: _minOrderCtrl,
//           prefixText: '₹ ',
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Offer Name'),
//         PromotionTextField(controller: _offerNameCtrl, hint: 'Offer name'),
//       ],
//     );
//   }
// }
//
// class OnePlusOneOfferForm extends StatefulWidget {
//   const OnePlusOneOfferForm({super.key});
//
//   @override
//   State<OnePlusOneOfferForm> createState() => _OnePlusOneOfferFormState();
// }
//
// class _OnePlusOneOfferFormState extends State<OnePlusOneOfferForm> {
//   String? _offerType = 'Buy 1 Get 1';
//   String? _offerOn = 'Same Item';
//   final _offerNameCtrl = TextEditingController(text: 'BOGO Special');
//   AppliesOnOption _appliesOn = AppliesOnOption.allItems;
//
//   @override
//   void dispose() {
//     _offerNameCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PromotionFormScaffold(
//       title: '1+1 Offer',
//       subtitle: 'Create buy-one-get-one style promotions.',
//       children: [
//         const PromotionFieldLabel('Offer Type'),
//         PromotionDropdownField(
//           value: _offerType,
//           items: const ['Buy 1 Get 1'],
//           onChanged: (v) => setState(() => _offerType = v),
//         ),
//         const SizedBox(height: 2),
//         const PromotionFieldLabel('Applies On'),
//         AppliesOnRadioGroup(
//           value: _appliesOn,
//           onChanged: (v) => setState(() => _appliesOn = v),
//         ),
//         const SizedBox(height: 2),
//         const PromotionFieldLabel('Offer on'),
//         PromotionDropdownField(
//           value: _offerOn,
//           items: const ['Same Item', 'Selected Item'],
//           onChanged: (v) => setState(() => _offerOn = v),
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Offer Name'),
//         PromotionTextField(controller: _offerNameCtrl, hint: 'Offer name'),
//       ],
//     );
//   }
// }
//
// class TwoPlusOneOfferForm extends StatefulWidget {
//   const TwoPlusOneOfferForm({super.key});
//
//   @override
//   State<TwoPlusOneOfferForm> createState() => _TwoPlusOneOfferFormState();
// }
//
// class _TwoPlusOneOfferFormState extends State<TwoPlusOneOfferForm> {
//   String? _offerType = 'Buy 2 Get 1';
//   String? _offerOn = 'Same Item';
//   final _offerNameCtrl = TextEditingController(text: '2+1 Special');
//   AppliesOnOption _appliesOn = AppliesOnOption.allItems;
//
//   @override
//   void dispose() {
//     _offerNameCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PromotionFormScaffold(
//       title: '2+1 Offer',
//       subtitle: 'Create buy-two-get-one style promotions.',
//       children: [
//         const PromotionFieldLabel('Offer Type'),
//         PromotionDropdownField(
//           value: _offerType,
//           items: const ['Buy 2 Get 1'],
//           onChanged: (v) => setState(() => _offerType = v),
//         ),
//         const SizedBox(height: 2),
//         const PromotionFieldLabel('Applies On'),
//         AppliesOnRadioGroup(
//           value: _appliesOn,
//           onChanged: (v) => setState(() => _appliesOn = v),
//         ),
//         const SizedBox(height: 2),
//         const PromotionFieldLabel('Offer on'),
//         PromotionDropdownField(
//           value: _offerOn,
//           items: const ['Same Item', 'Selected Item'],
//           onChanged: (v) => setState(() => _offerOn = v),
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Offer Name'),
//         PromotionTextField(controller: _offerNameCtrl, hint: 'Offer name'),
//       ],
//     );
//   }
// }
//
// class FlatOfferForm extends StatefulWidget {
//   const FlatOfferForm({super.key});
//
//   @override
//   State<FlatOfferForm> createState() => _FlatOfferFormState();
// }
//
// class _FlatOfferFormState extends State<FlatOfferForm> {
//   String? _discountType = 'Flat Amount';
//   final _discountCtrl = TextEditingController(text: '50');
//   final _minOrderCtrl = TextEditingController(text: '300');
//   final _offerNameCtrl = TextEditingController(text: 'Flat ₹50 Off');
//   AppliesOnOption _appliesOn = AppliesOnOption.allItems;
//
//   @override
//   void dispose() {
//     _discountCtrl.dispose();
//     _minOrderCtrl.dispose();
//     _offerNameCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PromotionFormScaffold(
//       title: 'Flat Offer',
//       subtitle: 'Offer a flat rupee discount on orders.',
//       children: [
//         const PromotionFieldLabel('Discount Type'),
//         PromotionDropdownField(
//           value: _discountType,
//           items: const ['Flat Amount', 'Percentage'],
//           onChanged: (v) => setState(() => _discountType = v),
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Discount Value (₹)'),
//         PromotionTextField(
//           controller: _discountCtrl,
//           prefixText: '₹ ',
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Minimum Order Value (Optional)'),
//         PromotionTextField(
//           controller: _minOrderCtrl,
//           prefixText: '₹ ',
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Applies On'),
//         AppliesOnRadioGroup(
//           value: _appliesOn,
//           onChanged: (v) => setState(() => _appliesOn = v),
//         ),
//         const SizedBox(height: 8),
//         const PromotionFieldLabel('Offer Name'),
//         PromotionTextField(controller: _offerNameCtrl, hint: 'Offer name'),
//       ],
//     );
//   }
// }
//
// class CreatePlanForm extends StatefulWidget {
//   const CreatePlanForm({super.key});
//
//   @override
//   State<CreatePlanForm> createState() => _CreatePlanFormState();
// }
//
// class _CreatePlanFormState extends State<CreatePlanForm> {
//   final _planNameCtrl = TextEditingController(text: 'Premium Visibility');
//   String? _planType = 'Visibility Boost';
//   final _discountCtrl = TextEditingController(text: '10');
//   final _dateRangeCtrl =
//       TextEditingController(text: '20 May 2025 – 26 May 2025');
//   AppliesOnOption _appliesOn = AppliesOnOption.allItems;
//
//   @override
//   void dispose() {
//     _planNameCtrl.dispose();
//     _discountCtrl.dispose();
//     _dateRangeCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PromotionFormScaffold(
//       title: 'Create Plan',
//       subtitle: 'Build a custom promotion plan for your restaurant.',
//       children: [
//         const PromotionFieldLabel('Plan Name'),
//         PromotionTextField(controller: _planNameCtrl, hint: 'Plan name'),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Plan Type'),
//         PromotionDropdownField(
//           value: _planType,
//           items: const [
//             'Visibility Boost',
//             'Discount Plan',
//             'Combo Plan',
//           ],
//           onChanged: (v) => setState(() => _planType = v),
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Discount Value'),
//         PromotionTextField(
//           controller: _discountCtrl,
//           hint: 'Enter value',
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Select Date Range'),
//         PromotionTextField(
//           controller: _dateRangeCtrl,
//           hint: 'Select date range',
//           readOnly: true,
//         ),
//         const SizedBox(height: 14),
//         const PromotionFieldLabel('Applies On'),
//         AppliesOnRadioGroup(
//           value: _appliesOn,
//           onChanged: (v) => setState(() => _appliesOn = v),
//         ),
//       ],
//     );
//   }
// }
//
// /// Default promotions panel: Active / Scheduled / Ended plan lists.
// class PromotionPlansStatusPanel extends StatefulWidget {
//   const PromotionPlansStatusPanel({super.key});
//
//   @override
//   State<PromotionPlansStatusPanel> createState() =>
//       _PromotionPlansStatusPanelState();
// }
//
// class _PromotionPlansStatusPanelState extends State<PromotionPlansStatusPanel>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
//     final borderColor =
//         isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
//       child: Container(
//         decoration: BoxDecoration(
//           color: cardBg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: borderColor),
//         ),
//         child: Column(
//           children: [
//             TabBar(
//               controller: _tabController,
//               labelColor: AppThemeData.secondary300,
//               unselectedLabelColor:
//                   isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B),
//               indicatorColor: AppThemeData.secondary300,
//               labelStyle: const TextStyle(
//                 fontFamily: AppThemeData.semiBold,
//                 fontSize: 11,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontFamily: AppThemeData.medium,
//                 fontSize: 11,
//               ),
//               tabs: const [
//                 Tab(text: 'Active'),
//                 Tab(text: 'Scheduled'),
//                 Tab(text: 'Ended'),
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _PlansList(
//                     plans: const [
//                       _PlanStatusItem(
//                         title: 'Lunch & Dinner Special',
//                         subtitle: '11:00 AM – 02:00 PM • 15% off',
//                         status: 'Active',
//                         isActive: true,
//                       ),
//                     ],
//                   ),
//                   _PlansList(
//                     plans: const [
//                       _PlanStatusItem(
//                         title: 'Weekend % Off',
//                         subtitle: 'Sat – Sun • 20% off',
//                         status: 'Scheduled',
//                         isActive: true,
//                       ),
//                     ],
//                   ),
//                   _PlansList(
//                     plans: const [
//                       _PlanStatusItem(
//                         title: 'New Year Flat Offer',
//                         subtitle: '₹50 off • Min ₹300',
//                         status: 'Ended',
//                         isActive: false,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class PlansStatusView extends StatefulWidget {
//   const PlansStatusView({super.key});
//
//   @override
//   State<PlansStatusView> createState() => _PlansStatusViewState();
// }
//
// class _PlansStatusViewState extends State<PlansStatusView>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
//     final borderColor =
//         isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);
//
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
//       child: Container(
//         decoration: BoxDecoration(
//           color: cardBg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: borderColor),
//         ),
//         child: Column(
//           children: [
//             TabBar(
//               controller: _tabController,
//               labelColor: AppThemeData.secondary300,
//               unselectedLabelColor:
//                   isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B),
//               indicatorColor: AppThemeData.secondary300,
//               labelStyle: const TextStyle(
//                 fontFamily: AppThemeData.semiBold,
//                 fontSize: 13,
//               ),
//               tabs: const [
//                 Tab(text: 'Active / Scheduled'),
//                 Tab(text: 'Ended'),
//               ],
//             ),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _PlansList(
//                     plans: const [
//                       _PlanStatusItem(
//                         title: 'Lunch & Dinner Special',
//                         subtitle: '11:00 AM – 02:00 PM • 15% off',
//                         status: 'Active',
//                         isActive: true,
//                       ),
//                       _PlanStatusItem(
//                         title: 'Weekend % Off',
//                         subtitle: 'Sat – Sun • 20% off',
//                         status: 'Scheduled',
//                         isActive: true,
//                       ),
//                     ],
//                   ),
//                   _PlansList(
//                     plans: const [
//                       _PlanStatusItem(
//                         title: 'New Year Flat Offer',
//                         subtitle: '₹50 off • Min ₹300',
//                         status: 'Ended',
//                         isActive: false,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _PlanStatusItem {
//   const _PlanStatusItem({
//     required this.title,
//     required this.subtitle,
//     required this.status,
//     required this.isActive,
//   });
//
//   final String title;
//   final String subtitle;
//   final String status;
//   final bool isActive;
// }
//
// class _PlansList extends StatelessWidget {
//   const _PlansList({required this.plans});
//
//   final List<_PlanStatusItem> plans;
//
//   @override
//   Widget build(BuildContext context) {
//     if (plans.isEmpty) {
//       return Center(
//         child: Text(
//           'No plans found',
//           style: TextStyle(
//             fontFamily: AppThemeData.regular,
//             color: Theme.of(context).brightness == Brightness.dark
//                 ? const Color(0xFF8892B0)
//                 : const Color(0xFF64748B),
//           ),
//         ),
//       );
//     }
//
//     return ListView.separated(
//       padding: const EdgeInsets.all(12),
//       itemCount: plans.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 8),
//       itemBuilder: (context, index) => _PlanStatusCard(plan: plans[index]),
//     );
//   }
// }
//
// class _PlanStatusCard extends StatelessWidget {
//   const _PlanStatusCard({required this.plan});
//
//   final _PlanStatusItem plan;
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
//     final statusColor = plan.isActive
//         ? const Color(0xFF16A34A)
//         : const Color(0xFFDC3545);
//
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: PromotionActionForms.showComingSoon,
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: bg,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(
//               color: isDark
//                   ? const Color(0xFF2A3050)
//                   : const Color(0xFFE8ECF5),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: AppThemeData.secondary300.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.local_offer_outlined,
//                   color: AppThemeData.secondary300,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       plan.title,
//                       style: TextStyle(
//                         fontFamily: AppThemeData.semiBold,
//                         fontSize: 12,
//                         color: isDark ? Colors.white : const Color(0xFF1A1F3C),
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       plan.subtitle,
//                       style: TextStyle(
//                         fontFamily: AppThemeData.regular,
//                         fontSize: 11,
//                         color: isDark
//                             ? const Color(0xFF8892B0)
//                             : const Color(0xFF64748B),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: statusColor.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   plan.status,
//                   style: TextStyle(
//                     fontFamily: AppThemeData.semiBold,
//                     fontSize: 10,
//                     color: statusColor,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Icon(
//                 Icons.chevron_right_rounded,
//                 color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';

class PromotionActionForms {
  static void showComingSoon() {
    ShowToastDialog.showToast('This feature will be available soon');
  }
}

/// Default promotions panel: Active / Scheduled / Ended plan lists.
class PromotionPlansStatusPanel extends StatefulWidget {
  const PromotionPlansStatusPanel({super.key});

  @override
  State<PromotionPlansStatusPanel> createState() =>
      _PromotionPlansStatusPanelState();
}

class _PromotionPlansStatusPanelState extends State<PromotionPlansStatusPanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final borderColor =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: AppThemeData.secondary300,
              unselectedLabelColor:
              isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B),
              indicatorColor: AppThemeData.secondary300,
              labelStyle: const TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 11,
              ),
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Scheduled'),
                Tab(text: 'Ended'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PlansList(
                    plans: const [
                      _PlanStatusItem(
                        title: 'Lunch & Dinner Special',
                        subtitle: '11:00 AM – 02:00 PM • 15% off',
                        status: 'Active',
                        isActive: true,
                      ),
                    ],
                  ),
                  _PlansList(
                    plans: const [
                      _PlanStatusItem(
                        title: 'Weekend % Off',
                        subtitle: 'Sat – Sun • 20% off',
                        status: 'Scheduled',
                        isActive: true,
                      ),
                    ],
                  ),
                  _PlansList(
                    plans: const [
                      _PlanStatusItem(
                        title: 'New Year Flat Offer',
                        subtitle: '₹50 off • Min ₹300',
                        status: 'Ended',
                        isActive: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlansStatusView extends StatefulWidget {
  const PlansStatusView({super.key});

  @override
  State<PlansStatusView> createState() => _PlansStatusViewState();
}

class _PlansStatusViewState extends State<PlansStatusView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A1E38) : Colors.white;
    final borderColor =
    isDark ? const Color(0xFF2A3050) : const Color(0xFFE8ECF5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: AppThemeData.secondary300,
              unselectedLabelColor:
              isDark ? const Color(0xFF8892B0) : const Color(0xFF64748B),
              indicatorColor: AppThemeData.secondary300,
              labelStyle: const TextStyle(
                fontFamily: AppThemeData.semiBold,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Active / Scheduled'),
                Tab(text: 'Ended'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _PlansList(
                    plans: const [
                      _PlanStatusItem(
                        title: 'Lunch & Dinner Special',
                        subtitle: '11:00 AM – 02:00 PM • 15% off',
                        status: 'Active',
                        isActive: true,
                      ),
                      _PlanStatusItem(
                        title: 'Weekend % Off',
                        subtitle: 'Sat – Sun • 20% off',
                        status: 'Scheduled',
                        isActive: true,
                      ),
                    ],
                  ),
                  _PlansList(
                    plans: const [
                      _PlanStatusItem(
                        title: 'New Year Flat Offer',
                        subtitle: '₹50 off • Min ₹300',
                        status: 'Ended',
                        isActive: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanStatusItem {
  const _PlanStatusItem({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isActive,
  });

  final String title;
  final String subtitle;
  final String status;
  final bool isActive;
}

class _PlansList extends StatelessWidget {
  const _PlansList({required this.plans});

  final List<_PlanStatusItem> plans;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Center(
        child: Text(
          'No plans found',
          style: TextStyle(
            fontFamily: AppThemeData.regular,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF8892B0)
                : const Color(0xFF64748B),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _PlanStatusCard(plan: plans[index]),
    );
  }
}

class _PlanStatusCard extends StatelessWidget {
  const _PlanStatusCard({required this.plan});

  final _PlanStatusItem plan;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC);
    final statusColor = plan.isActive
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC3545);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: PromotionActionForms.showComingSoon,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A3050)
                  : const Color(0xFFE8ECF5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemeData.secondary300.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_offer_outlined,
                  color: AppThemeData.secondary300,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        fontSize: 12,
                        color: isDark ? Colors.white : const Color(0xFF1A1F3C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.subtitle,
                      style: TextStyle(
                        fontFamily: AppThemeData.regular,
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF8892B0)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan.status,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    fontSize: 10,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}