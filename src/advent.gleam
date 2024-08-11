import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import gleam/int
import gleam/io
import gleam/iterator

pub fn main() {
  use day <- iterator.find(iterator.range(1, 25))
  io.println("Day " <> int.to_string(day) <> ":")
  day_n_main(day)
}

fn day_n_main(day: Int) -> Bool {
  case day {
    1 -> day1.main() != Nil
    2 -> day2.main() != Nil
    3 -> day3.main() != Nil
    4 -> day4.main() != Nil
    5 -> day5.main() != Nil
    6 -> day6.main() != Nil
    7 -> day7.main() != Nil
    8 -> day8.main() != Nil
    num if num <= 25 -> io.println("1. Unimplemented\n2. Unimplemented") == Nil
    _ -> panic as "Invalid Advent day"
  }
}
