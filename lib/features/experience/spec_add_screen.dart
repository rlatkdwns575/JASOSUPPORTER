import 'package:chatgptmini/app/app_routes.dart';
import 'package:chatgptmini/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// `/experience/specs` 딥링크 호환 — 카테고리→세부유형 흐름으로 리다이렉트.
class SpecAddScreen extends StatefulWidget {
  const SpecAddScreen({super.key});

  @override
  State<SpecAddScreen> createState() => _SpecAddScreenState();
}

class _SpecAddScreenState extends State<SpecAddScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.go(AppRoutes.experienceFormCategory('spec'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.scaffold,
      child: Center(
        child: CircularProgressIndicator(color: AppColors.experience),
      ),
    );
  }
}
