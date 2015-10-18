import std.algorithm.searching : find;

auto first(alias pred, InputRange)(InputRange haystack) {
  return find!pred(haystack)[0];
}
