import std.stdio : writefln;
import std.random : uniform;
import algorithm : first;
import game;
import creature;

class Spell {
  string name;

  this(string name) immutable {
    this.name = name;
  }

  bool canCast(Creature, Creature, bool) immutable {
    return true;
  }

  abstract void opCall(Creature, Creature) immutable;
}

class OffensiveSpell : Spell {
  int power;
  int cost;

  this(string name, int power, int cost) immutable {
    super(name);
    this.power = power;
    this.cost = cost;
  }

  override bool canCast(Creature self, Creature opponent, bool log) immutable {
    if (self.currentMp < cost) {
      if (log) {
        writefln("%s costs %d mana, %s only has %d",
          name, cost, self.name, self.currentMp);
      }
      return false;
    }
    return true;
  }

  override void opCall(Creature self, Creature opponent) immutable {
    self.currentMp -= cost;
    opponent.currentHp -= power;
    writefln("%s inflicted %d damage(s) to %s",
      self.name, power, opponent.name);
  }
}

class HealingSpell : Spell {
  int power;
  int cost;

  this(string name, int power, int cost) immutable {
    super(name);
    this.power = power;
    this.cost = cost;
  }

  override bool canCast(Creature self, Creature opponent, bool log) immutable {
    if (self.currentMp < cost) {
      if (log) {
        writefln("%s costs %d mana, %s only has %d",
          name, cost, self.name, self.currentMp);
      }
      return false;
    }
    if (self.isFullHp) {
      if (log) {
        writefln("%s is already full hp!", self.name);
      }
      return false;
    }
    return true;
  }

  override void opCall(Creature self, Creature opponent) immutable {
    self.currentMp -= cost;
    self.addHp(power);
    writefln("%s gains %d health back",
      self.name, power);
  }
}

class ManaSpell : Spell {
  int power;

  this(string name, int power) immutable {
    super(name);
    this.power = power;
  }

  override bool canCast(Creature self, Creature opponent, bool log) immutable {
    if (self.isFullMp) {
      if (log) {
        writefln("%s already has full mana", self.name);
      }
      return false;
    }
    return true;
  }

  override void opCall(Creature self, Creature opponent) immutable {
    self.addMp(power);
    writefln("%s gains %d mana back",
      self.name, power, self.currentMp);
  }
}

class GambleSpell : OffensiveSpell {
  this(string name, int power, int cost) immutable {
    super(name, power, cost);
  }

  override void opCall(Creature self, Creature opponent) immutable {
    auto damage = uniform(0, power);
    auto target = uniform(0, 2) ? self : opponent;
    self.currentMp -= cost;
    if (damage) {
      target.currentHp -= damage;
      writefln("%s gambles and inflicts %d damage(s) to %s",
        self.name, damage, self == target ? "himself" : target.name);
    } else {
      writefln("%s missed!", self.name);
    }
  }
}

immutable Spell[] basic_spells = [
  new immutable OffensiveSpell("slash", 15, 3),
  new immutable OffensiveSpell("fire", 30, 7),
  new immutable HealingSpell("heal", 20, 10),
  new immutable ManaSpell("rest", 10),
  new immutable GambleSpell("gamble", 20, 0),
];

immutable(Spell) getSpell(string name) {
  return first!(s => s.name == name)(basic_spells);
}
