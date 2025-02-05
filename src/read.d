import std.stdio : writeln, stdin;
import std.conv : to, ConvException;
import std.string : chomp;
import exception : InterruptException;

string readLine() {
  auto line = stdin.readln().chomp();
  if (stdin.eof) {
    // I didn't find a way to "clear" the stdin.eof state,
    // so just end the game...
    throw new InterruptException();
  }
  return line;
}

int readInt(string message) {
  while (1) {
    writeln(message);
    try {
      return to!int(readLine());
    } catch (ConvException e) {
      writeln("");
    }
  }
}

int readBetween(string message, int low, int high)
in {
  assert(low <= high);
}
out (result) {
  assert(result >= low && result <= high);
}
body {
  if (low != high) {
    message ~= " (between " ~ to!string(low) ~ " and " ~ to!string(high) ~ ")";
  } else {
    message ~= " (you can only pick " ~ to!string(low) ~ ")";
  }

  int n;
  do {
    n = readInt(message);
  }
  while (n < low || n > high);
  return n;
}
