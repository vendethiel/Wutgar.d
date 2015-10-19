import std.algorithm.comparison : min;
import std.algorithm.searching : any;
import std.random : uniform;
import std.string : format;
import algorithm : first;
import spell;

class CreatureStats {
  string name;
  int hp;
  int mp;
  immutable(Spell[]) spells;

  this(string name, int hp, int mp, immutable(Spell[]) spells) immutable {
    this.name = name;
    this.hp = hp;
    this.mp = mp;
    this.spells = spells;
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

  bool hasSpell(string name) {
    return any!(s => s.name == name)(spells);
  }

  immutable(Spell) getSpell(string name) {
    return first!(s => s.name == name)(spells);
  }

  @property immutable(Spell[]) spells() {
    // TODO if we want to add levels/per-level spells etc
    return baseStats.spells;
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

  @property string name() {
    return baseStats.name;
  }
}

auto creatures = [
  new immutable CreatureStats("Petit Lapin", 5, 10, [
      
  ]),
  new immutable CreatureStats("Gros Lapin", 20, 10, [
  ]),
  new immutable CreatureStats("Enorme Lapin", 40, 20, [
  ]),
];

Creature pick() {
  return creatures[uniform(0, $)].toCreature();
}
