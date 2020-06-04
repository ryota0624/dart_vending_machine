class MoneyValue {
  final int _intValue;

  static final MoneyValue zero = MoneyValue(0);

  MoneyValue(this._intValue);

  MoneyValue add(MoneyValue other) => MoneyValue(_intValue + other._intValue);

  MoneyValue sub(MoneyValue other) => MoneyValue(_intValue - other._intValue);

  bool isEqualGreaterThan(MoneyValue other) => _intValue >= other._intValue;

  bool equal(MoneyValue other) => _intValue == other._intValue;
}

class Decreased {
  final Monies remaining;
  final MoneyValue refund;

  Decreased(this.remaining, this.refund);
}

class Withdraw {
  final Monies remaining;
  final Monies selected;

  Withdraw(this.remaining, this.selected);
}

class Monies {
  final List<Money> _list;

  Monies(this._list);

  Monies concat(Monies other) {
    final list = [..._list, ...other._list];
    return Monies(list);
  }

  MoneyValue totalValue() {
    var value = MoneyValue.zero;
    _list.forEach((element) {
      value = value.add(element.value());
    });

    return value;
  }

  Withdraw withdraw(MoneyValue want) {
    final sorted = _sortedMoneyValueAsc();
    var totalWithdraw = MoneyValue.zero;
    var results = <Money>[];
    var remaining = <Money>[];
    for (final money in sorted) {
      if (Monies(results).totalValue().equal(want)) {
        remaining.add(money);
      } else {
        totalWithdraw = totalWithdraw.add(money.value());
        final overflow = totalWithdraw.sub(want);
        if (overflow.isEqualGreaterThan(MoneyValue(1))) {
          throw Exception('ちょうどいい金額ないやんException');
        }
        results.add(money);
      }
    }

    return Withdraw(Monies(remaining), Monies(results));
  }

  Decreased decrease(MoneyValue want) {
    final sorted = _sortedMoneyValueAsc();
    var overflow = MoneyValue.zero;
    var totalDecreased = MoneyValue.zero;
    var remaining = <Money>[];
    for (final money in sorted) {
      if (totalDecreased.equal(want)) {
        remaining.add(money);
      } else {
        totalDecreased = totalDecreased.add(money.value());
        overflow = totalDecreased.sub(want);
        totalDecreased = totalDecreased.sub(overflow);
      }
    }

    return Decreased(Monies(remaining), overflow);
  }

  List<Money> _sortedMoneyValueAsc() {
    final copied = List<Money>.from(_list);
    copied.sort((a, b) => a.value()._intValue - b.value()._intValue);
    return copied;
  }
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
