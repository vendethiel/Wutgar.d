import creature;

enum FightState {
  InFight, OutOfFight
};

class Fight {
  Creature fighter;
  Creature opponent;

  this(Creature fighter, Creature opponent) {
    this.fighter = fighter;
    this.opponent = opponent;
  }

  @property bool isDone() {
    return creature.
  }
}
