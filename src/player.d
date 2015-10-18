import std.algorithm.searching : any, find;
import std.algorithm.mutation : remove;
import std.random : uniform;
import algorithm : first;
import creature;
import item;

class Inventory {
  int money;
  Item[] items;
  
  @disable this();

  this(int money, Item[] items) {
    this.money = money;
    this.items = items;
  }

  bool hasItem(string name, int quantity = 1) {
    return any!(i => i.tmpl.name == name && i.quantity >= quantity)(items);
  }

  bool useItem(string name, int quantity = 1) {
    if (!hasItem(name, quantity)) {
      return false;
    }
    auto item = getItem(name); 
    item.quantity -= quantity;
    if (!item.quantity) {
      items = remove!(i => i == item)(items);
    }
    return true;
  }

  void addItem(string name, int quantity = 1) {
    if (hasItem(name)) {
      getItem(name).quantity += quantity;
    } else {
      items ~= new Item(quantity, get_template(name));
    }
  }

  private Item getItem(string name) {
    assert(hasItem(name));
    return first!(i => i.tmpl.name == name)(items);
  }
}

class Player {
  string name;
  Creature[] creatures;
  Inventory inventory;
  uint selectedId; // 0 if empty, otherwise 1-indexed into `creatures`

  this(string name, Inventory inventory) {
    this.name = name;
    this.inventory = inventory;
  }

  bool doesCapture(Creature opponent) {
    if (opponent is null) {
      // we don't have a creature
      return uniform(1, 3) == 1;
    } else if (opponent.currentHp < 5) {
      // critical state => this'll MOST DEFINITELY work
      return uniform(1, 5) != 5; // 4/5 chance to pick it
    } else if (opponent.hpPercent < 50) {
      // <50%: you got 1/2 chance
      return uniform(1, 2) == 1;
    } else {
      // >50%: you got 1/5 chance
      return uniform(1, 5) == 1;
    }
  }

  void captureCreature(Creature creature) {
    creature.regenHpMp();
    creatures ~= creature;
  }

  @property bool hasCreature() {
    return creatures.length > 0;
  }

  @property bool canStartFight() {
    if (!hasCreature) {
      return true;
    }
    // no need for a health check, a dead creature is free'd
    return selectedCreature !is null;
  }

  @property Creature selectedCreature() {
    if (creatures.length < selectedId || !selectedId) {
      // 0 because we 1-index otherwise
      selectedId = 0;
      return null;
    } else {
      return creatures[selectedId - 1];
    }
  }
}
