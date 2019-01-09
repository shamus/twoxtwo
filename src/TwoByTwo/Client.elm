module TwoByTwo.Client exposing (find, create, update, createCard, createPlacement, deletePlacement)

import Dict exposing (Dict)
import Http
import Json.Decode as Json
import Json.Encode
import Result exposing (Result)

import TwoByTwo.Board exposing (Board)
import TwoByTwo.Card exposing (Card)
import TwoByTwo.Coordinates exposing (SvgCoordinates)

base : String
base = "http://shamus-twobytwo.builtwithdark.localhost:8000"

find : (Result Http.Error Board -> msg) -> String -> Cmd msg
find toMsg id =
  Http.get
    { url = base ++ "/boards/" ++ id
    , expect = Http.expectJson toMsg boardDecoder
    }

create : (Result Http.Error Board -> msg) -> Cmd msg
create toMsg =
  Http.post
    { url = base ++ "/boards"
    , body = Http.emptyBody
    , expect = Http.expectJson toMsg boardDecoder
    }

update : (Result Http.Error Board -> msg) -> Board -> Cmd msg
update toMsg board =
  Http.post
    { url = base ++ "/boards/" ++ board.uuid
    , body = Http.jsonBody (encodeBoard board)
    , expect = Http.expectJson toMsg boardDecoder
    }

createCard : (Result Http.Error Card -> msg) -> String -> String -> Cmd msg
createCard toMsg boardId text =
  Http.post
    { url = base ++ "/cards"
    , body = Http.jsonBody (encodeCard boardId text)
    , expect = Http.expectJson toMsg cardDecoder
    }

createPlacement : (Result Http.Error () -> msg) -> String -> (Card, SvgCoordinates) -> Cmd msg
createPlacement toMsg boardId placement =
  Http.post
    { url = base ++ "/placements"
    , body = Http.jsonBody (encodePlacement boardId placement)
    , expect = Http.expectWhatever toMsg
    }

deletePlacement : (Result Http.Error () -> msg) -> String -> (Card, SvgCoordinates) -> Cmd msg
deletePlacement toMsg boardId placement =
  Http.request
    { method = "DELETE"
    , headers = []
    , url = base ++ "/placements"
    , body = Http.jsonBody (encodePlacement boardId placement)
    , expect = Http.expectWhatever toMsg
    , timeout = Nothing
    , tracker = Nothing
    }

encodeBoard : Board -> Json.Encode.Value
encodeBoard board =
  Json.Encode.object
    [ ("xAxis", Json.Encode.string board.xAxis)
    , ("yAxis", Json.Encode.string board.yAxis)
    ]

encodeCard : String -> String -> Json.Encode.Value
encodeCard boardId text =
  Json.Encode.object
    [ ("boardId", Json.Encode.string boardId)
    , ("text", Json.Encode.string text)
    ]

encodePlacement : String -> (Card, SvgCoordinates) -> Json.Encode.Value
encodePlacement boardId (card, coords) =
  Json.Encode.object
    [ ("boardId", Json.Encode.string boardId)
    , ("cardId", Json.Encode.string card.uuid)
    , ("x", Json.Encode.float coords.x)
    , ("y", Json.Encode.float coords.y)
    ]

boardDecoder : Json.Decoder Board
boardDecoder =
  Json.map5 TwoByTwo.Board.initialize
    (Json.field "uuid" Json.string)
    (Json.field "xAxis" Json.string)
    (Json.field "yAxis" Json.string)
    (Json.field "cards" (Json.list cardDecoder))
    (Json.field "placements" (Json.dict placementDecoder))

cardDecoder : Json.Decoder Card
cardDecoder =
  Json.map2 Card
    (Json.field "uuid" Json.string)
    (Json.field "text" Json.string)

placementDecoder : Json.Decoder SvgCoordinates
placementDecoder =
  Json.map2 TwoByTwo.Coordinates.initializeSvg
    (Json.field "x" Json.float)
    (Json.field "y" Json.float)
