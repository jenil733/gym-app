import 'package:get/get.dart';
import 'package:gym/scr/core/di/service_locator.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    ServiceLocator.init();
  }
}
