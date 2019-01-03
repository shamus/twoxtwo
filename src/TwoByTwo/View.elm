module TwoByTwo.View exposing (render)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Svg exposing (Svg)
import Svg.Attributes as A

import TwoByTwo.Board exposing (Board)

type alias Messages msg =
  { updateXAxis : String -> msg
  , updateYAxis : String -> msg
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
  div [class "l-workspace"] [ renderBoard messages board ]

renderBoard : Messages msg -> Board -> Html msg
renderBoard messages board =
  div [class "txt-graph"]
    [ Svg.svg [A.viewBox "0 0 1000 1000"]
      [ renderAxis board.xAxis (xAxisConfig messages.updateXAxis), renderAxis board.yAxis (yAxisConfig messages.updateYAxis) ]
    ]

renderAxis : String -> AxisConfig msg -> Svg msg
renderAxis name {containerClass, axis, label, updateName } =
  Svg.g [ A.class containerClass ]
    [ Svg.line [ A.preserveAspectRatio "xMidYMin meet", A.class "txt-graph__axis", A.x1 axis.x1, A.y1 axis.y1, A.x2 axis.x2, A.y2 axis.y2] []
    , Svg.foreignObject [A.x label.x, A.y label.y]
      [ div [class "txt-graph__axis-label-container"] [input [class "txt-graph__axis-label", value name, onChange updateName] []]
      ]
    ]

onChange : (String -> msg) -> Attribute msg
onChange tagger =
  stopPropagationOn "change" (Json.map (\a -> (a, True)) (Json.map tagger targetValue))

