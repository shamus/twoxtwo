port module TwoByTwo.Ports exposing (PlacementEncoding, dropCard, acceptPlacement, rejectPlacement, encodePlacement, decodePlacement)

import Json.Decode as D
import Json.Encode as E

import TwoByTwo.Card exposing (Card)
import TwoByTwo.Coordinates exposing (DomCoordinates, SvgCoordinates)

type alias PlacementEncoding = E.Value

port dropCard : PlacementEncoding -> Cmd msg
port acceptPlacement : (PlacementEncoding -> msg) -> Sub msg
port rejectPlacement : (PlacementEncoding -> msg) -> Sub msg

encodePlacement : (Card, DomCoordinates) -> PlacementEncoding
encodePlacement (card, coords) =
  E.object
    [ ("card", encodeCard card)
    , ("coords", encodeCoordinates coords)
    ]

decodePlacement : PlacementEncoding -> Result D.Error (Card, SvgCoordinates)
decodePlacement value =
  D.decodeValue placementDecoder value

encodeCard : Card -> E.Value
encodeCard card =
  E.object
    [ ("uuid", E.string card.uuid)
    , ("text", E.string card.text)
    ]

encodeCoordinates : DomCoordinates -> E.Value
encodeCoordinates coords =
  E.object
    [ ("x", E.float coords.x)
    , ("y", E.float coords.y)
    ]

placementDecoder : D.Decoder (Card, SvgCoordinates)
placementDecoder =
  D.map2 (\card coords -> (card, coords))
    (D.field "card" cardDecoder)
    (D.field "coords" coordinatesDecoder)

cardDecoder : D.Decoder Card
cardDecoder =
  D.map2 (\uuid text -> { uuid = uuid, text = text })
    (D.field "uuid" D.string)
    (D.field "text" D.string)

coordinatesDecoder : D.Decoder SvgCoordinates
coordinatesDecoder =
  D.map2 (\x y -> { x = x, y = y })
    (D.field "x" D.float)
    (D.field "y" D.float)

decodeCard : E.Value -> Result D.Error Card
decodeCard value =
  D.decodeValue cardDecoder value

decodeCoordinates : E.Value -> Result D.Error SvgCoordinates
decodeCoordinates value =
  D.decodeValue coordinatesDecoder value
