import 'dart:io';

import 'package:collection/collection.dart';
import 'package:data_grid_view/data_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Map<int, dynamic> generateColumnWidthAndRowHeight(
  List<Map<String, dynamic>> filterdata,
  DataGridView widget,
  double maxWidth,
  double scrollBarThickness,
) {
  if (widget.scrollbarAboveContent) {
    scrollBarThickness = 0;
  }
  Map<String, double> columnWidths = {};
  Map<int, double> rowHeights = {};
  if (filterdata.isEmpty) return {};
  double additonalWidth = 10;
  additonalWidth += widget.cellPadding.left;
  additonalWidth += widget.cellPadding.right;
  double additionalHeight = widget.cellPadding.top;
  additionalHeight += widget.cellPadding.bottom;

  if (!kIsWeb && Platform.isMacOS) {
    // additonalWidth += 30;
    // additionalHeight += 10;
  }

  if (!kIsWeb && Platform.isWindows) {
    // additonalWidth += 30;
    // additionalHeight += 10;
  }

  if (!kIsWeb && Platform.isAndroid) {
    additonalWidth += 30;
    additionalHeight += 10;
  }
  TextPainter textPainter;
  double headerHeight = widget.defaultRowHeight + widget.headerPadding.top + widget.headerPadding.bottom;
  filterdata.first.keys.toList().forEach((fieldname) {
    if (!(widget.hiddenDataColumns ?? []).contains(fieldname)) {
      if ((widget.dataColumnWidths ?? {}).containsKey(fieldname)) {
        columnWidths.addAll({fieldname: widget.dataColumnWidths![fieldname]!});
      } else {
        // print("from width 1 : $fieldname");
        double maxFieldWidth = widget.defaultColumnWidth;
        TextStyle style = TextStyle(fontSize: widget.headerFontSize);
        style = TextStyle(fontSize: widget.cellFontSize);
        for (int i = 0; i < filterdata.length; i++) {
          Map<String, dynamic> rowData = filterdata[i];
          var text = widget.cellFormat == null ? rowData[fieldname].toString().trim() : widget.cellFormat!(i, fieldname, rowData[fieldname]);
          textPainter = TextPainter()
            ..text = TextSpan(text: text, style: style)
            ..textDirection = TextDirection.ltr
            ..textWidthBasis = TextWidthBasis.longestLine
            ..layout(minWidth: 0, maxWidth: widget.maxColumnWidth);
          if (maxFieldWidth < textPainter.width + additonalWidth) {
            maxFieldWidth = textPainter.width + additonalWidth;
          }

          if ((rowHeights[i] ?? widget.defaultRowHeight) < (textPainter.height + additionalHeight) &&
              (textPainter.height + additionalHeight) > widget.defaultRowHeight) {
            rowHeights[i] = textPainter.height + additionalHeight;
          }
        }
        style = TextStyle(fontSize: widget.headerFontSize);
        for (String str in (widget.dataColumnHeadertexts?[fieldname] ?? fieldname).split(" ")) {
          textPainter = TextPainter()
            ..text = TextSpan(text: "⬇️ $str", style: style)
            ..textDirection = TextDirection.ltr
            ..layout(minWidth: 0, maxWidth: widget.maxColumnWidth);
          if (maxFieldWidth < textPainter.width + additonalWidth) {
            maxFieldWidth = textPainter.width + additonalWidth;
          }
        }
        textPainter = TextPainter()
          ..text = TextSpan(text: "⬇️ ${widget.dataColumnHeadertexts?[fieldname] ?? fieldname}", style: style)
          ..textDirection = TextDirection.ltr
          ..layout(minWidth: 0, maxWidth: maxFieldWidth - (additonalWidth)); //widget.maxColumnWidth

        if (headerHeight < (textPainter.height + additionalHeight + widget.headerPadding.top + widget.headerPadding.bottom) &&
            (textPainter.height + additionalHeight) > widget.defaultRowHeight) {
          headerHeight = textPainter.height + additionalHeight + widget.headerPadding.top + widget.headerPadding.bottom;
        }

        columnWidths.addAll({fieldname: maxFieldWidth});
      }
    }
  });
  maxWidth = (maxWidth - scrollBarThickness) - (columnWidths.length * 26); //155
  if (widget.isRowheader) maxWidth = maxWidth - widget.defaultRowHeaderWidth;
  var totalFixedWidth = (widget.additonalColumnsRight?.map((e) => e.columnWidth ?? 0).toList().sum ?? 0) +
      (widget.additonalColumnsLeft?.map((e) => e.columnWidth ?? 0).toList().sum ?? 0);
  double totalWidth = columnWidths.values.sum + totalFixedWidth; // + scrollBarThickness;
  // print("total width : $totalWidth  max : $maxWidth");
  if (totalWidth < maxWidth) {
    double ratio = 1.0;
    try {
      ratio = (maxWidth - totalFixedWidth) / (totalWidth - totalFixedWidth);
    } catch (_) {}
    for (var e in columnWidths.keys) {
      columnWidths[e] = (columnWidths[e] ?? 0) * ratio;
    }
    rowHeights = {};
    headerHeight = widget.defaultRowHeight + 10 + widget.headerPadding.top + widget.headerPadding.bottom;
    filterdata.first.keys.toList().forEach((fieldname) {
      if (!(widget.hiddenDataColumns ?? []).contains(fieldname)) {
        if ((widget.dataColumnWidths ?? {}).containsKey(fieldname)) {
          // columnWidths.addAll({fieldname: widget.dataColumnWidths![fieldname]!});
        } else {
          // print("from width 2 : $fieldname");
          double maxFieldWidth = (columnWidths[fieldname] ?? 0) - additonalWidth;
          TextStyle style = TextStyle(fontSize: widget.cellFontSize);
          for (int i = 0; i < filterdata.length; i++) {
            Map<String, dynamic> rowData = filterdata[i];
            var text = widget.cellFormat == null ? rowData[fieldname].toString().trim() : widget.cellFormat!(i, fieldname, rowData[fieldname]);
            TextPainter textPainter = TextPainter()
              ..text = TextSpan(text: text, style: style)
              ..textDirection = TextDirection.ltr
              ..textWidthBasis = TextWidthBasis.longestLine
              ..layout(minWidth: 0, maxWidth: maxFieldWidth);

            if ((rowHeights[i] ?? widget.defaultRowHeight) < (textPainter.height + additionalHeight) &&
                (textPainter.height + additionalHeight) > widget.defaultRowHeight) {
              rowHeights[i] = textPainter.height + additionalHeight;
            }
          }
          style = TextStyle(fontSize: widget.headerFontSize);
          textPainter = TextPainter()
            ..text = TextSpan(text: "⬇️ ${widget.dataColumnHeadertexts?[fieldname] ?? fieldname}", style: style)
            ..textDirection = TextDirection.ltr
            ..layout(minWidth: 0, maxWidth: maxFieldWidth); //widget.maxColumnWidth

          if (headerHeight < (textPainter.height + additionalHeight + widget.headerPadding.top + widget.headerPadding.bottom) &&
              (textPainter.height + additionalHeight) > widget.defaultRowHeight) {
            headerHeight = textPainter.height + additionalHeight + widget.headerPadding.top + widget.headerPadding.bottom;
          }
        }
      }
    });
  }

  return {0: columnWidths, 1: rowHeights, 2: headerHeight};
}
