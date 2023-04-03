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
  final bool visible;
  final Alignment alignment;

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
    required this.alignment,
    this.visible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return !visible
        ? Container()
        : Container(
            width: cellWidth,
            height: cellHeight + extraCellheight,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: Colors.black12,
                width: 1.0,
              ),
            ),
            alignment: alignment,
            child: columnType == ColumnType.textColumn
                ? TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>((states) => const EdgeInsets.all(2)),
                    ),
                    onPressed: () {
                      onCellPressed();
                    },
                    child: Align(
                      alignment: alignment,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Tooltip(
                          message: toolTip ?? "",
                          child: Text(
                            text == "null" ? "" : text,
                            style: style ??
                                const TextStyle(
                                  fontSize: 14.0,
                                  color: Color.fromARGB(255, 39, 39, 39),
                                ),
                            textAlign: ([Alignment.bottomCenter, Alignment.topCenter, Alignment.center].contains(alignment))
                                ? TextAlign.center
                                : ([Alignment.topLeft, Alignment.bottomLeft, Alignment.centerLeft].contains(alignment))
                                    ? TextAlign.left
                                    : TextAlign.right,
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
                          child: Align(
                            alignment: alignment,
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Tooltip(
                                message: toolTip ?? "",
                                child: Text(
                                  text == "null" ? "" : text,
                                  style: style ?? const TextStyle(fontSize: 16.0, color: Colors.black),
                                  textAlign: ([Alignment.bottomCenter, Alignment.topCenter, Alignment.center].contains(alignment))
                                      ? TextAlign.center
                                      : ([Alignment.topLeft, Alignment.bottomLeft, Alignment.centerLeft].contains(alignment))
                                          ? TextAlign.left
                                          : TextAlign.right,
                                ),
                              ),
                            ),
                          ),
                        ))
                    : Tooltip(
                        message: toolTip ?? "",
                        child: IconButton(
                          icon: Icon(
                            iconData ?? Icons.error,
                            size: 18,
                          ),
                          padding: const EdgeInsets.all(2),
                          onPressed: () {
                            onCellPressed();
                          },
                        ),
                      ),
          );
  }
}
