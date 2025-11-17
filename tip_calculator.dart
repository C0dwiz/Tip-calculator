import 'dart:io';

class TipCalculator {
  static const List<double> _defaultTipPercentages = [10.0, 15.0, 20.0];
  static const int _decimalPlaces = 2;

  void run() {
    _printWelcomeMessage();

    final double billAmount = _getBillAmount();
    final double tipPercentage = _getTipPercentage();
    final int numberOfPeople = _getNumberOfPeople();

    final CalculationResult result = _calculate(
      billAmount: billAmount,
      tipPercentage: tipPercentage,
      numberOfPeople: numberOfPeople,
    );

    _printResults(result);
  }

  void _printWelcomeMessage() {
    print('╔═══════════════════════════════════════╗');
    print('║        КАЛЬКУЛЯТОР ЧАЕВЫХ            ║');
    print('╚═══════════════════════════════════════╝');
    print('');
  }

  double _getBillAmount() {
    return _getValidatedDouble(
      prompt: 'Введите общую сумму счёта (руб): ',
      validator: (value) {
        if (value <= 0) {
          return 'Сумма должна быть больше 0';
        }
        if (value > 1000000) {
          return 'Сумма слишком большая. Введите сумму до 1 000 000 руб';
        }
        return null;
      },
    );
  }

  double _getTipPercentage() {
    while (true) {
      print('\n🎯 Выберите процент чаевых:');
      for (int i = 0; i < _defaultTipPercentages.length; i++) {
        print(
          '${i + 1} - ${_defaultTipPercentages[i]}% ${_getTipDescription(_defaultTipPercentages[i])}',
        );
      }
      print('${_defaultTipPercentages.length + 1} - Ввести свой процент');

      final String? choice = _getInput(
        'Ваш выбор (1-${_defaultTipPercentages.length + 1}): ',
      );

      if (choice == null) continue;

      switch (choice) {
        case '1':
          return _defaultTipPercentages[0];
        case '2':
          return _defaultTipPercentages[1];
        case '3':
          return _defaultTipPercentages[2];
        case '4':
          return _getCustomTipPercentage();
        default:
          print(
            '❌ Неверный выбор. Пожалуйста, выберите от 1 до ${_defaultTipPercentages.length + 1}',
          );
      }
    }
  }

  double _getCustomTipPercentage() {
    return _getValidatedDouble(
      prompt: 'Введите свой процент чаевых: ',
      validator: (value) {
        if (value < 0) return 'Процент не может быть отрицательным';
        if (value > 100) return 'Процент не может превышать 100%';
        if (value == 0)
          return 'Вы уверены, что хотите оставить 0% чаевых? (y/n): ';
        return null;
      },
    );
  }

  int _getNumberOfPeople() {
    return _getValidatedInt(
      prompt: 'На скольких человек разделить счёт? ',
      validator: (value) {
        if (value <= 0) return 'Количество человек должно быть больше 0';
        if (value > 50) return 'Слишком много людей. Максимум 50 человек';
        return null;
      },
    );
  }

  CalculationResult _calculate({
    required double billAmount,
    required double tipPercentage,
    required int numberOfPeople,
  }) {
    final double tipAmount = billAmount * tipPercentage / 100;
    final double totalAmount = billAmount + tipAmount;
    final double exactAmountPerPerson = totalAmount / numberOfPeople;

    final double roundedAmountPerPerson = _roundToNearestTen(
      exactAmountPerPerson,
    );
    final double roundedTotal = roundedAmountPerPerson * numberOfPeople;
    final double roundingDifference = roundedTotal - totalAmount;

    return CalculationResult(
      billAmount: billAmount,
      tipPercentage: tipPercentage,
      tipAmount: tipAmount,
      totalAmount: totalAmount,
      numberOfPeople: numberOfPeople,
      exactAmountPerPerson: exactAmountPerPerson,
      roundedAmountPerPerson: roundedAmountPerPerson,
      roundedTotal: roundedTotal,
      roundingDifference: roundingDifference,
    );
  }

  double _roundToNearestTen(double amount) {
    return (amount / 10).ceil() * 10;
  }

  void _printResults(CalculationResult result) {
    print('\n' + '=' * 50);
    print('💰 ВАШ РАСЧЕТ'.padLeft(30));
    print('=' * 50);

    print('Сумма счёта: ${_formatCurrency(result.billAmount)}');
    print('Процент чаевых: ${result.tipPercentage.toStringAsFixed(1)}%');
    print('Сумма чаевых: ${_formatCurrency(result.tipAmount)}');
    print('Общая сумма: ${_formatCurrency(result.totalAmount)}');
    print('Количество человек: ${result.numberOfPeople}');
    print('-' * 50);

    print(
      'Точная сумма с человека: ${_formatCurrency(result.exactAmountPerPerson)}',
    );

    if (result.roundedAmountPerPerson != result.exactAmountPerPerson) {
      print('\n💡 РЕКОМЕНДУЕМ (округлено для удобства):');
      print(
        'С каждого человека: ${_formatCurrency(result.roundedAmountPerPerson, showDecimals: false)}',
      );
      print(
        'Общая сумма с округлением: ${_formatCurrency(result.roundedTotal)}',
      );

      if (result.roundingDifference > 0) {
        print(
          'Доплата при округлении: +${_formatCurrency(result.roundingDifference)}',
        );
      } else if (result.roundingDifference < 0) {
        print(
          'Экономия при округлении: ${_formatCurrency(result.roundingDifference)}',
        );
      }
    }

    print('\n🎉 Приятного отдыха!');
  }

  String _formatCurrency(double amount, {bool showDecimals = true}) {
    final String formatted = showDecimals
        ? amount.toStringAsFixed(_decimalPlaces)
        : amount.floor().toString();

    final List<String> parts = formatted.split('.');
    String integerPart = parts[0];

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(integerPart[i]);
    }

    if (parts.length > 1 && showDecimals) {
      return '${buffer.toString()}.${parts[1]} руб.';
    } else {
      return '${buffer.toString()} руб.';
    }
  }

  String _getTipDescription(double percentage) {
    switch (percentage) {
      case 10.0:
        return '(стандартно)';
      case 15.0:
        return '(хорошо)';
      case 20.0:
        return '(отлично)';
      default:
        return '';
    }
  }

  double _getValidatedDouble({
    required String prompt,
    required String? Function(double) validator,
  }) {
    while (true) {
      final String? input = _getInput(prompt);
      if (input == null) continue;

      try {
        final double value = double.parse(input.replaceAll(',', '.'));
        final String? error = validator(value);

        if (error != null) {
          if (error.contains('0%')) {
            final String? confirmation = _getInput(error);
            if (confirmation?.toLowerCase() == 'y') {
              return value;
            }
            continue;
          }
          print('❌ $error');
          continue;
        }

        return value;
      } catch (e) {
        print(
          '❌ Пожалуйста, введите корректное число (например: 1500 или 99.50)',
        );
      }
    }
  }

  int _getValidatedInt({
    required String prompt,
    required String? Function(int) validator,
  }) {
    while (true) {
      final String? input = _getInput(prompt);
      if (input == null) continue;

      try {
        final int value = int.parse(input);
        final String? error = validator(value);

        if (error != null) {
          print('❌ $error');
          continue;
        }

        return value;
      } catch (e) {
        print('❌ Пожалуйста, введите целое число');
      }
    }
  }

  String? _getInput(String prompt) {
    stdout.write(prompt);
    final String? input = stdin.readLineSync()?.trim();

    if (input == null || input.isEmpty) {
      print('❌ Ввод не может быть пустым');
      return null;
    }

    return input;
  }
}

class CalculationResult {
  final double billAmount;
  final double tipPercentage;
  final double tipAmount;
  final double totalAmount;
  final int numberOfPeople;
  final double exactAmountPerPerson;
  final double roundedAmountPerPerson;
  final double roundedTotal;
  final double roundingDifference;

  CalculationResult({
    required this.billAmount,
    required this.tipPercentage,
    required this.tipAmount,
    required this.totalAmount,
    required this.numberOfPeople,
    required this.exactAmountPerPerson,
    required this.roundedAmountPerPerson,
    required this.roundedTotal,
    required this.roundingDifference,
  });
}

void main() {
  try {
    TipCalculator().run();
  } catch (e) {
    print('\n💥 Произошла непредвиденная ошибка: $e');
    print('Пожалуйста, перезапустите программу.');
  } finally {
    print('\n👋 До свидания!');
  }
}
