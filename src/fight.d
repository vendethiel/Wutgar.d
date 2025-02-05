import std.stdio : writeln, writefln;
import std.algorithm.iteration : filter;
import std.array : array;
import std.random : uniform;
import creature;

enum FightState {
  InFight,
  OutOfFight
}

class Fight {
  Creature fighter; /* TODO std.typecons.Nullable */
  Creature opponent;

  this(Creature fighter, Creature opponent) {
    this.fighter = fighter;
    this.opponent = opponent;
  }

  void opponentTurn() {
    auto launchableSpells =
      filter!(s => s.canCast(opponent, fighter, false))(opponent.spells)
      .array(); // eager
    if (launchableSpells.length) {
      launchableSpells[uniform(0, $)](opponent, fighter);
    } else {
      writefln("%s looks around, confused, as he figures he doesn't have a spell he can cast anymore", opponent
          .name);
    }
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
