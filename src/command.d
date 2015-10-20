import std.stdio : writeln, writefln;
import std.conv : to;
import std.random : uniform;
import std.algorithm : map;
import std.functional : toDelegate, compose;
import exception : InterruptException;
import read : readLine, readBetween;
import shop;
import game;
import player;
import fight;
import creature;

enum CommandReturn {
  ConsumeTurn,
  KeepTurn,
}

alias worldCommand = void delegate(Game);
alias fightCommand = CommandReturn delegate(Game);

worldCommand handleWorldCommand(Game game, string name) {
  static worldCommand[string] actions;
  if (!actions) {
    actions = [
      "team": toDelegate(&listTeam),
      "you are the chosen one": toDelegate(&pickPokemon),
      "let's fight": toDelegate(&startFight),
      "shroom": toDelegate(&useShroom),
      "shop": toDelegate(&goShopping),
      "inventory": toDelegate(&inventory),
      "quit": toDelegate(&quit),
    ];
  }
  return actions.get(name, null);
}

fightCommand handleFightCommand(Game game, string name) {
  static fightCommand[string] actions;
  if (!actions) {
    actions = [
      "stat": toDelegate(&stat),
      "magic catch": toDelegate(&magicCatch),
      "quit": toDelegate(&flee),
    ];
  }

  if (auto creature = game.fight.fighter) {
    if (creature.hasSpell(name)) {
      return (Game game) { 
        auto spell = creature.getSpell(name);
        if (!spell.canCast(creature, game.fight.opponent, true)) {
          return CommandReturn.KeepTurn;
        } else {
          spell(creature, game.fight.opponent);
          return CommandReturn.ConsumeTurn;
        }
      };
    }
  }

  return actions.get(name, null);
}

void listTeam(Game game) {
  writeln("Your team:");
  foreach (creature; game.player.creatures) {
    writeln("- " ~ creature.stringDesc);
  }
}

void pickPokemon(Game game) {
  checkCreature((Game game) {
    writeln("Your team:");
    foreach (i, creature; game.player.creatures) {
      writefln("- #%d %s", i + 1, creature.stringDesc);
    }

    game.player.selectedId =
      readBetween("Creature number: ", 1, to!int(game.player.creatures.length));
    return CommandReturn.KeepTurn; // :(
  })(game);
}

void startFight(Game game) {
  if (game.player.canStartFight) {
    auto creature = creature.pick();
    writeln("You're now fighting a " ~ creature.name);
    game.fight = new Fight(game.player.selectedCreature, creature);
  } else {
    writeln("Can't start a fight without a (healthy) creature");
  }
}

auto quit(Game game) {
  throw new InterruptException();
}

fightCommand checkCreature(fightCommand cmd) {
  return (Game game) {
    if (!game.player.hasCreature) {
      writeln("You don't have any creature!");
      return CommandReturn.KeepTurn;
    }
    return cmd(game);
  };
}

auto requireObject(string name, int quantity = 1) {
  return (fightCommand cmd) {
    return (Game game) {
      if (!game.player.inventory.hasItem(name, quantity)) {
        writefln("You're missing the item %s to do this", name);
        return CommandReturn.KeepTurn;
      }
      game.player.inventory.useItem(name);
      return cmd(game);
    };
  };
}

CommandReturn attackRest(Game game) {
  return checkCreature((Game game) {
    if (game.fight.fighter.isFullMp) {
      writeln("You're already full mana!");
      return CommandReturn.KeepTurn;
    }
    game.fight.fighter.currentMp += 10;
    return CommandReturn.ConsumeTurn;
  })(game);
}

CommandReturn magicCatch(Game game) {
  return requireObject("Magic Box")((Game game) {
    if (game.player.hasCreature) {
      if (game.player.doesCapture(game.fight.opponent)) {
        writefln("You successfully captured a %s", game.fight.opponent.name);
        game.player.captureCreature(game.fight.opponent);
        game.endFight();
      } else {
        writeln("You failed to capture the pokemon!");
        return CommandReturn.ConsumeTurn;
      }
    } else if (game.player.doesCapture(game.fight.opponent)) {
      writeln("You got a " ~ game.fight.opponent.name);
      game.player.creatures ~= game.fight.opponent;
      game.endFight();
    } else {
      writeln(game.fight.opponent.name ~ " scared you away from the fight");
      game.endFight();
    }
    return CommandReturn.KeepTurn;
  })(game);
}

void useShroom(Game game) {
  checkCreature(requireObject("Shroom")((Game game) {
    if (game.player.selectedCreature.isFullHp) {
      writeln("Your chosen one is already max hp");
    } else {
      auto creature = game.player.selectedCreature;
      // best algo world. l o l.
      auto percentRegen = 1 + (uniform(15, 26) / 100f);
      auto heal = to!int(creature.maxHp * percentRegen - creature.maxHp);
      writefln("Healed %s for %d hp", creature.name, heal);
      creature.addHp(heal);
    }
    return CommandReturn.KeepTurn; // :(
  }))(game);
}

void goShopping(Game game) {
  auto shop = main_shop();
  writefln("Welcome to %s. Items for sale: (0 to leave)", shop.name);
  foreach (i, item; shop.items) {
    writefln("- #%d: %s (costs %d)", i + 1, item.tmpl.name, item.cost);
  }
  int sel;
  do {
    sel = readBetween("Your choice", 0, to!int(shop.items.length));
    if (sel) {
      auto item = shop.items[sel - 1];
      if (game.player.inventory.money >= item.cost) {
        game.player.inventory.addItem(item.tmpl.name, 1);
        game.player.inventory.money -= item.cost;
        writefln("You bought %s for %d. Money left: %d",
            item.tmpl.name, item.cost, game.player.inventory.money);
      } else {
        writefln("You're too poor to buy %s", item.tmpl.name);
      }
    }
  } while (sel && game.player.inventory.money);
}

void inventory(Game game) {
  writefln("You have %d rupee(s)", game.player.inventory.money);
  writeln("Your inventory:");
  foreach (item; game.player.inventory.items) {
    writefln("- %dx %s", item.quantity, item.tmpl.name);
  }
}

CommandReturn stat(Game game) {
  return checkCreature((Game game) {
    writeln(game.fight.fighter.stringDesc);
    return CommandReturn.KeepTurn; // :(
  })(game);
}

CommandReturn quit(Game game) {
  throw new InterruptException();
}

CommandReturn flee(Game game) {
  writeln("You run away from the fight...");
  game.endFight();
  return CommandReturn.KeepTurn;
}
