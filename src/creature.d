import std.algorithm : min;
import std.random : uniform;
import std.string : format;

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

  void regenHpMp() {
    currentHp = baseStats.hp;
    currentMp = baseStats.mp;
  }

  void addHp(int hp) {
    currentHp += hp;
    // cap currentHp at the baseStats.hp limit
    currentHp = min(currentHp, baseStats.hp);
  }

  @property string stringDesc() {
    return format("%s (HP: %d/%d. MP: %d/%d)",
        name, currentHp, baseStats.hp, currentMp, baseStats.mp);
  }

  @property int hpPercent() {
    return 100 * (currentHp / baseStats.hp);
  }

  @property int maxHp() {
    return baseStats.hp;
  }

  @property int maxMp() {
    return baseStats.mp;
  }

  @property bool isFullHp() {
    return currentHp == baseStats.hp;
  }

  @property bool isFullMp() {
    return currentMp == baseStats.mp;
  }

  @property bool isDead() {
    return currentHp <= 0;
  }

  // TODO "alias this" or something?
  @property string name() {
    return baseStats.name;
  }
}

auto creatures = [
  new immutable CreatureStats("Foobar", 20, 10)
];

Creature pick() {
  return creatures[uniform(0, $)].toCreature();
}
