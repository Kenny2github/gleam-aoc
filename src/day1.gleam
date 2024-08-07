import gleam/dict
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
  utils.run_part(1, list.map(_, line_digit_num))
}

pub fn part2() -> String {
  utils.run_part(1, list.map(_, line_word_num))
}

fn line_digit_num(line line: String) -> Int {
  line
  |> string.to_graphemes
  |> list.filter_map(int.parse)
  |> digits_to_num(line)
}

const num_words = "one|two|three|four|five|six|seven|eight|nine"

const words_list = [
  #("one", 1), #("1", 1), #("two", 2), #("2", 2), #("three", 3), #("3", 3),
  #("four", 4), #("4", 4), #("five", 5), #("5", 5), #("six", 6), #("6", 6),
  #("seven", 7), #("7", 7), #("eight", 8), #("8", 8), #("nine", 9), #("9", 9),
]

fn line_word_num(line line: String) -> Int {
  let assert Ok(re_forth) = regex.from_string(num_words <> "|[1-9]")
  let assert Ok(re_back) =
    regex.from_string(string.reverse(num_words) <> "|[1-9]")
  let words = dict.from_list(words_list)
  let assert Ok(first) = regex.scan(re_forth, line) |> list.first
  let assert Ok(first) = dict.get(words, first.content)
  let assert Ok(last) =
    regex.scan(re_back, line |> string.reverse) |> list.first
  let assert Ok(last) = dict.get(words, last.content |> string.reverse)
  digits_to_num([first, last], line)
}

fn digits_to_num(digits: List(Int), line line: String) -> Int {
  let digits = case digits {
    [] -> {
      io.debug(line)
      panic as "no digits in line"
    }
    [only] -> #(only, only)
    [first, ..rest] -> {
      let assert Ok(last) = list.last(rest)
      #(first, last)
    }
  }
  digits.0 * 10 + digits.1
}
