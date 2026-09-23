import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/outlet_product_model.dart';
import '../../../themes/app_them_data.dart';
import '../../../utils/const/color_const.dart';

class TimingsBuilderSheetScreen extends StatefulWidget {
  final List<ProductTimingModel> initialTimings;

  const TimingsBuilderSheetScreen({Key? key, required this.initialTimings}) : super(key: key);

  @override
  _TimingsBuilderSheetScreenState createState() => _TimingsBuilderSheetScreenState();
}

class _TimingsBuilderSheetScreenState extends State<TimingsBuilderSheetScreen> {
  final List<_TimingSlot> _slots = [];

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    for (final timing in widget.initialTimings) {
      _slots.add(_TimingSlot(
        id: timing.productAvailableTimingId,
        dayOfWeekId: timing.dayOfWeekId ?? 1,
        startTime: timing.startTime ?? '09:00',
        endTime: timing.endTime ?? '22:00',
      ));
    }
  }

  void _addEmptySlot() {
    setState(() {
      _slots.add(_TimingSlot(
        id: null,
        dayOfWeekId: 1, // Default Monday
        startTime: '09:00',
        endTime: '22:00',
      ));
    });
  }

  void _save() {
    final result = _slots.map((s) {
      return ProductTimingModel(
        productAvailableTimingId: s.id,
        dayOfWeekId: s.dayOfWeekId,
        startTime: s.startTime,
        endTime: s.endTime,
      );
    }).toList();
    Navigator.of(context).pop(result);
  }

  Future<void> _pickTime(BuildContext context, _TimingSlot slot, bool isStartTime) async {
    final initialTimeStr = isStartTime ? slot.startTime : slot.endTime;
    TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);
    try {
      final parts = initialTimeStr.split(':');
      if (parts.length >= 2) {
        initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          slot.startTime = formattedTime;
        } else {
          slot.endTime = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: ColorConst.white,
        title: const Text('Manage Timings'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _slots.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  return Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Day of Week:', style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _slots.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                          DropdownButton<int>(
                            value: slot.dayOfWeekId,
                            isExpanded: true,
                            items: List.generate(7, (i) {
                              return DropdownMenuItem<int>(
                                value: i + 1,
                                child: Text(_days[i]),
                              );
                            }),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => slot.dayOfWeekId = val);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickTime(context, slot, true),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Start Time',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(slot.startTime, style: const TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () => _pickTime(context, slot, false),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'End Time',
                                      border: OutlineInputBorder(),
                                    ),
                                    child: Text(slot.endTime, style: const TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addEmptySlot,
              icon: const Icon(Icons.add),
              label: const Text('Add Timing Slot'),
              style: ElevatedButton.styleFrom(
                foregroundColor: ColorConst.white,
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimingSlot {
  int? id;
  int dayOfWeekId;
  String startTime;
  String endTime;

  _TimingSlot({
    this.id,
    required this.dayOfWeekId,
    required this.startTime,
    required this.endTime,
  });
}
