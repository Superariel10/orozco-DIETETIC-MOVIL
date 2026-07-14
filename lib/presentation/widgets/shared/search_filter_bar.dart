// lib/presentation/widgets/shared/search_filter_bar.dart

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onSearch;

  const SearchFilterBar({
    super.key,
    required this.hintText,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: AppColors.textFaint, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textFaint),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
