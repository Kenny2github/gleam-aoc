import argv
import gleam/int
import gleam/iterator
import gleam/list
import gleam/result
import gleam/string
import gleeunit/should
import simplifile

pub fn read_input(day day: Int) -> String {
  let suffix = argv.load().arguments |> list.last |> result.unwrap("")
  let assert Ok(content) =
    simplifile.read(
      "inputs" <> suffix <> "/day" <> int.to_string(day) <> ".txt",
    )
  content |> string.trim |> string.replace("\r\n", "\n")
}

pub fn read_output(day day: Int, part part: Int) -> String {
  let suffix = argv.load().arguments |> list.last |> result.unwrap("")
  let assert Ok(content) =
    simplifile.read(
      "outputs" <> suffix <> "/day" <> int.to_string(day) <> ".txt",
    )
  let assert Ok(output) =
    content
    |> string.trim
    |> string.replace("\r\n", "\n")
    |> string.split("\n")
    |> iterator.from_list
    |> iterator.at(part - 1)
  output
}

pub fn map_reduce(
  day day: Int,
  map map: fn(List(String)) -> List(Int),
  reduce reduce: fn(List(Int)) -> Int,
) -> String {
  read_input(day) |> string.split("\n") |> map |> reduce |> int.to_string
}

pub fn test_part(day day: Int, part part: Int, code code: fn() -> String) -> Nil {
  let golden = read_output(day, part)
  should.equal(code(), golden)
}
