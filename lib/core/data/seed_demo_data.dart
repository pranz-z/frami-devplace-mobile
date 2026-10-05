import '../../features/projects/domain/project_model.dart';
import '../../features/kanban/domain/task_model.dart';
import '../../features/portfolio/domain/public_models.dart';
import '../../features/github/domain/github_model.dart';
import '../../features/goals/domain/goal_model.dart';

class SeedDemoData {
  static final DateTime now = DateTime.now().toUtc();
  static final DateTime today = DateTime.utc(now.year, now.month, now.day);

  static List<Project> getProjects() {
    return [
      Project(
        id: 'proj-1',
        ownerId: 'owner-1',
        name: 'Developer Workplace',
        summary:
            'A developer operating system turning private daily workflow into a verified public portfolio.',
        fullDescription:
            'Developer Workplace provides an integrated workspace with Kanban boards, timestamped focus timer, GitHub sync, and deterministic health metrics, while enabling selective one-tap publication of approved case studies for recruiters.',
        workflowStage: ProjectWorkflowStage.polishing,
        lifecycleStatus: ProjectLifecycleStatus.active,
        isPublic: true,
        technologies: ['Flutter', 'Riverpod', 'GoRouter', 'Dart', 'CustomPainter'],
        githubRepoName: 'frami-mobile',
        progress: 0.88,
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        publishSummaryApproved: true,
        publishTechApproved: true,
        publishArchitectureApproved: true,
        publishScreenshotsApproved: true,
        publishChallengesApproved: true,
        publishOutcomeApproved: true,
        architectureNotes:
            'Strict domain layer isolation separating private tasks/notes from public projection models. Seeded pseudo-random CustomPainter jitter for persistent hand-drawn sketches.',
        challengesNotes:
            'Preserving timestamp accuracy for focus mode across OS lifecycle suspends without trusting in-memory tick counts.',
        outcomeNotes:
            'A tactile, fluid mobile experience on iOS and Android with 100% test coverage on critical invariant paths.',
        screenshotUrls: [
          'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600',
          'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600',
        ],
      ),
      Project(
        id: 'proj-2',
        ownerId: 'owner-1',
        name: 'OmniStream Engine',
        summary:
            'High-throughput real-time telemetry ingestion and time-series clustering engine.',
        fullDescription:
            'Built with Rust and gRPC to process 50k events/sec with sub-5ms p99 latency for IoT sensor streams.',
        workflowStage: ProjectWorkflowStage.shipped,
        lifecycleStatus: ProjectLifecycleStatus.completed,
        isPublic: true,
        technologies: ['Rust', 'gRPC', 'PostgreSQL', 'TimescaleDB', 'Docker'],
        githubRepoName: 'omnistream-core',
        progress: 1.0,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(days: 10)),
        publishSummaryApproved: true,
        publishTechApproved: true,
        publishArchitectureApproved: true,
        publishScreenshotsApproved: false,
        publishChallengesApproved: true,
        publishOutcomeApproved: true,
        architectureNotes:
            'Zero-copy deserialization using FlatBuffers, bounded ring buffers, and asynchronous actor pools.',
        challengesNotes:
            'Lock contention under heavy spike loads solved via lock-free ring buffers.',
        outcomeNotes:
            'Deployed across 3 edge nodes handling live smart grid telemetry.',
        screenshotUrls: [],
      ),
      Project(
        id: 'proj-3',
        ownerId: 'owner-1',
        name: 'KitePay Micro-checkout',
        summary:
            'Embeddable one-click checkout SDK for cross-border digital creators.',
        fullDescription:
            'Seamless mobile payment sheets with localized payment methods, webhook signing, and cryptographic fraud heuristics.',
        workflowStage: ProjectWorkflowStage.shipped,
        lifecycleStatus: ProjectLifecycleStatus.completed,
        isPublic: true,
        technologies: ['Dart', 'Kotlin', 'Swift', 'Stripe API', 'Webhooks'],
        githubRepoName: 'kitepay-sdk',
        progress: 0.95,
        createdAt: now.subtract(const Duration(days: 80)),
        updatedAt: now.subtract(const Duration(days: 4)),
        publishSummaryApproved: true,
        publishTechApproved: true,
        publishArchitectureApproved: true,
        publishScreenshotsApproved: true,
        publishChallengesApproved: true,
        publishOutcomeApproved: true,
        architectureNotes:
            'Platform channels bridging Flutter to Apple Pay and Google Pay native controllers.',
        challengesNotes:
            'Idempotency resolution during mobile network reconnects.',
        outcomeNotes: 'Over \$250k in processed volume in beta trials.',
        screenshotUrls: [
          'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=600',
        ],
      ),
      Project(
        id: 'proj-4',
        ownerId: 'owner-1',
        name: 'Internal Ledger V2 (Private)',
        summary: 'Proprietary multi-currency accounting system for internal audits.',
        fullDescription: 'Strict double-entry bookkeeping engine with automated reconciliation.',
        workflowStage: ProjectWorkflowStage.building,
        lifecycleStatus: ProjectLifecycleStatus.active,
        isPublic: false, // PRIVATE ONLY
        technologies: ['Go', 'CockroachDB', 'GraphQL'],
        githubRepoName: null,
        progress: 0.45,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Project(
        id: 'proj-5',
        ownerId: 'owner-1',
        name: 'Stealth AI Agent (Private)',
        summary: 'Autonomous research synthesis agent testing LLM tool orchestration.',
        fullDescription: 'Exploratory multi-agent sandbox for recursive paper summarization.',
        workflowStage: ProjectWorkflowStage.idea,
        lifecycleStatus: ProjectLifecycleStatus.paused,
        isPublic: false, // PRIVATE ONLY
        technologies: ['Python', 'LangChain', 'Gemini API'],
        githubRepoName: null,
        progress: 0.20,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<Task> getTasks() {
    return [
      // Due Today tasks
      Task(
        id: 'task-1',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Review hand-drawn sketch button physics',
        description: 'Ensure touch ripples look organic and hit target meets 48dp minimum.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        dueDate: today.add(const Duration(hours: 17)),
        orderIndex: 0,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        id: 'task-2',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Verify public context privacy tests',
        description: 'Run unit test suite proving zero private leakage to recruiter view.',
        status: TaskStatus.todo,
        priority: TaskPriority.urgent,
        dueDate: today.add(const Duration(hours: 18)),
        orderIndex: 1,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'task-3',
        ownerId: 'owner-1',
        projectId: 'proj-3',
        title: 'Prepare KitePay release notes for v1.2',
        description: 'Document the simplified webhook signature verification steps.',
        status: TaskStatus.inReview,
        priority: TaskPriority.medium,
        dueDate: today.add(const Duration(hours: 20)),
        orderIndex: 0,
        createdAt: now.subtract(const Duration(days: 3)),
      ),

      // Overdue tasks
      Task(
        id: 'task-4',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Audit accessibility contrast in dark sketchbook theme',
        description: 'Check Caveat title contrast ratio against dark paper charcoal.',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        dueDate: today.subtract(const Duration(days: 2)), // Overdue
        orderIndex: 2,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Task(
        id: 'task-5',
        ownerId: 'owner-1',
        projectId: 'proj-4',
        title: 'Run monthly ledger trial balance',
        description: 'Verify credit and debit balances match across all bank feeds.',
        status: TaskStatus.backlog,
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 1)), // Overdue
        orderIndex: 0,
        createdAt: now.subtract(const Duration(days: 6)),
      ),

      // Unscheduled tasks (No dueDate)
      Task(
        id: 'task-6',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Explore custom handwriting ink sound effects',
        description: 'Optional haptic audio click on task drag completion.',
        status: TaskStatus.backlog,
        priority: TaskPriority.low,
        dueDate: null, // Unscheduled
        orderIndex: 1,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Task(
        id: 'task-7',
        ownerId: 'owner-1',
        projectId: 'proj-2',
        title: 'Benchmark SIMD parser on AVX-512',
        description: 'Investigate if SIMD deserialization yields >10% throughput boost.',
        status: TaskStatus.backlog,
        priority: TaskPriority.low,
        dueDate: null, // Unscheduled
        orderIndex: 2,
        createdAt: now.subtract(const Duration(days: 14)),
      ),

      // Additional tasks across statuses (Total >30)
      Task(
        id: 'task-8',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Implement GoRouter ShellRoute with IndexedStack',
        description: 'Keep bottom nav tabs alive without state destruction.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        dueDate: today.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 3)),
        orderIndex: 0,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      Task(
        id: 'task-9',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Draft deterministic health scoring formula',
        description: 'Weigh consistency, progress, milestones, and task completion.',
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 4)),
        completedAt: now.subtract(const Duration(days: 4)),
        orderIndex: 1,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Task(
        id: 'task-10',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Create timestamp-based Focus Mode timer',
        description: 'Survive app suspension and kill without drift.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        dueDate: today.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(days: 2)),
        orderIndex: 2,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Task(
        id: 'task-11',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Build horizontal paged Kanban board with auto-scroll',
        description: 'Drag cards smoothly across Backlog, Todo, In Progress, Review, Done.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.urgent,
        dueDate: today.add(const Duration(days: 1)),
        orderIndex: 1,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        id: 'task-12',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Add day-agenda bottom sheet to calendar month grid',
        description: 'Allow tapping date cell to inspect tasks and schedule new items.',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        dueDate: today.add(const Duration(days: 2)),
        orderIndex: 3,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        id: 'task-13',
        ownerId: 'owner-1',
        projectId: 'proj-2',
        title: 'Write TimescaleDB hypertable partition script',
        description: 'Partition metrics table by weekly intervals.',
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 20)),
        completedAt: now.subtract(const Duration(days: 20)),
        orderIndex: 3,
        createdAt: now.subtract(const Duration(days: 35)),
      ),
      Task(
        id: 'task-14',
        ownerId: 'owner-1',
        projectId: 'proj-2',
        title: 'Set up Prometheus exporter endpoint',
        description: 'Expose engine latency histogram and active client count.',
        status: TaskStatus.done,
        priority: TaskPriority.low,
        dueDate: today.subtract(const Duration(days: 18)),
        completedAt: now.subtract(const Duration(days: 18)),
        orderIndex: 4,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Task(
        id: 'task-15',
        ownerId: 'owner-1',
        projectId: 'proj-3',
        title: 'Refactor Stripe intent confirmation flow',
        description: 'Gracefully handle 3D-Secure 2 challenge redirects.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        dueDate: today.subtract(const Duration(days: 12)),
        completedAt: now.subtract(const Duration(days: 12)),
        orderIndex: 5,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      Task(
        id: 'task-16',
        ownerId: 'owner-1',
        projectId: 'proj-3',
        title: 'Publish Dart package to private registry',
        description: 'Verify pubspec constraints and documentation coverage.',
        status: TaskStatus.inReview,
        priority: TaskPriority.medium,
        dueDate: today.add(const Duration(days: 3)),
        orderIndex: 1,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Task(
        id: 'task-17',
        ownerId: 'owner-1',
        projectId: 'proj-4',
        title: 'Draft schema migration for multi-tenant organizations',
        description: 'Add organization_id foreign key with composite indexes.',
        status: TaskStatus.todo,
        priority: TaskPriority.high,
        dueDate: today.add(const Duration(days: 4)),
        orderIndex: 4,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        id: 'task-18',
        ownerId: 'owner-1',
        projectId: 'proj-5',
        title: 'Test LangChain vector store retrieval with cosine similarity',
        description: 'Compare chunk size 500 vs 1000 for technical paper synthesis.',
        status: TaskStatus.backlog,
        priority: TaskPriority.low,
        dueDate: null,
        orderIndex: 3,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Task(
        id: 'task-19',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Seed demo data with realistic developer workspace items',
        description: 'Provide 5 projects, 30+ tasks, GitHub logs, and public profile.',
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        orderIndex: 6,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Task(
        id: 'task-20',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Implement ephemeral context chips for Workspace AI',
        description: 'Attach projects and tasks as context without persisting them in chat history.',
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        orderIndex: 7,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Task(
        id: 'task-21',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Construct structured AI suggestions review flow',
        description: 'Render cards with checkboxes and apply changes through repository.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        dueDate: today.add(const Duration(days: 1)),
        orderIndex: 2,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'task-22',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Test recruiter Ask AI concierge refusal on private data',
        description: 'Ensure questions about private tasks or notes trigger polite refusal.',
        status: TaskStatus.todo,
        priority: TaskPriority.urgent,
        dueDate: today.add(const Duration(days: 2)),
        orderIndex: 5,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'task-23',
        ownerId: 'owner-1',
        projectId: 'proj-2',
        title: 'Configure automated Docker multi-arch build pipeline',
        description: 'Build amd64 and arm64 images on GitHub Actions.',
        status: TaskStatus.done,
        priority: TaskPriority.low,
        dueDate: today.subtract(const Duration(days: 15)),
        completedAt: now.subtract(const Duration(days: 15)),
        orderIndex: 8,
        createdAt: now.subtract(const Duration(days: 28)),
      ),
      Task(
        id: 'task-24',
        ownerId: 'owner-1',
        projectId: 'proj-3',
        title: 'Setup automated mobile regression test matrix',
        description: 'Run integration test suite across iOS 17 and Android 14 simulators.',
        status: TaskStatus.backlog,
        priority: TaskPriority.medium,
        dueDate: today.add(const Duration(days: 6)),
        orderIndex: 4,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Task(
        id: 'task-25',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Polish 360dp phone layout padding and card scaling',
        description: 'Ensure zero horizontal scroll or layout clipping on compact displays.',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        dueDate: today.add(const Duration(days: 3)),
        orderIndex: 6,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'task-26',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Design hand-drawn doodle dividers and hatch progress bar',
        description: 'Create CustomPainters for warm tactile sketchbook look.',
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(days: 2)),
        orderIndex: 9,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      Task(
        id: 'task-27',
        ownerId: 'owner-1',
        projectId: 'proj-4',
        title: 'Audit cryptographic key rotation policy',
        description: 'Automate KMS key rollover every 90 days.',
        status: TaskStatus.backlog,
        priority: TaskPriority.low,
        dueDate: null,
        orderIndex: 5,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Task(
        id: 'task-28',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Validate mock owner login screen with security disclaimer',
        description: 'Clearly label workspace as owner-only while portfolio remains public.',
        status: TaskStatus.done,
        priority: TaskPriority.high,
        dueDate: today.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        orderIndex: 10,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Task(
        id: 'task-29',
        ownerId: 'owner-1',
        projectId: 'proj-5',
        title: 'Evaluate Claude vs Gemini API tokens for paper extraction',
        description: 'Measure latency and accuracy on 50 arXiv research PDFs.',
        status: TaskStatus.backlog,
        priority: TaskPriority.low,
        dueDate: null,
        orderIndex: 6,
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      Task(
        id: 'task-30',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Connect GitHub App explainer modal with read-only badges',
        description: 'Inform user that credentials never touch client storage.',
        status: TaskStatus.done,
        priority: TaskPriority.medium,
        dueDate: today.subtract(const Duration(days: 1)),
        completedAt: now.subtract(const Duration(days: 1)),
        orderIndex: 11,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Task(
        id: 'task-31',
        ownerId: 'owner-1',
        projectId: 'proj-1',
        title: 'Final smoke test of all navigation shell tabs',
        description: 'Verify Today, Projects, Calendar, Focus, and AI persistence.',
        status: TaskStatus.todo,
        priority: TaskPriority.urgent,
        dueDate: today.add(const Duration(hours: 22)),
        orderIndex: 7,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  static List<Milestone> getMilestones() {
    return [
      Milestone(
        id: 'mile-1',
        projectId: 'proj-1',
        title: 'Alpha Prototype with Sketchbook Design',
        description: 'Complete UI theme, domain models, and Kanban board.',
        dueDate: today.add(const Duration(days: 3)),
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 1)),
      ),
      Milestone(
        id: 'mile-2',
        projectId: 'proj-1',
        title: 'Public Recruiter Site Projection',
        description: 'Verify selective field publication and zero private leakage.',
        dueDate: today.add(const Duration(days: 7)),
        isCompleted: false,
      ),
      Milestone(
        id: 'mile-3',
        projectId: 'proj-1',
        title: 'App Store Submission Prep',
        description: 'Finalize icons, splash screen, and test builds.',
        dueDate: today.add(const Duration(days: 20)),
        isCompleted: false,
      ),
      Milestone(
        id: 'mile-4',
        projectId: 'proj-2',
        title: 'Production Load Test at 50k RPS',
        description: 'Verify zero drops across 48-hour continuous ingestion.',
        dueDate: today.subtract(const Duration(days: 15)),
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 16)),
      ),
      Milestone(
        id: 'mile-5',
        projectId: 'proj-3',
        title: 'PCI-DSS SAQ-A Compliance Audit',
        description: 'Verify no PAN data is handled by client application.',
        dueDate: today.subtract(const Duration(days: 8)),
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 9)),
      ),
    ];
  }

  static List<ProjectPlan> getPlans() {
    return [
      ProjectPlan(
        id: 'plan-1',
        projectId: 'proj-1',
        title: 'Phase 1: Architecture & Domain Isolation',
        content:
            '- Establish pure repository interfaces for all entities\n- Build separate public projections without leaking private fields\n- Implement seeded jitter CustomPainters for tactile aesthetics',
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      ProjectPlan(
        id: 'plan-2',
        projectId: 'proj-1',
        title: 'Phase 2: Mobile Adaptation of IDE Layout',
        content:
            '- Bottom navigation bar with persistent IndexedStack tabs\n- Contextual project tabs inside detail view\n- Quick-action modal sheets for quick captures',
        createdAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }

  static List<ProjectNote> getNotes() {
    return [
      ProjectNote(
        id: 'note-1',
        projectId: 'proj-1',
        title: 'Design Philosophy: Order First, Chaos Later',
        content:
            'Start with a solid flex grid, then apply slight 1-2dp jitter and hand-drawn borders. The text must remain 100% readable with Inter body font, using Caveat only for titles.',
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ProjectNote(
        id: 'note-2',
        projectId: 'proj-1',
        title: 'Timestamp-based Timer Invariants',
        content:
            'Never decrement an in-memory integer. In mobile OS environments, backgrounding pauses timers. Recomputing remaining = target - (now - start - paused) on resume guarantees precision.',
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  static PublicProfile getPublicProfile() {
    return const PublicProfile(
      id: 'prof-1',
      name: 'Frami Dev',
      title: 'Senior Full-Stack & Mobile Systems Engineer',
      bio:
          'Passionate systems builder focused on developer tools, distributed telemetry, and tactile mobile interfaces. Transforming complex backend architectures into intuitive, joyful user experiences.',
      location: 'Berlin / Remote',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      email: 'frami.dev@example.com',
      githubUsername: 'frami-dev',
      linkedinUrl: 'https://linkedin.com/in/frami-dev',
      primarySkills: [
        'Flutter & Dart',
        'Rust',
        'Distributed Systems',
        'TypeScript / React',
        'PostgreSQL & TimescaleDB',
        'UI/UX Design Systems',
      ],
      experiences: [
        PublicExperience(
          role: 'Staff Systems Architect',
          company: 'HyperScale Labs',
          period: '2023 - Present',
          description:
              'Leading the design of cross-platform developer toolchains and high-performance ingestion telemetry.',
          highlights: [
            'Architected real-time telemetry processing 50k events/sec with sub-5ms latency.',
            'Spearheaded the Developer Workplace initiative bridging private work to verified public proof.',
          ],
        ),
        PublicExperience(
          role: 'Senior Mobile Engineer',
          company: 'Kite Fintech',
          period: '2021 - 2023',
          description:
              'Built mobile payment checkout SDKs used by thousands of cross-border creators.',
          highlights: [
            'Reduced checkout drop-off by 18% with localized one-tap payment flows.',
            'Mentored 6 junior engineers and standardized testing best practices.',
          ],
        ),
      ],
      education: [
        PublicEducation(
          degree: 'B.S. in Computer Science',
          institution: 'Technical University',
          year: '2017 - 2021',
        ),
      ],
    );
  }

  static List<PublicEvidence> getPublicEvidence() {
    return [
      const PublicEvidence(
        id: 'ev-1',
        projectId: 'proj-1',
        title: 'Live Interactive Web/Mobile Preview',
        description:
            'Fully functional live deployment at frami-devplace.vercel.app with complete offline synchronization.',
        proofType: 'Live Demo',
        url: 'https://frami-devplace.vercel.app/app',
      ),
      const PublicEvidence(
        id: 'ev-2',
        projectId: 'proj-2',
        title: 'Telemetry Benchmark Whitepaper',
        description:
            'Benchmarked on AWS c6i.4xlarge instances sustaining 50k RPS with zero packet loss.',
        proofType: 'Benchmark',
        url: 'https://github.com/frami-dev/omnistream-core#benchmarks',
      ),
      const PublicEvidence(
        id: 'ev-3',
        projectId: 'proj-3',
        title: 'KitePay PCI Attestation of Compliance',
        description:
            'Certified SAQ-A merchant compliance with end-to-end tokenization.',
        proofType: 'Case Study',
        url: 'https://kitepay.dev/security',
      ),
    ];
  }

  static List<Goal> getGoals() {
    return [
      Goal(
        id: 'goal-1',
        title: 'Ship Developer Workplace Mobile Beta',
        description:
            'Deploy full mobile prototype with zero private leakage and clean test suite.',
        cadence: GoalCadence.monthly,
        currentProgress: 0.90,
        targetDate: today.add(const Duration(days: 10)),
      ),
      Goal(
        id: 'goal-2',
        title: 'Maintain 80+ Developer Health Index',
        description:
            'Log at least 10 active development days per 14-day rolling window without burnout.',
        cadence: GoalCadence.weekly,
        currentProgress: 0.85,
        targetDate: today.add(const Duration(days: 5)),
      ),
    ];
  }

  static List<GitHubRepoSummary> getGitHubRepos() {
    return [
      GitHubRepoSummary(
        name: 'frami-mobile',
        description: 'Developer Workplace mobile client in Flutter',
        defaultBranch: 'main',
        starsCount: 142,
        openIssuesCount: 4,
        isPrivate: false,
        lastPushedAt: now.subtract(const Duration(hours: 3)),
      ),
      GitHubRepoSummary(
        name: 'omnistream-core',
        description: 'Real-time telemetry ingestion engine in Rust',
        defaultBranch: 'main',
        starsCount: 389,
        openIssuesCount: 2,
        isPrivate: false,
        lastPushedAt: now.subtract(const Duration(days: 3)),
      ),
      GitHubRepoSummary(
        name: 'kitepay-sdk',
        description: 'Cross-platform mobile payment sheet SDK',
        defaultBranch: 'main',
        starsCount: 95,
        openIssuesCount: 1,
        isPrivate: false,
        lastPushedAt: now.subtract(const Duration(days: 8)),
      ),
    ];
  }

  static List<GitHubActivityItem> getGitHubActivity() {
    return [
      GitHubActivityItem(
        id: 'gh-1',
        repoName: 'frami-mobile',
        type: GitHubItemType.commit,
        title: 'feat: add seeded custom painter borders for sketch aesthetic',
        summary: 'Prevents card border recalculations on widget rebuilds.',
        author: 'frami-dev',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      GitHubActivityItem(
        id: 'gh-2',
        repoName: 'frami-mobile',
        type: GitHubItemType.pullRequest,
        title: 'pr #24: isolate public portfolio projection from private domain',
        summary: 'Enforces hard privacy boundary with automated test coverage.',
        author: 'frami-dev',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
      GitHubActivityItem(
        id: 'gh-3',
        repoName: 'frami-mobile',
        type: GitHubItemType.commit,
        title: 'fix: timestamp math for focus timer on app lifecycle resume',
        summary: 'Resolves background drift by re-anchoring from DateTime.now().',
        author: 'frami-dev',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      GitHubActivityItem(
        id: 'gh-4',
        repoName: 'omnistream-core',
        type: GitHubItemType.release,
        title: 'v1.4.0 High-Throughput Batching Release',
        summary: 'Optimized memory pooling and zero-copy JSON parser.',
        author: 'frami-dev',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      GitHubActivityItem(
        id: 'gh-5',
        repoName: 'kitepay-sdk',
        type: GitHubItemType.issue,
        title: 'issue #42: Add support for Apple Pay recurring mandates',
        summary: 'Investigating StoreKit 2 tokenization bridge.',
        author: 'community-dev',
        timestamp: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static PeriodicSnapshotReport getSnapshotReport() {
    return PeriodicSnapshotReport(
      id: 'rep-1',
      periodName: 'Weekly Summary (Current)',
      startDate: today.subtract(const Duration(days: 6)),
      endDate: today,
      focusMinutesLogged: 345,
      tasksCompletedCount: 12,
      commitsPushedCount: 18,
      dailyFocusMinutes: [45, 60, 25, 75, 50, 40, 50],
    );
  }
}
