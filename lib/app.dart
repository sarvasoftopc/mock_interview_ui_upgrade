
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/providers/auth_provider.dart';
import 'package:sarvasoft_moc_interview/ui/screens/ai_creer_coach_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/candidate_profile_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/login_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/mock_interview_adaptive_page.dart';
import 'package:sarvasoft_moc_interview/ui/screens/mock_interview_adaptive_session.dart';
import 'package:sarvasoft_moc_interview/ui/screens/mock_interview_profession_based_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/mock_interview_role_page.dart';
import 'package:sarvasoft_moc_interview/ui/screens/mock_interview_skill_page.dart';
import 'package:sarvasoft_moc_interview/ui/screens/panel_interview_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/placeholder_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/practice_hub_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/preparation_hub_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/profile_page.dart';
import 'package:sarvasoft_moc_interview/ui/screens/session_detail_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/sessions_list.dart';
import 'package:sarvasoft_moc_interview/ui/screens/signup_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/skill_dashboard_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/splash_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/star_story_bank_screen.dart';
import 'package:sarvasoft_moc_interview/ui/screens/user_insights.dart';
import 'package:sarvasoft_moc_interview/ui/screens/user_insights_old.dart';

import 'generated/l10n.dart'; // 👈 import your AppLocalizations
import 'providers/providers.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/home_screen_modern.dart'; // NEW: Modern home screen
import 'ui/screens/question_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'utils/constants.dart';


class InterviewPrepApp extends StatefulWidget {
  const InterviewPrepApp({Key? key}) : super(key: key);

  // helper for accessing from children
  static _InterviewPrepAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_InterviewPrepAppState>();

  @override
  State<InterviewPrepApp> createState() => _InterviewPrepAppState();
}

class _InterviewPrepAppState extends State<InterviewPrepApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: Providers.list(),
      child: Consumer(
        builder: (context, _, __) {
          final settings = Provider.of<AuthProvider>(context, listen: true);
          return MaterialApp(
            title: Constants.appTitle,
            theme: ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
            ),
            locale: _locale, // 👈 this makes switching work
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.delegate.supportedLocales,
            initialRoute: '/',
            routes: {
//              '/': (ctx) => const HomeScreen(),
              //splash screen: this works
              '/': (ctx) => const SplashScreen(), // <-- use AuthWrapper here
              //this also works
              '/question': (ctx) => const QuestionScreen(),
              //skill dashboard also wirks
              '/skills': (ctx) => const SkillDashboardScreen(), // new page
              //login works
              "/login": (ctx) => const LoginScreen(),
              //home screen works - UPGRADED TO MODERN UI
              "/home": (ctx) => const HomeScreenModern(),
              '/settings': (ctx) => const SettingsScreen(),
              //this works
              '/signup': (ctx) => const SignUpScreen(),
              //this works - UPGRADED TO MODERN UI
              '/dashboard': (ctx) => const HomeScreenModern(),
              //this is present and works
              '/settings': (ctx) => const SettingsScreen(),

              //this is present
              '/question': (ctx) => const QuestionScreen(),
              //this is present
              '/sessions': (ctx) => const SessionsScreen(),
              //this is not rpesent
              '/starStories': (ctx) => const StarStoryScreen(),

              //new mock interview pages
              '/mockInterviewSkill': (ctx) => const MockInterviewSkillPage(),
              '/mockInterviewRole': (ctx) => const MockInterviewRolePage(),
              '/mockInterviewAdaptive': (ctx) => const MockInterviewAdaptivePage(),
              //this also works
              '/sessionDetail': (ctx) {
                final args = ModalRoute.of(ctx)!.settings.arguments as Map<String, String>;
                return SessionDetailScreen(sessionId: args['sessionId']!, sessionType: args['sessionType']!);
              },
              '/createProfile': (ctx) => const ProfilePage(),
              '/profile': (ctx) => const CandidateProfileScreen(),
              '/insights': (ctx) => const InsightsDashboardScreen(),
              '/preparationHub': (ctx) => const PreparationHubScreen(),
              "/practice": (ctx) => const PracticeHubScreen(),
              "/mockInterviewAdaptiveSession" :(ctx) => const AdaptiveInterviewPage(),

              //TODO: this might not be needed anymore
              "/mockInterview" :(ctx) => const MockInterviewScreen(),


              '/resumeBuilder': (ctx) => const PlaceholderScreen(title: "Resume Builder"),
              "/panelInterview": (ctx) => const PanelInterviewScreen(),
              '/careerCoach': (ctx) => const CareerCoachScreen(),
              '/skillTutorials': (ctx) => const PlaceholderScreen(title: "Skill Tutorials"),
              '/questionBank': (ctx) => const PlaceholderScreen(title: "Question Bank"),


              '/mock': (ctx) => const PlaceholderScreen(title: "Mock Interviews"),
              '/reports': (ctx) => const PlaceholderScreen(title: "Reports"),
              '/history': (ctx) => const PlaceholderScreen(title: "History"),


            },
          );
        },
      ),
    );
  }
}
