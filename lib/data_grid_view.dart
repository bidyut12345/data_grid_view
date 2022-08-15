library data_grid_view;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
// import 'package:excel/excel.dart';
// import 'dart:io';
// import 'package:path/path.dart';

class DataGridView extends StatefulWidget {
  const DataGridView({
    Key? key,
    required this.data,
    this.isFooter = false,
    this.isRowheader = true,
    this.defaultColumnWidth = 20,
    this.defaultRowHeight = 30,
    this.defaultRowHeaderWidth = 30,
    this.additonalColumnsLeft,
    this.autoGenerateColumns = true,
    this.additonalColumnsRight,
    this.autoGenerateColumnDetails,
    this.scrollBarThickness = 40,
    this.maxColumnWidth = 300,
  }) : super(key: key);

  final List<Map<String, dynamic>> data;
  final bool isFooter;
  final bool autoGenerateColumns;
  final bool isRowheader;
  final double defaultColumnWidth;
  final double maxColumnWidth;
  final double defaultRowHeight;
  final double defaultRowHeaderWidth;
  final List<DataGridViewColumn>? additonalColumnsLeft;
  final List<DataGridViewColumn>? additonalColumnsRight;
  final List<DataGridViewColumn>? autoGenerateColumnDetails;
  final double scrollBarThickness;
  @override
  State<DataGridView> createState() => _DataGridViewState();

  static generatePDF(
      List<Map<String, dynamic>> data, String header, bool landscape, Map<String, double> columnWidths, double defaultColumnWidth, String filename,
      {double scale = 1.0}) async {
    Map<int, pw.TableColumnWidth> widths = {};
    for (int i = 0; i < data.first.keys.length; i++) {
      widths.addAll({i: pw.FlexColumnWidth(((columnWidths[data.first.keys.elementAt(i)] ?? defaultColumnWidth) * 1))});
    }
    var pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        maxPages: 10000,
        pageFormat: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        header: (context) => pw.Center(child: pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(header, textScaleFactor: 1.5))),
        build: (pw.Context context) {
          return [
            pw.Table.fromTextArray(
                cellStyle: pw.TextStyle(fontSize: 7 * scale),
                headerStyle: pw.TextStyle(fontSize: 7 * scale, fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.center,
                cellPadding: pw.EdgeInsets.all(2 * scale),
                border: const pw.TableBorder(
                  horizontalInside: pw.BorderSide(width: 0.5),
                  verticalInside: pw.BorderSide(width: 0.5),
                  top: pw.BorderSide(width: 0.5),
                  left: pw.BorderSide(width: 0.5),
                  right: pw.BorderSide(width: 0.5),
                  bottom: pw.BorderSide(width: 0.5),
                ),
                columnWidths: widths,
                context: context,
                data: [data.first.keys.toList()] +
                    data
                        .map(
                          (e) => (e.values
                              .toList()
                              .map(
                                (e) => e.toString() == "null" ? "" : e.toString(),
                              )
                              .toList()),
                        )
                        .toList()),
          ]; // Center
        },
      ),
    );
    if (kIsWeb) {
      await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
    } else {
      final file = File(filename);
      await file.writeAsBytes(await pdf.save());
    }
  }

  static Map<int, dynamic> generateColumnWidthAndRowHeight(
      List<Map<String, dynamic>> data, double defaultColumnWidth, double maxColumnWidth, double defaultRowHeight) {
    Map<String, double> columnWidths = {};
    Map<int, double> rowHeights = {};
    data.first.keys.toList().forEach((fieldname) {
      double maxFieldWidth = defaultColumnWidth;
      TextStyle style = const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black);
      TextPainter textPainter = TextPainter()
        ..text = TextSpan(text: fieldname, style: style)
        ..textDirection = TextDirection.ltr
        ..layout(minWidth: 0, maxWidth: maxColumnWidth);
      if (maxFieldWidth < textPainter.width + 10) {
        maxFieldWidth = textPainter.width + 10;
      }
      style = const TextStyle(fontSize: 16.0, color: Colors.black);

      for (int i = 0; i < data.length; i++) {
        Map<String, dynamic> rowData = data[i];
        textPainter = TextPainter()
          ..text = TextSpan(text: rowData[fieldname].toString(), style: style)
          ..textDirection = TextDirection.ltr
          ..layout(minWidth: 0, maxWidth: maxColumnWidth);
        if (maxFieldWidth < textPainter.width + 4) {
          maxFieldWidth = textPainter.width + 4;
        }
        if ((rowHeights[i] ?? defaultRowHeight) < textPainter.height + 4) {
          rowHeights[i] = textPainter.height + 4;
        }
      }
      columnWidths.addAll({fieldname: maxFieldWidth});
    });
    return {0: columnWidths, 1: rowHeights};
  }

  static generateExcel(List<Map<String, dynamic>> data) async {
// Create a new Excel document.
    final xls.Workbook workbook = xls.Workbook();
//Accessing worksheet via index.
    final xls.Worksheet sheet = workbook.worksheets[0];
    sheet.name = "Report";

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

    xls.Style headerStyle = workbook.styles.add('hederStyle');
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
        sheet.getRangeByIndex(rowIndex, colIndex).setText(row[element].toString() == "null" ? "" : row[element].toString());
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

// //Add Text.
//     sheet.getRangeByName('A1').setText('Hello World');
// //Add Number
//     sheet.getRangeByName('A3').setNumber(44);
// //set border color by hexa decimal.
//     // globalStyle.borders.all.color = '#9954CC';
//     sheet.getRangeByName('A1').cellStyle = headerStyle;
// //Add DateTime
//     sheet.getRangeByName('A5').setDateTime(DateTime(2020, 12, 12, 1, 10, 20));
// // Save the document.
    final List<int> bytes = workbook.saveAsStream();
    File('AddingTextNumberDateTime.xlsx').writeAsBytes(bytes);
//Dispose the workbook.
    workbook.dispose();

    // var excel = Excel.createExcel();

    // Sheet sheetObject = excel[excel.sheets.keys.toList().first];
    // CellStyle cellStyle = CellStyle(backgroundColorHex: "#1AFF1A", fontFamily: getFontFamily(FontFamily.Calibri));

    // cellStyle.underline = Underline.Single; // or Underline.Double
    // var cell = sheetObject.cell(CellIndex.indexByString("B4"));
    // cell.value = 8; // dynamic values support provided;
    // cell.cellStyle = cellStyle;
    // excel.updateCell(sheetObject.sheetName, CellIndex.indexByString("A2"), "Here value");
    // excel.tables.values.first.row(0)[0]!.
    // // printing cell-type
    // print("CellType: " + cell.cellType.toString());

    // ///
    // /// Inserting and removing column and rows

    // // insert column at index = 8
    // sheetObject.insertColumn(8);

    // // remove column at index = 18
    // sheetObject.removeColumn(18);

    // // insert row at index = 82
    // sheetObject.insertRow(82);

    // // remove row at index = 80
    // sheetObject.removeRow(80);

    // var fileBytes = excel.save();
    // // var directory = await getApplicationDocumentsDirectory();

    // File("output_file_name.xlsx")
    //   ..createSync(recursive: true)
    //   ..writeAsBytesSync(fileBytes!);
  }
}

class DataGridViewColumn {
  DataGridViewColumn({
    required this.columnWidth,
    required this.headerText,
    required this.dataField,
  });
  final double columnWidth;
  final String headerText;
  final String dataField;
}

class _DataGridViewState extends State<DataGridView> {
  late LinkedScrollControllerGroup _controllers1;
  late LinkedScrollControllerGroup _controllers2;
  late ScrollController _headController;
  late ScrollController _bodyController;
  late ScrollController _footController;

  late ScrollController _firstColumnController;
  late ScrollController _restColumnsController;
  late ScrollController _lastColumnController;

  @override
  void initState() {
    super.initState();
    _controllers1 = LinkedScrollControllerGroup();
    _controllers2 = LinkedScrollControllerGroup();
    _headController = _controllers1.addAndGet();
    _bodyController = _controllers1.addAndGet();
    _footController = _controllers1.addAndGet();
    _firstColumnController = _controllers2.addAndGet();
    _restColumnsController = _controllers2.addAndGet();
    _lastColumnController = _controllers2.addAndGet();
    var data = DataGridView.generateColumnWidthAndRowHeight(widget.data, widget.defaultColumnWidth, widget.maxColumnWidth, widget.defaultRowHeight);
    columnWidths = data[0];
    rowHeights = data[1];
  }

  Map<String, double> columnWidths = {};
  Map<int, double> rowHeights = {};

  @override
  void dispose() {
    _headController.dispose();
    _bodyController.dispose();
    _footController.dispose();
    _firstColumnController.dispose();
    _restColumnsController.dispose();
    _lastColumnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  child: Text("Generate PDF"),
                  onPressed: () async {
                    DataGridView.generatePDF(widget.data, "Report", true, columnWidths, widget.defaultColumnWidth, "Report.pdf", scale: 0.5);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  child: Text("Generate Excel"),
                  onPressed: () async {
                    DataGridView.generateExcel(widget.data);
                  }),
            ),
          ],
        ),
        //Header
        SizedBox(
          height: widget.defaultRowHeight + 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Row Header Column
              widget.isRowheader
                  ? DataGridViewCell(
                      color: Colors.yellow.withOpacity(0.3),
                      text: "",
                      cellWidth: widget.defaultRowHeaderWidth,
                      cellHeight: widget.defaultRowHeight,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                    )
                  : Container(),
              //Column Header
              Expanded(
                child: ListView(
                  controller: _headController,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: (widget.additonalColumnsLeft ?? [])
                          .map((e) => DataGridViewCell(
                                color: Colors.yellow.withOpacity(0.3),
                                text: e.headerText,
                                cellWidth: columnWidths[e.dataField] ?? widget.defaultColumnWidth,
                                cellHeight: widget.defaultRowHeight,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                              ))
                          .toList() +
                      widget.data.first.keys
                          .map(
                            (e) => DataGridViewCell(
                              color: Colors.yellow.withOpacity(0.3),
                              text: e,
                              cellWidth: columnWidths[e] ?? widget.defaultColumnWidth,
                              cellHeight: widget.defaultRowHeight,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                            ),
                          )
                          .toList(),
                ),
              ),
              //Right hand side scrollbar leave space
              SizedBox(width: widget.scrollBarThickness),
            ],
          ),
        ),
        //Rows
        Expanded(
          child: Row(
            children: [
              // Row Header
              widget.isRowheader
                  ? SizedBox(
                      width: widget.defaultRowHeaderWidth,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: ListView(
                          controller: _firstColumnController,
                          physics: const ClampingScrollPhysics(),
                          children: List.generate(widget.data.length, (index) {
                            return DataGridViewCell(
                              color: Colors.yellow.withOpacity(0.3),
                              text: (index + 1).toString(),
                              cellHeight: rowHeights[index] ?? widget.defaultRowHeight,
                              cellWidth: widget.defaultColumnWidth,
                            );
                          }),
                        ),
                      ),
                    )
                  : Container(),
              //Rows main data
              Expanded(
                child: Scrollbar(
                  controller: _bodyController,
                  isAlwaysShown: true,
                  thickness: widget.scrollBarThickness,
                  child: SingleChildScrollView(
                    controller: _bodyController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: columnWidths.values.toList().sum,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: ListView(
                          controller: _restColumnsController,
                          physics: const ClampingScrollPhysics(),
                          children: Function.apply(() {
                            List<Widget> ll = List.generate(widget.data.length, (rowIndex) {
                              return Row(
                                children: List.generate(widget.data.first.keys.length, (cellIndex) {
                                  return DataGridViewCell(
                                    text: widget.data[rowIndex][widget.data.first.keys.toList()[cellIndex].toString()].toString(),
                                    color: null,
                                    cellHeight: rowHeights[rowIndex] ?? widget.defaultRowHeight,
                                    cellWidth: columnWidths[widget.data.first.keys.toList()[cellIndex].toString()] ?? widget.defaultColumnWidth,
                                  );
                                }),
                              );
                            });
                            //Last Row
                            ll.add(SizedBox(
                              width: columnWidths.values.toList().sum,
                              height: widget.scrollBarThickness,
                            ));
                            return ll;
                          }, null),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: widget.scrollBarThickness,
                child: Scrollbar(
                  controller: _lastColumnController,
                  isAlwaysShown: true,
                  thickness: widget.scrollBarThickness,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView(
                      controller: _lastColumnController,
                      physics: const ClampingScrollPhysics(),
                      children: List.generate(widget.data.length, (rowIndex) {
                            return SizedBox(
                              height: rowHeights[rowIndex] ?? widget.defaultRowHeight,
                            );
                          }) +
                          [
                            SizedBox(
                              width: widget.scrollBarThickness,
                              height: widget.defaultRowHeight,
                            )
                          ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // DataGridViewBody(
          //   scrollController: _bodyController,
          //   cellWidth: widget.defaultColumnWidth,
          //   cellHeight: widget.defaultRowHeight,
          //   defaultRowHeaderWidth: widget.defaultRowHeaderWidth,
          //   autoGenerateColumns: widget.autoGenerateColumns,
          //   columns: widget.columns,
          //   data: widget.data,
          //   isRowHeader: widget.isRowheader,
          // ),
        ),
        // DataGridViewHeader(
        //   scrollController: _footController,
        // ),
      ],
    );
  }
}

class DataGridViewCell extends StatelessWidget {
  final String text;
  final Color? color;
  final double cellWidth;
  final double cellHeight;
  final TextStyle? style;
  const DataGridViewCell({
    Key? key,
    required this.text,
    this.color,
    required this.cellWidth,
    required this.cellHeight,
    this.style,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellWidth,
      height: cellHeight,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black12,
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>((states) => const EdgeInsets.all(2)),
        ),
        onPressed: () {},
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Tooltip(
              message: "", //text == "null" ? "" : text,
              child: Text(
                text == "null" ? "" : text,
                style: style ?? const TextStyle(fontSize: 16.0, color: Colors.black),
                textAlign: TextAlign.center,
                // maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
