import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Multi-artisan quantity allocation', () {
    test('should fully satisfy a 100-unit requirement', () {
      const requiredQuantity = 100;

      final artisans = [
        {'artisanId': 'A', 'availableQuantity': 20},
        {'artisanId': 'B', 'availableQuantity': 25},
        {'artisanId': 'C', 'availableQuantity': 15},
        {'artisanId': 'D', 'availableQuantity': 30},
        {'artisanId': 'E', 'availableQuantity': 10},
      ];

      int remainingQuantity = requiredQuantity;
      int matchedQuantity = 0;

      final matches = <Map<String, dynamic>>[];

      for (final artisan in artisans) {
        if (remainingQuantity <= 0) {
          break;
        }

        final availableQuantity = artisan['availableQuantity'] as int;

        final allocatedQuantity = availableQuantity < remainingQuantity
            ? availableQuantity
            : remainingQuantity;

        matches.add({
          'artisanId': artisan['artisanId'],
          'allocatedQuantity': allocatedQuantity,
        });

        matchedQuantity += allocatedQuantity;
        remainingQuantity -= allocatedQuantity;
      }

      expect(matchedQuantity, 100);
      expect(remainingQuantity, 0);
      expect(matches.length, 5);
    });

    test('should report remaining quantity when supply is insufficient', () {
      const requiredQuantity = 100;

      final artisans = [
        {'artisanId': 'A', 'availableQuantity': 20},
        {'artisanId': 'B', 'availableQuantity': 25},
        {'artisanId': 'C', 'availableQuantity': 30},
      ];

      int remainingQuantity = requiredQuantity;
      int matchedQuantity = 0;

      for (final artisan in artisans) {
        if (remainingQuantity <= 0) {
          break;
        }

        final availableQuantity = artisan['availableQuantity'] as int;

        final allocatedQuantity = availableQuantity < remainingQuantity
            ? availableQuantity
            : remainingQuantity;

        matchedQuantity += allocatedQuantity;
        remainingQuantity -= allocatedQuantity;
      }

      expect(matchedQuantity, 75);
      expect(remainingQuantity, 25);
      expect(remainingQuantity > 0, true);
    });

    test('should not allocate more than available quantity', () {
      const requiredQuantity = 100;

      final artisans = [
        {'artisanId': 'A', 'availableQuantity': 20},
        {'artisanId': 'B', 'availableQuantity': 150},
      ];

      int remainingQuantity = requiredQuantity;
      final allocations = <int>[];

      for (final artisan in artisans) {
        if (remainingQuantity <= 0) {
          break;
        }

        final availableQuantity = artisan['availableQuantity'] as int;

        final allocatedQuantity = availableQuantity < remainingQuantity
            ? availableQuantity
            : remainingQuantity;

        allocations.add(allocatedQuantity);
        remainingQuantity -= allocatedQuantity;
      }

      expect(allocations[0], 20);
      expect(allocations[1], 80);
      expect(remainingQuantity, 0);
    });
  });
}
