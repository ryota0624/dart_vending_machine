import 'package:vending_machine/model/money.dart';

class ProductID {}

class Product {
  final ProductID id;
  final Name name;
  final MoneyValue price;
  final Size size;

  Product(
    this.id,
    this.name,
    this.price,
    this.size,
  );
}

enum Size { l, m, s }

class Name {
  final String _value;

  Name(this._value);
}
