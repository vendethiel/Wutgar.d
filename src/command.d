import std.stdio : writeln, writefln;
import std.conv : to;
import std.random : uniform;
import std.algorithm : map;
import std.functional : toDelegate;
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
        "quit": toDelegate(&quit),
      ],
      FightState.InFight: [
        "slash": toDelegate(&attackSlash),
        "fire": toDelegate(&attackFire),
        "gamble": toDelegate(&attackGamble),
        "rest": toDelegate(&attackRest),

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
    writeln("- " ~ creature.name);
  }
  return CommandReturn.KeepTurn;
}
CommandReturn pickPokemon(Game game) {
  if (!game.player.hasCreature) {
    writeln("Can't pick a pokemon: you don't have any");
    return CommandReturn.KeepTurn;
  }

  writeln("Your team:");
  foreach (i, creature; game.player.creatures) {
    writefln("- #%d %s", i + 1, creature.name);
  }

  game.player.selectedId =
    readBetween("Creature number: ", 1, to!int(game.player.creatures.length));
  return CommandReturn.KeepTurn;
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
      writeln("You need a creature to attack!");
      return CommandReturn.KeepTurn;
    }
    return cmd(game);
  };
}

command useAttack(Game game, int dmg, int mp) {
  return checkCreature((Game game) {
    if (game.fight.fighter.currentMp < mp) {
      writefln("You need %d MP points to use this attack", mp);
      return CommandReturn.KeepTurn;
    }
    game.fight.fighter.currentMp -= mp;
    game.fight.opponent.currentHp -= dmg;
    writefln("You inflict %d damage(s)", dmg);
    return CommandReturn.ConsumeTurn;
  });
}

CommandReturn attackSlash(Game game) {
  return useAttack(game, 15, 3)(game);
}
CommandReturn attackFire(Game game) {
  return useAttack(game, 30, 7)(game);
}
CommandReturn attackGamble(Game game) {
  return checkCreature((Game game) {
    return CommandReturn.ConsumeTurn;
  })(game);
}

CommandReturn attackRest(Game game) {
  if (!game.player.hasCreature) {
    writeln("You can't do this without a monster!");
    return CommandReturn.KeepTurn;
  }
  if (game.fight.fighter.isFullMp) {
    writeln("You're already full mana!");
    return CommandReturn.KeepTurn;
  }
  game.fight.fighter.currentMp += 10;
  return CommandReturn.ConsumeTurn;
}

CommandReturn magicCatch(Game game) {
  immutable CHANCES = 3;
  if (game.player.hasCreature) {
    writeln("TODO algo % de vie");
  } else if (uniform(1, CHANCES) == 1) {
    writeln("You got a " ~ game.fight.opponent.name);
    game.player.creatures ~= game.fight.opponent;
    game.fight = null;
  } else {
    writeln(game.fight.opponent.name ~ " scared you away from the fight");
    game.fight = null;
  }
  return CommandReturn.KeepTurn;
}
CommandReturn quit(Game game) {
  throw new InterruptException();
}
CommandReturn flee(Game game) {
  game.fight = null;
  return CommandReturn.KeepTurn;
}
