import 'package:flutter/material.dart';
class NcCard extends StatelessWidget{
  const NcCard({super.key,this.title,required this.children,this.padding=20});
  final String? title;final List<Widget> children;final double padding;
  @override Widget build(BuildContext context)=>Card(child:Padding(padding:EdgeInsets.all(padding),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[if(title!=null)...[Text(title!,style:Theme.of(context).textTheme.titleMedium),const SizedBox(height:16)],for(var i=0;i<children.length;i++)...[if(i>0)const SizedBox(height:12),children[i]]])));
}

