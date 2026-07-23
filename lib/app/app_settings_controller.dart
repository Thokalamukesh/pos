import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PosLanguage {
  const PosLanguage({
    required this.code,
    required this.label,
    this.nativeLabel,
  });

  final String code;
  final String label;
  final String? nativeLabel;

  String get displayLabel {
    final native = nativeLabel?.trim();
    if (native == null || native.isEmpty || native == label) {
      return label;
    }
    return '$label / $native';
  }
}

const defaultPosLanguage = PosLanguage(code: 'en', label: 'English');

final appThemeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

final selectedPosLanguageProvider = StateProvider<PosLanguage>((ref) {
  return defaultPosLanguage;
});
