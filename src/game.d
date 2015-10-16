import std.stdio;
import std.string;
import read : readLine;
import command;
import fight;
import player;
import command;

class Game {
  Player player;
  Fight fight;

  this(Player player) {
    this.player = player;
  }

  @property FightState fightState() {
    if (fight is null) {
      return FightState.OutOfFight;
    }
    if (fight.isOver) {
      fight = null;
      return FightState.OutOfFight;
    }
    return FightState.InFight;
  }

  @property bool inFight() {
    return fightState() == FightState.InFight;
  }

  void start() {
    writeln("Welcome, " ~ player.name ~ ", to the world of Midwut...");
    while (true) {
      printTurnBanner();
      if (auto command = handleCommand(this, readLine())) {
        if (CommandReturn.ConsumeTurn == command(this) && inFight) {
          playOpponentTurn();
        }
      } else {
        writeln("Unrecognized command");
      }
    }
  }

  void playOpponentTurn() {
    checkFightEnd();
    if (fight !is null) {
      fight.opponentTurn();
      checkFightEnd();
    }
  }

  void checkFightEnd() {
    if (fight !is null && fight.isOver) {
      if (fight.opponent.isDead) {
        writeln("You win!");
      } else if (fight.fighter !is null) {
        writeln("You lost :(");
      } else {
        writeln("You ran away from the fight!");
      }
      fight = null;
    }
  }

  void printTurnBanner() {
    write("Your turn - ");
    if (fightState() == FightState.InFight) {
      write("In fight");
    } else {
      write("Out of fight");
    }
    write("> ");
  }
}
