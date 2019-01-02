import Browser exposing (Document)
import Browser.Navigation as Nav
import Html
import Url exposing (Url)

import Route exposing (Route)

type Model
  = Redirect Nav.Key
  | NotFound Nav.Key
  | TwoByTwo Nav.Key

type Msg
    = NoOp
    | ChangedRoute ( Maybe Route )
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest

toNavKey : Model -> Nav.Key
toNavKey model =
  case model of
    Redirect key ->
      key

    NotFound key ->
      key

    TwoByTwo key ->
      key

replaceUrl : Nav.Key -> Route -> Cmd Msg
replaceUrl key route =
  Nav.replaceUrl key (Route.toString route)

changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
  let navKey = toNavKey model in

  case maybeRoute of
    Nothing ->
      ( NotFound navKey, Cmd.none )

    Just Route.Root ->
      ( model, replaceUrl navKey Route.Root )

    Just Route.CreateTwoByTwo ->
      ( TwoByTwo navKey, replaceUrl navKey ( Route.TwoByTwo "id" ) )

    Just _ ->
      ( model, Cmd.none )

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
  changeRouteTo (Route.fromUrl url) (Redirect navKey)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model ) of
    ( NoOp, _ ) ->
      ( model, Cmd.none )

    ( ClickedLink urlRequest, _ ) ->
      case urlRequest of
        Browser.Internal url ->
          case url.fragment of
            Nothing ->
              ( model, Cmd.none )

            Just _ ->
              ( model , Nav.pushUrl (toNavKey model) (Url.toString url) )

        Browser.External href ->
          ( model , Nav.load href )

    ( ChangedUrl url, _ ) ->
      changeRouteTo (Route.fromUrl url) model

    ( ChangedRoute route, _ ) ->
      changeRouteTo route model

view : Model -> Document Msg
view model =
  case model of
    Redirect _ ->
      { title = ""
      , body = [ Html.text "redirecting" ]
      }

    NotFound _ ->
      { title = "Oh No!"
      , body = [ Html.text "found TK" ]
      }

    TwoByTwo  _ ->
      { title = "it's a graph y'all"
      , body = [ Html.text "graph" ]
      }

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , onUrlChange = ChangedUrl
    , onUrlRequest = ClickedLink
    , subscriptions = (\_ -> Sub.none)
    , update = update
    , view = view
    }
