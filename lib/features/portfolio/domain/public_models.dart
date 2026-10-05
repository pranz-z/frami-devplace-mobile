// PUBLIC PORTFOLIO DOMAIN MODELS
// Hard architectural separation: These models NEVER reference private tasks,
// notes, plans, focus sessions, calendar events, goals, or private repos.

class PublicProfile {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String location;
  final String avatarUrl;
  final String email;
  final String githubUsername;
  final String linkedinUrl;
  final List<String> primarySkills;
  final List<PublicExperience> experiences;
  final List<PublicEducation> education;

  const PublicProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    required this.location,
    required this.avatarUrl,
    required this.email,
    required this.githubUsername,
    required this.linkedinUrl,
    this.primarySkills = const [],
    this.experiences = const [],
    this.education = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'bio': bio,
        'location': location,
        'avatarUrl': avatarUrl,
        'email': email,
        'githubUsername': githubUsername,
        'linkedinUrl': linkedinUrl,
        'primarySkills': primarySkills,
        'experiences': experiences.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
      };

  factory PublicProfile.fromJson(Map<String, dynamic> json) => PublicProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        title: json['title'] as String,
        bio: json['bio'] as String,
        location: json['location'] as String,
        avatarUrl: json['avatarUrl'] as String,
        email: json['email'] as String,
        githubUsername: json['githubUsername'] as String,
        linkedinUrl: json['linkedinUrl'] as String,
        primarySkills: (json['primarySkills'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        experiences: (json['experiences'] as List<dynamic>?)
                ?.map((e) =>
                    PublicExperience.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        education: (json['education'] as List<dynamic>?)
                ?.map((e) =>
                    PublicEducation.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class PublicExperience {
  final String role;
  final String company;
  final String period;
  final String description;
  final List<String> highlights;

  const PublicExperience({
    required this.role,
    required this.company,
    required this.period,
    required this.description,
    this.highlights = const [],
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'company': company,
        'period': period,
        'description': description,
        'highlights': highlights,
      };

  factory PublicExperience.fromJson(Map<String, dynamic> json) =>
      PublicExperience(
        role: json['role'] as String,
        company: json['company'] as String,
        period: json['period'] as String,
        description: json['description'] as String,
        highlights: (json['highlights'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

class PublicEducation {
  final String degree;
  final String institution;
  final String year;

  const PublicEducation({
    required this.degree,
    required this.institution,
    required this.year,
  });

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'year': year,
      };

  factory PublicEducation.fromJson(Map<String, dynamic> json) => PublicEducation(
        degree: json['degree'] as String,
        institution: json['institution'] as String,
        year: json['year'] as String,
      );
}

/// A published projection of a project. Contains ONLY explicitly approved public fields.
class PublicProject {
  final String id;
  final String title;
  final String summary;
  final List<String> technologies;
  final String? architecture;
  final List<String> screenshots;
  final String? challenges;
  final String? outcome;
  final String? publicRepoUrl;
  final bool isFeatured;

  const PublicProject({
    required this.id,
    required this.title,
    required this.summary,
    this.technologies = const [],
    this.architecture,
    this.screenshots = const [],
    this.challenges,
    this.outcome,
    this.publicRepoUrl,
    this.isFeatured = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'technologies': technologies,
        if (architecture != null) 'architecture': architecture,
        'screenshots': screenshots,
        if (challenges != null) 'challenges': challenges,
        if (outcome != null) 'outcome': outcome,
        if (publicRepoUrl != null) 'publicRepoUrl': publicRepoUrl,
        'isFeatured': isFeatured,
      };

  factory PublicProject.fromJson(Map<String, dynamic> json) => PublicProject(
        id: json['id'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        technologies: (json['technologies'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        architecture: json['architecture'] as String?,
        screenshots: (json['screenshots'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        challenges: json['challenges'] as String?,
        outcome: json['outcome'] as String?,
        publicRepoUrl: json['publicRepoUrl'] as String?,
        isFeatured: json['isFeatured'] as bool? ?? false,
      );
}

class PublicEvidence {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String proofType; // e.g. "Live Demo", "Benchmark", "Case Study"
  final String url;

  const PublicEvidence({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.proofType,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'description': description,
        'proofType': proofType,
        'url': url,
      };

  factory PublicEvidence.fromJson(Map<String, dynamic> json) => PublicEvidence(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        proofType: json['proofType'] as String,
        url: json['url'] as String,
      );
}

/// The ONLY context object passed to Public AI Concierge.
/// Must never contain private tasks, notes, plans, calendar events, goals, or unapproved fields.
class PublicContext {
  final PublicProfile profile;
  final List<PublicProject> projects;
  final List<PublicEvidence> evidence;

  const PublicContext({
    required this.profile,
    required this.projects,
    required this.evidence,
  });

  Map<String, dynamic> toJson() => {
        'profile': profile.toJson(),
        'projects': projects.map((p) => p.toJson()).toList(),
        'evidence': evidence.map((e) => e.toJson()).toList(),
      };

  factory PublicContext.fromJson(Map<String, dynamic> json) => PublicContext(
        profile:
            PublicProfile.fromJson(json['profile'] as Map<String, dynamic>),
        projects: (json['projects'] as List<dynamic>?)
                ?.map((p) => PublicProject.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        evidence: (json['evidence'] as List<dynamic>?)
                ?.map(
                    (e) => PublicEvidence.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
