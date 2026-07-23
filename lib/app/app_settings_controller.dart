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
const defaultPosLanguages = [
  defaultPosLanguage,
  PosLanguage(code: 'te', label: 'Telugu', nativeLabel: 'తెలుగు'),
  PosLanguage(code: 'hi', label: 'Hindi', nativeLabel: 'हिन्दी'),
  PosLanguage(code: 'ta', label: 'Tamil', nativeLabel: 'தமிழ்'),
  PosLanguage(code: 'kn', label: 'Kannada', nativeLabel: 'ಕನ್ನಡ'),
  PosLanguage(code: 'ml', label: 'Malayalam', nativeLabel: 'മലയാളം'),
];

final appThemeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});

final selectedPosLanguageProvider = StateProvider<PosLanguage>((ref) {
  return defaultPosLanguage;
});
