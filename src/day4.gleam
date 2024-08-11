import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regex
import gleam/set
import gleam/string
import utils

pub fn main() {
  part1() |> string.append("1. ", _) |> io.println
  part2() |> string.append("2. ", _) |> io.println
}

pub fn part1() -> String {
  utils.map_reduce(4, list.map(_, points), int.sum)
}

pub fn part2() -> String {
  utils.map_reduce(4, cards, int.sum)
}

fn points(line: String) -> Int {
  int.bitwise_shift_left(1, wins(line) - 1)
}

fn wins(line: String) -> Int {
  let assert Ok(re) =
    regex.from_string(
      "Card\\s+([1-9]\\d*):((?:\\s+[1-9]\\d*)+)\\s*\\|((?:\\s+[1-9]\\d*)+)",
    )
  let assert Ok(ws) = regex.from_string("\\s+")
  let assert [regex.Match(_, [Some(_), Some(winning_str), Some(nums_str)]), ..] =
    regex.scan(re, line)
  let winning =
    winning_str
    |> string.trim
    |> regex.split(ws, _)
    |> list.filter_map(int.parse)
    |> set.from_list
  let nums =
    nums_str
    |> string.trim
    |> regex.split(ws, _)
    |> list.filter_map(int.parse)
    |> set.from_list
  set.intersection(winning, nums) |> set.size
}

fn cards(lines: List(String)) -> List(Int) {
  let all_wins = lines |> list.map(wins)
  let #(_, counts) =
    all_wins
    |> list.map_fold(list.repeat(1, list.length(all_wins)), fn(counts, winc) {
      let assert [count, ..rest] = counts
      #(
        rest
          |> list.index_map(fn(x, i) {
            case i < winc {
              True -> x + count
              False -> x
            }
          }),
        count,
      )
    })
  counts
}
