import 'dart:io';

import 'package:data_grid_view/data_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

pw.Alignment getPwAlignment(Alignment aln) {
  if (aln == Alignment.center) {
    return pw.Alignment.center;
  } else if (aln == Alignment.centerLeft) {
    return pw.Alignment.centerLeft;
  } else if (aln == Alignment.centerRight) {
    return pw.Alignment.centerRight;
  } else if (aln == Alignment.bottomCenter) {
    return pw.Alignment.bottomCenter;
  } else if (aln == Alignment.bottomLeft) {
    return pw.Alignment.bottomLeft;
  } else if (aln == Alignment.bottomRight) {
    return pw.Alignment.bottomRight;
  } else if (aln == Alignment.topCenter) {
    return pw.Alignment.topCenter;
  } else if (aln == Alignment.topLeft) {
    return pw.Alignment.topLeft;
  } else if (aln == Alignment.topRight) {
    return pw.Alignment.topRight;
  }
  return pw.Alignment.center;
}

pw.Document generatePdf(
  DataGridView widget,
  List<Map<String, dynamic>> data,
  String header,
  PdfPageFormat pageFormat,
  Map<String, double> columnWidths,
  double defaultColumnWidth,
  List<String> hiddenDataColumns, {
  double scale = 1.0,
}) {
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
  // var pageFormat = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
  var newPageFomat = PdfPageFormat(
    pageFormat.width,
    pageFormat.height,
    marginAll: 10,
  );
  newPageFomat = pageFormat;
  pdf.addPage(
    pw.MultiPage(
      maxPages: 10000,
      pageFormat: newPageFomat,
      header: (context) =>
          pw.Padding(padding: const pw.EdgeInsets.all(0), child: pw.Text(header, textScaleFactor: 1.5)),
      footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Padding(
              padding: const pw.EdgeInsets.all(0),
              child: pw.Text("Printed on ${DateTime.now().toString().split(".").first}",
                  style: pw.TextStyle(fontSize: 6)))),
      build: (pw.Context context) {
        return [
          pw.TableHelper.fromTextArray(
            cellStyle: pw.TextStyle(fontSize: 7 * scale),
            headerStyle: pw.TextStyle(fontSize: 7 * scale, fontWeight: pw.FontWeight.bold),
            headerAlignment: getPwAlignment(widget.headerAlignment),
            headerAlignments: {
              for (var i in List.generate(data.first.keys.length, (index) => index))
                i: getPwAlignment(widget.headerAlignment)
            },
            cellAlignment: pw.Alignment.center,
            cellAlignments: {
              for (var i in List.generate(data.first.keys.length, (index) => index))
                i: getPwAlignment(widget.dataColumnAlignments?[data.first.keys.toList()[i]] ?? widget.cellAlignment)
            },
            cellPadding: pw.EdgeInsets.all(2 * scale),
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey700),
              // verticalInside: pw.BorderSide(width: 0.5),
              top: pw.BorderSide(width: 0.5),
              // left: pw.BorderSide(width: 0.5),
              // right: pw.BorderSide(width: 0.5),
              bottom: pw.BorderSide(width: 0.5),
            ),
            columnWidths: widths,
            context: context,
            data: [
              ...[data.first.keys.toList()],
              ...data.map(
                (e) => (e.values
                    .toList()
                    .map(
                      (e) => e.toString() == "null" ? "" : e.toString(),
                    )
                    .toList()),
              ),
              ...[data.first.keys.map((e) => widget.footerData?[e] ?? "").toList()]
            ],
          ),
        ]; // Center
      },
    ),
  );
  return pdf;
}

savePdf(
  DataGridView widget,
  List<Map<String, dynamic>> data,
  String header,
  PdfPageFormat pageFormat,
  Map<String, double> columnWidths,
  double defaultColumnWidth,
  String filename,
  List<String> hiddenDataColumns, {
  double scale = 1.0,
}) async {
  if (kIsWeb) {
    await Printing.sharePdf(
        bytes: await generatePdf(widget, data, header, pageFormat, columnWidths, defaultColumnWidth, hiddenDataColumns,
                scale: scale)
            .save(),
        filename: filename);
  } else {
    final file = File(filename);
    await file.writeAsBytes(await generatePdf(
            widget, data, header, pageFormat, columnWidths, defaultColumnWidth, hiddenDataColumns,
            scale: scale)
        .save());
  }
}
