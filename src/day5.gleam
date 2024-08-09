import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

pub fn main() {
  part1() |> string.append("1. ", _) |> io.println
  part2() |> string.append("2. ", _) |> io.println
}

pub fn part1() -> String {
  utils.map_reduce(5, seeds_to_locations(_, simple_seeds), min_or_panic)
}

pub fn part2() -> String {
  utils.map_reduce(5, seeds_to_locations(_, range_seeds), min_or_panic)
}

type MapEntry {
  MapEntry(to: Int, from: Int, count: Int)
}

type SeedRange {
  SeedRange(start: Int, count: Int)
}

fn min_or_panic(locs) {
  let assert Ok(lowest) = list.reduce(locs, int.min)
  lowest
}

fn make_maps(lines: List(String)) -> List(List(MapEntry)) {
  list.fold(lines, [], fn(state, line) {
    let line = line |> string.trim
    let maybe_entry =
      line
      |> string.split(" ")
      |> list.filter_map(int.parse)
    case state {
      [] ->
        case maybe_entry {
          [to, from, count] -> [[MapEntry(to, from, count)]]
          _ if line == "" -> [[]]
          _ -> []
        }
      [first, ..rest] ->
        case maybe_entry {
          [to, from, count] -> [[MapEntry(to, from, count), ..first], ..rest]
          _ if line == "" -> [[], first, ..rest]
          _ -> [first, ..rest]
        }
    }
  })
  |> list.reverse
}

fn get_seeds(line: String) -> List(Int) {
  line
  |> string.trim
  |> string.split(" ")
  |> list.filter_map(int.parse)
}

fn simple_seeds(line: String) -> List(SeedRange) {
  line |> get_seeds |> list.map(fn(x) { SeedRange(x, 1) })
}

fn range_seeds(line: String) -> List(SeedRange) {
  line
  |> get_seeds
  |> list.sized_chunk(2)
  |> list.filter_map(fn(pair) {
    case pair {
      [start, count] -> Ok(SeedRange(start, count))
      _ -> Error(Nil)
    }
  })
}

fn seeds_to_locations(
  lines: List(String),
  seeds_fn: fn(String) -> List(SeedRange),
) -> List(Int) {
  let assert ["seeds:" <> seeds_line, ..lines] = lines
  let seeds = seeds_fn(seeds_line)
  let maps = make_maps(lines)
  list.fold(maps, seeds, map_seeds_once) |> list.map(fn(v) { v.start })
}

fn map_seeds_once(
  seeds: List(SeedRange),
  map: List(MapEntry),
) -> List(SeedRange) {
  seeds
  |> list.map(map_seed_once(_, map))
  |> list.flatten
}

fn map_seed_once(seed: SeedRange, map: List(MapEntry)) -> List(SeedRange) {
  case seed.count > 0 {
    False -> []
    True -> {
      case
        map
        |> list.find_map(fn(entry) {
          let delta = seed.start - entry.from
          case 0 <= delta && delta < entry.count {
            True ->
              Ok(SeedRange(
                entry.to + delta,
                int.min(entry.count - delta, seed.count),
              ))
            False -> Error(Nil)
          }
        })
      {
        Error(_) -> [seed]
        Ok(range) -> [
          range,
          ..map_seed_once(
            SeedRange(seed.start + range.count, seed.count - range.count),
            map,
          )
        ]
      }
    }
  }
}
