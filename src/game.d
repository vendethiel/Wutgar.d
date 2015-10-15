import std.stdio;
import std.string;
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

  void start() {
    writeln("Welcome, " ~ player.name ~ ", to the world of Midwut...");
    while (true) {
      printTurnBanner();
      if (auto command = handleCommand(this, readLine())) {
        command(this);
        // TODO if fight, enemy should play
        //      -> probably move the `command(this)` part to another function?
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

string readLine() {
  auto line = stdin.readln().chomp();
  if (stdin.eof) {
    throw new InterruptException(); // ugly as hell...
  }
  return line;
}
