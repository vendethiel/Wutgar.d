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
