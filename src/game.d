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
    if (fight.isDone) {
      fight = null;
      return FightState.OutOfFight;
    }
    return FightState.InFight;
  }

  void start() {
    writeln("Welcome, " ~ player.name ~ ", to the world of Midwut...");
    while (true) {
      printTurnBanner();
      if (auto command = handleCommand(this, readLine())) {
        if (ConsumeTurn == command(this) && fightState == FightState.InFight) {
          writeln("The monster plays...");
        }
      } else {
        writeln("Unrecognized command");
      }
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
