import 'package:flutter/material.dart';

enum ColumnType { textColumn, elevatedButtonColumn, iconButtonColumn, widgetColumn }

class DataGridViewColumn {
  DataGridViewColumn({
    required this.headerText,
    this.columnWidth,
    this.columnName,
    this.dataField,
    this.onCellPressed,
    this.cellText,
    this.toolTip,
    this.onClickReturnFieldNames,
    this.iconData,
    this.elevatedButtonStyle,
    this.columnType = ColumnType.textColumn,
    this.cellWidget,
  });
  final double? columnWidth;
  final String headerText;
  final String? Function(int rowIndex)? cellText;
  final Widget Function(int rowIndex)? cellWidget;
  final String? toolTip;
  final String? dataField;
  final List<String>? onClickReturnFieldNames;
  final IconData? iconData;
  final ButtonStyle? elevatedButtonStyle;
  final Function(int rowIndex, int cellIndex, List<dynamic>? returnValue)? onCellPressed;
  final ColumnType columnType;
  final String? columnName;
}
