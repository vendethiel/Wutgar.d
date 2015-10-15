import std.stdio;
import std.getopt;
import exception : InterruptException;
import game;
import player;

void main(string[] args) {
  string name = "";
  auto options = getopt(args,
      "n", &name);

  if (name != "") {
    auto player = new Player(name);
    auto game = new Game(player);
    try {
      game.start();
    } catch (InterruptException e) {
    }
  } else {
    printUsage();
  }
}

void printUsage() {
  writeln("Usage: ./bfw -n <NAME>");
}
