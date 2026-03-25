import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoint {
  static String get baseUrl {
    final configured = (dotenv.env['BASE_URL'] ?? '').trim();
    if (configured.isEmpty) {
      return '';
    }

    final normalized = configured.replaceFirst(RegExp(r'/+$'), '');
    final hasApiPrefix =
        normalized.endsWith('/api') || normalized.contains('/api/');
    return hasApiPrefix ? normalized : '$normalized/api';
  }

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
  static String deskQr(int deskId) => '/desks/$deskId/qr';
}
