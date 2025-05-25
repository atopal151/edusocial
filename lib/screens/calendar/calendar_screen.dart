import 'package:edusocial/components/user_appbar/back_appbar.dart';
import 'package:edusocial/screens/calendar/reminder_detail_modal.dart';
import 'package:edusocial/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/calendar_controller.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController controller = Get.put(CalendarController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(),
      backgroundColor: Color(0xffFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Açıklama
              Text(
                "Takvim",
                style: TextStyle(
                  fontSize: 18.72,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF272727),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do \neiusmod tempor incididunt ut labore et dolore magna aliqua.",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9CA3AE),
                ),
              ),
              SizedBox(height: 20),
              // Tarih Seçici
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: controller.previousDay,
                              child: Container(
                                width: 31,
                                height: 31,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFAFAFA),
                                ),
                                child: Icon(Icons.chevron_left),
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: controller.selectDate,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Color(0xffFAFAFA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0, right: 20),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            'images/icons/calendar_icon.svg'),
                                        SizedBox(width: 8),
                                        Obx(() => Text(
                                              controller.selectedDate.value,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: controller.nextDay,
                              child: Container(
                                width: 31,
                                height: 31,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFAFAFA),
                                ),
                                child: Icon(Icons.chevron_right),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.addOrUpdateReminder,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: controller.reminders.length,
                      itemBuilder: (context, index) {
                        var reminder = controller.reminders[index];
                        return Dismissible(
                          key: Key(reminder.id.toString()),
                          background: Container(
                            decoration: BoxDecoration(
                              color: Color(0xffFB535C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 16),
                            child: SvgPicture.asset(
                              "images/icons/delete_icon.svg",
                              colorFilter: const ColorFilter.mode(
                                Color(0xffffffff),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            controller.deleteReminder(reminder.id);
                          },
                          child: GestureDetector(
                            onTap: () =>
                                showReminderDetailDialog(context, reminder.id),
                            onLongPress: () {
                              // Güncelleme formunu aç
                              controller.addOrUpdateReminder(
                                  existing: reminder);
                            },
                            child: Container(
                              height: 80,
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.only(left: 5, right: 5),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xff36C897),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'images/icons/clock_icon.svg',
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xffffffff),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              reminder.title,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Text(
                                              formatSimpleDate(reminder
                                                  .dateTime), // 🔁 burası değişiyor
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF9CA3AE),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
