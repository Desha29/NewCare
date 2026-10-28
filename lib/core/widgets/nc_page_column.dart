import 'package:flutter/material.dart';
class NcPageColumn extends StatelessWidget{
  const NcPageColumn({super.key,required this.children,this.maxWidth=double.infinity});
  final List<Widget> children;final double maxWidth;
  @override Widget build(BuildContext context)=>Align(alignment:AlignmentDirectional.topStart,child:ConstrainedBox(constraints:BoxConstraints(maxWidth:maxWidth),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[for(var i=0;i<children.length;i++)...[if(i>0)const SizedBox(height:16),children[i]]])));
}

