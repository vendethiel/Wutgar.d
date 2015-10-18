import std.stdio : writeln;
import creature;

enum FightState {
  InFight, OutOfFight
};

class Fight {
  Creature fighter; /* TODO std.typecons.Nullable */
  Creature opponent;

  this(Creature fighter, Creature opponent) {
    this.fighter = fighter;
    this.opponent = opponent;
  }

  void opponentTurn() {
    writeln("Your opponent is playing");
    // TODO attack
    // TODO magic catch
  }

  @property bool isOver() {
    if (opponent.isDead) {
      return true;
    } else if (fighter !is null) {
      // it's not our first
      return fighter.isDead;
    }
    return false;
  }
}
