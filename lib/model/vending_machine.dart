import 'package:vending_machine/model/money.dart';
import 'package:vending_machine/model/product.dart';

abstract class BuyResult {}

class SuccessBuyResult extends BuyResult {
  final ProductID buyProductID;
  final Monies change;
  final VendingMachine machine;

  SuccessBuyResult(
    this.buyProductID,
    this.change,
    this.machine,
  );
}

enum BuyFailureReason {
  stockEmpty,
  notEnoughMonies,
  notExistProduct,
}

class FailureBuyResult extends BuyResult {
  final Monies refund;
  final BuyFailureReason reason;

  FailureBuyResult(
    this.refund,
    this.reason,
  );
}

abstract class VendingMachineStatus {
  static final pending = StatusPending();
  static final active = StatusActive();
  static final paused = StatusPaused();
  static final stopped = StatusStopped();
}

class StatusPending extends VendingMachineStatus {}

class StatusActive extends VendingMachineStatus {}

class StatusPaused extends VendingMachineStatus {}

class StatusStopped extends VendingMachineStatus {}

class VendingMachineID {
  static VendingMachineID generate() {}
}

class VendingMachine {
  VendingMachine._(
    this.id,
    this.status,
    this._racks,
    this._holdMonies,
  );

  final VendingMachineID id;
  final VendingMachineStatus status;

  factory VendingMachine(VendingMachineID id) {
    return VendingMachine._(
      id,
      VendingMachineStatus.pending,
      [],
      Monies([]),
    );
  }

  BuyResult buy(ProductID productID, Monies inputMoneys) {
    final productHoldRacks = _findRackByProductID(productID);
    if (productHoldRacks.isEmpty) {
      return FailureBuyResult(inputMoneys, BuyFailureReason.notExistProduct);
    }

    final productHoldRack = productHoldRacks.first;
    if (!productHoldRack.existStock()) {
      return FailureBuyResult(inputMoneys, BuyFailureReason.stockEmpty);
    }

    final rack = productHoldRack.reduce();
    if (!inputMoneys.totalValue().isEqualGreaterThan(rack.rackFor.price)) {
      return FailureBuyResult(inputMoneys, BuyFailureReason.notEnoughMonies);
    }

    final decreased = inputMoneys.decrease(rack.rackFor.price);
    final withdrawResult = holdMonies().withdraw(decreased.refund);
    final change = decreased.remaining.concat(withdrawResult.selected);
    final machine =
        _replaceRack(rack)._withHoldMonies(withdrawResult.remaining);

    return SuccessBuyResult(productID, change, machine);
  }

  VendingMachine deposit(Monies monies) {
    return _withHoldMonies(holdMonies().concat(monies));
  }

  VendingMachine refill(ProductID productID, StockCount count) {
    final productHoldRacks = _findRackByProductID(productID);
    if (productHoldRacks.isEmpty) {
      throw Exception('Rackが見つからんぞException');
    }

    // TODO: firstがcapacity超えてたら別のものを試みる。
    final addedRack = productHoldRacks.first.add(count);
    return _replaceRack(addedRack);
  }

  List<StockRack> _findRackByProductID(ProductID id) =>
      racks().where((element) => element.rackFor.id == id);

  final List<StockRack> _racks;
  final Monies _holdMonies;

  List<StockRack> racks() => _racks;

  Monies holdMonies() => _holdMonies;

  VendingMachine addRack(StockRack rack) {
    final copied = racks();
    copied.add(rack);
    return VendingMachine._(id, status, copied, _holdMonies);
  }

  VendingMachine changeProvidingProduct(StockRackID rackID, Product product) {
    final rack = _findRack(rackID);
    final changedRack = rack.changeRackFor(product);
    return _replaceRack(changedRack);
  }

  VendingMachine _replaceRack(StockRack rack) {
    final filtered = _racks.where((element) => element.id == rack.id).toList();
    filtered.add(rack);
    return VendingMachine._(id, status, filtered, _holdMonies);
  }

  VendingMachine _withHoldMonies(Monies monies) =>
      VendingMachine._(id, status, _racks, monies);


  StockRack _findRack(StockRackID rackID) {
    final rack = racks().where((element) => element.id == rackID);
    if (rack.isEmpty) {
      throw Exception('Rackが見つからんぞException');
    }
    return rack.first;
  }
}

class StockRackID {}

class StockRack {
  final StockRackID id;
  final Size capableSize;
  final HoldableProductCount holdableProductCount;
  final StockCount count;
  // TODO: RackはProductがない状態でも存在できるようにしたい。
  final Product rackFor;

  StockRack changeRackFor(Product rackFor) {
    return StockRack(
      id,
      capableSize,
      holdableProductCount,
      count,
      rackFor,
    )._asStockEmpty();
  }

  StockRack(
    this.id,
    this.capableSize,
    this.holdableProductCount,
    this.count,
    this.rackFor,
  ) {
    // TODO: rackForはcapableSizeを満たすか検証
    // TODO: HoldableProductCountを満たすStackCountであるか検証
  }

  bool existStock() => !count.isZero();

  StockRack add(StockCount count) {
    return StockRack(id, capableSize, holdableProductCount, count, rackFor);
  }

  StockRack _asStockEmpty() {
    return StockRack(id, capableSize, holdableProductCount, StockCount(0), rackFor);
  }

  StockRack reduce() => StockRack(
      id, capableSize, holdableProductCount, count.decrement(), rackFor);
}

class StockCount {
  final int _value;

  StockCount(this._value) {
    assert(_value >= 0);
  }

  bool isZero() => _value == 0;

  StockCount add(StockCount other) => StockCount(_value + other._value);

  StockCount increment() => StockCount(_value + 1);

  StockCount decrement() => StockCount(_value - 1);
}

class HoldableProductCount {
  final StockCount _count;

  HoldableProductCount(this._count);
}
