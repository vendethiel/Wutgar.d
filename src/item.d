class ItemTemplate {
  string name;

  public this(string name) {
    this.name = name;
  }
}

ItemTemplate get_template(string name) {
  static ItemTemplate[string] item_templates;
  if (!item_templates) {
    item_templates = [
      "shroom": new ItemTemplate("Magic Shroom"),
      "magic box": new ItemTemplate("Magic Shroom"),
    ];
  }
  return item_templates[name];
}

class Item {
  int quantity;
  ItemTemplate tmpl;

  this(int quantity, ItemTemplate tmpl) {
    this.quantity = quantity;
    this.tmpl = tmpl;
  }
}
