import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class StrukturScreen extends StatelessWidget {
  const StrukturScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CareHubAppBar(titleText: 'Struktur Organisasi'),
          ),
          SliverFillRemaining(
            child: Center(
              child: Text(
                'Segera Hadir: Struktur Organisasi\n(Terintegrasi dengan API)',
                textAlign: TextAlign.center,
                style: AppTextStyle.body,
              ),
            ),
          )
        ],
      ),
    );
  }
}
