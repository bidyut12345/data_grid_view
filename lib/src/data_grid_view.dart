library data_grid_view;

import 'dart:io';
import 'dart:math';

import 'package:data_grid_view/src/data_grid_view_cell.dart';
import 'package:data_grid_view/src/data_grid_view_column.dart';
import 'package:data_grid_view/src/data_grid_view_controller.dart';
import 'package:data_grid_view/src/data_grid_view_header_cells.dart';
import 'package:data_grid_view/src/data_grid_view_html.dart';
import 'package:data_grid_view/src/generate_pdf.dart';
import 'package:data_grid_view/src/generate_rowheight_columnWidth.dart';
import 'package:data_grid_view/src/generate_xls.dart';
import 'package:data_grid_view/src/print_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:collection/collection.dart';
import 'package:pdf/pdf.dart';

export 'data_grid_view_column.dart';
export 'data_grid_view_cell.dart';

double _extraCellPadding = 2.0;

class DataGridView extends StatefulWidget {
  const DataGridView({
    Key? key,
    required this.data,
    this.isFooter = false,
    this.isRowheader = true,
    this.defaultColumnWidth = 20,
    this.defaultRowHeight = 30,
    this.defaultRowHeaderWidth = 45,
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
    this.cellPadding = const EdgeInsets.all(5),
    this.headerPadding = const EdgeInsets.all(5),
    this.footerPadding = const EdgeInsets.all(5),
    this.dataColumnAlignments,
    this.dataColumnPadding,
    this.allowFilter = false,
    this.fieldTypes,
    // this.dateFormat = "dd/MM/yyyy",
    this.autoMobileView = true,
    this.mobileView,
    this.headerTextColor,
    this.footerData,
    this.isLandscapePreview = false,
    this.onPreviewClose,
    this.isHtmlView = false,
    this.hideHorizontalScroll = false,
    this.scrollbarAboveContent = true,
    this.itemsPerPage = 250,
    this.onRowClick,
    this.cellFormat,
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
  final Map<String, String>? footerData;
  final Map<String, Alignment>? dataColumnAlignments;
  final Map<String, EdgeInsets>? dataColumnPadding;
  final Map<String, double>? dataColumnWidths;
  final List<String>? hiddenDataColumns;
  final DataGridViewController? controller;
  final Color textColor;
  final Color? headerTextColor;
  final Alignment headerAlignment;
  final Alignment cellAlignment;
  final EdgeInsets cellPadding;
  final EdgeInsets headerPadding;
  final EdgeInsets footerPadding;
  final Map<String, String>? fieldTypes;

  final double headerFontSize;
  final double cellFontSize;
  final bool allowFilter;
  // final String dateFormat;
// final bool showS
  final bool autoMobileView;
  final bool? mobileView;
  final bool isLandscapePreview;
  final Function? onPreviewClose;
  final bool isHtmlView;
  final bool hideHorizontalScroll;
  final bool scrollbarAboveContent;
  final int itemsPerPage;
  final Function(int rowIndex, Map<String, dynamic>)? onRowClick;
  final String Function(int rowIndex, String fieldName, dynamic value)? cellFormat;
  @override
  State<DataGridView> createState() => _DataGridViewState();
}

class _DataGridViewState extends State<DataGridView> {
  late LinkedScrollControllerGroup horizontalMainScrollController;
  late LinkedScrollControllerGroup verticalMainScrollController;
  late ScrollController columnHeaderVerticalController;
  late ScrollController rowsVerticalController;
  late ScrollController footerVerticalController;

  late ScrollController rowHeaderVerticalController;
  late ScrollController listViewVerticalController;
  late ScrollController verticalScrollbarController;

  List<Map<String, dynamic>> filterdata = [];
  bool isMobileView = false;
  @override
  void initState() {
    super.initState();
    filterdata = widget.data;

    if (!widget.isHtmlView) {
      horizontalMainScrollController = LinkedScrollControllerGroup();
      verticalMainScrollController = LinkedScrollControllerGroup();
      columnHeaderVerticalController = horizontalMainScrollController.addAndGet();
      rowsVerticalController = horizontalMainScrollController.addAndGet();
      footerVerticalController = horizontalMainScrollController.addAndGet();
      rowHeaderVerticalController = verticalMainScrollController.addAndGet();
      listViewVerticalController = verticalMainScrollController.addAndGet();
      verticalScrollbarController = verticalMainScrollController.addAndGet();
    }
    if (widget.controller != null) {
      widget.controller?.resetFilterAndSort = () {
        sortData = {};
        filterIinfo = {};
      };
      widget.controller?.generatePdf =
          ({String fileName = "Report.pdf", double scale = 1.0, String reportHeaderText = "Report"}) {
        _generatePDF(fileName: fileName, scale: scale, reportHeaderText: reportHeaderText);
      };
      widget.controller?.generateXls = ({String fileName = "Report.xlsx", String reportHeaderText = "Report"}) {
        _generateXls(fileName: fileName, reportHeaderText: reportHeaderText);
      };
      widget.controller?.printPreview =
          ({double scale = 1.0, String reportHeaderText = "Report", String reportSubHeaderText = ""}) {
        _printPreview(scale: scale, reportHeaderText: reportHeaderText, reportSubHeaderText: reportSubHeaderText);
      };
    }
    // debugPrint("DataGridView initstate");
    if (widget.autoMobileView) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        isMobileView = true;
      }
    }
    if (widget.mobileView != null) {
      isMobileView = widget.mobileView!;
    }
  }

  _generatePDF(
      {String fileName = "Report.pdf",
      double scale = 1.0,
      String reportHeaderText = "Report",
      String reportSubHeaderText = ""}) {
    savePdf(
        widget,
        filterdata,
        reportHeaderText,
        reportSubHeaderText,
        PdfPageFormat.a4.copyWith(marginLeft: 20, marginTop: 20, marginRight: 20, marginBottom: 20),
        columnWidths,
        widget.defaultColumnWidth,
        fileName,
        widget.hiddenDataColumns ?? [],
        scale: scale);
  }

  _printPreview({double scale = 1.0, String reportHeaderText = "Report", String reportSubHeaderText = ""}) {
    reporttitle = reportHeaderText;
    reportsubtitle = reportSubHeaderText;
    showPrintPreview = !showPrintPreview;
    previewScale = scale;
    setState(() {});
  }

  String filename = "";
  String reporttitle = "";
  String reportsubtitle = "";
  double previewScale = 1.0;
  _generateXls({String fileName = "Report.xlsx", String reportHeaderText = "Report"}) {
    generateExcel(filterdata, fileName, reportHeaderText);
  }

  Map<String, double> columnWidths = {};
  Map<int, double> rowHeights = {};
  double headerHeight = 0;

  // @override
  // void dispose() {
  //   if (!widget.isHtmlView) {
  //     columnHeaderVerticalController.dispose();
  //     rowsVerticalController.dispose();
  //     footerVerticalController.dispose();
  //     rowHeaderVerticalController.dispose();
  //     listViewVerticalController.dispose();
  //     verticalScrollbarController.dispose();
  //   }

  //   super.dispose();
  // }

  bool showPrintPreview = false;
  @override
  Widget build(BuildContext context) {
    // if (!widget.isHtmlView) {
    //   horizontalMainScrollController = LinkedScrollControllerGroup();
    //   verticalMainScrollController = LinkedScrollControllerGroup();
    //   columnHeaderVerticalController = horizontalMainScrollController.addAndGet();
    //   rowsVerticalController = horizontalMainScrollController.addAndGet();
    //   footerVerticalController = horizontalMainScrollController.addAndGet();
    //   rowHeaderVerticalController = verticalMainScrollController.addAndGet();
    //   listViewVerticalController = verticalMainScrollController.addAndGet();
    //   verticalScrollbarController = verticalMainScrollController.addAndGet();
    // }
    // debugPrint("DataGridView Build");
    headerHeight = widget.defaultRowHeight;
    bool isScrollVisible = (kIsWeb ? true : Platform.isLinux || Platform.isMacOS || Platform.isWindows);
    double scrollBarThickness = isScrollVisible ? widget.scrollBarThickness : 5;
    getFiltereData();
    applySort();
    if (showPrintPreview) {
      return PrintPreviewDataGrid(
        dg: widget,
        reportTitle: reporttitle,
        reportSubTitle: reportsubtitle,
        filterData: filterdata,
        columnWidths: columnWidths,
        filename: filename,
        isLandscapePreview: widget.isLandscapePreview,
        scale: previewScale,
        onclose: () {
          showPrintPreview = !showPrintPreview;
          if (widget.onPreviewClose != null) {
            widget.onPreviewClose!();
          }
          setState(() {});
        },
      );
    }
    // if (widget.isHtmlView && filterdata.isNotEmpty) {
    //   return DgWebView(
    //     dg: widget,
    //     filterdata: filterdata,
    //   );
    // }
    if (isMobileView) {
      return ListView.builder(
        itemCount: widget.data.length,
        itemBuilder: (context, rowIndex) {
          var row = widget.data[rowIndex];
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: row.keys.map(
                        (e) {
                          var str = row[e].toString();
                          if (str == "null") {
                            str = "";
                          }
                          if (widget.hiddenDataColumns?.contains(e) ?? false) {
                            return Container();
                          }
                          return Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  e,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(str),
                              ),
                            ],
                          );
                        },
                      ).toList() +
                      [
                        Row(
                          children: widget.additonalColumnsLeft
                                  ?.map(
                                    (e) => Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.all(2),
                                          child: ElevatedButton(
                                            child: Icon(e.iconData),
                                            onPressed: () {
                                              if (e.onCellPressed != null) {
                                                e.onCellPressed!(
                                                    rowIndex,
                                                    0,
                                                    (e.onClickReturnFieldNames ?? [])
                                                        .map((cellname) => filterdata[rowIndex][cellname])
                                                        .toList());
                                              }
                                            },
                                          ),
                                        )),
                                  )
                                  .toList() ??
                              [],
                        ),
                      ],
                ),
              ),
            ),
          );
        },
      );
    }
    if (isMobileView && false) {
      int rowIndex = -1;
      return SingleChildScrollView(
        child: Column(
          children: widget.data.map(
            (row) {
              rowIndex++;
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: row.keys.map(
                            (e) {
                              var str = row[e].toString();
                              if (str == "null") {
                                str = "";
                              }
                              if (widget.hiddenDataColumns?.contains(e) ?? false) {
                                return Container();
                              }
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      e,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(str),
                                  ),
                                ],
                              );
                            },
                          ).toList() +
                          [
                            Row(
                              children: widget.additonalColumnsLeft
                                      ?.map(
                                        (e) => Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding: EdgeInsets.all(2),
                                              child: ElevatedButton(
                                                child: Icon(e.iconData),
                                                onPressed: () {
                                                  if (e.onCellPressed != null) {
                                                    e.onCellPressed!(
                                                        rowIndex,
                                                        0,
                                                        (e.onClickReturnFieldNames ?? [])
                                                            .map((cellname) => filterdata[rowIndex][cellname])
                                                            .toList());
                                                  }
                                                },
                                              ),
                                            )),
                                      )
                                      .toList() ??
                                  [],
                            ),
                          ],
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      );
    }
    return showPages(
      child: Column(
        key: ValueKey("MainData"),
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
                  : Container()
            ],
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, contrains) {
              if ((filterdata.length / widget.itemsPerPage) < currentPageNumber) {
                currentPageNumber = 0;
              }
              var data = generateColumnWidthAndRowHeight(
                  filterdata.sublist(currentPageNumber * widget.itemsPerPage,
                      min((currentPageNumber + 1) * widget.itemsPerPage, filterdata.length)),
                  widget,
                  contrains.maxWidth,
                  scrollBarThickness);
              columnWidths = data[0] ?? {};
              rowHeights = data[1] ?? {};
              headerHeight = data[2] ?? widget.defaultRowHeight;
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (filterdata.isNotEmpty)
                    Column(
                      children: [
                        //Header
                        SizedBox(
                          height: headerHeight,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              //Row Header Column
                              widget.isRowheader
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: widget.columnHeaderColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            // topRight: Radius.circular(5),
                                            bottomLeft: Radius.circular(5),
                                            // bottomRight: Radius.circular(5),
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: DataGridViewCell(
                                          rowIndex: -1,
                                          // color: widget.columnHeaderColor,
                                          text: "",
                                          cellWidth: widget.defaultRowHeaderWidth,
                                          cellHeight: headerHeight,
                                          style: TextStyle(
                                            // fontWeight: FontWeight.bold,
                                            fontSize: widget.headerFontSize,
                                            color: widget.headerTextColor ?? widget.textColor,
                                          ),
                                          extraCellheight: _extraCellPadding,
                                          alignment: widget.headerAlignment,
                                          padding: widget.cellPadding,
                                          isHeader: true,
                                        ),
                                      ),
                                    )
                                  : Container(),
                              //Column Header
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: columnHeaderVerticalController,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: widget.columnHeaderColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: (widget.isRowheader) ? Radius.zero : Radius.circular(5),
                                        topRight: Radius.circular(5),
                                        bottomLeft: (widget.isRowheader) ? Radius.zero : Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Row(
                                      children: [
                                        ...headerCells(
                                          widget,
                                          _extraCellPadding,
                                          sortData,
                                          columnWidths,
                                          setState,
                                          showSortingPopupMenu,
                                          (fieldname) {
                                            if (sortData.containsKey(fieldname)) {
                                              if (sortData[fieldname] == "ASC") {
                                                sortData = {};
                                                sortData.addAll({fieldname: "DESC"});
                                              } else {
                                                sortData = {};
                                              }
                                            } else {
                                              sortData = {};
                                              sortData.addAll({fieldname: "ASC"});
                                            }
                                            setState(() {});
                                          },
                                          headerHeight,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (isScrollVisible && !widget.scrollbarAboveContent) SizedBox(width: scrollBarThickness),
                              //Right hand side scrollbar leave space
                              // SizedBox(width: scrollBarThickness),
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
                                          controller: rowHeaderVerticalController,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          children: [
                                            ...List.generate(
                                                min(filterdata.length - (currentPageNumber * widget.itemsPerPage),
                                                    widget.itemsPerPage), (index_) {
                                              var rowIndex = (currentPageNumber * widget.itemsPerPage) + index_;
                                              // var rheight =
                                              //     (rowHeights[index_] ?? widget.defaultRowHeight) + _extraCellPadding;
                                              var rheight = getRowHeight(rowIndex);
                                              return DataGridViewCell(
                                                rowIndex: rowIndex,
                                                color: widget.rowHeaderColor,
                                                text: (rowIndex + 1).toString(),
                                                cellHeight: rheight,
                                                cellWidth: widget.defaultColumnWidth,
                                                isHeader: true,
                                                extraCellheight: _extraCellPadding,
                                                style: TextStyle(
                                                  fontSize: widget.cellFontSize,
                                                  color: widget.textColor,
                                                ),
                                                alignment: Alignment.center,
                                                padding: widget.cellPadding,
                                              );
                                            }),
                                            ...[
                                              Container(
                                                // color: Colors.red,
                                                height: scrollBarThickness + 3,
                                              )
                                            ]
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              //Rows main data
                              Expanded(
                                child: Stack(
                                  fit: StackFit.loose,
                                  alignment: Alignment.topRight,
                                  children: [
                                    Container(
                                      // color: Colors.red,
                                      alignment: Alignment.topLeft,
                                      padding: EdgeInsets.only(
                                          right: (isScrollVisible && !widget.scrollbarAboveContent)
                                              ? scrollBarThickness
                                              : 0),
                                      child: Scrollbar(
                                        controller: rowsVerticalController,
                                        thumbVisibility: isScrollVisible && !widget.hideHorizontalScroll,
                                        thickness: scrollBarThickness,
                                        child: SingleChildScrollView(
                                          controller: rowsVerticalController,
                                          scrollDirection: Axis.horizontal,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          child: SizedBox(
                                            //Row
                                            width: columnWidths.values.toList().sum +
                                                (columnWidths.values.toList().length * 25) +
                                                (widget.additonalColumnsLeft ?? [])
                                                    .map((e) => e.columnWidth ?? widget.defaultColumnWidth)
                                                    .toList()
                                                    .sum +
                                                (widget.additonalColumnsRight ?? [])
                                                    .map((e) => e.columnWidth ?? widget.defaultColumnWidth)
                                                    .toList()
                                                    .sum, // + ((!widget.hideHorizontalScroll) ? scrollBarThickness : 0),
                                            child: ScrollConfiguration(
                                              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                              child: ListView.builder(
                                                //Cells
                                                // cacheExtent: 5000,
                                                itemCount: min(
                                                        filterdata.length - (currentPageNumber * widget.itemsPerPage),
                                                        widget.itemsPerPage) +
                                                    1,
                                                controller: listViewVerticalController,
                                                physics: const AlwaysScrollableScrollPhysics(),
                                                itemBuilder: (context, rowIndex_) {
                                                  if (rowIndex_ >=
                                                      min(filterdata.length - (currentPageNumber * widget.itemsPerPage),
                                                          widget.itemsPerPage)) {
                                                    return SizedBox(
                                                      // color: Colors.red,
                                                      width: columnWidths.values.toList().sum +
                                                          ((!widget.hideHorizontalScroll) ? scrollBarThickness : 0),
                                                      height: scrollBarThickness + 3,
                                                    );
                                                  }
                                                  var rowIndex = (currentPageNumber * widget.itemsPerPage) + rowIndex_;
                                                  int cellIndec = -1;
                                                  var rheight = getRowHeight(rowIndex);
                                                  return SizedBox(
                                                    // color: Colors.red,
                                                    height: rheight,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        if (widget.onRowClick != null)
                                                          widget.onRowClick!(rowIndex, filterdata[rowIndex]);
                                                      },
                                                      style: TextButton.styleFrom().copyWith(
                                                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                                          (states) {
                                                            if (states.contains(MaterialState.hovered)) {
                                                              return Colors.blue.withOpacity(0.1);
                                                            }
                                                            // else if (states.contains(MaterialState.pressed)) {
                                                            //   return Colors.yellow;
                                                            // }
                                                            return Colors.transparent;
                                                          },
                                                        ),
                                                        // foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                                                        //   (states) {
                                                        //     if (states.contains(MaterialState.hovered)) {
                                                        //       return Colors.green;
                                                        //     }
                                                        //     return Colors.black;
                                                        //   },
                                                        // ),
                                                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                                                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(1))),
                                                      ),
                                                      child: Row(
                                                        children:
                                                            //Additional Column Left Cells
                                                            [
                                                          ...(widget.additonalColumnsLeft ?? []).map((e) {
                                                            cellIndec++;
                                                            return DataGridViewCell(
                                                              rowIndex: rowIndex,
                                                              text: e.cellText == null
                                                                  ? ""
                                                                  : (e.cellText!(rowIndex) ?? ""),
                                                              color: null,
                                                              toolTip: e.toolTip,
                                                              cellHeight: rheight,
                                                              cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
                                                              onCellPressed: e.onCellPressed == null
                                                                  ? null
                                                                  : () {
                                                                      if (e.onCellPressed != null) {
                                                                        e.onCellPressed!(
                                                                            rowIndex,
                                                                            cellIndec,
                                                                            (e.onClickReturnFieldNames ?? [])
                                                                                .map((cellname) =>
                                                                                    filterdata[rowIndex][cellname])
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
                                                              alignment:
                                                                  widget.dataColumnAlignments?[e.columnName ?? ""] ??
                                                                      widget.cellAlignment,
                                                              padding: widget.cellPadding,
                                                            );
                                                          }),
                                                          //Main Cells
                                                          ...List.generate(filterdata.first.keys.length, (cellIndex) {
                                                            cellIndec++;
                                                            String cellName =
                                                                filterdata.first.keys.toList()[cellIndex].toString();
                                                            if ((widget.hiddenDataColumns ?? []).contains(cellName)) {
                                                              return Container();
                                                            }
                                                            return DataGridViewCell(
                                                              rowIndex: rowIndex,
                                                              text: widget.cellFormat == null
                                                                  ? filterdata[rowIndex][cellName].toString().trim()
                                                                  : widget.cellFormat!(rowIndex, cellName,
                                                                      filterdata[rowIndex][cellName]),
                                                              color: null,
                                                              cellHeight: rheight,
                                                              cellWidth: (columnWidths[cellName] ??
                                                                      widget.defaultColumnWidth) +
                                                                  25,
                                                              visible:
                                                                  !(widget.hiddenDataColumns ?? []).contains(cellName),
                                                              extraCellheight: _extraCellPadding,
                                                              style: TextStyle(
                                                                fontSize: widget.cellFontSize,
                                                                color: widget.textColor,
                                                              ),
                                                              alignment: widget.dataColumnAlignments?[cellName] ??
                                                                  widget.cellAlignment,
                                                              padding: widget.cellPadding,
                                                            );
                                                          }).map((e) =>
                                                              widget.hideHorizontalScroll ? Expanded(child: e) : e),
                                                          //Additional Columns Right Cells
                                                          ...(widget.additonalColumnsRight ?? []).map((e) {
                                                            cellIndec++;
                                                            return DataGridViewCell(
                                                              rowIndex: rowIndex,
                                                              text: e.cellText == null
                                                                  ? ""
                                                                  : (e.cellText!(rowIndex) ?? ""),
                                                              color: null,
                                                              toolTip: e.toolTip,
                                                              cellHeight: rheight,
                                                              cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
                                                              onCellPressed: e.onCellPressed == null
                                                                  ? null
                                                                  : () {
                                                                      if (e.onCellPressed != null) {
                                                                        e.onCellPressed!(
                                                                            rowIndex,
                                                                            cellIndec,
                                                                            (e.onClickReturnFieldNames ?? [])
                                                                                .map((cellname) =>
                                                                                    filterdata[rowIndex][cellname])
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
                                                              alignment:
                                                                  widget.dataColumnAlignments?[e.columnName ?? ""] ??
                                                                      widget.cellAlignment,
                                                              padding: widget.cellPadding,
                                                            );
                                                          }),

                                                          //Right hand side scrollbar leave space
                                                        ],
                                                      ),
                                                    ),
                                                  );

                                                  // List<Widget> ll = [];

                                                  // ll.addAll(List.generate(
                                                  //     , (rowIndex_) {
                                                  //   }));
                                                  // //Last Row
                                                  // ll.add();
                                                  // return ll;
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    //Verical scroll spacer
                                    Container(
                                      // color: Colors.green.withOpacity(0.1),
                                      width: scrollBarThickness + 3,
                                      child: ScrollConfiguration(
                                        behavior: ScrollConfiguration.of(context)
                                            .copyWith(scrollbars: !widget.hideHorizontalScroll),
                                        child: Scrollbar(
                                          controller: verticalScrollbarController,
                                          thumbVisibility: isScrollVisible,
                                          thickness: scrollBarThickness,
                                          child: ScrollConfiguration(
                                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                            child: ListView(
                                              controller: verticalScrollbarController,
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              children: List.generate(
                                                      min(filterdata.length - (currentPageNumber * widget.itemsPerPage),
                                                          widget.itemsPerPage), (rowIndex_) {
                                                    var rowIndex =
                                                        (currentPageNumber * widget.itemsPerPage) + rowIndex_;
                                                    return SizedBox(
                                                      height: (rowHeights[rowIndex] ?? widget.defaultRowHeight),
                                                      // height: (rowHeights[rowIndex] ?? widget.defaultRowHeight) +
                                                      //     (_extraCellPadding * 2),
                                                    );
                                                  }) +
                                                  [
                                                    SizedBox(
                                                      width: ((!widget.hideHorizontalScroll) ? scrollBarThickness : 0),
                                                      height: scrollBarThickness + 3,
                                                    )
                                                  ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                          //   data: filterdata,
                          //   isRowHeader: widget.isRowheader,
                          // ),
                        ),
                        //Footer
                        if (widget.isFooter)
                          SizedBox(
                            height: widget.defaultRowHeight + 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                //Row Header Column Footer
                                widget.isRowheader
                                    ? DataGridViewCell(
                                        rowIndex: -1,
                                        color: widget.columnHeaderColor,
                                        text: "",
                                        cellWidth: widget.defaultRowHeaderWidth,
                                        cellHeight: widget.defaultRowHeight,
                                        style: TextStyle(
                                          // fontWeight: FontWeight.bold,
                                          fontSize: widget.headerFontSize,
                                          color: widget.headerTextColor ?? widget.textColor,
                                        ),
                                        extraCellheight: _extraCellPadding,
                                        alignment: widget.cellAlignment,
                                        padding: widget.cellPadding,
                                      )
                                    : Container(),
                                //Column Footer
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: footerVerticalController,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: widget.columnHeaderColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Row(
                                        children: [
                                          ...(widget.additonalColumnsLeft ?? []).map(
                                            (e) => DataGridViewCell(
                                              rowIndex: -1,
                                              // color: widget.columnHeaderColor,
                                              text: "",
                                              cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
                                              cellHeight: widget.defaultRowHeight,
                                              style: TextStyle(
                                                // fontWeight: FontWeight.bold,
                                                fontSize: widget.headerFontSize,
                                                color: widget.headerTextColor ?? widget.textColor,
                                              ),
                                              extraCellheight: _extraCellPadding,
                                              alignment: widget.dataColumnAlignments?[e.columnName ?? ""] ??
                                                  widget.cellAlignment,
                                              padding: widget.footerPadding,
                                            ),
                                          ),
                                          ...(widget.data.isEmpty
                                              ? []
                                              : widget.data.first.keys.map(
                                                  (fieldname) {
                                                    return DataGridViewCell(
                                                      rowIndex: -1,
                                                      // color: widget.columnHeaderColor,
                                                      text: ((widget.footerData ?? {})[fieldname] ?? ""),
                                                      cellWidth:
                                                          (columnWidths[fieldname] ?? widget.defaultColumnWidth) + 25,
                                                      visible: !(widget.hiddenDataColumns ?? []).contains(fieldname),
                                                      cellHeight: widget.defaultRowHeight,
                                                      style: TextStyle(
                                                        // fontWeight: FontWeight.bold,
                                                        fontSize: widget.headerFontSize,
                                                        color: widget.headerTextColor ?? widget.textColor,
                                                      ),
                                                      extraCellheight: _extraCellPadding,
                                                      alignment: widget.dataColumnAlignments?[fieldname] ??
                                                          widget.cellAlignment,
                                                      padding: widget.footerPadding,
                                                    );
                                                  },
                                                )),
                                          ...(widget.additonalColumnsRight ?? []).map(
                                            (e) => DataGridViewCell(
                                              rowIndex: -1,
                                              // color: widget.columnHeaderColor,
                                              text: "",
                                              cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
                                              cellHeight: widget.defaultRowHeight,
                                              style: TextStyle(
                                                // fontWeight: FontWeight.bold,
                                                fontSize: widget.headerFontSize,
                                                color: widget.textColor,
                                              ),
                                              extraCellheight: _extraCellPadding,
                                              alignment: widget.headerAlignment,
                                              padding: widget.footerPadding,
                                            ),
                                          ),
                                          SizedBox(width: scrollBarThickness),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //Right hand side scrollbar leave space
                                // SizedBox(width: scrollBarThickness),
                              ],
                            ),
                          ),
                      ],
                    ),
                  // Align(
                  //     alignment: Alignment.topLeft,
                  //     child: Text(
                  //       contrains.maxWidth.toString() + " - " + columnWidths.values.sum.toString(),
                  //       style: TextStyle(color: Colors.green, fontSize: 8),
                  //     )),
                ],
              );
            }),
          ),
          // DataGridViewHeader(
          //   scrollController: _footController,
          // ),
        ],
      ),
    );
  }

  double getRowHeight(int rowIndex) {
    return (rowHeights[rowIndex] ?? widget.defaultRowHeight) + _extraCellPadding;
  }

  int currentPageNumber = 0;
  Widget showPages({required Widget child}) {
    return Column(
      children: [
        Expanded(child: child),
        if (filterdata.length > widget.itemsPerPage)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                          (filterdata.length / widget.itemsPerPage).ceil(),
                          (index) => IconButton(
                            onPressed: () {
                              setState(() {
                                currentPageNumber = index;
                              });
                            },
                            style:
                                IconButton.styleFrom(backgroundColor: index == currentPageNumber ? Colors.red : null),
                            icon: Text(
                              (index + 1).toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Map<String, Map<String, bool>> filterIinfo = {};
  Map<String, String> sortData = {};
  showSortingPopupMenu(BuildContext context1, String fieldname) {
    Offset position = (context1.findRenderObject() as RenderBox).localToGlobal(Offset.zero);
    showMenu(
      context: context1,
      position: RelativeRect.fromLTRB(position.dx, position.dy + 30, 100000, 0),
      items: [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              sortData[fieldname] == "ASC" ? const Icon(Icons.check_outlined) : const SizedBox(width: 25),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_downward),
              const SizedBox(width: 5),
              const Text("Sort Ascending"),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              sortData[fieldname] == "DESC" ? const Icon(Icons.check_outlined) : const SizedBox(width: 25),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_upward),
              const SizedBox(width: 5),
              const Text("Sort Descending"),
            ],
          ),
        ),
        if (sortData.containsKey(fieldname))
          const PopupMenuItem(
            value: 3,
            child: Row(
              children: [
                SizedBox(width: 25),
                SizedBox(width: 5),
                Icon(Icons.sort_by_alpha_outlined),
                SizedBox(width: 5),
                Text("Reset Sort"),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              SizedBox(width: 25),
              SizedBox(width: 5),
              Icon(Icons.filter_alt),
              SizedBox(width: 5),
              Text("Filter"),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      switch (value) {
        case 1:
          sortData.remove(fieldname);
          sortData.addAll({fieldname: "ASC"});
          var keys = List.from(sortData.keys);
          for (var key in keys) {
            if (key != fieldname) sortData.remove(key);
          }
          setState(() {});
          break;
        case 2:
          sortData.remove(fieldname);
          sortData.addAll({fieldname: "DESC"});
          var keys = List.from(sortData.keys);
          for (var key in keys) {
            if (key != fieldname) sortData.remove(key);
          }
          setState(() {});
          break;
        case 3:
          sortData.remove(fieldname);
          var keys = List.from(sortData.keys);
          for (var key in keys) {
            if (key != fieldname) sortData.remove(key);
          }
          setState(() {});
          break;
        case 4:
          applyFilter(fieldname);
          break;
      }
    });
  }

  applyFilter(String columnName) {
    List<String> discintValues = widget.data.map((e) => e[columnName].toString()).toList();
    var seen = <String>{};
    discintValues = discintValues.where((country) => seen.add(country)).toList();

    // Map<String, bool> selectedValues =
    //     filterIinfo[columnName] ?? {for (var v in discintValues) (v.isEmpty ? " " : v): true};
    Map<String, bool> selectedValues = filterIinfo[columnName] ?? {};
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Column(
              children: [
                Text(columnName),
                const Divider(),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: discintValues
                    .map((e) => Row(
                          children: [
                            Checkbox(
                                value: selectedValues[e] ?? true,
                                onChanged: (value) {
                                  if (value ?? true) {
                                    selectedValues.remove(e);
                                  } else {
                                    selectedValues.addAll({e: false});
                                  }
                                  // selectedValues[e] = value ?? true;
                                  setState(() {});
                                }),
                            Text(e),
                          ],
                        ))
                    .toList(),
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    discintValues.forEach((key) {
                      selectedValues = {};
                      setState(() {});
                    });
                  },
                  child: const Text("Select All")),
              ElevatedButton(
                  onPressed: () {
                    discintValues.forEach((key) {
                      selectedValues.addAll({key: false});
                      setState(() {});
                    });
                  },
                  child: const Text("Select None")),
              ElevatedButton(
                  onPressed: () {
                    filterIinfo[columnName] == null
                        ? filterIinfo.addAll({columnName: selectedValues})
                        : filterIinfo[columnName] = selectedValues;
                    Navigator.pop(context, "APPLY");
                  },
                  child: const Text("Apply Filter")),
            ],
          );
        });
      },
    ).then((value) {
      if (value == "APPLY") {
        getFiltereData();
        setState(() {});
      }
    });
  }

  getFiltereData() {
    filterdata = List<Map<String, dynamic>>.from(widget.data);
    for (String colname in filterIinfo.keys) {
      List<dynamic> unwantedValue =
          filterIinfo[colname]?.keys.where((element) => filterIinfo[colname]![element] == false).toList() ?? [];
      filterdata = filterdata.where((element) => !unwantedValue.contains(element[colname])).toList();
    }
  }

  applySort() {
    getFiltereData();
    if (sortData.isEmpty) return;
    String colName = sortData.keys.first;
    String type = sortData.values.first;
    if (["ASC", "DESC"].contains(type)) {
      filterdata.sort((m1, m2) {
        if ((widget.fieldTypes?.containsKey(colName) ?? false) && widget.fieldTypes![colName] == "NUMBER") {
          if (type == "ASC") {
            return double.parse(m1[colName].toString()).compareTo(double.parse(m2[colName].toString()));
          } else {
            return double.parse(m2[colName].toString()).compareTo(double.parse(m1[colName].toString()));
          }
        } else if ((widget.fieldTypes?.containsKey(colName) ?? false) && widget.fieldTypes![colName] == "DATE") {
          if (type == "ASC") {
            // return intl.DateFormat(widget.dateFormat).parse(m1[colName].toString()).compareTo(intl.DateFormat(widget.dateFormat).parse(m2[colName].toString()));
            return DateTime.parse(m1[colName].toString()).compareTo(DateTime.parse(m2[colName].toString()));
          } else {
            // return intl.DateFormat(widget.dateFormat).parse(m2[colName].toString()).compareTo(intl.DateFormat(widget.dateFormat).parse(m1[colName].toString()));
            return DateTime.parse(m2[colName].toString()).compareTo(DateTime.parse(m1[colName].toString()));
          }
        } else {
          if (type == "ASC") {
            // return m1[colName].toString().toUpperCase().compareTo(m2[colName].toString().toUpperCase());
            return m1[colName].compareTo(m2[colName]);
          } else {
            // return m2[colName].toString().toUpperCase().compareTo(m1[colName].toString().toUpperCase());
            return m2[colName].compareTo(m1[colName]);
          }
        }
      });
    }
    // setState(() {});
  }
}
