import std.stdio;
import std.string;
import command;
import fight;
import player;
import command;

class Game {
  Player player;
  Fight fight;
  bool playing = true;

  this(Player player) {
    this.player = player;
  }

  @property FightState fightState() {
    return fight is null ? FightState.OutOfFight : FightState.InFight;
  }
  void start() {
    writeln("Bienvenue, " ~ player.name ~ ", dans le monde magnifique de Wutgard...");
    while (playing) {
      write("Votre tour> ");
      string line = stdin.readln().chomp();
      if (line is null || line == "Quit") {
        return;
      } else {
        handleCommand(this, line);
      }
    }
  }
}
