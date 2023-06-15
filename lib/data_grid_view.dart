library data_grid_view;

import 'dart:io';

import 'package:data_grid_view/data_grid_view_cell.dart';
import 'package:data_grid_view/data_grid_view_column.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;

export 'data_grid_view_column.dart';
export 'data_grid_view_cell.dart';

double _extraCellPadding = 2.0;

class DataGridViewController {
  Function({String fileName, double scale, String reportHeaderText})? generatePdf;
  Function({String fileName, String reportHeaderText})? generateXls;
  Function? printPreview;
  void dispose() {
    generatePdf = null;
    generateXls = null;
    printPreview = null;
  }
}

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
    this.showExportExcelButton = false,
    this.showExportPDFButton = false,
    this.columnHeaderColor = Colors.black26,
    this.rowHeaderColor = Colors.black12,
    this.dataColumnHeadertexts,
    this.dataColumnWidths,
    this.hiddenDataColumns,
    this.controller,
    this.textColor = Colors.black87,
    this.headerAlignment = Alignment.center,
    this.cellAlignment = Alignment.center,
    this.headerFontSize = 16,
    this.cellFontSize = 14,
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
  final bool showExportExcelButton;
  final bool showExportPDFButton;
  final Color columnHeaderColor;
  final Color rowHeaderColor;
  final Map<String, String>? dataColumnHeadertexts;
  final Map<String, double>? dataColumnWidths;
  final List<String>? hiddenDataColumns;
  final DataGridViewController? controller;
  final Color textColor;
  final Alignment headerAlignment;
  final Alignment cellAlignment;

  final double headerFontSize;
  final double cellFontSize;
// final bool showS
  @override
  State<DataGridView> createState() => _DataGridViewState();

  static _generatePDF(
    List<Map<String, dynamic>> data,
    String header,
    bool landscape,
    Map<String, double> columnWidths,
    double defaultColumnWidth,
    String filename,
    List<String> hiddenDataColumns, {
    double scale = 1.0,
  }) async {
    Map<int, pw.TableColumnWidth> widths = {};
    for (int i = 0; i < data.first.keys.length; i++) {
      String columnName = data.first.keys.elementAt(i);
      if (hiddenDataColumns.contains(columnName)) {
        widths.addAll({i: const pw.FixedColumnWidth(0)});
      } else {
        widths.addAll({i: pw.FlexColumnWidth(((columnWidths[columnName] ?? defaultColumnWidth) * 1))});
      }
    }

    var pdf = pw.Document();
    var pageFormat = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
    var newPageFomat = PdfPageFormat(
      pageFormat.width,
      pageFormat.height,
      marginAll: 10,
    );
    pdf.addPage(
      pw.MultiPage(
        maxPages: 10000,
        pageFormat: newPageFomat,
        header: (context) => pw.Center(
            child: pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(header, textScaleFactor: 1.5))),
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

  static Map<int, dynamic> _generateColumnWidthAndRowHeight(
      List<Map<String, dynamic>> data,
      double defaultColumnWidth,
      double maxColumnWidth,
      double defaultRowHeight,
      List<String>? hiddenDataColumns,
      Map<String, String>? dataColumnHeadertexts,
      Map<String, double>? dataColumnWidths,
      double headerFontSize,
      double cellFontSize) {
    Map<String, double> columnWidths = {};
    Map<int, double> rowHeights = {};

    data.first.keys.toList().forEach((fieldname) {
      if (!(hiddenDataColumns ?? []).contains(fieldname)) {
        if ((dataColumnWidths ?? {}).containsKey(fieldname)) {
          columnWidths.addAll({fieldname: dataColumnWidths![fieldname]!});
        } else {
          int additonalWidth = 20;
          int additionalHeight = 0;
          if (!kIsWeb && Platform.isMacOS) {
            additonalWidth = 30;
          }
          if (!kIsWeb && Platform.isAndroid) {
            additonalWidth = 30;
            additionalHeight = 10;
          }
          double maxFieldWidth = defaultColumnWidth;
          TextStyle style = TextStyle(fontSize: headerFontSize);
          TextPainter textPainter = TextPainter()
            ..text = TextSpan(text: (dataColumnHeadertexts ?? {})[fieldname] ?? fieldname, style: style)
            ..textDirection = TextDirection.ltr
            ..layout(minWidth: 0, maxWidth: maxColumnWidth);
          if (maxFieldWidth < textPainter.width + additonalWidth) {
            maxFieldWidth = textPainter.width + additonalWidth;
          }
          style = TextStyle(fontSize: cellFontSize);
          for (int i = 0; i < data.length; i++) {
            Map<String, dynamic> rowData = data[i];
            textPainter = TextPainter()
              ..text = TextSpan(text: rowData[fieldname].toString().trim(), style: style)
              ..textDirection = TextDirection.ltr
              ..layout(minWidth: 0, maxWidth: maxColumnWidth);
            if (maxFieldWidth < textPainter.width + additonalWidth) {
              maxFieldWidth = textPainter.width + additonalWidth;
            }
            if ((rowHeights[i] ?? defaultRowHeight) < textPainter.height + additionalHeight) {
              rowHeights[i] = textPainter.height + additionalHeight;
            }
          }
          columnWidths.addAll({fieldname: maxFieldWidth});
        }
      }
    });
    return {0: columnWidths, 1: rowHeights};
  }

  static _generateExcel(List<Map<String, dynamic>> data, String fileName, String reportHeaderName) async {
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

    if (widget.controller != null) {
      widget.controller?.generatePdf =
          ({String fileName = "Report.pdf", double scale = 1.0, String reportHeaderText = "Report"}) {
        _generatePDF(fileName: fileName, scale: scale, reportHeaderText: reportHeaderText);
      };
      widget.controller?.generateXls = ({String fileName = "Report.slsx", String reportHeaderText = "Report"}) {
        _generateXls(fileName: fileName, reportHeaderText: reportHeaderText);
      };
      widget.controller?.printPreview = () {
        _generatePDF();
      };
    }
  }

  _generatePDF(
      {bool isPreview = false,
      String fileName = "Report.pdf",
      double scale = 1.0,
      String reportHeaderText = "Report"}) {
    DataGridView._generatePDF(widget.data, reportHeaderText, true, columnWidths, widget.defaultColumnWidth, fileName,
        widget.hiddenDataColumns ?? [],
        scale: scale);
  }

  _generateXls({String fileName = "Report.xlsx", String reportHeaderText = "Report"}) {
    DataGridView._generateExcel(widget.data, fileName, reportHeaderText);
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
    bool isScrollVisible = (kIsWeb ? true : Platform.isLinux || Platform.isMacOS || Platform.isWindows);
    double scrollBarThickness = isScrollVisible ? widget.scrollBarThickness : 5;
    var data = DataGridView._generateColumnWidthAndRowHeight(
      widget.data,
      widget.defaultColumnWidth,
      widget.maxColumnWidth,
      widget.defaultRowHeight,
      widget.hiddenDataColumns,
      widget.dataColumnHeadertexts,
      widget.dataColumnWidths,
      widget.headerFontSize,
      widget.cellFontSize,
    );
    columnWidths = data[0];
    rowHeights = data[1];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.showExportPDFButton
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        child: const Text("Generate PDF"),
                        onPressed: () async {
                          _generatePDF();
                        }),
                  )
                : Container(),
            widget.showExportExcelButton
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: const Text("Generate Excel"),
                      onPressed: () async {
                        _generateXls();
                      },
                    ),
                  )
                : Container(),
          ],
        ),
        //Header
        SizedBox(
          height: widget.defaultRowHeight + 10,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //Row Header Column
              widget.isRowheader
                  ? DataGridViewCell(
                      color: widget.columnHeaderColor,
                      text: "",
                      cellWidth: widget.defaultRowHeaderWidth,
                      cellHeight: widget.defaultRowHeight,
                      style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: widget.headerFontSize,
                        color: widget.textColor,
                      ),
                      onCellPressed: () {},
                      extraCellheight: _extraCellPadding,
                      alignment: widget.headerAlignment,
                    )
                  : Container(),
              //Column Header
              Expanded(
                child: ListView(
                  controller: _headController,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: (widget.additonalColumnsLeft ?? [])
                          .map(
                            (e) => DataGridViewCell(
                              color: widget.columnHeaderColor,
                              text: e.headerText,
                              cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
                              cellHeight: widget.defaultRowHeight,
                              style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: widget.headerFontSize,
                                color: widget.textColor,
                              ),
                              onCellPressed: () {},
                              extraCellheight: _extraCellPadding,
                              alignment: widget.headerAlignment,
                            ),
                          )
                          .toList() +
                      widget.data.first.keys.map(
                        (e) {
                          return DataGridViewCell(
                            color: widget.columnHeaderColor,
                            text: e,
                            cellWidth: columnWidths[e] ?? widget.defaultColumnWidth,
                            visible: !(widget.hiddenDataColumns ?? []).contains(e),
                            cellHeight: widget.defaultRowHeight,
                            style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: widget.headerFontSize,
                              color: widget.textColor,
                            ),
                            onCellPressed: () {},
                            extraCellheight: _extraCellPadding,
                            alignment: widget.headerAlignment,
                          );
                        },
                      ).toList(),
                ),
              ),
              //Right hand side scrollbar leave space
              SizedBox(width: scrollBarThickness),
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
                              color: widget.rowHeaderColor,
                              text: (index + 1).toString(),
                              cellHeight: (rowHeights[index] ?? widget.defaultRowHeight) + _extraCellPadding,
                              cellWidth: widget.defaultColumnWidth,
                              onCellPressed: () {},
                              extraCellheight: _extraCellPadding,
                              style: TextStyle(
                                fontSize: widget.cellFontSize,
                                color: widget.textColor,
                              ),
                              alignment: widget.cellAlignment,
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
                  isAlwaysShown: isScrollVisible,
                  thickness: scrollBarThickness,
                  child: SingleChildScrollView(
                    controller: _bodyController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      //Row
                      width: columnWidths.values.toList().sum +
                          (widget.additonalColumnsLeft ?? [])
                              .map((e) => e.columnWidth ?? widget.defaultColumnWidth)
                              .toList()
                              .sum,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: ListView(
                          //Cells
                          controller: _restColumnsController,
                          physics: const ClampingScrollPhysics(),
                          children: Function.apply(() {
                            List<Widget> ll = [];
                            ll.addAll(List.generate(widget.data.length, (rowIndex) {
                              int cellIndec = -1;
                              return Row(
                                children: (widget.additonalColumnsLeft ?? []).map((e) {
                                      cellIndec++;
                                      return DataGridViewCell(
                                        text: e.cellText ?? "",
                                        color: null,
                                        toolTip: e.toolTip,
                                        cellHeight:
                                            (rowHeights[rowIndex] ?? widget.defaultRowHeight) + _extraCellPadding,
                                        cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
                                        onCellPressed: () {
                                          if (e.onCellPressed != null) {
                                            e.onCellPressed!(
                                                rowIndex,
                                                cellIndec,
                                                (e.onClickReturnFieldNames ?? [])
                                                    .map((cellname) => widget.data[rowIndex][cellname])
                                                    .toList());
                                          }
                                        },
                                        columnType: e.columnType,
                                        iconData: e.iconData,
                                        extraCellheight: _extraCellPadding,
                                        style: TextStyle(
                                          fontSize: widget.cellFontSize,
                                          color: widget.textColor,
                                        ),
                                        alignment: widget.cellAlignment,
                                      );
                                    }).toList() +
                                    List.generate(widget.data.first.keys.length, (cellIndex) {
                                      cellIndec++;
                                      String cellName = widget.data.first.keys.toList()[cellIndex].toString();
                                      return DataGridViewCell(
                                        text: widget.data[rowIndex][cellName].toString().trim(),
                                        color: null,
                                        cellHeight:
                                            (rowHeights[rowIndex] ?? widget.defaultRowHeight) + _extraCellPadding,
                                        cellWidth: columnWidths[cellName] ?? widget.defaultColumnWidth,
                                        visible: !(widget.hiddenDataColumns ?? []).contains(cellName),
                                        onCellPressed: () {},
                                        extraCellheight: _extraCellPadding,
                                        style: TextStyle(
                                          fontSize: widget.cellFontSize,
                                          color: widget.textColor,
                                        ),
                                        alignment: widget.cellAlignment,
                                      );
                                    }),
                              );
                            }));
                            //Last Row
                            ll.add(SizedBox(
                              width: columnWidths.values.toList().sum,
                              height: scrollBarThickness + 3,
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
                width: scrollBarThickness + 3,
                child: Scrollbar(
                  controller: _lastColumnController,
                  isAlwaysShown: isScrollVisible,
                  thickness: scrollBarThickness,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView(
                      controller: _lastColumnController,
                      physics: const ClampingScrollPhysics(),
                      children: List.generate(widget.data.length, (rowIndex) {
                            return SizedBox(
                              height: (rowHeights[rowIndex] ?? widget.defaultRowHeight) + (_extraCellPadding * 2),
                            );
                          }) +
                          [
                            SizedBox(
                              width: scrollBarThickness,
                              height: scrollBarThickness + 3,
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
