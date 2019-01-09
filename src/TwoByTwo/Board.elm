module TwoByTwo.Board exposing (Board, addCard, cards, default, initialize, proposePlacement, updateProposedPlacement, acceptPlacement, rejectPlacement, proposedPlacement, updateXAxis, updateYAxis, showCardForm, placements, isPlaced)

import Dict exposing (Dict)
import Maybe exposing (Maybe)

import TwoByTwo.Card exposing (Card)
import TwoByTwo.Coordinates exposing (DomCoordinates, SvgCoordinates)

type alias ActivePlacement =
  { card : Card
  , starting : DomCoordinates
  , delta : DomCoordinates
  }

type alias Board =
  { uuid : String
  , xAxis : String
  , yAxis : String
  , showCardForm : Bool
  , cards : Dict String Card
  , placing : Maybe ActivePlacement
  , placements : Dict String SvgCoordinates
  }

default : String -> Board
default uuid =
  { uuid  = uuid
  , xAxis = ""
  , yAxis = ""
  , showCardForm = False
  , cards = Dict.empty
  , placing = Nothing
  , placements = Dict.empty
  }

initialize : String -> String -> String -> List Card -> Dict String SvgCoordinates -> Board
initialize uuid xAxis yAxis cardList placementDict =
  let cardDict =
        cardList
        |> List.map (\c -> (c.uuid, c))
        |> Dict.fromList
  in

  { uuid = uuid, showCardForm = False, xAxis = xAxis, yAxis = yAxis, cards = cardDict, placing = Nothing, placements = placementDict }

updateXAxis : String -> Board -> Board
updateXAxis value board =
  { board | xAxis = value }

updateYAxis : String -> Board -> Board
updateYAxis value board =
  { board | yAxis = value }

showCardForm : Board -> Board
showCardForm board =
  { board | showCardForm = True }

cards : Board -> List Card
cards board =
  Dict.values board.cards

addCard : Card -> Board -> Board
addCard card board =
  let updatedCards = Dict.insert card.uuid card board.cards in
  { board | cards = updatedCards, showCardForm = False }

isPlaced : Card -> Board -> Bool
isPlaced card board =
  Dict.member card.uuid board.placements

placements : Board -> List (Card, SvgCoordinates)
placements board =
  let getCard cardId =
        case Dict.get cardId board.cards of
          Just card ->
            card

          Nothing ->
            Debug.todo "impossible"
  in

  Dict.toList board.placements
  |> List.map (\(cardId, coords) -> (getCard cardId, coords))

proposePlacement : (Card, DomCoordinates) -> Board -> Board
proposePlacement (card, coords) board =
  let placing = { card = card, starting = coords, delta = TwoByTwo.Coordinates.defaultDom } in
  { board | placing = Just placing }

updateProposedPlacement : DomCoordinates -> Board -> Board
updateProposedPlacement delta board =
  case board.placing of
    Just placing ->
      let updatedDelta = TwoByTwo.Coordinates.add placing.delta delta in
      { board | placing = Just { placing | delta = updatedDelta } }

    Nothing ->
      Debug.todo "impossible"

acceptPlacement : (Card, SvgCoordinates) -> Board -> Board
acceptPlacement (card, coords) board =
  { board | placements = Dict.insert card.uuid coords board.placements, placing = Nothing }

rejectPlacement : (Card, SvgCoordinates) -> Board -> Board
rejectPlacement (card, _) board =
  { board | placements = Dict.remove card.uuid board.placements, placing = Nothing }

proposedPlacement : Board -> Maybe (Card, DomCoordinates)
proposedPlacement board =
  board.placing
  |> Maybe.map (\p -> (p.card, TwoByTwo.Coordinates.add p.starting p.delta ))
