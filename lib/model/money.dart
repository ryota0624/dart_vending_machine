class MoneyValue {
  final int _intValue;

  MoneyValue(this._intValue);
}

mixin Money {
  MoneyValue value();
}

abstract class Coin with Money {}

class Coin10 extends Coin {
  @override
  MoneyValue value() => MoneyValue(10);

}

class Coin50 extends Coin {
  @override
  MoneyValue value() => MoneyValue(50);
}

class Coin100 extends Coin {
  @override
  MoneyValue value() => MoneyValue(100);
}

class Coin500 extends Coin {
  @override
  MoneyValue value() => MoneyValue(500);
}

abstract class Bil with Money {}

class Bill1000 extends Bil {
  @override
  MoneyValue value() => MoneyValue(1000);
}