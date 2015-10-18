import std.stdio;
import std.getopt;
import exception : InterruptException;
import game;
import player;
import item : Item, get_template;

void main(string[] args) {
  string name = "";
  auto options = getopt(args,
      "n", &name);

  if (name != "") {
    auto inventory = new Inventory(420, [
      new Item(5, get_template("magic box"))
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
  writeln("Usage: ./bfw -n <NAME>");
}
