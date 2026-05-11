import 'package:aulasmart_front_end/services/storage_service.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EvidenceView extends ConsumerStatefulWidget {
  const EvidenceView({super.key});

  @override
  ConsumerState<EvidenceView> createState() => _EvidenceViewState();
}

class _EvidenceViewState extends ConsumerState<EvidenceView> {
  Map<String, dynamic>? _userInfo;
  String? _accessToken;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storageService = ref.read(storageServiceProvider);
    final userInfo = await storageService.getUserInfo();
    final accessToken = await storageService.accessToken;

    setState(() {
      _userInfo = userInfo;
      _accessToken = accessToken;
      _loading = false;
    });
  }

  String _formatToken(String? token) {
    if (token == null || token.length < 20) return 'Token inválido o no existe';
    final start = token.substring(0, 10);
    final end = token.substring(token.length - 10);
    return '$start...$end';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evidencia (Debugging UI)', style: AppTextStyles.sectionTitle.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Datos de Shared Preferences (Usuario):',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _userInfo?.toString() ?? 'No hay datos de usuario',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Datos de Flutter Secure Storage (Token):',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Access Token:\n${_formatToken(_accessToken)}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
