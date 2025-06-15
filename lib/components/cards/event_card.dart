import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final String eventTitle;
  final String eventDescription;
  final String eventDate;
  final String eventImage;
  final VoidCallback onShare;
  final VoidCallback onLocation;

  const EventCard({
    Key? key,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventDate,
    required this.eventImage,
    required this.onShare,
    required this.onLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              eventImage,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Color(0xfff5f6f7),
                  child: Icon(Icons.image_not_supported, size: 40, color: Color(0xff9ca3ae)),
                );
              },
            ),
          ),

          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventTitle,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff414751),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  eventDescription,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff9ca3ae),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Color(0xff9ca3ae)),
                    SizedBox(width: 8),
                    Text(
                      eventDate,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff9ca3ae),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: onShare,
                      icon: Icon(Icons.share, size: 20, color: Color(0xff9ca3ae)),
                    ),
                    IconButton(
                      onPressed: onLocation,
                      icon: Icon(Icons.location_on, size: 20, color: Color(0xff9ca3ae)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
