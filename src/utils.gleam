import gleam/int
import gleam/iterator
import gleam/string
import simplifile

pub fn read_input(day day: Int) -> String {
  let assert Ok(content) =
    simplifile.read("inputs/day" <> int.to_string(day) <> ".txt")
  content |> string.trim |> string.replace("\r\n", "\n")
}

pub fn read_output(day day: Int, part part: Int) -> String {
  let assert Ok(content) =
    simplifile.read("outputs/day" <> int.to_string(day) <> ".txt")
  let assert Ok(output) =
    content
    |> string.trim
    |> string.replace("\r\n", "\n")
    |> string.split("\n")
    |> iterator.from_list
    |> iterator.at(part - 1)
  output
}
