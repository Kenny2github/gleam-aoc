import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/order
import gleam/regex
import gleam/result
import gleam/string
import utils

pub fn main() {
  part1() |> string.append("1. ", _) |> io.println
  part2() |> string.append("2. ", _) |> io.println
}

pub fn part1() -> String {
  utils.map_reduce(7, winnings(_, num_order, make_hand), int.sum)
}

pub fn part2() -> String {
  utils.map_reduce(7, winnings(_, joke_order, make_best_hand(_, 12)), int.sum)
}

const num_order = "AKQJT98765432"

const joke_order = "AKQT98765432J"

type Hand {
  Quintuplet(cards: List(Int), rank: Int)
  Quadruplet(cards: List(Int), rank: Int)
  FullHouse(cards: List(Int), rank: Int)
  Triplet(cards: List(Int), rank: Int)
  TwoPair(cards: List(Int), rank: Int)
  OnePair(cards: List(Int), rank: Int)
  HighCard(cards: List(Int), rank: Int)
}

fn count_cards(cards: List(Int)) -> List(#(Int, Int)) {
  list.fold(cards, dict.new(), fn(counts, card) {
    counts
    |> dict.insert(card, case dict.get(counts, card) {
      Ok(count) -> count + 1
      Error(Nil) -> 1
    })
  })
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(a.1, b.1) })
}

fn make_hand(cards: List(Int)) -> Result(Hand, Nil) {
  case count_cards(cards) {
    [#(_, 5)] -> Ok(Quintuplet(cards, 1))
    [#(_, 1), #(_, 4)] -> Ok(Quadruplet(cards, 2))
    [#(_, 2), #(_, 3)] -> Ok(FullHouse(cards, 3))
    [#(_, 1), #(_, 1), #(_, 3)] -> Ok(Triplet(cards, 4))
    [#(_, 1), #(_, 2), #(_, 2)] -> Ok(TwoPair(cards, 5))
    [#(_, 1), #(_, 1), #(_, 1), #(_, 2)] -> Ok(OnePair(cards, 6))
    [#(_, 1), #(_, 1), #(_, 1), #(_, 1), #(_, 1)] -> Ok(HighCard(cards, 7))
    _ -> Error(Nil)
  }
}

fn make_best_hand(cards: List(Int), wild: Int) -> Result(Hand, Nil) {
  let no_wild =
    cards
    |> list.filter(fn(card) { card != wild })
  let highest =
    no_wild
    |> list.reduce(int.min)
    |> result.unwrap(0)
  let #(mode, _) =
    count_cards(no_wild)
    |> list.reduce(fn(a, b) { bool.guard(a.1 > b.1, a, fn() { b }) })
    |> result.unwrap(#(highest, -1))
  case
    cards
    |> list.map(fn(card) { bool.guard(card == wild, mode, fn() { card }) })
    |> make_hand
  {
    Ok(Quintuplet(_, rank)) -> Ok(Quintuplet(cards, rank))
    Ok(Quadruplet(_, rank)) -> Ok(Quadruplet(cards, rank))
    Ok(FullHouse(_, rank)) -> Ok(FullHouse(cards, rank))
    Ok(Triplet(_, rank)) -> Ok(Triplet(cards, rank))
    Ok(TwoPair(_, rank)) -> Ok(TwoPair(cards, rank))
    Ok(OnePair(_, rank)) -> Ok(OnePair(cards, rank))
    Ok(HighCard(_, rank)) -> Ok(HighCard(cards, rank))
    Error(x) -> Error(x)
  }
}

fn compare_hands(a: Hand, b: Hand) -> order.Order {
  list.zip([a.rank, ..a.cards], [b.rank, ..b.cards])
  |> list.map(fn(cards) { int.compare(cards.0, cards.1) })
  |> list.find(fn(ord) { ord != order.Eq })
  |> result.lazy_unwrap(fn() { panic as "input should not contain equal hands" })
}

fn make_cards(line: String, ord: String) -> List(Int) {
  line
  |> string.to_graphemes
  |> list.map(fn(char) {
    ord
    |> string.to_graphemes
    |> list.index_map(fn(c, i) { #(c == char, i) })
    |> list.find(fn(x) { x.0 })
    |> result.map(fn(x) { x.1 })
    |> result.lazy_unwrap(fn() {
      panic as { "could not find char " <> " in " <> ord }
    })
  })
}

fn winnings(
  lines: List(String),
  ord: String,
  hand_maker: fn(List(Int)) -> Result(Hand, Nil),
) -> List(Int) {
  let assert Ok(re) = regex.from_string("([" <> num_order <> "]{5})\\s+(\\d+)")
  lines
  |> list.map(fn(line) {
    let assert [regex.Match(_, [Some(cards_str), Some(bid_str)])] =
      regex.scan(re, line)
    {
      use bid <- result.try(int.parse(bid_str))
      use hand <- result.try(cards_str |> make_cards(ord) |> hand_maker)
      Ok(#(hand, bid))
    }
    |> result.lazy_unwrap(fn() { panic as { "failed to parse " <> line } })
  })
  |> list.sort(fn(a, b) { compare_hands(a.0, b.0) |> order.negate })
  |> list.index_map(fn(bid, i) { bid.1 * { i + 1 } })
}
