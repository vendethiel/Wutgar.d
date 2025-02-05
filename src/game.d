import std.algorithm.mutation : remove;
import std.stdio : writefln, writeln, write;
import std.random : uniform;
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
    return fight !is null;
  }

  void start() {
    writeln("Welcome, " ~ player.name ~ ", to the world of Midwut...");
    while (true) {
      printTurnBanner();
      if (inFight) {
        if (auto command = handleFightCommand(this, readLine())) {
          if (CommandReturn.ConsumeTurn == command(this)) {
            playOpponentTurn();
          }
        } else {
          writeln("No such fight command");
        }
      } else {
        if (auto command = handleWorldCommand(this, readLine())) {
          command(this);
        } else {
          writeln("No such world command");
        }
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
        auto gain = uniform(90, 120);
        player.inventory.money += gain;
        writefln("You win! You also find %d rupees on the %s's body",
          gain, fight.opponent.name);
      } else if (fight.fighter !is null) {
        writeln("You lost, and your creature is in heaven... or hell");
        player.removeDead();
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
