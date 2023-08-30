import 'package:intl/intl.dart';

extension DateTimeParser on DateTime {
  String dMMMyFormat() {
    return DateFormat('d MMM y', 'id').format(
      this,
    );
  }
}
