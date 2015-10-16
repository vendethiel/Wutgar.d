import std.random : uniform;

class CreatureStats {
  string name;
  int hp;
  int mp;

  this(string name, int hp, int mp) immutable {
    this.name = name;
    this.hp = hp;
    this.mp = mp;
  }

  Creature toCreature() immutable {
    return new Creature(this);
  }
}

class Creature {
  int currentHp;
  int currentMp;
  const(CreatureStats) baseStats;

  this(const(CreatureStats) baseStats) {
    this.baseStats = baseStats;
    currentHp = baseStats.hp;
    currentMp = baseStats.mp;
  }

  // TODO "alias this" or something?
  @property string name() { return baseStats.name; }

  @property bool isDead() {
    return currentHp <= 0;
  }
}

auto creatures = [
  new immutable CreatureStats("Foobar", 50, 50)
];

Creature pick() {
  return creatures[uniform(0, $)].toCreature();
}
