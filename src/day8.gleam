import gleam/dict
import gleam/int
import gleam/io
import gleam/iterator
import gleam/list
import gleam/option.{Some}
import gleam/pair
import gleam/regex
import gleam/string
import utils

pub fn main() {
  part1() |> string.append("1. ", _) |> io.println
  part2() |> string.append("2. ", _) |> io.println
}

pub fn part1() -> String {
  utils.map_reduce(8, steps(_, single_director), int.sum)
}

pub fn part2() -> String {
  utils.map_reduce(8, steps(_, parallel_director), int.sum)
}

fn steps(
  lines: List(String),
  director: fn(iterator.Iterator(String), dict.Dict(String, #(String, String))) ->
    Int,
) -> List(Int) {
  let assert [directions, "", ..rest] = lines
  let map = tree(rest)
  directions
  |> string.to_graphemes
  |> iterator.from_list
  |> iterator.cycle
  |> director(map)
  |> list.wrap
}

fn tree(lines: List(String)) -> dict.Dict(String, #(String, String)) {
  let assert Ok(re) =
    regex.from_string(
      "([0-9A-Z]+)\\s*=\\s*\\(\\s*([0-9A-Z]+)\\s*,\\s*([0-9A-Z]+)\\s*\\)",
    )
  lines
  |> list.fold(dict.new(), fn(map, line) {
    let assert [regex.Match(_, [Some(from), Some(left), Some(right)])] =
      regex.scan(re, line)
    map |> dict.insert(from, #(left, right))
  })
}

fn single_director(
  directions: iterator.Iterator(String),
  map: dict.Dict(String, #(String, String)),
) -> Int {
  directions
  |> iterator.fold_until(#("AAA", 0), fn(state, dir) {
    let assert Ok(entry) = map |> dict.get(state.0)
    let next = case dir {
      "L" -> entry.0
      "R" -> entry.1
      _ -> panic as { "invalid direction character " <> dir }
    }
    let pair = #(next, state.1 + 1)
    case next {
      "ZZZ" -> list.Stop(pair)
      _ -> list.Continue(pair)
    }
  })
  |> pair.second
}

fn gcd(a: Int, b: Int) -> Int {
  case a, b {
    _, 0 -> int.absolute_value(a)
    _, _ -> gcd(b, a % b)
  }
}

fn lcm(a: Int, b: Int) -> Int {
  int.absolute_value(a * b) / gcd(a, b)
}

fn parallel_director(
  directions: iterator.Iterator(String),
  map: dict.Dict(String, #(String, String)),
) -> Int {
  let start = map |> dict.keys |> list.filter(string.ends_with(_, "A"))
  let assert Ok(count) =
    start
    |> list.map(fn(from) {
      directions
      |> iterator.fold_until(#(from, 0), fn(state, dir) {
        let assert Ok(entry) = map |> dict.get(state.0)
        let next = case dir {
          "L" -> entry.0
          "R" -> entry.1
          _ -> panic as { "invalid direction character " <> dir }
        }
        let pair = #(next, state.1 + 1)
        case next |> string.ends_with("Z") {
          True -> list.Stop(pair)
          False -> list.Continue(pair)
        }
      })
      |> pair.second
    })
    |> list.reduce(lcm)
  count
}
