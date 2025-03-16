import 'dart:io';


double inputDoubleOr(String prompt, {double defaultDouble = 0.0}) {
  print(prompt);
  String input = stdin.readLineSync()!.trim();
  if (input.isEmpty) {
    print('Ввід порожній, отже використаємо стандартне значення: $defaultDouble');
    return defaultDouble;
  }

  return double.parse(input);
}

List<String> readEpsFromUser() {
  List<String> userSelectedKeys = [];
  Map<int, String> indexToElement = {
    1: 'ПЛ-110 кВ',
    2: 'ПЛ-35 кВ',
    3: 'ПЛ-10 кВ',
    4: 'КЛ-10 кВ (траншея)',
    5: 'КЛ-10 кВ (кабельний канал)',
    6: 'Т-110 кВ',
    7: 'Т-35 кВ',
    8: 'Т-10 кВ (кабельна мережа 10 кВ)',
    9: 'Т-10 кВ (повітряна мережа 10 кВ)',
    10: 'В-110 кВ (елегазовий)',
    11: 'В-10 кВ (малооливний)',
    12: 'В-10 кВ (вакуумний)',
    13: 'АВ-0.38 кВ',
    14: 'ЕД 6, 10 кВ',
    15: 'ЕД 0,38 кВ'
  };
  while (true) {
    stdout.write('Введіть номери потрібних елементів через пробіл: ');
    String? inputEP = stdin.readLineSync();

    if (inputEP != null) {
      List<String> selectedOptions = inputEP.split(' ');

      bool allValid = true;
      for (var option in selectedOptions) {
        int index = int.tryParse(option) ?? -1;
        if (indexToElement.containsKey(index)) {
          String key = indexToElement[index]!;
          userSelectedKeys.add(key);
        } else {
          print('Не існує ЕП з номером $index.');
          allValid = false;
          break;
        }
      }
      if (allValid) {
        break;
      }
    }
  }
  print(userSelectedKeys);
  return userSelectedKeys;
}



void main() {
  Map<String, Map<String, double>> epsElements = {
    'ПЛ-110 кВ': {'omega': 0.07, 'tv':  10, 'mu': 0.167, 'tp': 35},
    'ПЛ-35 кВ': {'omega': 0.02,  'tv': 8, 'mu': 0.167, 'tp': 35},
    'ПЛ-10 кВ': {'omega': 0.02,  'tv': 10, 'mu': 0.167, 'tp': 35},
    'КЛ-10 кВ (траншея)': {'omega': 0.03, 'tv': 44, 'mu': 1, 'tp': 9},
    'КЛ-10 кВ (кабельний канал)': {'omega': 0.005, 'tv': 17.5, 'mu': 1, 'tp': 9},
    'Т-110 кВ': {'omega': 0.015, 'tv': 100, 'mu': 1, 'tp': 43},
    'Т-35 кВ': {'omega': 0.02, 'tv': 80, 'mu': 1, 'tp': 28},
    'Т-10 кВ (кабельна мережа 10 кВ)': {'omega': 0.005, 'tv': 60, 'mu': 0.5, 'tp': 10},
    'Т-10 кВ (повітряна мережа 10 кВ)': {'omega': 0.05, 'tv': 60, 'mu': 0.5, 'tp': 10},
    'В-110 кВ (елегазовий)': {'omega': 0.01, 'tv': 30, 'mu': 0.1, 'tp': 30},
    'В-10 кВ (малооливний)': {'omega': 0.02, 'tv': 15, 'mu': 0.33, 'tp': 15},
    'В-10 кВ (вакуумний)': {'omega': 0.01, 'tv': 15, 'mu': 0.33, 'tp': 15},
    'АВ-0.38 кВ': {'omega': 0.05, 'tv': 4, 'mu': 0.33, 'tp': 10},
    'ЕД 6, 10 кВ': {'omega': 0.1, 'tv': 160, 'mu': 0.5, 'tp': 0},
    'ЕД 0,38 кВ': {'omega': 0.1, 'tv': 50, 'mu': 0.5, 'tp': 0}
  };

  List<String> userKeys = readEpsFromUser();
  if (userKeys.isEmpty){
    print("Введені некоректні дані. Спробуйте ще раз.");
    return;
  }
  double n = inputDoubleOr('Введіть кількість збірних шин: ', defaultDouble:6);
  double omegaSum = 0;
  double tRecovery = 0;
  double maxTp = 0;

  for (String key in userKeys){
    omegaSum += epsElements[key]?["omega"] ?? 0;
    tRecovery += (epsElements[key]?["omega"] ?? 0) * (epsElements[key]?["tv"] ?? 0);
    double tp = epsElements[key]?["tp"] ?? 0;
    if (tp > maxTp) {
      maxTp = tp;
    }
  }

  omegaSum += 0.03 * n;
  tRecovery += 0.06 * n;

  tRecovery = tRecovery / omegaSum;


  double kAP = omegaSum * tRecovery / 8760;

  double kPP = 1.2 * maxTp / 8760;


  double omegaDK = 2 * 0.295 * (kAP + kPP);

  double omegaDKS = omegaDK + 0.02;

  print('Частота відмов одноколової системи: ${omegaSum.toStringAsFixed(2)} рік^-1\n' +
      'Середня тривалість відновлення: ${tRecovery.toStringAsFixed(2)} год\n' +
      'Коефіцієнт аварійного простою: ${kAP.toStringAsFixed(5)}\n' +
      'Коефіцієнт планового простою: ${kPP.toStringAsFixed(5)}\n' +
      'Частота відмов одночасно двох кіл двоколової системи: ${omegaDK.toStringAsFixed(5)} рік^-1\n' +
      'Частота відмов двоколової системи з урахуванням секційного вимикача: ${omegaDKS.toStringAsFixed(5)} рік^-1');


  double zPerA = inputDoubleOr('Введіть збитки в разі аварійних вимкнень: ', defaultDouble: 23.6);
  double zPerP = inputDoubleOr('Введіть збитки в разі планових вимкнень: ', defaultDouble: 17.6);

  double omega = inputDoubleOr('Введіть частоту відмов: ', defaultDouble: 0.01);
  double t = inputDoubleOr('Введіть середній час відновлення трансформатора: ', defaultDouble: 0.045);
  double kp = inputDoubleOr('Введіть середній час планового простою: ', defaultDouble: 0.004);
  double Pm = inputDoubleOr('Введіть потужність трансформатора: ', defaultDouble: 5120);
  double Tm = inputDoubleOr('Введіть час відключення: ', defaultDouble: 6451);

  double MWA = omega * t * Pm * Tm;

  double MWP = kp * Pm * Tm;

  double M = zPerA * MWA + zPerP * MWP;
  print('Математичне сподівання аварійного недовідпущення: ${MWA.toStringAsFixed(0)} кВт * год\n' +
      'Математичне сподівання планового недовідпущення: ${MWP.toStringAsFixed(0)} кВт * год\n' +
      'Математичне сподівання збитків від перервання електропостачання: ${M.toStringAsFixed(0)} грн');
}