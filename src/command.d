import std.stdio : writeln, writefln;
import std.conv : to;
import std.random : uniform;
import std.algorithm : map;
import std.functional : toDelegate, compose;
import exception : InterruptException;
import read : readLine, readBetween;
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
      "shop": toDelegate(&shop),
      "inventory": toDelegate(&inventory),
      "quit": toDelegate(&quit),
    ];
  }
  return actions.get(name, null);
}
/*
        "slash": toDelegate(&attackSlash),
        "fire": toDelegate(&attackFire),
        "gamble": toDelegate(&attackGamble),
        "rest": toDelegate(&attackRest),
        */

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
        if (creature.getSpell(name)(game, creature, game.fight.opponent)) {
          return CommandReturn.ConsumeTurn;
        } else {
          return CommandReturn.KeepTurn;
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
  checkCreature((Game game) {
    if (game.player.canStartFight) {
      auto creature = creature.pick();
      writeln("You're now fighting a " ~ creature.name);
      game.fight = new Fight(game.player.selectedCreature, creature);
    }
    return CommandReturn.KeepTurn; // :(
  });
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

auto restrictMp(int mp) {
  return (fightCommand cmd) {
    return (Game game) {
      if (game.fight.fighter.currentMp < mp) {
        writefln("You need at least %d", mp);
        return CommandReturn.KeepTurn;
      }
      return cmd(game);
    };
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

fightCommand useAttack(int dmg, int mp) {
//return compose(checkCreature, restrictMp(mp))((Game game) {
  return restrictMp(mp)((Game game) {
    game.fight.fighter.currentMp -= mp;
    game.fight.opponent.currentHp -= dmg;
    writefln("You inflict %d damage(s)", dmg);
    return CommandReturn.ConsumeTurn;
  });
}

CommandReturn attackGamble(Game game) {
  return checkCreature((Game game) {
    int damage = uniform(0, 20);
    auto target = uniform(0, 1) ? game.fight.fighter : game.fight.opponent;
    target.currentHp -= damage;
    if (damage) {
      writefln("You inflict %s %d damage(s)",
        target == game.fight.fighter ? "yourself" : "your enemy",
        damage);
    } else {
      writeln("You missed!");
    }
    return CommandReturn.ConsumeTurn;
  })(game);
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
  checkCreature((Game game) {
    if (game.player.selectedCreature is null) {
      writeln("You need to select your chosen one before healing him");
    } else if (game.player.selectedCreature.isFullHp) {
      writeln("Your chosen one is already max hp");
    } else {
      // TODO check inventory + remove one shroom
      auto creature = game.player.selectedCreature;
      auto percentRegen = uniform(15, 25) / 100;
      creature.addHp(creature.maxHp * percentRegen);
    }
    return CommandReturn.KeepTurn; // :(
  })(game);
}

void shop(Game game) {
  writeln("You're going shopping!");
  game.player.inventory.useItem("Magic Box");
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
