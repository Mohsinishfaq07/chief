// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefix;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool isPasswordField;

  const CustomTextField({
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    required this.hintText,
    this.prefix,
    this.isPasswordField = false,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText =
        widget.isPasswordField; // Initialize with true if it's a password field
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8.w,
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: widget.prefix,
          suffixIcon: widget.isPasswordField
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          isDense: true,
          contentPadding: EdgeInsets.all(20.h),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
