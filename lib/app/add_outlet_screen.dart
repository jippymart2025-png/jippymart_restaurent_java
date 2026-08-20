import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_outlet_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/add_outlet_controller.dart';
import '../models/location_model.dart';

class AddOutletScreen extends StatelessWidget {
  AddOutletScreen({super.key});

  final AddOutletController controller =
  Get.put(AddOutletController());
  // ADD HERE 👇
  Widget buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Outlet Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            /// Outlet Information
            buildSection(
              title: "Outlet Information",
              children: [

                TextField(
                  controller: controller.outletNameController,
                  decoration: const InputDecoration(
                    labelText: "Outlet Name",
                    hintText:"Enter Outlet Name",
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: controller.cuisineController,
                  decoration: const InputDecoration(
                    labelText: "Cuisine Type",
                    hintText: "South Indian",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    hintText: "Enter Outlet Phone",
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller.alternatePhoneController,
                  decoration: const InputDecoration(
                    labelText: "Alternate Phone Number",
                    hintText: "Enter Alternate Phone Number",
                  ),
                  // keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller.emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    hintText: "Enter Outlet Email",
                  ),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: controller.fssaiNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "FSSAI Number",
                    hintText: "Enter FSSAI Number",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.gstNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: "GST Number",
                    hintText: "Enter GST Number",
                  ),
                ),
                TextField(
                  controller: controller.usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    hintText: "Enter Username",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    hintText: "Enter Password",
                  ),
                ),
              ],
            ),

            /// Address Information
            buildSection(
              title: "Address Information",
              children: [

                TextField(
                  controller: controller.buildingController,
                  decoration: const InputDecoration(
                    labelText: "Building Number",
                    hintText: "12/345",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.roadController,
                  decoration: const InputDecoration(
                    labelText: "Road",
                    hintText: "Road Name",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.landmarkController,
                  decoration: const InputDecoration(
                    labelText: "Landmark",
                    hintText: " Enter Landmark",
                  ),
                ),

                const SizedBox(height: 12),

                // TextField(
                //   controller: controller.stateController,
                //   decoration: const InputDecoration(
                //     labelText: "State Name",
                //     hintText: " Enter StateName",
                //   ),
                // ),
                Obx(() {
                  return DropdownButtonFormField<StateModel>(
                    value: controller.selectedState.value,
                    decoration: const InputDecoration(
                      labelText: "State",
                      hintText: "Select State",
                    ),
                    isExpanded: true,
                    items: controller.states.map((state) {
                      return DropdownMenuItem<StateModel>(
                        value: state,
                        child: Text(state.stateName),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      await controller.onStateSelected(value);
                    },
                  );
                }) ,
                const SizedBox(height: 12),

                // TextField(
                //   controller: controller.areaController,
                //   decoration: const InputDecoration(
                //     labelText: "Area Name",
                //     hintText: "Enter Area NAme",
                //   ),
                // ),
                Obx(() {
                  return DropdownButtonFormField<CityModel>(
                    value: controller.selectedCity.value,
                    decoration: const InputDecoration(
                      labelText: "City",
                      hintText: "Select City",
                    ),
                    isExpanded: true,
                    items: controller.cities.map((city) {
                      return DropdownMenuItem<CityModel>(
                        value: city,
                        child: Text(city.cityName),
                      );
                    }).toList(),
                    onChanged: (value) async {
                      await controller.onCitySelected(value);
                    },
                  );
                }),

                const SizedBox(height: 12),

                // TextField(
                //   controller: controller.cityIdController,
                //   keyboardType: TextInputType.number,
                //   decoration: const InputDecoration(
                //     labelText: "City Id",
                //     hintText: "Enter CityId",
                //   ),
                // ),
                Obx(() {
                  return DropdownButtonFormField<AreaModel>(
                    value: controller.selectedArea.value,
                    decoration: const InputDecoration(
                      labelText: "Area",
                      hintText: "Select Area",
                    ),
                    isExpanded: true,
                    items: controller.areas.map((area) {
                      return DropdownMenuItem<AreaModel>(
                        value: area,
                        child: Text(area.areaName),
                      );
                    }).toList(),
                    onChanged: controller.onAreaSelected,
                  );
                }) ,
                const SizedBox(height: 12),

                TextField(
                  controller: controller.latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                    hintText: "Enter Latitude"
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                    hintText: "Enter Longitude",
                  ),
                ),
              ],
            ),

            /// Operating Hours
            buildSection(
              title: "Operating Hours",
              children: [

                Obx(() => CheckboxListTile(
                  value: controller.sameTimingForAllDays.value,
                  onChanged: (value) {
                    controller.sameTimingForAllDays.value = value!;
                  },
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Same timings for all days"),
                  controlAffinity: ListTileControlAffinity.leading,
                )),

                const SizedBox(height: 15),

                Obx(() {

                  if (controller.sameTimingForAllDays.value) {

                    return Column(
                      children: [

                        TextField(
                          controller: controller.openingTimeController,
                          decoration: const InputDecoration(
                            labelText: "Opening Time",
                            hintText: "09:00",
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: controller.closingTimeController,
                          decoration: const InputDecoration(
                            labelText: "Closing Time",
                            hintText: "22:00",
                          ),
                        ),

                      ],
                    );
                  }

                  return Column(
                    children: [

                      ListView.builder(

                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: controller.operatingDays.length,

                        itemBuilder: (context, index) {

                          final day = controller.operatingDays[index];

                          return Card(

                            margin: const EdgeInsets.only(bottom: 15),

                            child: Padding(

                              padding: const EdgeInsets.all(12),

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    day["dayName"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  TextFormField(
                                    initialValue: day["openingTime"],
                                    decoration: const InputDecoration(
                                      labelText: "Opening Time",
                                      hintText: "09:00",
                                    ),
                                    onChanged: (value) {
                                      controller.updateOpeningTime(index, value);
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  TextFormField(
                                    initialValue: day["closingTime"],
                                    decoration: const InputDecoration(
                                      labelText: "Closing Time",
                                      hintText: "22:00",
                                    ),
                                    onChanged: (value) {
                                      controller.updateClosingTime(index, value);
                                    },
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: () {
                                        controller.removeOperatingDay(index);
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 15),

                      SizedBox(

                        width: double.infinity,

                        child: ElevatedButton.icon(

                          onPressed: controller.addOperatingDay,

                          icon: const Icon(Icons.add),

                          label: const Text("Add Day"),

                        ),
                      ),

                    ],
                  );
                }),

              ],
            ),

            const SizedBox(height: 20),
            buildSection(
              title: "Bank Details",
              children: [

                Obx(() => CheckboxListTile(
                  value: controller.useMerchantBankDetails.value,
                  onChanged: (value) {
                    controller.onMerchantBankChanged(value ?? false);
                  },
                  title: const Text(
                    "Same as Merchant Bank Details",
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity:
                  ListTileControlAffinity.leading,
                )),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.accountHolderController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "Account Holder",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.accountNumberController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "Account Number",
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.ifscController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "IFSC Code",
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: controller.bankNameController,
                  readOnly: controller.useMerchantBankDetails.value,
                  decoration: const InputDecoration(
                    labelText: "Bank Name",
                  ),
                ),
              ],
            ),
            /// Save Outlet Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await controller.saveOutlet();
                },
                child: const Text(
                  "Save Outlet",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}