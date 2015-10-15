import std.stdio : writeln, writefln;
import std.conv : to;
import std.random : uniform;
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

alias command = CommandReturn function(Game);

command handleCommand(Game game, string name) {
  static command[string][FightState] actions;
  if (!actions) {
    actions = [
      FightState.OutOfFight: [
        "team": &listTeam,
        "you are the chosen one": &pickPokemon,
        "let's fight": &startFight,
        "quit": &quit,
      ],
      FightState.InFight: [
        "slash": &attackSlash,
        "fire": &attackFire,
        "gamble": &attackGamble,
        "rest": &attackRest,

        "magic catch": &magicCatch,
        "quit": &flee,
      ],
    ];
  }

  return actions[game.fightState].get(name, null);
}


void listTeam(Game game) {
  writeln("Your team:");
  foreach (creature; game.player.creatures) {
    writeln("- " ~ creature.name);
  }
  return KeepTurn;
}
void pickPokemon(Game game) {
  if (!game.player.hasCreature) {
    writeln("Can't pick a pokemon: you don't have any");
    return;
  }

  writeln("Your team:");
  foreach (i, creature; game.player.creatures) {
    writefln("- #%d %s", i, creature.name);
  }

  game.player.selectedId =
    readBetween("Creature number: ", 1, to!int(game.player.creatures.length));
  return KeepTurn;
}
void startFight(Game game) {
  if (game.player.canStartFight) {
    auto creature = creature.pick();
    writeln("You're now fighting a " ~ creature.name);
    game.fight = new Fight(creature);
  } else {
    writeln("You can't fight until you picked a healthy pokemon to fight for you");
  }
  return KeepTurn;
}
void quit(Game game) {
  throw new InterruptException();
}
void attackSlash(Game game) {
  if (game.player.mp >= 3) {
    game.player.mp -= 3;
    game.fight;
  }
  return KeepTurn;
}
void attackFire(Game game) {
}
void attackGamble(Game game) {
}
void attackRest(Game game) {
}

void magicCatch(Game game) {
  immutable CHANCES = 3;
  if (game.player.hasCreature) {
    writeln("TODO");
  } else if (uniform(1, CHANCES) == 1) {
    writeln("You got a " ~ game.fight.creature.name);
    game.player.creatures ~= game.fight.creature;
    game.fight = null;
  } else {
    writeln(game.fight.creature.name ~ " scared you away from the fight");
    game.fight = null;
  }
  return KeepTurn;
}
void quit(Game game) {
  throw new InterruptException();
}
void flee(Game game) {
  game.fight = null;
  return KeepTurn;
}
