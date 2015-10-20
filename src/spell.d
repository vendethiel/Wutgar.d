import std.stdio : writefln;
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
    if (self.currentMp < cost) {
      // TODO flag "isPlayer" to avoid outputting an error message?
      //      or add a "canCast" method?
      //      or throw a Exception.NotEnoughMana?
      writefln("Not enough mana: need %d, got %d",
          cost, self.currentMp);
      return false;
    }
    self.currentMp -= cost;
    opponent.currentHp -= power;
    writefln("%s inflicted %d damage(s) to %s",
        self.name, power, opponent.name);
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
