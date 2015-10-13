import std.stdio;
import std.getopt;
import game;
import player;

void main(string[] args) {
  string name = "";
  auto options = getopt(args,
      "n", &name);

  if (name != "") {
    auto player = new Player(name);
    auto game = new Game(player);
    game.start();
  } else {
    printUsage();
  }
}

void printUsage() {
  writeln("Usage: ./bfw -n <NAME>");
}
