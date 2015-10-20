import std.typecons;
import item;

alias ShopItem = Tuple!(ItemTemplate, "tmpl", int, "cost");

// NOTE: if we wanted quantities, we'd use Inventory
class Shop {
  string name;
  ShopItem[] items;

  this(string name, ShopItem[] items) {
    this.name = name;
    this.items = items;
  }
}

// TODO: implement multiple shops (by level? number of wins? number of creatures?)
Shop main_shop() {
  static Shop shop;
  // NOTE: can't do `static shop = ...` because getItemTemplate
  //       can't be called at compile-time.
  //       (it can't, because it needs the `static a; if (!a){a=..}` trick
  //       because dmd forbids assoc.arrays. in static :[
  if (!shop) {
    shop = new Shop("Main Shop", [
      ShopItem(getItemTemplate("Shroom"), 30),
      ShopItem(getItemTemplate("Magic Box"), 90),
    ]);
  }
  return shop;
}
