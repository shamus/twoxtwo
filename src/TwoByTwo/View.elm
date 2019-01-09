module TwoByTwo.View exposing (render)

import Dict exposing (Dict)
import Draggable
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Svg exposing (Svg)
import Svg.Attributes as A

import TwoByTwo.Board exposing (Board)
import TwoByTwo.Card exposing (Card)
import TwoByTwo.Coordinates exposing (DomCoordinates, SvgCoordinates)

type alias Messages msg =
  { updateXAxis : String -> msg
  , updateYAxis : String -> msg
  , showCardForm : msg
  , submitCard : String -> msg
  , initializePlacement : Card -> (Draggable.Msg ()) -> DomCoordinates -> msg
  , dropPlacement : (Card, DomCoordinates) -> msg
  }

type alias AxisConfig msg =
  { containerClass : String
  , axis : { x1 : String, y1 : String, x2 : String, y2 : String }
  , label : { x : String, y : String }
  , updateName : String -> msg
  }

xAxisConfig : (String -> msg) -> AxisConfig msg
xAxisConfig updateName =
  { containerClass = "txt-graph__x"
  , axis = { x1 = "0", y1 = "500", x2 = "1000", y2 = "500" }
  , label = { x = "990", y = "49%" }
  , updateName = updateName
  }

yAxisConfig : (String -> msg) -> AxisConfig msg
yAxisConfig updateName =
  { containerClass = "txt-graph__y"
  , axis = { x1 = "500", y1 = "0", x2 = "500", y2 = "1000" }
  , label = { x = "50%", y = "10" }
  , updateName = updateName
  }

render : Messages msg -> Board -> Html msg
render messages board =
  div [class "l-workspace"] ([ renderBoard messages board, renderCardList messages board ] ++ renderPlacing messages board)

renderBoard : Messages msg -> Board -> Html msg
renderBoard messages board =
  let placements =
       TwoByTwo.Board.placements board
       |> List.map (renderPlacement messages)
  in

  div [class "txt-graph"]
    [ Svg.svg [A.viewBox "0 0 1000 1000"]
      ([ renderAxis board.xAxis (xAxisConfig messages.updateXAxis), renderAxis board.yAxis (yAxisConfig messages.updateYAxis) ] ++ placements)
    ]

renderAxis : String -> AxisConfig msg -> Svg msg
renderAxis name {containerClass, axis, label, updateName } =
  Svg.g [ A.class containerClass ]
    [ Svg.line [ A.preserveAspectRatio "xMidYMin meet", A.class "txt-graph__axis", A.x1 axis.x1, A.y1 axis.y1, A.x2 axis.x2, A.y2 axis.y2] []
    , Svg.foreignObject [A.x label.x, A.y label.y]
      [ div [class "txt-graph__axis-label-container"] [input [class "txt-graph__axis-label", value name, onChange updateName] []]
      ]
    ]

renderCardList : Messages msg -> Board -> Html msg
renderCardList messages board =
  let cards = List.map (renderCard messages board) (TwoByTwo.Board.cards board) in
  let cardForm =
        if board.showCardForm
        then renderCardForm messages board
        else renderNewCardButton messages board
  in

  div [ class "txt-cards" ] (cards ++ [ cardForm ])

renderCard : Messages msg -> Board -> Card -> Html msg
renderCard messages board card =
  let placed = TwoByTwo.Board.isPlaced card board in
  let trigger =
        if placed
        then []
        else [ Draggable.customMouseTrigger coordinatesDecoder (messages.initializePlacement card) ]
  in

  div ([classList [ ("txt-card", True), ("is-Placed", placed)]] ++ trigger) [text card.text]

renderCardForm : Messages msg -> Board -> Html msg
renderCardForm messages board =
  div [class "txt-cards__form"]
    [input [class "txt-card__form-text", onChange messages.submitCard] [] ]

renderNewCardButton : Messages msg -> Board -> Html msg
renderNewCardButton messages board =
  div [class "txt-cards__new", onClick messages.showCardForm] [text "+"]

renderPlacing : Messages msg -> Board -> List (Html msg)
renderPlacing messages board =
  case TwoByTwo.Board.proposedPlacement board of
    Just (card, coords) ->
      let toPx value = (String.fromFloat value) ++ "px" in

      [div [class "txt-graph__placing", style "top" (toPx coords.y), style "left" (toPx coords.x), onMouseUp (messages.dropPlacement (card, coords)) ] [text card.text]
      ]

    Nothing ->
      []

renderPlacement : Messages msg -> (Card, SvgCoordinates) -> Html msg
renderPlacement messages (card, {x, y}) =
  let trigger = Draggable.customMouseTrigger coordinatesDecoder (messages.initializePlacement card) in
  Svg.g [A.class "txt-graph__placement", trigger]
    [ Svg.circle [A.cx (String.fromFloat x), A.cy (String.fromFloat y), A.r "5"] []
    , Svg.text_ [A.x (String.fromFloat x), A.y (String.fromFloat (y + 15)) ] [Svg.text card.text ]
    ]

onChange : (String -> msg) -> Attribute msg
onChange tagger =
  stopPropagationOn "change" (Json.map (\a -> (a, True)) (Json.map tagger targetValue))

coordinatesDecoder : Json.Decoder DomCoordinates
coordinatesDecoder =
  Json.map2 TwoByTwo.Coordinates.initializeDom
    (Json.field "pageX" Json.float)
    (Json.field "pageY" Json.float)
