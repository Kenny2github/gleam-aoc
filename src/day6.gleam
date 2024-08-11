import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/string
import utils

pub fn main() {
  part1() |> string.append("1. ", _) |> io.println
  part2() |> string.append("2. ", _) |> io.println
}

pub fn part1() -> String {
  utils.map_reduce(6, part(_, read_races), int.product)
}

pub fn part2() -> String {
  utils.map_reduce(6, part(_, read_race), int.product)
}

fn part(
  lines: List(String),
  read_fn: fn(List(String)) -> List(Race),
) -> List(Int) {
  lines |> read_fn |> list.map(solve_race)
}

type Race {
  Race(time: Int, distance: Int)
}

fn read_races(lines: List(String)) -> List(Race) {
  let assert Ok(re) = regex.from_string("\\d+")
  let assert ["Time:" <> times_str, "Distance:" <> distances_str] = lines
  let assert [times, distances] =
    [times_str, distances_str]
    |> list.map(fn(s) {
      regex.scan(re, s)
      |> list.filter_map(fn(m) { m.content |> int.parse })
    })
  list.zip(times, distances) |> list.map(fn(r) { Race(r.0, r.1) })
}

fn read_race(lines: List(String)) -> List(Race) {
  let assert Ok(re) = regex.from_string("\\d+")
  let assert ["Time:" <> times_str, "Distance:" <> distances_str] = lines
  let assert [time, distance] =
    [times_str, distances_str]
    |> list.filter_map(fn(s) {
      regex.scan(re, s)
      |> list.map(fn(m) { m.content })
      |> string.join("")
      |> int.parse
    })
  [Race(time, distance)]
}

fn solve_race(race: Race) -> Int {
  // Quadratic inequality: x * {race.time - x} > race.distance
  let assert Ok(sqrt_delta) =
    int.square_root(race.time * race.time - 4 * race.distance)
  let min =
    {
      { int.to_float(race.time) -. sqrt_delta } /. 2.0
      |> float.floor
      |> float.truncate
    }
    + 1
  let max =
    {
      { int.to_float(race.time) +. sqrt_delta } /. 2.0
      |> float.ceiling
      |> float.truncate
    }
    - 1
  max - min + 1
}
