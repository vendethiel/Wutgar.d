import game;
import player;
import std.stdio;
import fight : FightState;

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

  auto applicableActions = actions[game.fightState];
  return applicableActions.get(name, null);
}


void listTeam(Game game) {
  foreach (creature; game.player.creatures) {
    writeln("Pokemon: " ~ creature.name);
  }
}
void pickPokemon(Game game) { }
void startFight(Game game) {
}
void quit(Game game) { }
void attackSlash(Game game) { }
void attackFire(Game game) { }
void attackGamble(Game game) { }
void attackRest(Game game) { }
void magicCatch(Game game) { }
void quit(Game game) {
  game.playing = false;
}
void flee(Game game) {
  game.fight = null;
}
