import 'package:edusocial/bindings/calendar_binding.dart';
import 'package:edusocial/bindings/chat_binding.dart';
import 'package:edusocial/bindings/entry_binding.dart';
import 'package:edusocial/bindings/event_binding.dart';
import 'package:edusocial/bindings/group_binding.dart';
import 'package:edusocial/bindings/match_binding.dart';
import 'package:edusocial/bindings/profile_binding.dart';
import 'package:edusocial/bindings/search_binding.dart';
import 'package:edusocial/bindings/settings_binding.dart';
import 'package:edusocial/screens/calendar/calendar_screen.dart';
import 'package:edusocial/screens/chat/group_chat/group_chat_detail_screen.dart';
import 'package:edusocial/screens/chat/user_chat/chat_detail_screen.dart';
import 'package:edusocial/screens/chat/user_chat/chat_list_screen.dart';
import 'package:edusocial/screens/entry/entry_detail_screen.dart';
import 'package:edusocial/screens/entry/entry_screen.dart';
import 'package:edusocial/screens/entry/entry_share_screen.dart';
import 'package:edusocial/screens/event/event_screen.dart';
import 'package:edusocial/screens/groups/create_group_screen.dart';
import 'package:edusocial/screens/groups/group_list_screen.dart';
import 'package:edusocial/screens/groups/grup_detail_screen.dart';
import 'package:edusocial/screens/home/post/create_post_screen.dart';
import 'package:edusocial/screens/match/match_result_screen.dart';
import 'package:edusocial/screens/match/match_screen.dart';
import 'package:edusocial/screens/notifications/notifications_screen.dart';
import 'package:edusocial/screens/profile/edit_profile_screen.dart';
import 'package:edusocial/screens/profile/profile_follower_screen.dart';
import 'package:edusocial/screens/profile/profile_following_screen.dart';
import 'package:edusocial/screens/profile/profile_screen.dart';
import 'package:edusocial/screens/search/search_text_screen.dart';
import 'package:edusocial/screens/settings/settings_screen.dart';
import 'package:get/get.dart';
import '../bindings/signup_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/step1_screen.dart';
import '../screens/auth/step2_screen.dart';
import '../screens/auth/step3_screen.dart';
import '../screens/chat/user_chat/user_chat_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/story/add_story_screen.dart';
import '../screens/main_screen.dart';

class Routes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String step1 = '/step1';
  static const String step2 = '/step2';
  static const String step3 = '/step3';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String chatDetail = '/chat_detail';
  static const String event = '/event';
  static const String profile = '/profile';
  static const String match = '/match';
  static const String matchResult = '/match_result';
  static const String main = '/main';
  static const String editProfile = "/settings";
  static const String calendar = "/calendar";
  static const String searchText = "/search_text";
  static const String groupList = "/group_list";
  static const String groupDetailScreen = "/groupDetailScreen";
  static const String entry = "/entry";
  static const String entryShare = "/entryShare";
  static const String entryDetail = "/entryDetail";
  static const String userSetting = "/userSettings";
  static const String peopleProfile = "/peopleProfile";
  static const String groupChatDetail = '/group_chat_detail';
  static const String userChatDetail = '/user_chat_detail';
  static const String followers = '/followers';
  static const String following = '/following';
  static const String addStory = '/addStory';
  static const String notifications = '/notifications';
  static const String createGroup = '/createGroup';
  static const String createPost = '/create_post';

  static final List<GetPage> pages = [
    GetPage(
      name: login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: signup,
      page: () => SignupView(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: step1,
      page: () => Step1View(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: step2,
      page: () => Step2View(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: step3,
      page: () => Step3View(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: chat,
      page: () => ChatListScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: chatDetail,
      page: () => ChatDetailScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: event,
      page: () => EventScreen(),
      binding: EventBinding(),
    ),
    GetPage(
      name: match,
      page: () => MatchScreen(),
    ),
    GetPage(
      name: matchResult,
      page: () => MatchResultScreen(),
      binding: MatchBinding(),
    ),
    GetPage(
      name: editProfile,
      page: () => EditProfileScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: calendar,
      page: () => CalendarScreen(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: groupList,
      page: () => GroupListScreen(),
      binding: GroupBinding(),
    ),
    GetPage(
      name: groupDetailScreen,
      page: () => GroupDetailScreen(),
      binding: GroupBinding(),
    ),
    GetPage(
      name: searchText,
      page: () => SearchTextScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: entry,
      page: () => EntryScreen(),
      binding: EntryBinding(),
    ),
    GetPage(
      name: entryShare,
      page: () => EntryShareScreen(),
      binding: EntryBinding(),
    ),
    GetPage(
      name: entryDetail,
      page: () => EntryDetailScreen(),
      binding: EntryBinding(),
    ),
    GetPage(
      name: userSetting,
      page: () => UserSettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: followers,
      page: () => ProfileFollowerScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: following,
      page: () => ProfileFollowingScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: groupChatDetail,
      page: () => GroupChatDetailScreen(),
    ),
    GetPage(
      name: userChatDetail,
      page: () => UserChatDetailScreen(),
    ),
    GetPage(
      name: notifications,
      page: () => NotificationScreen(),
    ),
    GetPage(
      name: createGroup,
      page: () => CreateGroupScreen(),
    ),
    GetPage(
      name: createPost,
      page: () => CreatePostScreen(),
    ),
    GetPage(
      name: main,
      page: () => MainScreen(),
    ),
    GetPage(name: addStory, page: () => AddStoryScreen()),
  ];
}
