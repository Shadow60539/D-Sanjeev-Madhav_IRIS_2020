//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoeight/utils/src/customization/calendar_style.dart';


class MyCellWidget extends StatelessWidget {
  final String text;
  final bool isUnavailable;
  final bool isSelected;
  final bool isToday;
  final bool isWeekend;
  final bool isOutsideMonth;
  final bool isHoliday;
  final MyCalendarStyle calendarStyle;

  const MyCellWidget({
    Key key,
    @required this.text,
    this.isUnavailable = false,
    this.isSelected = false,
    this.isToday = false,
    this.isWeekend = false,
    this.isOutsideMonth = false,
    this.isHoliday = false,
    @required this.calendarStyle,
  })  : assert(text != null),
        assert(calendarStyle != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.slowMiddle,
      decoration: _buildCellDecoration(),
      margin: const EdgeInsets.all(6.0),
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 3, top: 3),
        child: Text(
          text,
          style: _buildCellTextStyle(),
        ),
      ),
    );
  }

  Decoration _buildCellDecoration() {
    if (isSelected &&
        calendarStyle.renderSelectedFirst &&
        calendarStyle.highlightSelected) {
      return BoxDecoration(
          shape: BoxShape.rectangle,
//          boxShadow: [
//            BoxShadow(
//                color: Colors.black,
//                offset: Offset(5, 4),
//                blurRadius: 1,
//                spreadRadius: 1),
//          ],
          borderRadius: BorderRadius.circular(2),
          color: calendarStyle.selectedColor);
    } else if (isToday && calendarStyle.highlightToday) {
      return BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          color: calendarStyle.todayColor);
    } else if (isSelected && calendarStyle.highlightSelected) {
      return BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          color: calendarStyle.selectedColor);
    } else {
      return BoxDecoration(
          shape: BoxShape.rectangle,
          // border: Border.all(color: Colors.white),

          //  color: Colors.white10,
          borderRadius: BorderRadius.circular(5));
    }
  }

  TextStyle _buildCellTextStyle() {
    if (isUnavailable) {
      return calendarStyle.unavailableStyle;
    } else if (isSelected &&
        calendarStyle.renderSelectedFirst &&
        calendarStyle.highlightSelected) {
      return calendarStyle.selectedStyle;
    } else if (isToday && calendarStyle.highlightToday) {
      return calendarStyle.todayStyle;
    } else if (isSelected && calendarStyle.highlightSelected) {
      return calendarStyle.selectedStyle;
    } else if (isOutsideMonth && isHoliday) {
      return calendarStyle.outsideHolidayStyle;
    } else if (isHoliday) {
      return calendarStyle.holidayStyle;
    } else if (isOutsideMonth && isWeekend) {
      return calendarStyle.outsideWeekendStyle;
    } else if (isOutsideMonth) {
      return calendarStyle.outsideStyle;
    } else if (isWeekend) {
      return calendarStyle.weekendStyle;
    } else {
      return calendarStyle.weekdayStyle;
    }
  }
}
