import 'package:vending_machine/model/repository/vending_machine.dart';
import 'package:vending_machine/model/vending_machine.dart';

abstract class RackConfiguration {
  StockRack toRack();
}

class CreateVendingMachineUseCaseInput {
  final List<RackConfiguration> rackConfigurations;

  CreateVendingMachineUseCaseInput(this.rackConfigurations);
}

class CreateVendingMachineUseCaseOutput {
  final VendingMachineID created;

  CreateVendingMachineUseCaseOutput(this.created);
}

class CreateVendingMachineUseCase {
  final VendingMachineRepository _repository;

  CreateVendingMachineUseCase(this._repository);

  // rackのサイズと容量指定を指定して作成
  Future<CreateVendingMachineUseCaseOutput> execute(
      CreateVendingMachineUseCaseInput input) async {
    final id = VendingMachineID.generate();
    var machine = VendingMachine(id);

    for (final rackConf in input.rackConfigurations) {
      machine = machine.addRack(rackConf.toRack());
    }
    await _repository.store(machine);
    return CreateVendingMachineUseCaseOutput(machine.id);
  }
}
