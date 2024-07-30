import 'package:data_grid_view/data_grid_view.dart';
import 'package:flutter/material.dart';

List<Widget> headerCells(
  DataGridView widget,
  double extraCellPadding,
  Map<String, String> sortData,
  Map<String, double> columnWidths,
  Function(Function()) setState,
  Function(BuildContext, String) showSortingPopupMenu,
  Function(String fieldname) onCellPressed,
  double height,
) {
  return (widget.additonalColumnsLeft ?? [])
          .map(
            (e) => DataGridViewCell(
              rowIndex: -1,
              // color: widget.columnHeaderColor,
              text: e.headerText,
              cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
              cellHeight: height,
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: widget.headerFontSize,
                color: widget.headerTextColor ?? widget.textColor,
              ),
              onCellPressed: () {},
              extraCellheight: extraCellPadding,
              alignment: widget.headerAlignment,
              padding: widget.cellPadding,
            ),
          )
          .toList() +
      (widget.data.isEmpty
          ? []
          : widget.data.first.keys.map(
              (fieldname) {
                return DataGridViewCell(
                  rowIndex: -1,
                  // color: widget.columnHeaderColor,
                  text: (sortData.containsKey(fieldname) ? (sortData[fieldname] == "ASC" ? "⬇️ " : "⬆️ ") : "") +
                      ((widget.dataColumnHeadertexts ?? {})[fieldname] ?? fieldname),
                  cellWidth: (columnWidths[fieldname] ?? widget.defaultColumnWidth) + 25,
                  visible: !(widget.hiddenDataColumns ?? []).contains(fieldname),
                  cellHeight: height,
                  style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: widget.headerFontSize,
                    color: widget.headerTextColor ?? widget.textColor,
                  ),
                  onCellPressed: () {
                    onCellPressed(fieldname);
                  },
                  extraCellheight: extraCellPadding,
                  alignment: widget.headerAlignment,
                  padding: widget.cellPadding,
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: SizedBox(
                      width: 20,
                      child: Builder(
                        builder: (context1) => TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          ),
                          onPressed: () {
                            showSortingPopupMenu(context1, fieldname); //
                          },
                          child: Icon(
                            Icons.more_vert,
                            size: 15,
                            color: widget.headerTextColor ?? widget.textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList()) +
      (widget.additonalColumnsRight ?? [])
          .map(
            (e) => DataGridViewCell(
              rowIndex: -1,
              // color: widget.columnHeaderColor,
              text: e.headerText,
              cellWidth: e.columnWidth ?? widget.defaultColumnWidth,
              cellHeight: height,
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: widget.headerFontSize,
                color: widget.textColor,
              ),
              onCellPressed: () {},
              extraCellheight: extraCellPadding,
              alignment: widget.headerAlignment,
              padding: widget.cellPadding,
            ),
          )
          .toList();
}
