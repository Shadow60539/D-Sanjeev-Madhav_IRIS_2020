//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


/// Class containing styling for `TableCalendar`'s days of week panel.
class MyDaysOfWeekStyle {
  /// Use to customize days of week panel text (eg. with different `DateFormat`).
  /// You can use `String` transformations to further customize the text.
  /// Defaults to simple `'E'` format (eg. Mon, Tue, Wed, etc.).
  ///
  /// Example usage:
  /// ```dart
  /// dowTextBuilder: (date, locale) => DateFormat.E(locale).format(date)[0],
  /// ```

  /// Style for weekdays on the top of Calendar.
  final TextStyle weekdayStyle;

  /// Style for weekend days on the top of Calendar.
  final TextStyle weekendStyle;

  const MyDaysOfWeekStyle(
      {this.weekdayStyle =
          const TextStyle(color: Colors.white, fontFamily: 'Calendar'),
      this.weekendStyle = const TextStyle(
          color: const Color(0xFF098cec), fontFamily: 'Calendar')});
}
