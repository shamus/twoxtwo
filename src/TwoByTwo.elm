module TwoByTwo exposing (Model, Msg (..), create, init, subscriptions, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Draggable
import Draggable.Events exposing (onDragBy)
import Http
import Result exposing (Result)

import TwoByTwo.Board exposing (Board)
import TwoByTwo.Card exposing (Card)
import TwoByTwo.Client
import TwoByTwo.Coordinates exposing (DomCoordinates, SvgCoordinates)
import TwoByTwo.Ports
import TwoByTwo.View

type Msg
  = NoOp
  | InitializeBoard Board
  | UpdateXAxis String
  | UpdateYAxis String
  | ShowCardForm
  | SubmitCard String
  | AddCard Card
  | DragMsg (Draggable.Msg ())
  | InitializePlacement Card (Draggable.Msg ()) DomCoordinates
  | MovePlacement (Float, Float)
  | DropPlacement (Card, DomCoordinates)
  | AcceptPlacement (Card, SvgCoordinates)
  | RejectPlacement (Card, SvgCoordinates)
  | ServerError Http.Error

type alias Model =
  { navKey : Nav.Key
  , drag : Draggable.State ()
  , board : Board
  }

create : (Result Http.Error Board -> msg) -> Cmd msg
create toMsg =
  TwoByTwo.Client.create toMsg

init : Nav.Key -> String -> (Model, Cmd Msg)
init navKey uuid =
  let board = TwoByTwo.Board.default uuid in
  let toMsg = convertHttpResult InitializeBoard in

  ( { navKey = navKey, drag = Draggable.init,  board = board } , TwoByTwo.Client.find toMsg uuid )

subscriptions : Model -> Sub Msg
subscriptions {drag} =
  let decode value msg =
        case TwoByTwo.Ports.decodePlacement value of
          Ok placement ->
            msg placement

          Err _ ->
            Debug.todo "impossible"
  in

  Sub.batch
    [ Draggable.subscriptions DragMsg drag
    , TwoByTwo.Ports.acceptPlacement (\placement -> decode placement AcceptPlacement)
    , TwoByTwo.Ports.rejectPlacement (\placement -> decode placement RejectPlacement)
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      ( model, Cmd.none )

    InitializeBoard updatedBoard ->
      ( { model | board = updatedBoard }, Cmd.none )

    UpdateXAxis name ->
      let toMsg = convertHttpResult (\_ -> NoOp) in
      let updatedBoard = TwoByTwo.Board.updateXAxis name model.board in

      ( { model | board = updatedBoard }, TwoByTwo.Client.update toMsg updatedBoard )

    UpdateYAxis name ->
      let toMsg = convertHttpResult (\_ -> NoOp) in
      let updatedBoard = TwoByTwo.Board.updateYAxis name model.board in

      ( { model | board = updatedBoard }, TwoByTwo.Client.update toMsg updatedBoard )

    ShowCardForm ->
      ( { model | board = TwoByTwo.Board.showCardForm model.board }, Cmd.none )

    SubmitCard text ->
      let toMsg = convertHttpResult AddCard in

      ( model, TwoByTwo.Client.createCard toMsg model.board.uuid text )

    AddCard card ->
      ( { model | board = TwoByTwo.Board.addCard card model.board }, Cmd.none )

    DragMsg dragMsg ->
      Draggable.update dragConfig dragMsg model

    InitializePlacement card dragMsg coords ->
      let updatedBoard = TwoByTwo.Board.proposePlacement (card, coords) model.board in

      Draggable.update dragConfig dragMsg { model | board = updatedBoard }

    MovePlacement (x, y) ->
      let coords = TwoByTwo.Coordinates.initializeDom x y in

      ( { model | board = TwoByTwo.Board.updateProposedPlacement coords model.board }, Cmd.none )

    DropPlacement placement ->
      ( model, TwoByTwo.Ports.dropCard (TwoByTwo.Ports.encodePlacement placement) )

    AcceptPlacement (placement) ->
      let updatedBoard = TwoByTwo.Board.acceptPlacement placement model.board in
      let toMsg = convertHttpResult (\_ -> NoOp) in

      ( { model | board = updatedBoard }, TwoByTwo.Client.createPlacement toMsg updatedBoard.uuid placement )

    RejectPlacement ((card, _) as placement) ->
      let cmd =
            if TwoByTwo.Board.isPlaced card model.board
            then
              let toMsg = convertHttpResult (\_ -> NoOp) in
              TwoByTwo.Client.deletePlacement toMsg model.board.uuid placement
            else
              Cmd.none
      in

      ( { model | board = TwoByTwo.Board.rejectPlacement placement model.board }, cmd )

    ServerError err ->
      Debug.todo (Debug.toString err)

view : Model -> Document Msg
view model =
  let messages =
        { updateXAxis = UpdateXAxis
        , updateYAxis = UpdateYAxis
        , showCardForm = ShowCardForm
        , submitCard = SubmitCard
        , initializePlacement = InitializePlacement
        , dropPlacement = DropPlacement
        }
  in

  { title = "it's a graph y'all"
  , body = [ TwoByTwo.View.render messages model.board ]
  }

dragConfig : Draggable.Config () Msg
dragConfig =
  Draggable.customConfig [ onDragBy MovePlacement ]

convertHttpResult : (data -> Msg) -> (Result Http.Error data -> Msg)
convertHttpResult wrap =
  \result ->
    case result of
      Ok data ->
        wrap data

      Err err ->
        ServerError err
