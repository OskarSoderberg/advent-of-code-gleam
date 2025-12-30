import gleam/float
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import nibble
import nibble/lexer

type Token {
  Num(Int)
  Comma
  Hyphen
}

pub type Range {
  Range(from: Int, to: Int)
}

pub fn parse(input: String) -> List(Range) {
  let lexer =
    lexer.simple([
      lexer.int(Num),
      lexer.token(",", Comma),
      lexer.token("-", Hyphen),
      lexer.whitespace(Nil)
        |> lexer.ignore,
    ])

  let int_parser = {
    nibble.take_map("expected number", fn(tok) {
      case tok {
        Num(n) -> option.Some(n)
        _ -> option.None
      }
    })
  }

  let parser = {
    use from <- nibble.do(int_parser)
    use _ <- nibble.do(nibble.token(Hyphen))
    use to <- nibble.do(int_parser)

    nibble.return(Range(from, to))
  }

  let assert Ok(tokens) = lexer.run(input, lexer)
  let assert Ok(points) =
    nibble.run(tokens, nibble.sequence(parser, nibble.token(Comma)))

  points
}

fn is_even_digits(number: Int) {
  int.to_string(number)
  |> string.length()
  |> int.is_even()
}

/// Takes in a number with an even amount of digits and returns the two numbers resulting from splitting it in two
fn get_first_half(even_digits_number: Int) -> Int {
  let string_number = int.to_string(even_digits_number)
  let length = string.length(string_number)
  let split_pos = length / 2
  let assert Ok(result) =
    int.parse(string.slice(from: string_number, at_index: 0, length: split_pos))
  result
}

fn get_repeated(number: Int) -> Int {
  let assert Ok(repeated) =
    int.parse(int.to_string(number) <> int.to_string(number))
  repeated
}

fn get_invalid_ids(from: Int, to: Int, invalid_ids: List(Int)) {
  let half_from_repeated = get_first_half(from) |> get_repeated()
  let next_from = get_first_half(from) + 1 |> get_repeated()

  let next_from = case is_even_digits(half_from_repeated) {
    True -> next_from
    False -> next_from * 10
  }

  let ids = case half_from_repeated < to {
    True -> get_invalid_ids(next_from, to, [half_from_repeated, ..invalid_ids])
    False -> invalid_ids
  }

  ids
}

pub fn pt_1(input: List(Range)) {
  list.fold(over: input, from: [], with: fn(acc, range) {
    let next_from = case is_even_digits(range.from) {
      True -> range.from
      False ->
        range.from
        |> int.to_string()
        |> string.length
        |> int.to_float()
        |> int.power(10, _)
        |> result.unwrap(1.0)
        |> float.round()
    }
    get_invalid_ids(next_from, range.to, acc)
  })
  // |> list.reduce(fn(acc, x) { acc + x })
}

pub fn pt_2(input: List(Range)) {
  echo "hello"
}
