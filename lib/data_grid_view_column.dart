import 'package:flutter/material.dart';

enum ColumnType { textColumn, elevatedButtonColumn, iconButtonColumn }

class DataGridViewColumn {
  DataGridViewColumn({
    required this.headerText,
    this.columnWidth,
    this.dataField,
    this.onCellPressed,
    this.cellText,
    this.toolTip,
    this.onClickReturnFieldNames,
    this.iconData,
    this.elevatedButtonStyle,
    this.columnType = ColumnType.textColumn,
  });
  final double? columnWidth;
  final String headerText;
  final String? cellText;
  final String? toolTip;
  final String? dataField;
  final List<String>? onClickReturnFieldNames;
  final IconData? iconData;
  final ButtonStyle? elevatedButtonStyle;
  final Function(int rowIndex, int cellIndex, List<dynamic>? returnValue)? onCellPressed;
  final ColumnType columnType;
}
