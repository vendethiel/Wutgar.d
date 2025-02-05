import std.stdio;
import std.getopt;
import exception : InterruptException;
import game;
import player;
import item;

void main(string[] args) {
  string name = "";
  getopt(args, "n", &name);

  if (name != "") {
    auto inventory = new Inventory(420,
      [
        new Item(5, getItemTemplate("Magic Box")),
      ]);
    auto player = new Player(name, inventory);
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
  writeln("Usage: ./battle-for-wudgar -n <NAME>");
}
