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
    return fight is null ? FightState.OutOfFight : FightState.InFight;
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

  /* Forces the fight's end, for example when you capture a pokemon
     or when you run away from the fight */
  void endFight() {
    fight = null;
  }

  void checkFightEnd() {
    if (fight !is null && fight.isOver) {
      if (fight.opponent.isDead) {
        // TODO win uniform(90, 120) rupees
        writeln("You win!");
      } else if (fight.fighter !is null) {
        // TODO we need to remove fighter from our team
        //    + reset the "selectedFighter" from player
        writeln("You lost :(");
      } else {
        // we got scared
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
