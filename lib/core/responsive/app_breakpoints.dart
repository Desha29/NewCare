import 'package:flutter/widgets.dart';
enum WindowClass {compact,medium,expanded}
abstract final class AppBreakpoints{
  static WindowClass of(BuildContext context)=>fromWidth(MediaQuery.sizeOf(context).width);
  static WindowClass fromWidth(double width)=>width<600?WindowClass.compact:width<1200?WindowClass.medium:WindowClass.expanded;
  static bool compact(BuildContext context)=>of(context)==WindowClass.compact;
}

