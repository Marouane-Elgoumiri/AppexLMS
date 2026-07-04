import 'package:get/get.dart';

import '../../domain/usecases/number_trivia/get_concrete_number_trivia.dart';
import '../../domain/usecases/number_trivia/get_random_number_trivia.dart';
import 'number_trivia_controller.dart';

class NumberTriviaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GetConcreteNumberTrivia>(
      () => GetConcreteNumberTrivia(Get.find()),
      fenix: true,
    );
    Get.lazyPut<GetRandomNumberTrivia>(
      () => GetRandomNumberTrivia(Get.find()),
      fenix: true,
    );
    Get.lazyPut<NumberTriviaController>(
      () => NumberTriviaController(
        getConcrete: Get.find(),
        getRandom: Get.find(),
      ),
    );
  }
}
