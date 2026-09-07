/// Every route path as a named constant. Screens navigate via these, never
/// a raw string literal — keeps a path rename a one-file change.
class RoutePaths {
  RoutePaths._();

  static const splash = '/';
  static const mobileNumber = '/login';
  static const otpVerify = '/login/verify';

  // Public Mode shell (Section 3.3).
  static const home = '/home';
  static const myRegistrations = '/registrations/mine';
  static const myTickets = '/tickets/mine';
  static const ticketTransfers = '/tickets/transfers';
  static const myWaitlists = '/waitlists/mine';
  static const profile = '/profile';
  static const myFeedback = '/feedback/mine';
  static const certificates = '/achievements';
  static const certificateDetail = '/achievements/:certificateId';
  static const sponsorship = '/sponsorship';
  static const sponsorshipInquiry = '/sponsorship/inquire';
  static const mySponsorshipInquiries = '/sponsorship/inquiries/mine';
  static const volunteers = '/volunteers';
  static const volunteerApply = '/volunteers/apply/:eventId';
  static String volunteerApplyPath(String eventId) =>
      '/volunteers/apply/$eventId';
  static const myVolunteerApplications = '/volunteers/applications/mine';
  static const myVolunteerShifts = '/volunteers/shifts/mine';

  // Phase 2 — Event Discovery & Categories. eventDetail and
  // eventDetailPath both exist because go_router needs the templated
  // form ('/events/:eventId') for route registration, while callers
  // building a real link need the interpolated form — eventDetailPath
  // is the one every screen should call rather than interpolating the
  // literal '/events/' string itself.
  static const eventDetail = '/events/:eventId';
  static String eventDetailPath(String eventId) => '/events/$eventId';
  static const eventFeedback = '/events/:eventId/feedback';
  static String eventFeedbackPath(String eventId) =>
      '/events/$eventId/feedback';
  static const eventInteractions = '/events/:eventId/interactions';
  static String eventInteractionsPath(String eventId) =>
      '/events/$eventId/interactions';
  static const eventNetworking = '/events/:eventId/networking';
  static String eventNetworkingPath(String eventId) =>
      '/events/$eventId/networking';
  static const search = '/search';

  // Phase 3 — Registration Engine.
  static const participationTypeSelector = '/events/:eventId/register';
  static String participationTypeSelectorPath(String eventId) =>
      '/events/$eventId/register';

  static const registrationForm =
      '/events/:eventId/register/:participationType';
  static String registrationFormPath(
          String eventId, String participationType) =>
      '/events/$eventId/register/$participationType';

  static const waitlistJoin = '/events/:eventId/waitlist';
  static String waitlistJoinPath(String eventId) => '/events/$eventId/waitlist';

  static const registrationDetail = '/registrations/:registrationId';
  static String registrationDetailPath(String registrationId) =>
      '/registrations/$registrationId';

  static const createTeam = '/events/:eventId/register/team/create';
  static String createTeamPath(String eventId) =>
      '/events/$eventId/register/team/create';

  static const teamRoster = '/teams/:teamId';
  static String teamRosterPath(String teamId) => '/teams/$teamId';
  static const myTeams = '/teams/mine';

  static const myChildren = '/children';
  static const addChild = '/children/add';

  // Phase 4 — Payments & Tickets.
  static const paymentCheckout = '/registrations/:registrationId/pay';
  static String paymentCheckoutPath(String registrationId) =>
      '/registrations/$registrationId/pay';

  static const ticketDetail = '/ticket/:ticketId';
  static String ticketDetailPath(String ticketId) => '/ticket/$ticketId';

  // Phase 6 — Staff Mode Extended, Growth & Engagement.
  static const notifications = '/notifications';
  static const assistanceRequests = '/assistance';
  static const requestAssistance =
      '/events/:eventId/registrations/:registrationId/assistance/new';
  static String requestAssistancePath(String eventId, String registrationId) =>
      '/events/$eventId/registrations/$registrationId/assistance/new';
  static const referral = '/events/:eventId/refer';
  static String referralPath(String eventId) => '/events/$eventId/refer';
  static const mediaGallery = '/events/:eventId/gallery';
  static String mediaGalleryPath(String eventId) => '/events/$eventId/gallery';
  static const competitionStages = '/events/:eventId/competition';
  static String competitionStagesPath(String eventId) =>
      '/events/$eventId/competition';
  static const voting = '/competition/vote/:stageId';
  static String votingPath(String stageId) => '/competition/vote/$stageId';

  // Phase 7 — Profile, Settings & Polish.
  static const editProfile = '/profile/edit';
  static const identityDocuments = '/profile/identity-documents';
  static const appSettings = '/profile/settings';

  // Staff Mode shell (Section 3.3).
  static const staffScan = '/staff/scan';
  static const staffTasks = '/staff/tasks';
  static const staffMyEvents = '/staff/events';
  static const staffProfile = '/staff/profile';
  static const staffIncidents = '/staff/incidents';
}
