import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../components/buttons/custom_button.dart';
import '../../components/input_fields/costum_textfield.dart';
import '../../components/input_fields/custom_multiline_textfield.dart';
import '../../components/user_appbar/back_appbar.dart';
import '../../controllers/event_create_controller.dart';
import '../../services/language_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final EventCreateController controller = Get.put(EventCreateController());
  final LanguageService languageService = Get.find<LanguageService>();

  @override
  void initState() {
    super.initState();
    final groupId = Get.arguments?['groupId'];
    if (groupId != null) {
      controller.setGroupId(groupId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: BackAppBar(
        iconBackgroundColor: Color(0xffffffff),
        title: languageService.tr("event.createEvent.title"),
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Image Upload
            _buildBannerUpload(),
            SizedBox(height: 24),

            // Event Title
            CustomTextField(
              controller: controller.titleController,
              hintText: languageService.tr("event.createEvent.eventTitle"),
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              
            ),
            SizedBox(height: 16),

            // Event Description
            CustomMultilineTextField(
              controller: controller.descriptionController,
              hintText: languageService.tr("event.createEvent.eventDescription"),
              backgroundColor: Color(0xffffffff),
              textColor: Color(0xff414751),
              count: 4,
            ),
            SizedBox(height: 16),

            // Location
            _buildLocationField(),
            SizedBox(height: 16),

            // Start Date & Time
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    label: languageService.tr("event.createEvent.startDate"),
                    value: controller.startDate.value,
                    onTap: () => _selectStartDate(context),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeField(
                    label: languageService.tr("event.createEvent.startTime"),
                    value: controller.startTime.value,
                    onTap: () => _selectStartTime(context),
                    isTimeField: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // End Date & Time
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeField(
                    label: languageService.tr("event.createEvent.endDate"),
                    value: controller.endDate.value,
                    onTap: () => _selectEndDate(context),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeField(
                    label: languageService.tr("event.createEvent.endTime"),
                    value: controller.endTime.value,
                    onTap: () => _selectEndTime(context),
                    isTimeField: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Create Button
            CustomButton(
              text: languageService.tr("event.createEvent.createButton"),
              height: 50,
              borderRadius: 15,
              onPressed: () => controller.createEvent(),
              isLoading: controller.isLoading,
              backgroundColor: Color(0xfffb535c),
              textColor: Color(0xffffffff),
            
            ),
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
            fontWeight: FontWeight.w500,
            color: Color(0xff414751),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickBannerImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xfff5f6f7),
              borderRadius: BorderRadius.circular(15),
             
            ),
            child: controller.bannerImage.value != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      controller.bannerImage.value!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Color(0xff9ca3ae),
                      ),
                      SizedBox(height: 8),
                      Text(
                        languageService.tr("event.createEvent.bannerHint"),
                        style: GoogleFonts.inter(
                          fontSize: 13.27,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff9ca3ae),
                        ),
                      ),
                    ],
                  ),
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
            fontSize: 13.27,
            fontWeight: FontWeight.w500,
            color: Color(0xff414751),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _openLocationPicker,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15),
             
            ),
            child: Row(
              children: [
               SvgPicture.asset(
                  "images/icons/location.svg",
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    Color(0xff9ca3ae),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Text(
                    controller.selectedLocationAddress.value.isEmpty 
                        ? languageService.tr("event.createEvent.locationHint")
                        : controller.selectedLocationAddress.value,
                    style: GoogleFonts.inter(
                      fontSize: 13.27,
                      color: controller.selectedLocationAddress.value.isEmpty 
                          ? Color(0xff9ca3ae) 
                          : Color(0xff414751),
                    ),
                  )),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  size: 16,
                  color: Color(0xff9ca3ae),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isTimeField = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xff414751),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(15),
            
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  isTimeField ? "images/icons/clock_icon.svg" : "images/icons/calendar_icon.svg",
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    Color(0xff9ca3ae),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value.isEmpty ? languageService.tr("event.createEvent.selectDateTime") : value,
                    style: GoogleFonts.inter(
                      fontSize: 13.28,
                      color: value.isEmpty ? Color(0xff9ca3ae) : Color(0xff414751),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Color(0xff9ca3ae),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickBannerImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      controller.bannerImage.value = File(image.path);
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Get.toNamed('/locationPicker');
    if (result != null && result is Map<String, dynamic>) {
      controller.setSelectedLocation(
        latitude: result['latitude'],
        longitude: result['longitude'], 
        address: result['address'],
        googleMapsUrl: result['googleMapsUrl'],
      );
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      controller.startDate.value = DateFormat('dd/MM/yyyy').format(picked);
      controller.selectedStartDate = picked;
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.startTime.value = formattedTime;
      controller.selectedStartTime = picked;
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedStartDate ?? DateTime.now(),
      firstDate: controller.selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (picked != null) {
      controller.endDate.value = DateFormat('dd/MM/yyyy').format(picked);
      controller.selectedEndDate = picked;
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.endTime.value = formattedTime;
      controller.selectedEndTime = picked;
    }
  }
}
