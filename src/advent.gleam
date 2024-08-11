import day1
import day2
import day3
import day4
import day5
import day6
import gleam/int
import gleam/io
import gleam/iterator

pub fn main() {
  use day <- iterator.each(iterator.range(1, 25))
  io.println("Day " <> int.to_string(day) <> ":")
  day_n_main(day)
}

fn day_n_main(day: Int) -> Nil {
  case day {
    1 -> day1.main()
    2 -> day2.main()
    3 -> day3.main()
    4 -> day4.main()
    5 -> day5.main()
    6 -> day6.main()
    num if num <= 25 -> io.println("1. Unimplemented\n2. Unimplemented")
    _ -> panic as "Invalid Advent day"
  }
}
