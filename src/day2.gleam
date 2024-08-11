import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/result
import gleam/string
import utils

pub fn main() {
  part1() |> string.append("1. ", _) |> io.println
  part2() |> string.append("2. ", _) |> io.println
}

pub fn part1() -> String {
  utils.map_reduce(
    2,
    list.filter_map(_, possible(_, red: 12, green: 13, blue: 14)),
    int.sum,
  )
}

pub fn part2() -> String {
  utils.map_reduce(2, list.filter_map(_, game_power), int.sum)
}

type Round {
  Round(r: Int, g: Int, b: Int)
}

fn possible(
  line: String,
  red r: Int,
  green g: Int,
  blue b: Int,
) -> Result(Int, Nil) {
  use #(game_id, rounds) <- result.try(game_rounds(line))
  let impossible =
    rounds |> list.any(fn(round) { round.r > r || round.g > g || round.b > b })
  case impossible {
    False -> Ok(game_id)
    True -> Error(Nil)
  }
}

fn game_power(line: String) -> Result(Int, Nil) {
  use #(_, rounds) <- result.try(line |> game_rounds)
  let round = max_round(rounds, Round(0, 0, 0))
  Ok(round.r * round.g * round.b)
}

fn max_round(rounds: List(Round), max: Round) -> Round {
  case rounds {
    [] -> max
    [next, ..rest] -> {
      let new_max =
        Round(
          int.max(max.r, next.r),
          int.max(max.g, next.g),
          int.max(max.b, next.b),
        )
      max_round(rest, new_max)
    }
  }
}

fn game_rounds(line: String) -> Result(#(Int, List(Round)), Nil) {
  let assert Ok(re) = regex.from_string("Game ([1-9]\\d*):\\s+(.+)")
  let assert Ok(semicolon) = regex.from_string("\\s*;\\s*")
  case regex.scan(re, line) {
    [regex.Match(_, [Some(id_match), Some(rounds)])] -> {
      use game_id <- result.try(int.parse(id_match))
      Ok(#(
        game_id,
        regex.split(semicolon, rounds)
          |> list.map(decode_round),
      ))
    }
    _ -> Error(Nil)
  }
}

fn decode_round(round: String) -> Round {
  let assert Ok(re) = regex.from_string("([1-9]\\d*)\\s+(red|green|blue)")
  let d =
    regex.scan(re, round)
    |> list.map(fn(match) {
      let assert [Some(count_str), Some(color)] = match.submatches
      let assert Ok(count) = int.parse(count_str)
      #(color, count)
    })
    |> dict.from_list
  let red = dict.get(d, "red") |> result.unwrap(0)
  let green = dict.get(d, "green") |> result.unwrap(0)
  let blue = dict.get(d, "blue") |> result.unwrap(0)
  Round(red, green, blue)
}
