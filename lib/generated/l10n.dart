// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class AppLocalizations {
  AppLocalizations();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
      _current != null,
      'No instance of AppLocalizations was loaded. Try to initialize the AppLocalizations delegate before accessing AppLocalizations.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = AppLocalizations();
      AppLocalizations._current = instance;

      return instance;
    });
  }

  static AppLocalizations of(BuildContext context) {
    final instance = AppLocalizations.maybeOf(context);
    assert(
      instance != null,
      'No instance of AppLocalizations present in the widget tree. Did you add AppLocalizations.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static AppLocalizations? maybeOf(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Interview Prep`
  String get appTitle {
    return Intl.message('Interview Prep', name: 'appTitle', desc: '', args: []);
  }

  /// `Upload CV`
  String get uploadCv {
    return Intl.message('Upload CV', name: 'uploadCv', desc: '', args: []);
  }

  /// `CV Uploaded`
  String get cvUploaded {
    return Intl.message('CV Uploaded', name: 'cvUploaded', desc: '', args: []);
  }

  /// `Change CV`
  String get changeCv {
    return Intl.message('Change CV', name: 'changeCv', desc: '', args: []);
  }

  /// `Upload JD`
  String get uploadJd {
    return Intl.message('Upload JD', name: 'uploadJd', desc: '', args: []);
  }

  /// `JD Uploaded`
  String get jdUploaded {
    return Intl.message('JD Uploaded', name: 'jdUploaded', desc: '', args: []);
  }

  /// `Change JD`
  String get changeJd {
    return Intl.message('Change JD', name: 'changeJd', desc: '', args: []);
  }

  /// `Perform Analysis`
  String get performAnalysis {
    return Intl.message(
      'Perform Analysis',
      name: 'performAnalysis',
      desc: '',
      args: [],
    );
  }

  /// `Analysis Complete`
  String get analysisComplete {
    return Intl.message(
      'Analysis Complete',
      name: 'analysisComplete',
      desc: '',
      args: [],
    );
  }

  /// `Your CV and Job Description have been analyzed.`
  String get analysisDoneMsg {
    return Intl.message(
      'Your CV and Job Description have been analyzed.',
      name: 'analysisDoneMsg',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message('OK', name: 'ok', desc: '', args: []);
  }

  /// `Skills Dashboard`
  String get skillsDashboard {
    return Intl.message(
      'Skills Dashboard',
      name: 'skillsDashboard',
      desc: '',
      args: [],
    );
  }

  /// `Pie chart placeholder for skills`
  String get skillsChartPlaceholder {
    return Intl.message(
      'Pie chart placeholder for skills',
      name: 'skillsChartPlaceholder',
      desc: '',
      args: [],
    );
  }

  /// `Matched Skills`
  String get matchedSkills {
    return Intl.message(
      'Matched Skills',
      name: 'matchedSkills',
      desc: '',
      args: [],
    );
  }

  /// `Missing Skills`
  String get missingSkills {
    return Intl.message(
      'Missing Skills',
      name: 'missingSkills',
      desc: '',
      args: [],
    );
  }

  /// `Prepare for Missing Skills`
  String get prepareMissingSkills {
    return Intl.message(
      'Prepare for Missing Skills',
      name: 'prepareMissingSkills',
      desc: '',
      args: [],
    );
  }

  /// `Start Mock Interview`
  String get startMockInterview {
    return Intl.message(
      'Start Mock Interview',
      name: 'startMockInterview',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported file type`
  String get unsupportedFile {
    return Intl.message(
      'Unsupported file type',
      name: 'unsupportedFile',
      desc: '',
      args: [],
    );
  }

  /// `Error reading file`
  String get errorReadingFile {
    return Intl.message(
      'Error reading file',
      name: 'errorReadingFile',
      desc: '',
      args: [],
    );
  }

  /// `Your AI Interview Coach`
  String get heroTitle {
    return Intl.message(
      'Your AI Interview Coach',
      name: 'heroTitle',
      desc: '',
      args: [],
    );
  }

  /// `Practice smarter. Get hired faster.`
  String get heroSubtitle {
    return Intl.message(
      'Practice smarter. Get hired faster.',
      name: 'heroSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Upload your resume to extract your strengths.`
  String get uploadCvDesc {
    return Intl.message(
      'Upload your resume to extract your strengths.',
      name: 'uploadCvDesc',
      desc: '',
      args: [],
    );
  }

  /// `Upload the job description to match required skills.`
  String get uploadJdDesc {
    return Intl.message(
      'Upload the job description to match required skills.',
      name: 'uploadJdDesc',
      desc: '',
      args: [],
    );
  }

  /// `File uploaded ✅`
  String get fileUploaded {
    return Intl.message(
      'File uploaded ✅',
      name: 'fileUploaded',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Preparation Hub`
  String get preparationHub {
    return Intl.message(
      'Preparation Hub',
      name: 'preparationHub',
      desc: '',
      args: [],
    );
  }

  /// `AI Resume Builder`
  String get resumeBuilder {
    return Intl.message(
      'AI Resume Builder',
      name: 'resumeBuilder',
      desc: '',
      args: [],
    );
  }

  /// `Create or improve your resume with AI`
  String get resumeBuilderDesc {
    return Intl.message(
      'Create or improve your resume with AI',
      name: 'resumeBuilderDesc',
      desc: '',
      args: [],
    );
  }

  /// `AI Career Coach`
  String get careerCoach {
    return Intl.message(
      'AI Career Coach',
      name: 'careerCoach',
      desc: '',
      args: [],
    );
  }

  /// `Get career guidance and interview tips`
  String get careerCoachDesc {
    return Intl.message(
      'Get career guidance and interview tips',
      name: 'careerCoachDesc',
      desc: '',
      args: [],
    );
  }

  /// `Skill Tutorials`
  String get skillTutorials {
    return Intl.message(
      'Skill Tutorials',
      name: 'skillTutorials',
      desc: '',
      args: [],
    );
  }

  /// `Learn & practice missing skills`
  String get skillTutorialsDesc {
    return Intl.message(
      'Learn & practice missing skills',
      name: 'skillTutorialsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Interview Q&A Bank`
  String get questionBank {
    return Intl.message(
      'Interview Q&A Bank',
      name: 'questionBank',
      desc: '',
      args: [],
    );
  }

  /// `Explore common interview questions`
  String get questionBankDesc {
    return Intl.message(
      'Explore common interview questions',
      name: 'questionBankDesc',
      desc: '',
      args: [],
    );
  }

  /// `Reports`
  String get reports {
    return Intl.message('Reports', name: 'reports', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Prepare. Practice. Perform.`
  String get drawerSubtitle {
    return Intl.message(
      'Prepare. Practice. Perform.',
      name: 'drawerSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Interviews Completed`
  String get interviewsCompleted {
    return Intl.message(
      'Interviews Completed',
      name: 'interviewsCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Average Score`
  String get averageScore {
    return Intl.message(
      'Average Score',
      name: 'averageScore',
      desc: '',
      args: [],
    );
  }

  /// `Practice Hours`
  String get practiceHours {
    return Intl.message(
      'Practice Hours',
      name: 'practiceHours',
      desc: '',
      args: [],
    );
  }

  /// `Quick Actions`
  String get quickActions {
    return Intl.message(
      'Quick Actions',
      name: 'quickActions',
      desc: '',
      args: [],
    );
  }

  /// `View all`
  String get viewAll {
    return Intl.message('View all', name: 'viewAll', desc: '', args: []);
  }

  /// `Upload CV`
  String get uploadCvShort {
    return Intl.message('Upload CV', name: 'uploadCvShort', desc: '', args: []);
  }

  /// `Upload JD`
  String get uploadJdShort {
    return Intl.message('Upload JD', name: 'uploadJdShort', desc: '', args: []);
  }

  /// `Ready`
  String get ready {
    return Intl.message('Ready', name: 'ready', desc: '', args: []);
  }

  /// `Disabled`
  String get disabled {
    return Intl.message('Disabled', name: 'disabled', desc: '', args: []);
  }

  /// `Practice & Improve`
  String get practice {
    return Intl.message(
      'Practice & Improve',
      name: 'practice',
      desc: '',
      args: [],
    );
  }

  /// `Practive & Improve Skills`
  String get practiceDesc {
    return Intl.message(
      'Practive & Improve Skills',
      name: 'practiceDesc',
      desc: '',
      args: [],
    );
  }

  /// `Mock Interview`
  String get mockInterview {
    return Intl.message(
      'Mock Interview',
      name: 'mockInterview',
      desc: '',
      args: [],
    );
  }

  /// `Practice spoken & technical interviews`
  String get mockInterviewDesc {
    return Intl.message(
      'Practice spoken & technical interviews',
      name: 'mockInterviewDesc',
      desc: '',
      args: [],
    );
  }

  /// `View detailed performance reports`
  String get reportsDesc {
    return Intl.message(
      'View detailed performance reports',
      name: 'reportsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Recent Activities`
  String get recentActivities {
    return Intl.message(
      'Recent Activities',
      name: 'recentActivities',
      desc: '',
      args: [],
    );
  }

  /// `Completed Mock Interviews`
  String get completedMocks {
    return Intl.message(
      'Completed Mock Interviews',
      name: 'completedMocks',
      desc: '',
      args: [],
    );
  }

  /// `Analyses Performed`
  String get analysesPerformed {
    return Intl.message(
      'Analyses Performed',
      name: 'analysesPerformed',
      desc: '',
      args: [],
    );
  }

  /// `View report`
  String get viewReport {
    return Intl.message('View report', name: 'viewReport', desc: '', args: []);
  }

  /// `Extra Skills`
  String get extraSkills {
    return Intl.message(
      'Extra Skills',
      name: 'extraSkills',
      desc: '',
      args: [],
    );
  }

  /// `Strength Area`
  String get strengthArea {
    return Intl.message(
      'Strength Area',
      name: 'strengthArea',
      desc: '',
      args: [],
    );
  }

  /// `Insights`
  String get insights {
    return Intl.message('Insights', name: 'insights', desc: '', args: []);
  }

  /// `Match Score`
  String get matchScore {
    return Intl.message('Match Score', name: 'matchScore', desc: '', args: []);
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `New & Unique Features`
  String get uniqueFeatures {
    return Intl.message(
      'New & Unique Features',
      name: 'uniqueFeatures',
      desc: '',
      args: [],
    );
  }

  /// `No Data Available`
  String get noSkillsFound {
    return Intl.message(
      'No Data Available',
      name: 'noSkillsFound',
      desc: '',
      args: [],
    );
  }

  /// `Your Skills Dashboard`
  String get skillsOverview {
    return Intl.message(
      'Your Skills Dashboard',
      name: 'skillsOverview',
      desc: '',
      args: [],
    );
  }

  /// `Next Steps`
  String get nextSteps {
    return Intl.message('Next Steps', name: 'nextSteps', desc: '', args: []);
  }

  /// `Skills in Job Description`
  String get jdSkills {
    return Intl.message(
      'Skills in Job Description',
      name: 'jdSkills',
      desc: '',
      args: [],
    );
  }

  /// `No Skill Analysis Available`
  String get noAnalysisYet {
    return Intl.message(
      'No Skill Analysis Available',
      name: 'noAnalysisYet',
      desc: '',
      args: [],
    );
  }

  /// `Stress Simulator`
  String get stressSimulator {
    return Intl.message(
      'Stress Simulator',
      name: 'stressSimulator',
      desc: '',
      args: [],
    );
  }

  /// `Fast-paced Q&A to simulate real pressure`
  String get stressSimulatorDesc {
    return Intl.message(
      'Fast-paced Q&A to simulate real pressure',
      name: 'stressSimulatorDesc',
      desc: '',
      args: [],
    );
  }

  /// `Upload Cv & JD to perform skill analysis`
  String get uploadCvAndJdToStart {
    return Intl.message(
      'Upload Cv & JD to perform skill analysis',
      name: 'uploadCvAndJdToStart',
      desc: '',
      args: [],
    );
  }

  /// `Panel Interview`
  String get panelInterview {
    return Intl.message(
      'Panel Interview',
      name: 'panelInterview',
      desc: '',
      args: [],
    );
  }

  /// `Face multiple AI interviewers at once`
  String get panelInterviewDesc {
    return Intl.message(
      'Face multiple AI interviewers at once',
      name: 'panelInterviewDesc',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get na {
    return Intl.message('N/A', name: 'na', desc: '', args: []);
  }

  /// `AI Career Coach`
  String get aiCareerCoach {
    return Intl.message(
      'AI Career Coach',
      name: 'aiCareerCoach',
      desc: '',
      args: [],
    );
  }

  /// `Personalized career roadmap from your CV & JD`
  String get aiCareerCoachDesc {
    return Intl.message(
      'Personalized career roadmap from your CV & JD',
      name: 'aiCareerCoachDesc',
      desc: '',
      args: [],
    );
  }

  /// `STAR Story Bank`
  String get storyBank {
    return Intl.message(
      'STAR Story Bank',
      name: 'storyBank',
      desc: '',
      args: [],
    );
  }

  /// `Save and refine your STAR interview answers`
  String get storyBankDesc {
    return Intl.message(
      'Save and refine your STAR interview answers',
      name: 'storyBankDesc',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'hi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
