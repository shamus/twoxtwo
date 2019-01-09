module TwoByTwo.Client exposing (find, create, update, createCard)

import Http
import Json.Decode as Json
import Json.Encode
import Result exposing (Result)
import TwoByTwo.Board exposing (Board, Card)

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
  let json =
        Json.Encode.object
          [ ("xAxis", Json.Encode.string board.xAxis)
          , ("yAxis", Json.Encode.string board.yAxis)
          ]
  in

  Http.post
    { url = base ++ "/boards/" ++ board.uuid
    , body = Http.jsonBody json
    , expect = Http.expectJson toMsg boardDecoder
    }

createCard : (Result Http.Error Card -> msg) -> String -> String -> Cmd msg
createCard toMsg boardId text =
  let json =
        Json.Encode.object
          [ ("text", Json.Encode.string text)
          ]
  in

  Http.post
    { url = base ++ "/cards/" ++ boardId
    , body = Http.jsonBody json
    , expect = Http.expectJson toMsg cardData
    }

boardDecoder : Json.Decoder Board
boardDecoder =
  Json.map4 (\uuid xAxis yAxis cards -> { uuid = uuid, showCardForm = False, xAxis = xAxis, yAxis = yAxis, cards = cards })
    (Json.field "uuid" Json.string)
    (Json.field "xAxis" Json.string)
    (Json.field "yAxis" Json.string)
    (Json.field "cards" (Json.list cardData))

cardData : Json.Decoder Card
cardData =
  Json.map2 (\uuid text -> { uuid = uuid, text = text })
    (Json.field "uuid" Json.string)
    (Json.field "text" Json.string)
