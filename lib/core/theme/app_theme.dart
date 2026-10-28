import 'package:flutter/material.dart';
import 'app_colors.dart';
abstract final class AppTheme{
  static ThemeData light(){
    final scheme=ColorScheme.fromSeed(seedColor:AppColors.navy,primary:AppColors.navy,secondary:AppColors.teal,surface:Colors.white);
    return ThemeData(useMaterial3:true,fontFamily:'Cairo',colorScheme:scheme,scaffoldBackgroundColor:AppColors.background,
      textTheme:const TextTheme(headlineSmall:TextStyle(fontSize:25,fontWeight:FontWeight.w700,color:AppColors.text),titleMedium:TextStyle(fontSize:15,fontWeight:FontWeight.w600,color:AppColors.text),bodyMedium:TextStyle(fontSize:13,color:AppColors.text),bodySmall:TextStyle(fontSize:11,color:AppColors.muted)),
      inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:AppColors.background,isDense:true,contentPadding:const EdgeInsets.symmetric(horizontal:14,vertical:15),border:OutlineInputBorder(borderRadius:BorderRadius.circular(8),borderSide:const BorderSide(color:AppColors.border)),enabledBorder:OutlineInputBorder(borderRadius:BorderRadius.circular(8),borderSide:const BorderSide(color:AppColors.border)),labelStyle:const TextStyle(fontSize:12,color:AppColors.muted)),
      filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(minimumSize:const Size(140,44),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),textStyle:const TextStyle(fontFamily:'Cairo',fontWeight:FontWeight.w600,fontSize:13))),
      outlinedButtonTheme:OutlinedButtonThemeData(style:OutlinedButton.styleFrom(minimumSize:const Size(140,44),side:const BorderSide(color:AppColors.navy),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),textStyle:const TextStyle(fontFamily:'Cairo',fontWeight:FontWeight.w600,fontSize:13))),
      dividerColor:AppColors.border,cardTheme:CardThemeData(elevation:0,color:Colors.white,margin:EdgeInsets.zero,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12),side:const BorderSide(color:AppColors.border))));
  }
}

