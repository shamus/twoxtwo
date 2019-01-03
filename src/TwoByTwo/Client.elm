module TwoByTwo.Client exposing (BoardData, find, create, update)

import Http
import Json.Decode as Json
import Json.Encode
import Result exposing (Result)

type alias BoardData =
  { uuid : String
  , xAxis : String
  , yAxis : String
  }

base : String
base = "http://shamus-twobytwo.builtwithdark.localhost:8000"

find : (Result Http.Error BoardData -> msg) -> String -> Cmd msg
find toMsg id =
  Http.get
    { url = base ++ "/boards/" ++ id
    , expect = Http.expectJson toMsg boardData
    }

create : (Result Http.Error BoardData -> msg) -> Cmd msg
create toMsg =
  Http.post
    { url = base ++ "/boards"
    , body = Http.emptyBody
    , expect = Http.expectJson toMsg boardData
    }

update : (Result Http.Error BoardData -> msg) -> BoardData -> Cmd msg
update toMsg board =
  let json =
        Json.Encode.object
          [ ("uuid", Json.Encode.string board.uuid)
          , ("xAxis", Json.Encode.string board.xAxis)
          , ("yAxis", Json.Encode.string board.yAxis)
          , ("cards", Json.Encode.list Json.Encode.string [])
          , ("placements", Json.Encode.list Json.Encode.string [])
          ]
  in

  Http.post
    { url = base ++ "/boards/" ++ board.uuid
    , body = Http.jsonBody json
    , expect = Http.expectJson toMsg boardData
    }

boardData : Json.Decoder BoardData
boardData =
  Json.map3 BoardData
    (Json.field "uuid" Json.string)
    (Json.field "xAxis" Json.string)
    (Json.field "yAxis" Json.string)
