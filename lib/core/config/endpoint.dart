class Endpoint {
  // Append /api so Laravel API routes (which are prefixed with /api) resolve correctly.
  static String get baseUrl => 'https://unconcernedly-acetylic-shirleen.ngrok-free.dev/api';

  static const String register = '/register';
  static const String login = '/login';

  static const String loans = '/loans';
  static String approveLoan(int id) => '/loans/$id/approve';
  static String rejectLoan(int id) => '/loans/$id/reject';
  static const String checkIn = '/loans/check-in';
  static const String checkOut = '/loans/check-out';

  static const String rooms = '/rooms';
  static String roomDesks(int roomId) => '/rooms/$roomId/desks';
  static String roomAvailableDesks(int roomId) =>
      '/rooms/$roomId/available-desks';
}
