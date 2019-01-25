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
  , captureCard : String -> msg
  , submitCard : msg
  , deleteCard : Card -> msg
  , initializePlacement : Card -> (Draggable.Msg ()) -> DomCoordinates -> msg
  , dropPlacement : (Card, DomCoordinates) -> msg
  , noop : msg
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
  , axis = { x1 = "50", y1 = "500", x2 = "950", y2 = "500" }
  , label = { x = "960", y = "49%" }
  , updateName = updateName
  }

yAxisConfig : (String -> msg) -> AxisConfig msg
yAxisConfig updateName =
  { containerClass = "txt-graph__y"
  , axis = { x1 = "500", y1 = "50", x2 = "500", y2 = "950" }
  , label = { x = "50%", y = "20" }
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
  Svg.g [ A.class containerClass, A.preserveAspectRatio "xMidYMin meet" ]
    [ Svg.line [ A.class "txt-graph__axis", A.x1 axis.x1, A.y1 axis.y1, A.x2 axis.x2, A.y2 axis.y2] []
    , Svg.foreignObject [A.x label.x, A.y label.y]
      [ div [class "txt-graph__axis-label-container"] [input [class "txt-graph__axis-label", value name, onChange updateName] []]
      ]
    ]

renderCardList : Messages msg -> Board -> Html msg
renderCardList messages board =
  div [ class "txt-cards" ]
    [ renderUnplacedCards messages board
    , renderPlacedCards messages board
    ]

renderUnplacedCards : Messages msg -> Board -> Html msg
renderUnplacedCards messages board =
  let cards = List.map (renderCard messages board) (TwoByTwo.Board.unplacedCards board) in

  div [ class "txt-cards__section" ]
    [ div [ class "txt-cards__section-header" ] [ text "Unplaced" ]
    , div [] (cards ++ [ renderCardForm messages board ])
    ]

renderPlacedCards : Messages msg -> Board -> Html msg
renderPlacedCards messages board =
  let cards = List.map (renderCard messages board) (TwoByTwo.Board.placedCards board) in

  div [ class "txt-cards__section" ]
    [ div [ class "txt-cards__section-header" ] [ text "Placed" ]
    , div [] cards
    ]

renderCard : Messages msg -> Board -> Card -> Html msg
renderCard messages board card =
  let placed = TwoByTwo.Board.isPlaced card board in
  let trigger =
        if placed
        then []
        else [ Draggable.customMouseTrigger coordinatesDecoder (messages.initializePlacement card) ]
  in

  div ([classList [ ("txt-card", True), ("is-placed", placed)]] ++ trigger)
    [ div [class "txt-card__text"] [ text card.text ]
    , i [class "fas fa-times txt-card__delete", captureMouseDown messages.noop, onClick (messages.deleteCard card) ] []
    ]

renderCardForm : Messages msg -> Board -> Html msg
renderCardForm messages board =
  Html.form [class "txt-cards__form", onSubmit messages.submitCard]
    [ div [class "txt-card__form-input"]
      [input [class "txt-card__form-text", placeholder "Add an item", value board.newCard, onInput messages.captureCard] []
      , button [classList [("txt-card__form-button", True), ("is-active", TwoByTwo.Board.isNewCardPending board)]] [ i [class "fas fa-plus"] [] ]
      ]
    ]

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
    , Svg.foreignObject [A.x (String.fromFloat x), A.y  (String.fromFloat (y + 15)) ]
      [ div [class "txt-graph__placement-label-container"] [ div [class "txt-graph__placement-label"] [ text card.text ] ]
      ]
    ]

onChange : (String -> msg) -> Attribute msg
onChange tagger =
  stopPropagationOn "change" (Json.map (\a -> (a, True)) (Json.map tagger targetValue))

captureMouseDown : msg -> Attribute msg
captureMouseDown msg =
  stopPropagationOn "mousedown" (Json.map (\a -> (a, True)) (Json.succeed msg))

coordinatesDecoder : Json.Decoder DomCoordinates
coordinatesDecoder =
  Json.map2 TwoByTwo.Coordinates.initializeDom
    (Json.field "pageX" Json.float)
    (Json.field "pageY" Json.float)
