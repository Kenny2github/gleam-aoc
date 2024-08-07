import day3
import gleeunit/should
import utils

pub fn part1_test() {
  let golden = utils.read_output(3, 1)
  should.equal(golden, day3.part1())
}

pub fn part2_test() {
  let golden = utils.read_output(3, 2)
  should.equal(golden, day3.part2())
}
