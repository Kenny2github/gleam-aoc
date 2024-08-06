import day2
import gleeunit/should
import utils

pub fn part1_test() {
  let golden = utils.read_output(2, 1)
  should.equal(golden, day2.part1())
}

pub fn part2_test() {
  let golden = utils.read_output(2, 2)
  should.equal(golden, day2.part2())
}
