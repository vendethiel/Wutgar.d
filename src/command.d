import std.stdio;
import std.random : uniform;
import exception : InterruptException;
import game;
import player;
import fight;
import creature;

enum CommandReturn {
  ConsumeTurn,
  KeepTurn,
}

alias command = void function(Game);

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
}
void pickPokemon(Game game) { }
void startFight(Game game) {
  auto creature = creature.pick();
  writeln("You're now fighting a " ~ creature.name);
  game.fight = new Fight(creature);
}
void quit(Game game) { }
void attackSlash(Game game) { }
void attackFire(Game game) { }
void attackGamble(Game game) { }
void attackRest(Game game) { }
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
}
void quit(Game game) {
  throw new InterruptException();
}
void flee(Game game) {
  game.fight = null;
}
