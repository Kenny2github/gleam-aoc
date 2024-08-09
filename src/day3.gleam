import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/result
import gleam/set
import gleam/string
import utils

pub fn main() {
  part1() |> string.append("1. ", _) |> io.println
  part2() |> string.append("2. ", _) |> io.println
}

pub fn part1() -> String {
  utils.map_reduce(3, symbol_nums, int.sum)
}

pub fn part2() -> String {
  utils.map_reduce(3, gear_ratios, int.sum)
}

type Pos {
  Pos(row: Int, col: Int)
}

const adjacent = [
  Pos(-1, -1), Pos(-1, 0), Pos(-1, 1), Pos(0, -1), Pos(0, 1), Pos(1, -1),
  Pos(1, 0), Pos(1, 1),
]

fn symbol_nums(lines: List(String)) -> List(Int) {
  let nums = numbers(lines)
  lines
  |> symbols("")
  |> list.flat_map(fn(pos) { collect_nums(pos, adjacent, nums, set.new()) })
}

fn gear_ratios(lines: List(String)) -> List(Int) {
  let nums = numbers(lines)
  lines
  |> symbols("*")
  |> list.filter_map(fn(pos) {
    case collect_nums(pos, adjacent, nums, set.new()) {
      [a, b] -> Ok(a * b)
      _ -> Error(Nil)
    }
  })
}

fn collect_nums(
  symbol_pos: Pos,
  deltas: List(Pos),
  nums: dict.Dict(Pos, Int),
  seen: set.Set(Int),
) -> List(Int) {
  case deltas {
    [] -> []
    [delta, ..rest] -> {
      {
        let pos = Pos(symbol_pos.row + delta.row, symbol_pos.col + delta.col)
        use num <- result.try(dict.get(nums, pos))
        case set.contains(seen, num) {
          True -> Error(Nil)
          False ->
            Ok([
              num,
              ..collect_nums(symbol_pos, rest, nums, set.insert(seen, num))
            ])
        }
      }
      |> result.lazy_unwrap(fn() { collect_nums(symbol_pos, rest, nums, seen) })
    }
  }
}

fn symbols(lines: List(String), symbol: String) -> List(Pos) {
  lines
  |> list.index_map(fn(line, row) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, col) {
      case isdigit(char) || char == "." || !string.contains(char, symbol) {
        False -> Ok(Pos(row, col))
        True -> Error(Nil)
      }
    })
    |> list.filter_map(function.identity)
  })
  |> list.flat_map(function.identity)
}

fn numbers(lines: List(String)) -> dict.Dict(Pos, Int) {
  let assert Ok(re) = regex.from_string("[0-9]+")
  lines
  |> list.index_map(fn(line, row) {
    let nums =
      line
      |> regex.scan(re, _)
      |> list.filter_map(fn(match) { match.content |> int.parse })
    line
    |> string.to_graphemes
    |> number_poses(0, nums, ".")
    |> list.map(fn(pair) { #(Pos(row, pair.0), pair.1) })
  })
  |> list.flat_map(function.identity)
  |> dict.from_list
}

fn number_poses(
  chars: List(String),
  col: Int,
  nums: List(Int),
  last_char: String,
) -> List(#(Int, Int)) {
  case chars {
    [] -> []
    [char, ..rest] ->
      case isdigit(last_char), isdigit(char) {
        False, False -> number_poses(rest, col + 1, nums, char)
        _, True -> {
          let assert [num, ..] = nums
          [#(col, num), ..number_poses(rest, col + 1, nums, char)]
        }
        True, False -> {
          let assert [_, ..remaining] = nums
          number_poses(rest, col + 1, remaining, char)
        }
      }
  }
}

fn isdigit(c: String) -> Bool {
  string.contains("0123456789", c)
}
