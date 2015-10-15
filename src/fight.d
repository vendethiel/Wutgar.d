import creature;

enum FightState {
  InFight, OutOfFight
};

class Fight {
  Creature creature;

  this(Creature creature) {
    this.creature = creature;
  }
}
