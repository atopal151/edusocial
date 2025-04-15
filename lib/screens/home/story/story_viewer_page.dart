import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusocial/controllers/story_controller.dart';

class StoryViewerPage extends StatefulWidget {
  final int initialIndex;
  const StoryViewerPage({super.key, required this.initialIndex});

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage>
    with TickerProviderStateMixin {
  final StoryController storyController = Get.find<StoryController>();
  late PageController _pageController;
  int _currentIndex = 0;
  int _storyIndex = 0;
  Timer? _timer;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _startStory();
  }

  void _startStory() {
    _animationController?.stop();
    _animationController?.dispose();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          nextStory();
        }
      });
    _animationController!.forward();
  }

  void _pauseStory() {
    _animationController?.stop();
  }

  void _resumeStory() {
    _animationController?.forward();
  }

  void nextStory() {
    final stories = storyController.getOtherStories();
    final currentStory = stories[_currentIndex];
    if (_storyIndex < currentStory.storyUrls.length - 1) {
      setState(() {
        _storyIndex++;
      });
      _startStory();
    } else if (_currentIndex < stories.length - 1) {
      setState(() {
        _currentIndex++;
        _storyIndex = 0;
      });
      _pageController.jumpToPage(_currentIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startStory();
      });
    } else {
      Get.back();
    }
  }

  void previousStory() {
    final stories = storyController.getOtherStories();
    if (_storyIndex > 0) {
      setState(() {
        _storyIndex--;
      });
      _startStory();
    } else if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        final previous = stories[_currentIndex];
        _storyIndex = previous.storyUrls.length - 1;
      });
      _pageController.jumpToPage(_currentIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startStory();
      });
    } else {
      Get.back();
    }
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'az önce';
    if (difference.inMinutes < 60) return '${difference.inMinutes} dk önce';
    if (difference.inHours < 24) return '${difference.inHours} saat önce';
    if (difference.inDays == 1) return 'dün';
    if (difference.inDays < 7) return '${difference.inDays} gün önce';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stories = storyController.getOtherStories();

    return SafeArea(

  top: true,
  bottom: false,
  minimum: EdgeInsets.only(top: 12),
      child: Container(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final isCurrentStory = index == _currentIndex;
        
              return GestureDetector(
                onLongPressStart: (_) => _pauseStory(),
                onLongPressEnd: (_) => _resumeStory(),
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! > 0) {
                      if (_currentIndex > 0) {
                        setState(() {
                          _currentIndex--;
                          _storyIndex = 0;
                        });
                        _pageController.jumpToPage(_currentIndex);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _startStory();
                        });
                      }
                    } else {
                      if (_currentIndex < stories.length - 1) {
                        setState(() {
                          _currentIndex++;
                          _storyIndex = 0;
                        });
                        _pageController.jumpToPage(_currentIndex);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _startStory();
                        });
                      }
                    }
                  }
                },
                onTapDown: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < width / 2) {
                    previousStory();
                  } else {
                    nextStory();
                  }
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: story.storyUrls.isNotEmpty
                          ? Image.network(
                              story.storyUrls[_storyIndex],
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.black),
                    ),
                    if (isCurrentStory)
                      Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        child: Row(
                          children: List.generate(
                            story.storyUrls.length,
                            (i) => Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                child: LinearProgressIndicator(
                                  value: i < _storyIndex
                                      ? 1
                                      : i == _storyIndex
                                          ? _animationController?.value ?? 0
                                          : 0,
                                  backgroundColor: Colors.white38,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 25,
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
                              Text(
                                story.username,
                                style:
                                    TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                timeAgo(story.createdAt),
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
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
      ),
    );
  }
}
