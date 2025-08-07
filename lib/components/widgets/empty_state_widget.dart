import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/language_service.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final double? iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen constraints
        final isSmallScreen = constraints.maxHeight < 600;
        final iconSizeValue = iconSize ?? (isSmallScreen ? 36.0 : 48.0);
        final titleFontSize = isSmallScreen ? 16.0 : 18.0;
        final descriptionFontSize = isSmallScreen ? 12.0 : 14.0;
        final padding = isSmallScreen ? 16.0 : 32.0;
        final iconPadding = isSmallScreen ? 16.0 : 20.0;
        
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with responsive sizing
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: (iconColor ?? const Color(0xFFEF5050)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      icon,
                      size: iconSizeValue,
                      color: iconColor ?? const Color(0xFFEF5050),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 16.0 : 24.0),
                  
                  // Title with responsive font size
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF414751),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: isSmallScreen ? 6.0 : 8.0),
                  
                  // Description with responsive font size
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: descriptionFontSize,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF9CA3AE),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Predefined empty state widgets for common use cases
class EmptyStateWidgets {
  static Widget postsEmptyState(LanguageService languageService) {
    return EmptyStateWidget(
      title: languageService.tr("profile.emptyStates.noPostsTitle"),
      description: languageService.tr("profile.emptyStates.noPostsDescription"),
      icon: Icons.inbox_outlined,
      iconColor: const Color(0xFFEF5050),
    );
  }

  static Widget entriesEmptyState(LanguageService languageService) {
    return EmptyStateWidget(
      title: languageService.tr("profile.emptyStates.noEntriesTitle"),
      description: languageService.tr("profile.emptyStates.noEntriesDescription"),
      icon: CupertinoIcons.pencil,
      iconColor: const Color(0xFFEF5050),
    );
  }
} 