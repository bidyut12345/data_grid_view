import 'dart:ffi';

import 'package:data_grid_view/data_grid_view.dart';
import 'package:data_grid_view/src/generate_pdf.dart';
import 'package:data_grid_view/src/get_save_file_path.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PrintPreviewDataGrid extends StatefulWidget {
  const PrintPreviewDataGrid(
      {Key? key,
      required this.dg,
      required this.reportTitle,
      required this.filterData,
      required this.columnWidths,
      required this.filename,
      required this.onclose})
      : super(key: key);

  final DataGridView dg;
  final String reportTitle;
  final String filename;
  final List<Map<String, dynamic>> filterData;
  final Map<String, double> columnWidths;
  final Function onclose;
  @override
  State<PrintPreviewDataGrid> createState() => _PrintPreviewDataGridState();
}

class _PrintPreviewDataGridState extends State<PrintPreviewDataGrid> {
  double margin = 35.0;
  late PdfPageFormat dataPageFormat;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataPageFormat =
        PdfPageFormat.a4.copyWith(marginLeft: margin, marginTop: margin, marginRight: margin, marginBottom: margin);
  }

  @override
  Widget build(BuildContext context) {
    // (!kIsWeb && Platform.isAndroid)
    //     ? ValueListenableBuilder(
    //         valueListenable: vt,
    //         builder: (context, value, child) {
    //           return (value == null
    //               ? Container()
    //               : Column(
    //                   children: [
    //                     Expanded(child: SfPdfViewer.memory(value)),
    //                     // ElevatedButton(
    //                     //     onPressed: () async {
    //                     //       await ReportPDFGenerator.savetodownloads(
    //                     //           pageFormat,
    //                     //           "${widget.reportTitle} ${DateFormat("dd MMM yyyy").format(widget.reportDate)}.pdf",
    //                     //           widget.reports,
    //                     //           context);
    //                     //     },
    //                     //     child: const Text("Download"))
    //                   ],
    //                 )); //
    //         },
    //       )
    //     :
    return PdfPreview(
      pdfFileName: widget.reportTitle,
      initialPageFormat: dataPageFormat,
      canChangePageFormat: true,
      allowSharing: false,
      actions: [
        IconButton.filled(
          onPressed: () async {
            String? path = await getSaveFilePath("${widget.reportTitle}.pdf");
            if (path == null) return;
            await savePdf(widget.dg, widget.filterData, widget.reportTitle, dataPageFormat, widget.columnWidths,
                widget.dg.defaultColumnWidth, path, widget.dg.hiddenDataColumns ?? []);
          },
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download),
            ],
          ),
        ),
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            widget.onclose();
          },
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.close),
            ],
          ),
        ),
      ],
      pageFormats: {
        "Letter": PdfPageFormat.letter
            .copyWith(marginLeft: margin, marginTop: margin, marginRight: margin, marginBottom: margin),
        "Legal": PdfPageFormat.legal
            .copyWith(marginLeft: margin, marginTop: margin, marginRight: margin, marginBottom: margin),
        "A3":
            PdfPageFormat.a3.copyWith(marginLeft: margin, marginTop: margin, marginRight: margin, marginBottom: margin),
        "A4":
            PdfPageFormat.a4.copyWith(marginLeft: margin, marginTop: margin, marginRight: margin, marginBottom: margin),
        "A5":
            PdfPageFormat.a5.copyWith(marginLeft: margin, marginTop: margin, marginRight: margin, marginBottom: margin),
      },
      allowPrinting: true,
      canDebug: false,
      canChangeOrientation: true,
      build: (data) async {
        return await generatePdf(widget.dg, widget.filterData, widget.reportTitle, data, widget.columnWidths,
                widget.dg.defaultColumnWidth, widget.dg.hiddenDataColumns ?? [])
            .save();
      },
      onPageFormatChanged: (data) {
        dataPageFormat = data;
      },
    );
  }
}
