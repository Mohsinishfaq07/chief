// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;

  final String? hintText;
  final String? label;
  final Widget? prefix;
  final IconData? suffix;
  final VoidCallback? onPressedSuffix;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final bool isPasswordField;
  final bool formatDate;
  final bool formatTime;
  final bool readOnly;
  final int? maxLength;
  final double? width;
  final double? height;

  const CustomTextField({
    required this.controller,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.label,
    this.prefix,
    this.suffix,
    this.onPressedSuffix,
    this.isPasswordField = false,
    this.formatDate = false,
    this.formatTime = false,
    this.readOnly = false,
    this.maxLength,
    this.width,
    this.height,
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
    _obscureText = widget.isPasswordField;
  }

  @override
  Widget build(BuildContext context) {
    double defaultWidth =
        widget.width ?? MediaQuery.of(context).size.width * 0.8;
    double defaultHeight = widget.height ?? 70;

    return SizedBox(
      width: defaultWidth,
      height: defaultHeight,
      child: TextFormField(
        readOnly: widget.readOnly,
        textAlign: TextAlign.start,
        maxLength: widget.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        decoration: InputDecoration(
          label: widget.label != null ? Text(widget.label!) : null,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.transparent, fontSize: 14.sp),
          labelStyle:TextStyle(color: Colors.black, fontSize: 14.sp),
          prefixIcon: widget.prefix,
          suffixIcon: _buildSuffixIcon(),
          contentPadding: EdgeInsets.symmetric(
              vertical: defaultHeight * 0.1, horizontal: 20.w),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: const BorderSide(
              color: Colors.transparent, // Adjust the border color as needed
              width: 1.0, // Adjust the border width as needed
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: const BorderSide(
              color:
              Colors.transparent, // Adjust the color for the normal state
              width: 1.0, // Adjust the width as needed
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9.h),
            borderSide: const BorderSide(
              color: Colors.transparent, // Adjust the color for the focused state
              width: 1.0, // Adjust the width as needed
            ),
          ),
          counterText: '',
        ),
        inputFormatters: widget.formatDate
            ? [DateInputFormatter()]
            : widget.formatTime
                ? [TimeInputFormatter()]
                : [],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPasswordField) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.suffix != null && widget.onPressedSuffix != null) {
      return IconButton(
        icon: Icon(widget.suffix),
        onPressed: widget.onPressedSuffix,
      );
    }
    return null;
  }
}

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // First, ensure only digits are allowed
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // If trying to enter more than 4 digits, keep old value
    if (numericOnly.length > 4) {
      return oldValue;
    }

    // Insert colon between hour and minute when applicable
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < numericOnly.length; i++) {
      // Append numeric character
      buffer.write(numericOnly[i]);

      // After the 2nd digit, add a colon (but not at the end)
      if (i == 1 && numericOnly.length > 2) {
        buffer.write(':');
      }
    }

    // Use the modified string with a colon as the new text value
    String formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      // Ensure the cursor is at the end of the current text
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Extracting only the digits from the input
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    // Ensure we do not exceed the length for dd/mm/yyyy format (i.e., 8 digits + 2 slashes = 10 characters)
    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    // Formatting the digits with slashes
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      // Insert slashes after the day (2 digits) and month (4 digits) parts
      if (i == 2 || i == 4) {
        formatted += '/';
      }
      formatted += digitsOnly[i];
    }

    // Returning the newly formatted value, adjusting the cursor position accordingly
    return newValue.copyWith(
      text: formatted,
      // Ensure the cursor is positioned correctly, at the end of the current input
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
