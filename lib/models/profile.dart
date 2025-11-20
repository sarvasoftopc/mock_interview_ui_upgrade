class Profile {
  final String userId;
  String? fullName;
  String? email;
  String? headline;
  String? location;
  int? yearsExperience;
  List<String> preferredRoles;
  String? cvText;
  String? cvFilename;
  List<String> skills;
  bool publicProfile;

  Profile({
    required this.userId,
    this.fullName,
    this.email,
    this.headline,
    this.location,
    this.yearsExperience,
    List<String>? preferredRoles,
    this.cvText,
    this.cvFilename,
    List<String>? skills,
    this.publicProfile = false,
  })  : preferredRoles = preferredRoles ?? [],
        skills = skills ?? [];

  factory Profile.fromJson(Map<String, dynamic> j) {
    return Profile(
      userId: j['candidate_id'] as String,
      fullName: j['full_name'],
      email: j['email'],
      headline: j['headline'],
      location: j['location'],
      yearsExperience: j['years_experience'] is int ? j['years_experience'] : (j['years_experience'] != null ? int.tryParse("${j['years_experience']}") : null),
      preferredRoles: (j['preferred_roles'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cvText: j['cv_text'],
      cvFilename: j['cv_filename'],
      skills: (j['skills'] as List?)?.map((e) => e.toString()).toList() ?? [],
      publicProfile: j['public_profile'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'headline': headline,
      'location': location,
      'years_experience': yearsExperience,
      'preferred_roles': preferredRoles,
      'cv_text': cvText,
      'cv_filename': cvFilename,
      'skills': skills,
      'public_profile': publicProfile,
    };
  }
}
