module Route exposing (Route(..), fromUrl, toString)

import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, oneOf, string)

type Route
    = Root
    | CreateTwoByTwo
    | TwoByTwo String

parser : Parser (Route -> a) a
parser =
  oneOf
    [ Parser.map CreateTwoByTwo Parser.top
    , Parser.map TwoByTwo string
    ]

fromUrl : Url -> Maybe Route
fromUrl url =
  let path = Maybe.withDefault "" url.fragment in
  Parser.parse parser { url | path = path, fragment = Nothing }

toString : Route -> String
toString page =
  let pieces =
        case page of
          Root ->
            []

          CreateTwoByTwo ->
            [ "boards" ]

          TwoByTwo id ->
            [ "boards", id ]
  in
  "#/" ++ String.join "/" pieces
