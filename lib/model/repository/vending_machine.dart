import 'package:vending_machine/model/vending_machine.dart';

abstract class VendingMachineRepository {
  void store(VendingMachine machine);

  Future<VendingMachine> get(VendingMachineID id);
}
