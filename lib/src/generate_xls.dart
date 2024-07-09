import 'dart:io';

import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

generateExcel(List<Map<String, dynamic>> data, String fileName, String reportHeaderName) async {
  // Create a new Excel document.
  final xls.Workbook workbook = xls.Workbook();
  //Accessing worksheet via index.
  final xls.Worksheet sheet = workbook.worksheets[0];
  sheet.name = reportHeaderName;

  int startColIndex = 2;
  int startRowIndex = 2;

  int colIndex = startColIndex;
  int rowIndex = startRowIndex;

  xls.Style reportHeaderStyle = workbook.styles.add('reportHeaderStyle');
  reportHeaderStyle.hAlign = xls.HAlignType.center;
  reportHeaderStyle.bold = true;
  reportHeaderStyle.fontSize = 14;

  sheet.getRangeByIndex(rowIndex, colIndex, -1, colIndex + data.first.keys.toList().length - 1).merge();
  sheet.getRangeByIndex(rowIndex, colIndex).cellStyle = reportHeaderStyle;
  sheet.getRangeByIndex(rowIndex, colIndex).setText(reportHeaderName);
  rowIndex++;

  xls.Style headerStyle = workbook.styles.add('headerStyle');
  headerStyle.borders.all.lineStyle = xls.LineStyle.thin;
  headerStyle.bold = true;
  headerStyle.hAlign = xls.HAlignType.center;
  data.first.keys.toList().forEach((element) {
    sheet.getRangeByIndex(rowIndex, colIndex).setText(element);
    sheet.getRangeByIndex(rowIndex, colIndex).cellStyle = headerStyle;
    colIndex++;
  });
  rowIndex++;

  xls.Style cellStyle = workbook.styles.add('cellStyle');
  cellStyle.borders.all.lineStyle = xls.LineStyle.thin;
  cellStyle.hAlign = xls.HAlignType.center;
  cellStyle.wrapText = true;
  for (var row in data) {
    colIndex = startColIndex;
    row.keys.toList().forEach((element) {
      sheet
          .getRangeByIndex(rowIndex, colIndex)
          .setText(row[element].toString() == "null" ? "" : row[element].toString());
      sheet.getRangeByIndex(rowIndex, colIndex).cellStyle = cellStyle;
      colIndex++;
    });
    rowIndex++;
  }

  for (var element in List.generate(rowIndex, (index) => index)) {
    sheet.setRowHeightInPixels(element + 1, 20);
  }

  colIndex = startColIndex;
  data.first.keys.toList().forEach((element) {
    sheet.autoFitColumn(colIndex);
    if (sheet.getColumnWidth(colIndex) > 60) {
      sheet.setColumnWidthInPixels(colIndex, 425);
    }
    colIndex++;
  });

  for (var element in List.generate(rowIndex, (index) => index)) {
    sheet.autoFitRow(element + 1);
  }

  final List<int> bytes = workbook.saveAsStream();
  if (!fileName.toLowerCase().endsWith(".xlsx")) {
    fileName += ".xlsx";
  }
  File(fileName).writeAsBytes(bytes);
  //Dispose the workbook.
  workbook.dispose();
}
