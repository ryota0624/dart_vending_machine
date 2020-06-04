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

abstract class VendingMachine {
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
      throw Exception('容量オーバーやでException');
    }

    final addedRack = productHoldRacks.first.add(count);
    return _replaceRack(addedRack);
  }

  List<StockRack> _findRackByProductID(ProductID id) =>
      racks().where((element) => element.rackFor.id == id);

  List<StockRack> racks();

  Monies holdMonies();

  VendingMachine _replaceRack(StockRack rack);

  VendingMachine _withHoldMonies(Monies monies);
}

class StockRackID {}

class StockRack {
  final StockRackID id;
  final Size capableSize;
  final HoldableProductCount holdableProductCount;
  final StockCount count;
  final Product rackFor;

  StockRack(
    this.id,
    this.capableSize,
    this.holdableProductCount,
    this.count,
    this.rackFor,
  );

  bool existStock() => !count.isZero();

  StockRack add(StockCount count) =>
      StockRack(id, capableSize, holdableProductCount, count, rackFor);

  StockRack reduce() => StockRack(
      id, capableSize, holdableProductCount, count.decrement(), rackFor);
}

class StockCount {
  final int _value;

  StockCount(this._value);

  bool isZero() => _value == 0;

  StockCount increment() => StockCount(_value + 1);

  StockCount decrement() => StockCount(_value - 1);
}

class HoldableProductCount {
  final StockCount _count;

  HoldableProductCount(this._count);
}
