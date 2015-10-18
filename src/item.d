import algorithm : first;

class ItemTemplate {
  string name;

  public this(string name) {
    this.name = name;
  }
}

ItemTemplate get_template(string name) {
  static ItemTemplate[] item_templates = [
    new ItemTemplate("Magic Shroom"),
    new ItemTemplate("Magic Box"),
  ];
  return first!(i => i.name == name)(item_templates);
}

class Item {
  int quantity;
  ItemTemplate tmpl;

  this(int quantity, ItemTemplate tmpl) {
    this.quantity = quantity;
    this.tmpl = tmpl;
  }
}
