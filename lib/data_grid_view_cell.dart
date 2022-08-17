import 'package:data_grid_view/data_grid_view_column.dart';
import 'package:flutter/material.dart';

class DataGridViewCell extends StatelessWidget {
  final String text;
  final String? toolTip;
  final Color? color;
  final double cellWidth;
  final double cellHeight;
  final TextStyle? style;
  final Function onCellPressed;
  final ColumnType columnType;
  final IconData? iconData;
  final double extraCellheight;

  const DataGridViewCell({
    Key? key,
    required this.text,
    this.toolTip,
    this.color,
    required this.cellWidth,
    required this.cellHeight,
    this.style,
    this.iconData,
    this.columnType = ColumnType.textColumn,
    required this.onCellPressed,
    required this.extraCellheight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cellWidth,
      height: cellHeight + extraCellheight,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black12,
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: columnType == ColumnType.textColumn
          ? TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>((states) => const EdgeInsets.all(2)),
              ),
              onPressed: () {
                onCellPressed();
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Tooltip(
                    message: toolTip ?? "", //text == "null" ? "" : text,
                    child: Text(
                      text == "null" ? "" : text,
                      style: style ?? const TextStyle(fontSize: 16.0, color: Colors.black),
                      textAlign: TextAlign.center,
                      // maxLines: 1,
                    ),
                  ),
                ),
              ),
            )
          : columnType == ColumnType.elevatedButtonColumn
              ? Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>((states) => const EdgeInsets.all(2)),
                    ),
                    onPressed: () {
                      onCellPressed();
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Tooltip(
                          message: toolTip ?? "", //text == "null" ? "" : text,
                          child: Text(
                            text == "null" ? "" : text,
                            style: style ?? const TextStyle(fontSize: 16.0, color: Colors.black),
                            textAlign: TextAlign.center,
                            // maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ))
              : Tooltip(
                  message: toolTip ?? "", //text == "null" ? "" : text,
                  child: IconButton(
                    icon: Icon(iconData ?? Icons.error),
                    padding: const EdgeInsets.all(2),
                    onPressed: () {
                      onCellPressed();
                    },
                  ),
                ),
    );
  }
}
