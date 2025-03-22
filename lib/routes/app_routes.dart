import 'package:edusocial/bindings/calendar_binding.dart';
import 'package:edusocial/bindings/chat_binding.dart';
import 'package:edusocial/bindings/event_binding.dart';
import 'package:edusocial/bindings/group_binding.dart';
import 'package:edusocial/bindings/match_binding.dart';
import 'package:edusocial/bindings/profile_binding.dart';
import 'package:edusocial/bindings/search_binding.dart';
import 'package:edusocial/bindings/settings_binding.dart';
import 'package:edusocial/screens/calendar/calendar_screen.dart';
import 'package:edusocial/screens/chat/chat_detail_screen.dart';
import 'package:edusocial/screens/chat/chat_list_screen.dart';
import 'package:edusocial/screens/event/event_screen.dart';
import 'package:edusocial/screens/groups/group_list_screen.dart';
import 'package:edusocial/screens/match/match_result_screen.dart';
import 'package:edusocial/screens/match/match_screen.dart';
import 'package:edusocial/screens/profile/edit_profile_screen.dart';
import 'package:edusocial/screens/profile/profile_screen.dart';
import 'package:edusocial/screens/search/search_text_screen.dart';
import 'package:get/get.dart';
import '../bindings/signup_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/step1_screen.dart';
import '../screens/auth/step2_screen.dart';
import '../screens/auth/step3_screen.dart';
import '../screens/home/home_screen.dart';
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
  static const String matchResult = '/math_result';
  static const String main = '/main';
  static const String editProfile = "/settings";
  static const String calendar = "/calendar";
  static const String searchText = "/search_text";
  static const String groupList = "/group_list";

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
    GetPage(name: chat, page: () => ChatListScreen(), binding: ChatBinding()),
    GetPage(
        name: chatDetail,
        page: () => ChatDetailScreen(),
        binding: ChatBinding()),
    GetPage(name: event, page: () => EventScreen(), binding: EventBinding()),
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
      name: searchText,
      page: () => SearchTextScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
        name: profile, page: () => ProfileScreen(), binding: ProfileBinding()),
    GetPage(
      name: main,
      page: () => MainScreen(),
    ),
  ];
}
