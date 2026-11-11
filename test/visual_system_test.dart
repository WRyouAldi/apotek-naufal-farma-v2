import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dshe_farma_pos/main.dart';

double _luminance(Color color) {
  double channel(double normalized) {
    return normalized <= 0.04045
        ? normalized / 12.92
        : ((normalized + 0.055) / 1.055) * ((normalized + 0.055) / 1.055) *
            ((normalized + 0.055) / 1.055);
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color first, Color second) {
  final a = _luminance(first);
  final b = _luminance(second);
  return (a > b ? a + 0.05 : b + 0.05) /
      (a > b ? b + 0.05 : a + 0.05);
}

void main() {
  group('Dshe Farma visual tokens', () {
    test('Pearl Crystal and Charcoal Silver token values stay locked', () {
      expect(DsheVisualTokens.pearlBackground, const Color(0xFFF1F3F6));
      expect(DsheVisualTokens.pearlSurface, const Color(0xFFFFFFFF));
      expect(DsheVisualTokens.pearlAccent, const Color(0xFF7D9CA5));
      expect(DsheVisualTokens.pearlPrimary, const Color(0xFF405A63));
      expect(DsheVisualTokens.charcoalBackground, const Color(0xFF111317));
      expect(DsheVisualTokens.charcoalSurface, const Color(0xFF20242A));
      expect(DsheVisualTokens.silverAccent, const Color(0xFFAAB5C2));
      expect(DsheVisualTokens.radiusCard, 22);
      expect(DsheVisualTokens.radiusControl, 18);
    });

    test('primary, secondary and error text meet WCAG AA contrast', () {
      const minimum = 4.5;
      expect(
        _contrast(DsheVisualTokens.pearlText, DsheVisualTokens.pearlSurface),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.pearlSecondaryText, DsheVisualTokens.pearlSurface),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.charcoalText, DsheVisualTokens.charcoalSurface),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.charcoalSecondaryText, DsheVisualTokens.charcoalSurface),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.pearlPrimary, DsheVisualTokens.pearlSurface),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.pearlSurface, DsheVisualTokens.pearlPrimary),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.charcoalBackground, DsheVisualTokens.silverAccent),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.statusError, DsheVisualTokens.pearlSurface),
        greaterThanOrEqualTo(minimum),
      );
      expect(
        _contrast(DsheVisualTokens.statusErrorDark, DsheVisualTokens.charcoalSurface),
        greaterThanOrEqualTo(minimum),
      );
    });

    test('shared glass and icon tokens are present for both themes', () {
      expect(DsheVisualTokens.glassTint, isNot(DsheVisualTokens.charcoalSurface));
      expect(DsheVisualTokens.glassDarkTint, DsheVisualTokens.charcoalRaised);
      expect(DsheVisualTokens.iconLight, isNot(DsheVisualTokens.iconDark));
      expect(DsheVisualTokens.iconLightAccent, DsheVisualTokens.pearlAccent);
      expect(DsheVisualTokens.iconDarkAccent, DsheVisualTokens.silverAccent);
    });
  });
}
