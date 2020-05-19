import 'package:flutter/cupertino.dart';
import 'package:todoeight/utils/src/calendar.dart';

const double _dxMax = 1.2;
const double _dxMin = -1.2;

typedef void _SelectedDayCallback(DateTime day);

class MyCalendarController {
  /// Currently focused day (used to determine which year/month should be visible).
  DateTime get focusedDay => _focusedDay;

  /// Currently selected day.
  DateTime get selectedDay => _selectedDay;

  /// Currently visible calendar format.
  CalendarFormat get calendarFormat => _calendarFormat.value;

  /// List of currently visible days.
  List<DateTime> get visibleDays =>
      calendarFormat == CalendarFormat.month && !_includeInvisibleDays
          ? myvisibleDays.value.where((day) => !isExtraDay(day)).toList()
          : myvisibleDays.value;

  /// `Map` of currently visible events.
  Map<DateTime, List> get visibleEvents {
    if (myevents == null) {
      return {};
    }
    return Map.fromEntries(
      myevents.entries.where((entry) {
        for (final day in visibleDays) {
          if (_isSameDay(day, entry.key)) {
            return true;
          }
        }

        return false;
      }),
    );
  }

  /// `Map` of currently visible holidays.
  Map<DateTime, List> get visibleHolidays {
    if (myholidays == null) {
      return {};
    }

    return Map.fromEntries(
      myholidays.entries.where((entry) {
        for (final day in visibleDays) {
          if (_isSameDay(day, entry.key)) {
            return true;
          }
        }

        return false;
      }),
    );
  }

  Map<DateTime, List> myevents;
  Map<DateTime, List> myholidays;
  DateTime _focusedDay;
  DateTime _selectedDay;
  StartingDayOfWeek _startingDayOfWeek;
  ValueNotifier<CalendarFormat> _calendarFormat;
  ValueNotifier<List<DateTime>> myvisibleDays;
  Map<CalendarFormat, String> _availableCalendarFormats;
  DateTime _previousFirstDay;
  DateTime _previousLastDay;
  int pageId;
  double dx;
  bool _useNextCalendarFormat;
  bool _includeInvisibleDays;
  _SelectedDayCallback _selectedDayCallback;

  void init({
    @required Map<DateTime, List> events,
    @required Map<DateTime, List> holidays,
    @required DateTime initialDay,
    @required CalendarFormat initialFormat,
    @required Map<CalendarFormat, String> availableCalendarFormats,
    @required bool useNextCalendarFormat,
    @required StartingDayOfWeek startingDayOfWeek,
    @required _SelectedDayCallback selectedDayCallback,
    @required OnVisibleDaysChanged onVisibleDaysChanged,
    @required OnCalendarCreated onCalendarCreated,
    @required bool includeInvisibleDays,
  }) {
    myevents = events;
    myholidays = holidays;
    _availableCalendarFormats = availableCalendarFormats;
    _startingDayOfWeek = startingDayOfWeek;
    _useNextCalendarFormat = useNextCalendarFormat;
    _selectedDayCallback = selectedDayCallback;
    _includeInvisibleDays = includeInvisibleDays;

    pageId = 0;
    dx = 0;

    final now = DateTime.now();
    _focusedDay = initialDay ?? normalizeDate(now);
    _selectedDay = _focusedDay;
    _calendarFormat = ValueNotifier(initialFormat);
    myvisibleDays = ValueNotifier(_getVisibleDays());
    _previousFirstDay = myvisibleDays.value.first;
    _previousLastDay = myvisibleDays.value.last;

    _calendarFormat.addListener(() {
      myvisibleDays.value = _getVisibleDays();
    });

    if (onVisibleDaysChanged != null) {
      myvisibleDays.addListener(() {
        if (!_isSameDay(myvisibleDays.value.first, _previousFirstDay) ||
            !_isSameDay(myvisibleDays.value.last, _previousLastDay)) {
          _previousFirstDay = myvisibleDays.value.first;
          _previousLastDay = myvisibleDays.value.last;
          onVisibleDaysChanged(
            _getFirstDay(includeInvisible: _includeInvisibleDays),
            _getLastDay(includeInvisible: _includeInvisibleDays),
            _calendarFormat.value,
          );
        }
      });
    }

    if (onCalendarCreated != null) {
      onCalendarCreated(
        _getFirstDay(includeInvisible: _includeInvisibleDays),
        _getLastDay(includeInvisible: _includeInvisibleDays),
        _calendarFormat.value,
        events,
      );
    }
  }

  /// Disposes the controller.
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _calendarController.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _calendarFormat?.dispose();
    myvisibleDays?.dispose();
  }

  /// Toggles calendar format. Same as using `FormatButton`.
  void toggleCalendarFormat() {
    _calendarFormat.value = _nextFormat();
  }

  /// Sets calendar format by emulating swipe.
  void swipeCalendarFormat({@required bool isSwipeUp}) {
    assert(isSwipeUp != null);

    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);

    // Order of CalendarFormats must be from biggest to smallest,
    // eg.: [month, twoWeeks, week]
    if (isSwipeUp) {
      id = _clamp(0, formats.length - 1, id + 1);
    } else {
      id = _clamp(0, formats.length - 1, id - 1);
    }
    _calendarFormat.value = formats[id];
  }

  /// Sets calendar format to a given `value`.
  void setCalendarFormat(CalendarFormat value) {
    _calendarFormat.value = value;
  }

  /// Sets selected day to a given `value`.
  /// Use `runCallback: true` if this should trigger `OnDaySelected` callback.
  void setSelectedDay(
    DateTime value, {
    bool isProgrammatic = true,
    bool animate = true,
    bool runCallback = false,
  }) {
    final normalizedDate = normalizeDate(value);

    if (animate) {
      if (normalizedDate.isBefore(_getFirstDay(includeInvisible: false))) {
        _decrementPage();
      } else if (normalizedDate.isAfter(_getLastDay(includeInvisible: false))) {
        _incrementPage();
      }
    }

    _selectedDay = normalizedDate;
    _focusedDay = normalizedDate;
    _updateVisibleDays(isProgrammatic);

    if (isProgrammatic && runCallback && _selectedDayCallback != null) {
      _selectedDayCallback(normalizedDate);
    }
  }

  /// Sets displayed month/year without changing the currently selected day.
  void setFocusedDay(DateTime value) {
    _focusedDay = normalizeDate(value);
    _updateVisibleDays(true);
  }

  void _updateVisibleDays(bool isProgrammatic) {
    if (calendarFormat != CalendarFormat.twoWeeks || isProgrammatic) {
      myvisibleDays.value = _getVisibleDays();
    }
  }

  CalendarFormat _nextFormat() {
    final formats = _availableCalendarFormats.keys.toList();
    int id = formats.indexOf(_calendarFormat.value);
    id = (id + 1) % formats.length;

    return formats[id];
  }

  String getFormatButtonText() => _useNextCalendarFormat
      ? _availableCalendarFormats[_nextFormat()]
      : _availableCalendarFormats[_calendarFormat.value];

  void selectPrevious() {
    if (calendarFormat == CalendarFormat.month) {
      selectPreviousMonth();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      selectPreviousTwoWeeks();
    } else {
      selectPreviousWeek();
    }

    myvisibleDays.value = _getVisibleDays();
    _decrementPage();
  }

  void selectNext() {
    if (calendarFormat == CalendarFormat.month) {
      _selectNextMonth();
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      _selectNextTwoWeeks();
    } else {
      _selectNextWeek();
    }

    myvisibleDays.value = _getVisibleDays();
    _incrementPage();
  }

  void selectPreviousMonth() {
    _focusedDay = previousMonth(_focusedDay);
  }

  void _selectNextMonth() {
    _focusedDay = nextMonth(_focusedDay);
  }

  void selectPreviousTwoWeeks() {
    if (myvisibleDays.value.take(7).contains(_focusedDay)) {
      // in top row
      _focusedDay = previousWeek(_focusedDay);
    } else {
      // in bottom row OR not visible
      _focusedDay = previousWeek(_focusedDay.subtract(const Duration(days: 7)));
    }
  }

  void _selectNextTwoWeeks() {
    if (!myvisibleDays.value.skip(7).contains(_focusedDay)) {
      // not in bottom row [eg: in top row OR not visible]
      _focusedDay = nextWeek(_focusedDay);
    }
  }

  void selectPreviousWeek() {
    _focusedDay = previousWeek(_focusedDay);
  }

  void _selectNextWeek() {
    _focusedDay = nextWeek(_focusedDay);
  }

  DateTime _getFirstDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return _firstDayOfMonth(_focusedDay);
    } else {
      return myvisibleDays.value.first;
    }
  }

  DateTime _getLastDay({@required bool includeInvisible}) {
    if (_calendarFormat.value == CalendarFormat.month && !includeInvisible) {
      return lastDayOfMonth(_focusedDay);
    } else {
      return myvisibleDays.value.last;
    }
  }

  List<DateTime> _getVisibleDays() {
    if (calendarFormat == CalendarFormat.month) {
      return _daysInMonth(_focusedDay);
    } else if (calendarFormat == CalendarFormat.twoWeeks) {
      return daysInWeek(_focusedDay)
        ..addAll(daysInWeek(
          _focusedDay.add(const Duration(days: 7)),
        ));
    } else {
      return daysInWeek(_focusedDay);
    }
  }

  void _decrementPage() {
    pageId--;
    dx = _dxMin;
  }

  void _incrementPage() {
    pageId++;
    dx = _dxMax;
  }

  int _getWeekdayNumber(StartingDayOfWeek weekday) {
    return StartingDayOfWeek.values.indexOf(weekday) + 1;
  }

  List<DateTime> _daysInMonth(DateTime month) {
    final first = _firstDayOfMonth(month);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = lastDayOfMonth(month);
    final daysAfter = getDaysAfter(last);

    final lastToDisplay = last.add(Duration(days: daysAfter));
    return daysInRange(firstToDisplay, lastToDisplay).toList();
  }

  int _getDaysBefore(DateTime firstDay) {
    return (firstDay.weekday + 7 - _getWeekdayNumber(_startingDayOfWeek)) % 7;
  }

  int getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday = 8 - _getWeekdayNumber(_startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7) + 1;
    if (daysAfter == 8) {
      daysAfter = 1;
    }

    return daysAfter;
  }

  List<DateTime> daysInWeek(DateTime week) {
    final first = _firstDayOfWeek(week);
    final last = _lastDayOfWeek(week);

    return daysInRange(first, last).toList();
  }

  DateTime _firstDayOfWeek(DateTime day) {
    day = normalizeDate(day);

    final decreaseNum = _getDaysBefore(day);
    return day.subtract(Duration(days: decreaseNum));
  }

  DateTime _lastDayOfWeek(DateTime day) {
    day = normalizeDate(day);

    final increaseNum = _getDaysBefore(day);
    return day.add(Duration(days: 7 - increaseNum));
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1, 12);
  }

  DateTime lastDayOfMonth(DateTime month) {
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1, 1, 12)
        : DateTime.utc(month.year + 1, 1, 1, 12);
    return date.subtract(const Duration(days: 1));
  }

  DateTime previousWeek(DateTime week) {
    return week.subtract(const Duration(days: 7));
  }

  DateTime nextWeek(DateTime week) {
    return week.add(const Duration(days: 7));
  }

  DateTime previousMonth(DateTime month) {
    if (month.month == 1) {
      return DateTime(month.year - 1, 12);
    } else {
      return DateTime(month.year, month.month - 1);
    }
  }

  DateTime nextMonth(DateTime month) {
    if (month.month == 12) {
      return DateTime(month.year + 1, 1);
    } else {
      return DateTime(month.year, month.month + 1);
    }
  }

  Iterable<DateTime> daysInRange(DateTime firstDay, DateTime lastDay) sync* {
    var temp = firstDay;

    while (temp.isBefore(lastDay)) {
      yield normalizeDate(temp);
      temp = temp.add(const Duration(days: 1));
    }
  }

  DateTime normalizeDate(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day, 12);
  }

  DateTime getEventKey(DateTime day) {
    return visibleEvents.keys
        .firstWhere((it) => _isSameDay(it, day), orElse: () => null);
  }

  DateTime getHolidayKey(DateTime day) {
    return visibleHolidays.keys
        .firstWhere((it) => _isSameDay(it, day), orElse: () => null);
  }

  /// Returns true if `day` is currently selected.
  bool isSelected(DateTime day) {
    return _isSameDay(day, selectedDay);
  }

  /// Returns true if `day` is the same day as `DateTime.now()`.
  bool isToday(DateTime day) {
    return _isSameDay(day, DateTime.now());
  }

  bool _isSameDay(DateTime dayA, DateTime dayB) {
    return dayA.year == dayB.year &&
        dayA.month == dayB.month &&
        dayA.day == dayB.day;
  }

  bool isWeekend(DateTime day, List<int> weekendDays) {
    return weekendDays.contains(day.weekday);
  }

  bool isExtraDay(DateTime day) {
    return isExtraDayBefore(day) || isExtraDayAfter(day);
  }

  bool isExtraDayBefore(DateTime day) {
    return day.month < _focusedDay.month;
  }

  bool isExtraDayAfter(DateTime day) {
    return day.month > _focusedDay.month;
  }

  int _clamp(int min, int max, int value) {
    if (value > max) {
      return max;
    } else if (value < min) {
      return min;
    } else {
      return value;
    }
  }
}
