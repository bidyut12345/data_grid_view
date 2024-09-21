import 'package:data_grid_view/src/data_grid_view_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// class DataGridViewCell extends StatelessWidget {
//   final String text;
//   final String? toolTip;
//   final Color? color;
//   final double cellWidth;
//   final double cellHeight;
//   final TextStyle? style;
//   final Function onCellPressed;
//   final ColumnType columnType;
//   final IconData? iconData;
//   final double extraCellheight;
//   final bool visible;
//   final Alignment alignment;
//   final EdgeInsets padding;
//   final Widget? child;
//   final Widget? trailing;
//   final int rowIndex;

//   const DataGridViewCell({
//     Key? key,
//     required this.text,
//     this.toolTip,
//     this.color,
//     required this.cellWidth,
//     required this.cellHeight,
//     this.style,
//     this.iconData,
//     this.columnType = ColumnType.textColumn,
//     required this.onCellPressed,
//     required this.extraCellheight,
//     required this.alignment,
//     this.visible = true,
//     required this.padding,
//     this.child,
//     this.trailing,
//     required this.rowIndex,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: color,
//       child: !visible
//           ? Container()
//           : Container(
//               width: cellWidth,
//               height: cellHeight + extraCellheight,
//               decoration: BoxDecoration(
//                 color: rowIndex >= 0 && rowIndex % 2 == 1
//                     ? const Color.fromARGB(255, 129, 129, 129).withOpacity(0.07)
//                     : null,
//                 border: const Border.symmetric(
//                   horizontal: BorderSide(
//                     color: Colors.grey,
//                     width: 0.1,
//                   ),
//                 ),
//               ),
//               alignment: alignment,
//               child: Stack(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: columnType == ColumnType.textColumn
//                             ? Container(
//                                 // style: ButtonStyle(
//                                 //   padding: MaterialStateProperty.all(const EdgeInsets.all(2)),
//                                 //   shape: MaterialStateProperty.all(
//                                 //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
//                                 // ),
//                                 // onPressed: () {
//                                 //   onCellPressed();
//                                 // },
//                                 child: Align(
//                                   alignment: alignment,
//                                   child: Padding(
//                                     padding: padding,
//                                     child: Tooltip(
//                                       message: toolTip ?? "",
//                                       child: Text(
//                                         text == "null" ? "" : text,
//                                         style: style ??
//                                             const TextStyle(
//                                               fontSize: 14.0,
//                                               color: Color.fromARGB(255, 39, 39, 39),
//                                             ),
//                                         textAlign: ([Alignment.bottomCenter, Alignment.topCenter, Alignment.center]
//                                                 .contains(alignment))
//                                             ? TextAlign.center
//                                             : ([Alignment.topLeft, Alignment.bottomLeft, Alignment.centerLeft]
//                                                     .contains(alignment))
//                                                 ? TextAlign.left
//                                                 : TextAlign.right,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : columnType == ColumnType.elevatedButtonColumn
//                                 ? Padding(
//                                     padding: const EdgeInsets.all(0.0),
//                                     child: ElevatedButton(
//                                       style: ButtonStyle(
//                                         padding: MaterialStateProperty.all(EdgeInsets.all(2)),
//                                         shape: MaterialStateProperty.all(
//                                             RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
//                                       ),
//                                       onPressed: () {
//                                         onCellPressed();
//                                       },
//                                       child: Align(
//                                         alignment: alignment,
//                                         child: Padding(
//                                           padding: padding,
//                                           child: Tooltip(
//                                             message: toolTip ?? "",
//                                             child: Text(
//                                               text == "null" ? "" : text,
//                                               style: style ?? const TextStyle(fontSize: 16.0, color: Colors.black),
//                                               textAlign: ([
//                                                 Alignment.bottomCenter,
//                                                 Alignment.topCenter,
//                                                 Alignment.center
//                                               ].contains(alignment))
//                                                   ? TextAlign.center
//                                                   : ([Alignment.topLeft, Alignment.bottomLeft, Alignment.centerLeft]
//                                                           .contains(alignment))
//                                                       ? TextAlign.left
//                                                       : TextAlign.right,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ))
//                                 : Tooltip(
//                                     message: toolTip ?? "",
//                                     child: IconButton(
//                                       icon: Icon(
//                                         iconData ?? Icons.error,
//                                         size: 18,
//                                       ),
//                                       padding: const EdgeInsets.all(2),
//                                       onPressed: () {
//                                         onCellPressed();
//                                       },
//                                     ),
//                                   ),
//                       ),
//                       if (trailing != null) trailing!,
//                     ],
//                   ),
//                   if (child != null) Align(alignment: Alignment.centerRight, child: child!),
//                   // Align(
//                   //     alignment: Alignment.topRight,
//                   //     child: Text(
//                   //       widget.cellWidth.toString() + " - " + contrains.maxWidth.toString(),
//                   //       style: TextStyle(color: Colors.red, fontSize: 8),
//                   //     )),
//                 ],
//               ),
//             ),
//     );
//   }
// }

class DataGridViewCell extends StatefulWidget {
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
  final EdgeInsets padding;
  final Widget? child;
  final Widget? trailing;
  final int rowIndex;

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
    required this.padding,
    this.child,
    this.trailing,
    required this.rowIndex,
  }) : super(key: key);

  @override
  State<DataGridViewCell> createState() => _DataGridViewCellState();
}

class _DataGridViewCellState extends State<DataGridViewCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.color,
      child: !widget.visible
          ? Container()
          : Container(
              width: widget.cellWidth,
              height: widget.cellHeight + widget.extraCellheight,
              decoration: BoxDecoration(
                color: widget.rowIndex >= 0 && widget.rowIndex % 2 == 1
                    ? const Color.fromARGB(255, 129, 129, 129).withOpacity(0.07)
                    : null,
                border: const Border.symmetric(
                  horizontal: BorderSide(
                    color: Colors.grey,
                    width: 0.1,
                  ),
                ),
              ),
              alignment: widget.alignment,
              child: GestureDetector(
                onSecondaryTap: () {
                  showSortingPopupMenu(context, widget.text == "null" ? "" : widget.text);
                },
                // onTapDown: _storePosition,
                onSecondaryTapDown: _storePosition,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: widget.columnType == ColumnType.textColumn
                              ? TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(const EdgeInsets.all(2)),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                                  ),
                                  onPressed: () {
                                    widget.onCellPressed();
                                  },
                                  child: Align(
                                    alignment: widget.alignment,
                                    child: Padding(
                                      padding: widget.padding,
                                      child: Tooltip(
                                        message: widget.toolTip ?? "",
                                        child: Text(
                                          widget.text == "null" ? "" : widget.text,
                                          style: widget.style ??
                                              const TextStyle(
                                                fontSize: 14.0,
                                                color: Color.fromARGB(255, 39, 39, 39),
                                              ),
                                          textAlign: ([Alignment.bottomCenter, Alignment.topCenter, Alignment.center]
                                                  .contains(widget.alignment))
                                              ? TextAlign.center
                                              : ([Alignment.topLeft, Alignment.bottomLeft, Alignment.centerLeft]
                                                      .contains(widget.alignment))
                                                  ? TextAlign.left
                                                  : TextAlign.right,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : widget.columnType == ColumnType.elevatedButtonColumn
                                  ? Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(EdgeInsets.all(2)),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))),
                                        ),
                                        onPressed: () {
                                          widget.onCellPressed();
                                        },
                                        child: Align(
                                          alignment: widget.alignment,
                                          child: Padding(
                                            padding: widget.padding,
                                            child: Tooltip(
                                              message: widget.toolTip ?? "",
                                              child: Text(
                                                widget.text == "null" ? "" : widget.text,
                                                style: widget.style ??
                                                    const TextStyle(fontSize: 16.0, color: Colors.black),
                                                textAlign: ([
                                                  Alignment.bottomCenter,
                                                  Alignment.topCenter,
                                                  Alignment.center
                                                ].contains(widget.alignment))
                                                    ? TextAlign.center
                                                    : ([Alignment.topLeft, Alignment.bottomLeft, Alignment.centerLeft]
                                                            .contains(widget.alignment))
                                                        ? TextAlign.left
                                                        : TextAlign.right,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                                  : Tooltip(
                                      message: widget.toolTip ?? "",
                                      child: IconButton(
                                        icon: Icon(
                                          widget.iconData ?? Icons.error,
                                          size: 18,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        onPressed: () {
                                          widget.onCellPressed();
                                        },
                                      ),
                                    ),
                        ),
                        if (widget.trailing != null) widget.trailing!,
                      ],
                    ),
                    if (widget.child != null) Align(alignment: Alignment.centerRight, child: widget.child!),
                    // Align(
                    //     alignment: Alignment.topRight,
                    //     child: Text(
                    //       widget.cellWidth.toString() + " - " + contrains.maxWidth.toString(),
                    //       style: TextStyle(color: Colors.red, fontSize: 8),
                    //     )),
                  ],
                ),
              ),
            ),
    );
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  var _tapPosition;

  showSortingPopupMenu(BuildContext context1, String data) {
    if (_tapPosition == null) {
      return;
    }
    showMenu(
      context: context1,
      position: RelativeRect.fromLTRB(_tapPosition.dx, _tapPosition.dy, 100000, 0),
      items: [
        const PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              SizedBox(width: 5),
              Text("Copy"),
            ],
          ),
        ),
        // const PopupMenuItem(
        //   value: 2,
        //   child: Row(
        //     children: [
        //       SizedBox(width: 5),
        //       Text("Copy Entire Row"),
        //     ],
        //   ),
        // ),
        // const PopupMenuItem(
        //   value: 4,
        //   child: Row(
        //     children: [
        //       SizedBox(width: 5),
        //       Text("Copy Entire Table"),
        //     ],
        //   ),
        // ),
      ],
      elevation: 8.0,
    ).then((value) {
      switch (value) {
        case 1:
          {
            Clipboard.setData(ClipboardData(text: data));
          }
      }
    });
  }
}
