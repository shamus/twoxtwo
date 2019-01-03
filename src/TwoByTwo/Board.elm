module TwoByTwo.Board exposing (Board, default)

type alias Board =
  { uuid : String
  , xAxis : String
  , yAxis : String
  }

default : String -> Board
default uuid =
  { uuid  = uuid
  , xAxis = ""
  , yAxis = ""
  }
