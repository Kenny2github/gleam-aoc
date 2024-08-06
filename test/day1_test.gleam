import day1
import gleeunit/should
import utils

pub fn part1_test() {
  let golden = utils.read_output(1, 1)
  should.equal(golden, day1.part1())
}

pub fn part2_test() {
  let golden = utils.read_output(1, 2)
  should.equal(golden, day1.part2())
}
