class ControlFlowException : Throwable {
  this(string message) {
    super(message);
  }
}

class InterruptException : ControlFlowException {
  this() {
    super("Game was interrupted");
  }
}
