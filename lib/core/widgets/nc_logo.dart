import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
class NcLogo extends StatelessWidget{
  const NcLogo({super.key,this.dark=false,this.full=false,this.size=48});
  final bool dark,full;final double size;
  @override Widget build(BuildContext context){
    if(full)return Image.asset('assets/branding/newcare-logo.png',height:size,fit:BoxFit.contain,semanticLabel:'NewCare');
    return Row(mainAxisSize:MainAxisSize.min,children:[ClipRRect(borderRadius:BorderRadius.circular(10),child:Image.asset('assets/branding/newcare-icon.png',width:size,height:size,fit:BoxFit.contain,semanticLabel:'NewCare')),const SizedBox(width:8),Flexible(child:Text('NewCare',style:TextStyle(fontSize:20,fontWeight:FontWeight.w700,color:dark?Colors.white:AppColors.navyDark)))]);
  }
}

