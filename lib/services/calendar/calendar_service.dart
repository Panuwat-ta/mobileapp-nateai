import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/result.dart';

final calendarServiceProvider = Provider<CalendarService>((ref) {
  return CalendarService();
});

class CalendarService {
  Future<Result<bool>> addEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final Event event = Event(
        title: title,
        description: description,
        location: '',
        startDate: startDate,
        endDate: endDate,
      );
      final success = await Add2Calendar.addEvent2Cal(event);
      return Success(success);
    } catch (e, st) {
      return Failure('Failed to add event to calendar: $e', e, st);
    }
  }
}
