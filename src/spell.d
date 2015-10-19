import algorithm : first;
import game;
import creature;

class Spell {
  string name;

  this(string name) {
    this.name = name;
  }

  abstract bool opCall(Game, Creature, Creature) immutable;
}

class OffensiveSpell : Spell {
  int power;
  int cost;

  this(string name, int power, int cost) {
    super(name);
    this.power = power;
    this.cost = cost;
  }

  override bool opCall(Game game, Creature self, Creature opponent) immutable {
    return true;
  }
}

static basic_spells = [
  new OffensiveSpell("slash", 15, 3),
  new OffensiveSpell("fire", 30, 7),
];

Spell getSpell(string name) {
  return first!(s => s.name == name)(basic_spells);
}
