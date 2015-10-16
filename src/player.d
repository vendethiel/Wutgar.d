import creature;

class Player {
  string name;
  Creature[] creatures;
  uint selectedId; // 0 if empty, otherwise 1-indexed into `creatures`

  this(string name) {
    this.name = name;
  }

  @property bool hasCreature() {
    return creatures.length > 0;
  }

  @property bool canStartFight() {
    // we're always allowed to fight if we're going
    // to capture our first pokemon
    if (!hasCreature) {
      return true;
    }
    // otherwise, ensure we have a champion
    // TODO "healthy" check?
    return selectedCreature !is null;
  }

  @property Creature selectedCreature() {
    if (creatures.length < selectedId || !selectedId) {
      // 0... what if we don't have any pokemons?
      selectedId = 0;
      return null;
    } else {
      return creatures[selectedId - 1];
    }
  }
}
