module TwoByTwo.Board exposing (Board, Card, default)

type alias Card =
  { uuid : String
  , text : String
  }

type alias Board =
  { uuid : String
  , xAxis : String
  , yAxis : String
  , showCardForm : Bool
  , cards : List Card
  }

default : String -> Board
default uuid =
  { uuid  = uuid
  , xAxis = ""
  , yAxis = ""
  , showCardForm = False
  , cards = []
  }
