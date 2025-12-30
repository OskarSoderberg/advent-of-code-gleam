import gleam/int
import gleam/list
import gleam/string

pub type Direction {
  Left
  Right
}

pub type Rotation {
  Rotation(direction: Direction, steps: Int)
}

type Scorer =
  fn(Int, Rotation) -> Int

type DialState {
  DialState(pointer: Int, clicks: Int)
}

pub fn parse(input: String) -> List(Rotation) {
  string.split(input, on: "\n")
  |> list.map(fn(line: String) {
    let direction = case string.first(line) {
      Ok("R") -> Right
      Ok("L") -> Left
      _ -> panic
    }
    let assert Ok(steps) = string.drop_start(line, 1) |> int.parse()
    Rotation(direction, steps)
  })
}

fn next_pointer(pointer: Int, rotation: Rotation) -> Int {
  let assert Ok(new_pointer) = case rotation.direction {
    Right -> int.modulo(pointer + rotation.steps, 100)
    Left -> int.modulo(pointer - rotation.steps, 100)
  }
  new_pointer
}

fn dial(state: DialState, rotation: Rotation, scorer: Scorer) -> DialState {
  let score = scorer(state.pointer, rotation)

  DialState(next_pointer(state.pointer, rotation), state.clicks + score)
}

// --- Part 1 ---

fn scorer1(pointer: Int, rotation: Rotation) {
  case next_pointer(pointer, rotation) {
    0 -> 1
    _ -> 0
  }
}

pub fn pt_1(input: List(Rotation)) {
  let dial1 = fn(state, rotation) { dial(state, rotation, scorer1) }
  list.fold(input, DialState(50, 0), dial1).clicks
}

// pub fn pt_1(input: List(Rotation)) {
//   list.fold(input, [50], fn(acc, x) {
//     let assert Ok(current) = list.first(acc)
//     let next = case x.direction {
//       "R" -> current + x.steps
//       "L" -> current - x.steps
//       _ -> panic
//     }
//     list.append([next], acc)
//   })
//   |> list.fold(0, fn(acc, x) {
//     let assert Ok(dial) = int.modulo(x, 100)
//     case dial == 0 {
//       True -> acc + 1
//       False -> acc
//     }
//   })
//   |> echo
// }

// --- Part 2 ---

fn scorer2(pointer: Int, rotation: Rotation) {
  let assert Ok(laps) = int.divide(rotation.steps, 100)
  let assert Ok(change) = int.modulo(rotation.steps, 100)

  let zero_pass =
    pointer != 0
    && case rotation.direction {
      Right -> pointer + change > 100
      Left -> pointer - change < 0
    }
  let zero_pass_bonus = case zero_pass {
    True -> 1
    _ -> 0
  }

  case next_pointer(pointer, rotation) {
    0 -> laps + 1
    _ -> laps + zero_pass_bonus
  }
}

pub fn pt_2(input: List(Rotation)) {
  let dial2 = fn(state, rotation) { dial(state, rotation, scorer2) }
  list.fold(input, DialState(50, 0), dial2).clicks
}
