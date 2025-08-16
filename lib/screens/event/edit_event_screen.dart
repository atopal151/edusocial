import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../components/input_fields/custom_multiline_textfield.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../controllers/event_edit_controller.dart';
import '../../services/language_service.dart';

class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final EventEditController controller = Get.put(EventEditController());
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void initState() {
    super.initState();
    final eventId = Get.arguments?['eventId'];
    if (eventId != null) {
      controller.loadEventData(eventId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        iconBackgroundColor: Color(0xffffffff),
        title: languageService.tr("event.editEvent.title"),
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image Upload
            _buildBannerUpload(),
            SizedBox(height: 24),

            // Title Field
            CustomTextField(
              controller: controller.titleController,
              hintText: languageService.tr("event.createEvent.eventTitle"),
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
            ),
            SizedBox(height: 16),

            // Description Field
            CustomMultilineTextField(
              controller: controller.descriptionController,
              hintText: languageService.tr("event.createEvent.eventDescription"),
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              count: 4,
            ),
            SizedBox(height: 16),

            // Location Field
            _buildLocationField(),
            SizedBox(height: 16),

            // Date and Time Row
            Row(
              children: [
                Expanded(child: _buildDateTimeField(
                  "event.createEvent.startDate",
                  controller.selectedStartDate.value != null
                      ? DateFormat('dd/MM/yyyy').format(controller.selectedStartDate.value!)
                      : languageService.tr("event.createEvent.selectDateTime"),
                  () => _selectDate(true),
                  isTimeField: false,
                )),
                SizedBox(width: 12),
                Expanded(child: _buildDateTimeField(
                  "event.createEvent.startTime",
                  controller.selectedStartTime.value != null
                      ? controller.selectedStartTime.value!.format(context)
                      : languageService.tr("event.createEvent.selectDateTime"),
                  () => _selectTime(true),
                  isTimeField: true,
                )),
              ],
            ),
            SizedBox(height: 16),

            // End Date and Time Row
            Row(
              children: [
                Expanded(child: _buildDateTimeField(
                  "event.createEvent.endDate",
                  controller.selectedEndDate.value != null
                      ? DateFormat('dd/MM/yyyy').format(controller.selectedEndDate.value!)
                      : languageService.tr("event.createEvent.selectDateTime"),
                  () => _selectDate(false),
                  isTimeField: false,
                )),
                SizedBox(width: 12),
                Expanded(child: _buildDateTimeField(
                  "event.createEvent.endTime",
                  controller.selectedEndTime.value != null
                      ? controller.selectedEndTime.value!.format(context)
                      : languageService.tr("event.createEvent.selectDateTime"),
                  () => _selectTime(false),
                  isTimeField: true,
                )),
              ],
            ),
            SizedBox(height: 32),

            // Update Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: languageService.tr("event.editEvent.updateButton"),
                height: 50,
                borderRadius: 15,
                onPressed: controller.updateEvent,
                isLoading: controller.isLoading,
                backgroundColor: Color(0xffef5050),
                textColor: Color(0xffffffff),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      )),
    );
  }

  Widget _buildBannerUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageService.tr("event.createEvent.eventBanner"),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff414751),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: controller.pickBanner,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Color(0xfff5f5f5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: controller.selectedBanner.value != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      controller.selectedBanner.value!,
                      fit: BoxFit.cover,
                    ),
                  )
                : controller.currentBannerUrl.value.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          controller.currentBannerUrl.value,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Color(0xff9ca3ae),
        ),
        SizedBox(height: 8),
        Text(
          languageService.tr("event.createEvent.bannerHint"),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Color(0xff9ca3ae),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageService.tr("event.createEvent.location"),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff414751),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: controller.openLocationPicker,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  "images/icons/location.svg",
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Color(0xff9ca3ae),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.selectedLocationAddress.value.isNotEmpty
                        ? controller.selectedLocationAddress.value
                        : languageService.tr("event.createEvent.locationHint"),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: controller.selectedLocationAddress.value.isNotEmpty
                          ? Color(0xff414751)
                          : Color(0xff9ca3ae),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField(String labelKey, String value, VoidCallback onTap, {required bool isTimeField}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageService.tr(labelKey),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xff414751),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  isTimeField ? "images/icons/clock_icon.svg" : "images/icons/calendar_icon.svg",
                  width: 18,
                  height: 18,
                  colorFilter: ColorFilter.mode(
                    Color(0xff9ca3ae),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff414751),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (controller.selectedStartDate.value ?? DateTime.now())
          : (controller.selectedEndDate.value ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      if (isStartDate) {
        controller.selectedStartDate.value = picked;
      } else {
        controller.selectedEndDate.value = picked;
      }
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime 
          ? (controller.selectedStartTime.value ?? TimeOfDay.now())
          : (controller.selectedEndTime.value ?? TimeOfDay.now()),
    );
    if (picked != null) {
      if (isStartTime) {
        controller.selectedStartTime.value = picked;
      } else {
        controller.selectedEndTime.value = picked;
      }
    }
  }
}
