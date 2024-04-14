import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProductDetailSmallContainer extends StatelessWidget {
  final String title;
  final String? label;

  const CustomProductDetailSmallContainer({
    super.key,
    required this.title,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    // Function to limit words in the title
    String limitWords(String text, int wordLimit) {
      List<String> words = text.split(RegExp(r'\s+'));
      return words.take(wordLimit).join(' ') + (words.length > wordLimit ? '...' : '');
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.006.h,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.038.h,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.pink.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(

          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Text(
                label!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            const SizedBox(width: 8),  // Provides spacing between label and title
            Text(
              limitWords(title, 8),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
