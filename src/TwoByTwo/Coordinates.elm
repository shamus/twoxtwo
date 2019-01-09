module TwoByTwo.Coordinates exposing (DomCoordinates, SvgCoordinates, add, defaultDom, initializeDom, initializeSvg)

type alias Coordinates =
  { x : Float
  , y : Float
  }

type alias DomCoordinates = Coordinates
type alias SvgCoordinates = Coordinates

add : Coordinates -> Coordinates -> Coordinates
add a b =
  { x = a.x + b.x, y = a.y + b.y }

defaultDom : DomCoordinates
defaultDom =
  { x = 0, y = 0 }

initializeDom : Float -> Float -> DomCoordinates
initializeDom x y =
  { x = x, y = y }

initializeSvg : Float -> Float -> SvgCoordinates
initializeSvg x y =
  { x = x, y = y }
