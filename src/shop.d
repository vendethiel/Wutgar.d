import std.typecons;
import item : ItemTemplate, get_template;

alias ShopItem = Tuple!(ItemTemplate, "tmpl", int, "cost");

class Shop {
  public ShopItem[] items;

  this(ShopItem[] items) {
    this.items = items;
  }
}

// TODO: implement multiple shops (by level? number of wins? number of creatures?)
Shop main_shop() {
  static Shop shop;
  // NOTE: can't do `static shop = ...` because get_templates
  //       can't be called at compile-time.
  //       (it can't, because it needs the `static a; if (!a){a=..}` trick
  //       because dmd forbids assoc.arrays. in static :[
  if (!shop) {
    shop = new Shop([
      ShopItem(get_template("shroom"), 30),
      ShopItem(get_template("magic box"), 90),
    ]);
  }
  return shop;
}
