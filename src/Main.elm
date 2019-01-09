import Browser exposing (Document)
import Browser.Navigation as Nav
import Html
import Url exposing (Url)

import Route exposing (Route)
import TwoByTwo

type Model
  = Redirect Nav.Key
  | NotFound Nav.Key
  | TwoByTwo TwoByTwo.Model

type Msg
    = NoOp
    | ChangeRouteAndReplaceUrl ( Maybe Route )
    | ChangeRoute ( Maybe Route )
    | ChangeUrl Url
    | ClickLink Browser.UrlRequest
    | UpdateTwoByTwo TwoByTwo.Msg

toNavKey : Model -> Nav.Key
toNavKey model =
  case model of
    Redirect key ->
      key

    NotFound key ->
      key

    TwoByTwo submodel ->
      submodel.navKey

mapUpdate : (model -> Model) -> (msg -> Msg) -> (model, Cmd msg) -> (Model, Cmd Msg)
mapUpdate modelMapper cmdMapper (model, cmd) =
  (modelMapper model, Cmd.map cmdMapper cmd)

mapView : (msg -> Msg) -> Document msg -> Document Msg
mapView toMsg {title, body} =
  { title = title,  body = List.map (Html.map toMsg) body }

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
      let toMsg result =
            case result of
              Ok data ->
                let route = Route.TwoByTwo data.uuid in
                ChangeRouteAndReplaceUrl (Just route)

              Err error ->
                NoOp
      in

      ( Redirect navKey, TwoByTwo.create toMsg )

    Just (Route.TwoByTwo uuid) ->
      TwoByTwo.init navKey uuid
      |> mapUpdate TwoByTwo UpdateTwoByTwo

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
  changeRouteTo (Route.fromUrl url) (Redirect navKey)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case ( msg, model ) of
    ( NoOp, _ ) ->
      ( model, Cmd.none )

    ( ChangeRouteAndReplaceUrl (Just route), _ ) ->
      let replaceCmd = replaceUrl (toNavKey model) route in
      changeRouteTo (Just route) model
      |> (\(updatedModel, cmd) -> ( updatedModel, Cmd.batch [ cmd, replaceCmd ] ))

    ( ChangeRoute route, _ ) ->
      changeRouteTo route model

    ( ChangeUrl url, _ ) ->
      changeRouteTo (Route.fromUrl url) model

    ( ClickLink urlRequest, _ ) ->
      case urlRequest of
        Browser.Internal url ->
          case url.fragment of
            Nothing ->
              ( model, Cmd.none )

            Just _ ->
              ( model , Nav.pushUrl (toNavKey model) (Url.toString url) )

        Browser.External href ->
          ( model , Nav.load href )

    ( UpdateTwoByTwo subMsg, TwoByTwo subModel ) ->
      TwoByTwo.update subMsg subModel
      |> mapUpdate TwoByTwo UpdateTwoByTwo

    ( _, _ ) ->
      ( model, Cmd.none )

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

    TwoByTwo subModel ->
      TwoByTwo.view subModel |> mapView UpdateTwoByTwo


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        TwoByTwo subModel ->
            Sub.map UpdateTwoByTwo (TwoByTwo.subscriptions subModel)

        _ ->
            Sub.none

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , onUrlChange = ChangeUrl
    , onUrlRequest = ClickLink
    , subscriptions = subscriptions
    , update = update
    , view = view
    }
