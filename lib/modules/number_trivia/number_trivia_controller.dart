import 'package:get/get.dart';

import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/number_trivia/get_concrete_number_trivia.dart';
import '../../domain/usecases/number_trivia/get_random_number_trivia.dart';

class NumberTriviaController extends GetxController {
  NumberTriviaController({
    required this.getConcrete,
    required this.getRandom,
  });

  final GetConcreteNumberTrivia getConcrete;
  final GetRandomNumberTrivia getRandom;

  final isLoading = false.obs;
  final numberInput = ''.obs;
  final trivia = Rxn<NumberTrivia>();
  final errorMessage = RxnString();

  void onInputChanged(String value) {
    numberInput.value = value;
    if (errorMessage.value != null && value.isNotEmpty) {
      errorMessage.value = null;
    }
  }

  Future<void> getConcreteTrivia() async {
    final raw = numberInput.value;
    if (raw.trim().isEmpty) {
      errorMessage.value = 'Please enter a number first.';
      trivia.value = null;
      return;
    }

    isLoading.value = true;
    final result = await getConcrete(raw);
    isLoading.value = false;

    result.fold(
      (failure) {
        trivia.value = null;
        errorMessage.value = failure.message;
      },
      (trv) {
        trivia.value = trv;
        errorMessage.value = null;
      },
    );
  }

  Future<void> getRandomTrivia() async {
    isLoading.value = true;
    final result = await getRandom();
    isLoading.value = false;

    result.fold(
      (failure) {
        trivia.value = null;
        errorMessage.value = failure.message;
      },
      (trv) {
        trivia.value = trv;
        numberInput.value = trv.number.toString();
        errorMessage.value = null;
      },
    );
  }
}
