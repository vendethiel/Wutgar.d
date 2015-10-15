import creature;

class Player {
  string name;
  Creature[] creatures;

  this(string name) {
    this.name = name;
  }

  @property bool hasCreature() {
    return creatures.length > 0;
  }
}
