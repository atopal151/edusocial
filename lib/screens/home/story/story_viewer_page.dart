import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusocial/controllers/story_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/language_service.dart';

class StoryViewerPage extends StatefulWidget {
  final int initialIndex;
  const StoryViewerPage({super.key, required this.initialIndex});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with TickerProviderStateMixin {
  final StoryController storyController = Get.find<StoryController>();
  final LanguageService languageService = Get.find<LanguageService>();

  late PageController _pageController;
  late List<dynamic> allStories; // myStory + otherStories
  int _currentIndex = 0;
  int _storyIndex = 0;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();

    final my = storyController.getMyStory();
    final others = storyController.getOtherStories();
    allStories = [
      if (my != null) my,
      ...others,
    ];

    // Hatalı index varsa geri dön
    if (widget.initialIndex >= allStories.length || allStories.isEmpty) {
      debugPrint("❗ Story görüntülenemiyor: index=${widget.initialIndex}, total=${allStories.length}");
      Future.delayed(Duration.zero, () => Get.back());
      return;
    }

    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _startStory();
  }

  void _startStory() {
    _animationController?.stop();
    _animationController?.dispose();

    final story = allStories[_currentIndex];
    final totalStoryCount = story.storyUrls.length;

    if (_storyIndex >= totalStoryCount) {
      _storyIndex = 0;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 7),
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          nextStory();
        }
      });

    _animationController?.forward();
  }

  void nextStory() {
    final currentStory = allStories[_currentIndex];

    if (_storyIndex < currentStory.storyUrls.length - 1) {
      setState(() => _storyIndex++);
      _startStory();
    } else if (_currentIndex < allStories.length - 1) {
      setState(() {
        _currentIndex++;
        _storyIndex = 0;
      });
      _pageController.jumpToPage(_currentIndex);
      _startStory();
    } else {
      Get.back();
    }
  }

  void previousStory() {
    if (_storyIndex > 0) {
      setState(() => _storyIndex--);
      _startStory();
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _storyIndex = allStories[_currentIndex].storyUrls.length - 1;
      });
      _pageController.jumpToPage(_currentIndex);
      _startStory();
    } else {
      Get.back();
    }
  }
    String timeAgo(DateTime date) {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) return languageService.tr("common.time.justNow");
      if (difference.inMinutes < 60) return "${difference.inMinutes} ${languageService.tr("common.time.minutesAgo")}";
      if (difference.inHours < 24) return "${difference.inHours} ${languageService.tr("common.time.hoursAgo")}";
      if (difference.inDays == 1) return languageService.tr("common.time.yesterday");
      if (difference.inDays < 7) return "${difference.inDays} ${languageService.tr("common.time.daysAgo")}";
      return "${date.day}/${date.month}/${date.year}";
    }

  @override
  void dispose() {
    _animationController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (allStories.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xff272727),
        body: Center(
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xff272727),
        body: PageView.builder(
          controller: _pageController,
          physics: NeverScrollableScrollPhysics(),
          itemCount: allStories.length,
          itemBuilder: (context, index) {
            final story = allStories[index];
            final isCurrent = index == _currentIndex;
      
            return GestureDetector(
              onTapDown: (details) {
                final width = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < width / 2) {
                  previousStory();
                } else {
                  nextStory();
                }
              },
              onLongPressStart: (_) => _animationController?.stop(),
              onLongPressEnd: (_) => _animationController?.forward(),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: story.storyUrls.isNotEmpty
                        ? Image.network(
                            story.storyUrls[_storyIndex],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(Icons.broken_image, color: Color(0xffffffff), size: 48),
                              );
                            },
                          )
                        : Center(
                            child: Text(languageService.tr("story.viewer.noImage"), style: TextStyle(color: Colors.white)),
                          ),
                  ),
                  if (isCurrent)
                    Positioned(
                      top: 40,
                      left: 10,
                      right: 10,
                      child: Row(
                        children: List.generate(
                          story.storyUrls.length,
                          (i) => Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 2),
                              child: LinearProgressIndicator(
                                value: i < _storyIndex
                                    ? 1
                                    : i == _storyIndex
                                        ? _animationController?.value ?? 0
                                        : 0,
                                backgroundColor: Colors.white30,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 60,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(story.profileImage),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(story.username,
                                style: GoogleFonts.inter(color: Color(0xffffffff), fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(timeAgo(story.createdat), style: GoogleFonts.inter(color: Color(0xffffffff), fontSize: 10, fontWeight: FontWeight.w400)),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: Color(0xffffffff)),
                          onPressed: () => Get.back(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
