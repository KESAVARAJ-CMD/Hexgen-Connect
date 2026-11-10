class ApiConstants {
  // With `adb reverse tcp:5000 tcp:5000` or web/desktop, localhost:5000 works for both real Android device & PC.
  // 10.0.2.2 works on standard Android emulators.
  static String customHost = '127.0.0.1:5000';

  static String get baseUrl {
    return 'http://$customHost/api';
  }

  // Auth endpoints
  static String get sendOtp => '$baseUrl/auth/send-otp';
  static String get verifyOtp => '$baseUrl/auth/verify-otp';
  static String get me => '$baseUrl/auth/me';

  // Venues & Slots
  static String get venues => '$baseUrl/venues';
  static String venueSlots(String venueId, {String date = 'today'}) =>
      '$baseUrl/venues/$venueId/slots?date=$date';

  // Bookings
  static String get createBooking => '$baseUrl/bookings';
  static String get myBookings => '$baseUrl/bookings/my-bookings';
  static String get health => '$baseUrl/health';
}
