import 'package:flutter/material.dart';
class NcField extends StatelessWidget{
  const NcField({super.key,required this.label,required this.controller,this.hint,this.validator,this.keyboardType,this.lines=1,this.obscure=false,this.onChanged,this.enabled=true});
  final String label;final TextEditingController controller;final String? hint;final String? Function(String?)? validator;final TextInputType? keyboardType;final int lines;final bool obscure,enabled;final ValueChanged<String>? onChanged;
  @override Widget build(BuildContext context)=>TextFormField(controller:controller,enabled:enabled,onChanged:onChanged,obscureText:obscure,maxLines:lines,keyboardType:keyboardType,validator:validator,decoration:InputDecoration(labelText:label,hintText:hint),textInputAction:lines>1?TextInputAction.newline:TextInputAction.next);
}
class NcSelect<T> extends StatelessWidget{
  const NcSelect({super.key,required this.label,required this.value,required this.items,required this.onChanged,this.validator});
  final String label;final T? value;final List<DropdownMenuItem<T>> items;final ValueChanged<T?> onChanged;final String? Function(T?)? validator;
  @override Widget build(BuildContext context)=>DropdownButtonFormField<T>(key:ValueKey(value),initialValue:value,isExpanded:true,items:items,onChanged:onChanged,validator:validator,decoration:InputDecoration(labelText:label));
}

