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

alias command = CommandReturn delegate(Game);

command handleCommand(Game game, string name) {
  static command[string][FightState] actions;
  if (!actions) {
    actions = [
      FightState.OutOfFight: [
        "team": toDelegate(&listTeam),
        "you are the chosen one": toDelegate(&pickPokemon),
        "let's fight": toDelegate(&startFight),
        "shroom": toDelegate(&useShroom),
        "shop": toDelegate(&shop),
        "quit": toDelegate(&quit),
      ],
      FightState.InFight: [
        "slash": toDelegate(&attackSlash),
        "fire": toDelegate(&attackFire),
        "gamble": toDelegate(&attackGamble),
        "rest": toDelegate(&attackRest),

        "stat": toDelegate(&stat),
        "magic catch": toDelegate(&magicCatch),
        "quit": toDelegate(&flee),
      ],
    ];
  }

  return actions[game.fightState].get(name, null);
}

CommandReturn listTeam(Game game) {
  writeln("Your team:");
  foreach (creature; game.player.creatures) {
    writeln("- " ~ creature.stringDesc);
  }
  return CommandReturn.KeepTurn;
}

CommandReturn pickPokemon(Game game) {
  return checkCreature((Game game) {
    writeln("Your team:");
    foreach (i, creature; game.player.creatures) {
      writefln("- #%d %s", i + 1, creature.stringDesc);
    }

    game.player.selectedId =
      readBetween("Creature number: ", 1, to!int(game.player.creatures.length));
    return CommandReturn.KeepTurn;
  })(game);
}

CommandReturn startFight(Game game) {
  if (game.player.canStartFight) {
    auto creature = creature.pick();
    writeln("You're now fighting a " ~ creature.name);
    game.fight = new Fight(game.player.selectedCreature, creature);
  } else {
    writeln("You can't fight until you picked a healthy pokemon to fight for you");
  }
  return CommandReturn.KeepTurn;
}

CommandReturn quit(Game game) {
  throw new InterruptException();
}

command checkCreature(command cmd) {
  return (Game game) {
    if (!game.player.hasCreature) {
      writeln("You don't have any creature!");
      return CommandReturn.KeepTurn;
    }
    return cmd(game); };
}

auto restrictMp(int mp) {
  return (command cmd) {
    return (Game game) {
      if (game.fight.fighter.currentMp < mp) {
        writefln("You need at least %d", mp);
        return CommandReturn.KeepTurn;
      }
      return cmd(game);
    };
  };
}

command useAttack(int dmg, int mp) {
//return compose(checkCreature, restrictMp(mp))((Game game) {
  return restrictMp(mp)((Game game) {
    game.fight.fighter.currentMp -= mp;
    game.fight.opponent.currentHp -= dmg;
    writefln("You inflict %d damage(s)", dmg);
    return CommandReturn.ConsumeTurn;
  });
}

CommandReturn attackSlash(Game game) {
  return useAttack(15, 3)(game);
}
CommandReturn attackFire(Game game) {
  return useAttack(30, 7)(game);
}
CommandReturn attackGamble(Game game) {
  return checkCreature((Game game) {
    writeln("gambling TODO");
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
  immutable CHANCES = 3;
  if (game.player.hasCreature) {
    bool success = false;
    if (game.fight.opponent.currentHp < 5) {
      // critical state => this'll MOST DEFINITELY work
      success = uniform(1, 5) != 5; // 4/5 chance to pick it
    } else if (game.fight.opponent.hpPercent < 50) {
      // <50%: you got 1/2 chance
      success = uniform(1, 2) == 1;
    } else {
      // >50%: you got 1/5 chance
      success = uniform(1, 5) == 1;
    }
    
    if (success) {
      writefln("You successfully captured a %s", game.fight.opponent.name);
      game.fight.opponent.regenHpMp();
      game.player.creatures ~= game.fight.opponent;
      game.endFight();
    } else {
      writeln("You failed to capture the pokemon!");
      return CommandReturn.ConsumeTurn;
    }
  } else if (uniform(1, CHANCES) == 1) {
    writeln("You got a " ~ game.fight.opponent.name);
    game.player.creatures ~= game.fight.opponent;
    game.endFight();
  } else {
    writeln(game.fight.opponent.name ~ " scared you away from the fight");
    game.endFight();
  }
  return CommandReturn.KeepTurn;
}

CommandReturn useShroom(Game game) {
  return checkCreature((Game game) {
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
    return CommandReturn.KeepTurn;
  })(game);
}

CommandReturn shop(Game game) {
  writeln("You're going shopping!");
  return CommandReturn.KeepTurn;
}
CommandReturn stat(Game game) {
  return checkCreature((Game game) {
    writeln(game.fight.fighter.stringDesc);
    return CommandReturn.KeepTurn;
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
