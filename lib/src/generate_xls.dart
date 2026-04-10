import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

Future<void> generateExcel(
    List<Map<String, dynamic>> data, String fileName, String reportHeaderName, List<String>? hiddenColumns, Map<String, String>? footerData) async {
  try {
    await compute((_) async {
      try {
// Create a new Excel document.
        final xls.Workbook workbook = xls.Workbook();
        //Accessing worksheet via index.
        final xls.Worksheet sheet = workbook.worksheets[0];
        sheet.name = reportHeaderName;

        int startColIndex = 1;
        int startRowIndex = 1;

        int colIndex = startColIndex;
        int rowIndex = startRowIndex;

        xls.Style reportHeaderStyle = workbook.styles.add('reportHeaderStyle');
        reportHeaderStyle.hAlign = xls.HAlignType.center;
        reportHeaderStyle.bold = true;
        reportHeaderStyle.fontSize = 14;
        List<String> allColumns = data.isNotEmpty ? data.first.keys.toList() : [];
        List<String> visibleColumns = hiddenColumns != null ? allColumns.where((col) => !hiddenColumns.contains(col)).toList() : allColumns;

        for (var element in List.generate(visibleColumns.length, (index) => index)) {
          sheet.setColumnWidthInPixels(element + startColIndex, 500);
        }

        sheet.getRangeByIndex(rowIndex, colIndex, -1, colIndex + visibleColumns.length - 1).merge();
        sheet.getRangeByIndex(rowIndex, colIndex).cellStyle = reportHeaderStyle;
        sheet.getRangeByIndex(rowIndex, colIndex).setText(reportHeaderName);
        rowIndex++;

        xls.Style headerStyle = workbook.styles.add('headerStyle');
        headerStyle.borders.all.lineStyle = xls.LineStyle.thin;
        headerStyle.bold = true;
        headerStyle.hAlign = xls.HAlignType.center;
        for (var columnName in visibleColumns) {
          sheet.getRangeByIndex(rowIndex, colIndex).setText(columnName);
          sheet.getRangeByIndex(rowIndex, colIndex).cellStyle = headerStyle;
          colIndex++;
        }
        rowIndex++;

        xls.Style cellStyle = workbook.styles.add('cellStyle');
        cellStyle.borders.all.lineStyle = xls.LineStyle.thin;
        cellStyle.hAlign = xls.HAlignType.center;
        cellStyle.wrapText = true;
        for (var row in data) {
          colIndex = startColIndex;
          for (var columnName in visibleColumns) {
            // check if value is numeric, if yes then set number, else set text
            if (double.tryParse(row[columnName].toString()) != null) {
              sheet.getRangeByIndex(rowIndex, colIndex).setNumber(double.tryParse(row[columnName].toString()) ?? 0);
            } else {
              sheet.getRangeByIndex(rowIndex, colIndex).setText(row[columnName].toString() == "null" ? "" : row[columnName].toString());
            }
            sheet.getRangeByIndex(rowIndex, colIndex).cellStyle = cellStyle;
            colIndex++;
          }
          rowIndex++;
        }

//footer

        if (footerData != null) {
          xls.Style footerStyle = workbook.styles.add('footerStyle');
          footerStyle.borders.all.lineStyle = xls.LineStyle.thin;
          footerStyle.hAlign = xls.HAlignType.center;
          footerStyle.wrapText = true;
          footerStyle.bold = true;
          colIndex = startColIndex;
          for (var columnName in visibleColumns) {
            // check if value is numeric, if yes then set number, else set text
            if (double.tryParse(footerData[columnName].toString()) != null) {
              sheet.getRangeByIndex(rowIndex, colIndex).setNumber(double.tryParse(footerData[columnName].toString()) ?? 0);
            } else {
              sheet.getRangeByIndex(rowIndex, colIndex).setText(footerData[columnName].toString() == "null" ? "" : footerData[columnName].toString());
            }
            sheet.getRangeByIndex(rowIndex, colIndex).cellStyle = footerStyle;
            colIndex++;
          }
          rowIndex++;
        }
        for (var element in List.generate(rowIndex, (index) => index)) {
          sheet.setRowHeightInPixels(element + 1, 20);
        }

        colIndex = startColIndex;
        for (var columnName in visibleColumns) {
          sheet.autoFitColumn(colIndex);
          // if (sheet.getColumnWidth(colIndex) > 60) {
          //   sheet.setColumnWidthInPixels(colIndex, 425);
          // }
          colIndex++;
        }
        colIndex = startColIndex;
        for (var columnName in visibleColumns) {
          sheet.autoFitColumn(colIndex);
          // if (sheet.getColumnWidth(colIndex) > 60) {
          //   sheet.setColumnWidthInPixels(colIndex, 425);
          // }
          colIndex++;
        }

        // for (var element in List.generate(rowIndex, (index) => index)) {
        //   sheet.autoFitRow(element + 1);
        // }

        // final List<int> bytes = workbook.saveAsStream();
        if (!fileName.toLowerCase().endsWith(".xlsx")) {
          fileName += ".xlsx";
        }
        await workbook.save().then((bytes) async {
          await File(fileName).writeAsBytes(bytes);
        });
        //Dispose the workbook.
        workbook.dispose();
        print("Excel Generated at $fileName");
      } catch (e) {
        print("Error in generateExcel: $e");
      }
    }, null);
  } catch (e) {
    print("Error in generateExcel: $e");
  }
}
