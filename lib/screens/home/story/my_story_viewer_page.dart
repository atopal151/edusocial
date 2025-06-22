import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../controllers/story_controller.dart';

class MyStoryViewerPage extends StatefulWidget {
  const MyStoryViewerPage({super.key});

  @override
  State<MyStoryViewerPage> createState() => _MyStoryViewerPageState();
}

class _MyStoryViewerPageState extends State<MyStoryViewerPage>
    with TickerProviderStateMixin {
  final StoryController storyController = Get.find<StoryController>();
  int _storyIndex = 0;
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _storyIndex = 0;

    final story = storyController.getMyStory();
    if (story != null && story.storyUrls.length > 1) {
      _startStory();
    }
  }

  void _startStory() {
    _animationController?.stop();
    _animationController?.dispose();

    final story = storyController.getMyStory();
    if (story == null || story.storyUrls.length <= 1)
      return; // güvenlik kontrolü

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
    final story = storyController.getMyStory();
    if (story == null) return;

    final total = story.storyUrls.length;

    // Eğer son story ise → çık
    if (_storyIndex >= total - 1) {
      _animationController?.stop();
      Get.back();
      return;
    }

    // Aksi halde bir sonraki story'ye geç
    setState(() {
      _storyIndex++;
    });
    _startStory();
  }

  void previousStory() {
    if (_storyIndex > 0) {
      setState(() {
        _storyIndex--;
      });
      _startStory();
    } else {
      _animationController?.stop(); // güvenlik için
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
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = storyController.getMyStory();

    if (story == null || story.storyUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xff272727),
        body: const Center(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPressStart: (_) => _pauseStory(),
        onLongPressEnd: (_) => _resumeStory(),
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
              child: Image.network(
                story.storyUrls[_storyIndex],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child:
                        Icon(Icons.broken_image, color: Color(0xffffffff), size: 48),
                  );
                },
              ),
            ),
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(
                  story.storyUrls.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: LinearProgressIndicator(
                        borderRadius: BorderRadius.circular(50),
                        value: i < _storyIndex
                            ? 1
                            : i == _storyIndex
                                ? _animationController?.value ?? 0
                                : 0,
                        backgroundColor: Colors.white38,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
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
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.username,
                        style:
                            GoogleFonts.inter(color: Color(0xffffffff), fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        timeAgo(story.created_at),
                        style: GoogleFonts.inter(
                            color: Color(0xffffffff), fontSize: 10, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xffffffff)),
                    onPressed: () => Get.back(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
