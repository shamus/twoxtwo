module TwoByTwo exposing (Model, Msg (..), create, init, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html)
import Http
import Result exposing (Result)

import TwoByTwo.Board exposing (Board, Card)
import TwoByTwo.Client
import TwoByTwo.View

type Msg
  = NoOp
  | InitializeBoard Board
  | UpdateXAxis String
  | UpdateYAxis String
  | ShowCardForm
  | SubmitCard String
  | AddCard Card

type alias Model =
  { navKey : Nav.Key
  , board : Board
  }

create : (Result Http.Error Board -> msg) -> Cmd msg
create toMsg =
  TwoByTwo.Client.create toMsg

init : Nav.Key -> String -> (Model, Cmd Msg)
init navKey uuid =
  let toMsg result =
        case result of
          Ok data ->
            InitializeBoard data

          Err err ->
            let _ = Debug.log "ERROR" err in
            Debug.todo "oh no"
  in
  let board = TwoByTwo.Board.default uuid in
  ({ navKey = navKey, board = board } , TwoByTwo.Client.find toMsg uuid )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  let updateBoard transform board =
        transform board
  in

  case msg of
    NoOp ->
      (model, Cmd.none)

    InitializeBoard data ->
      let updatedBoard =
            model.board
            |> updateBoard (\b -> { b | xAxis = data.xAxis })
            |> updateBoard (\b -> { b | yAxis = data.yAxis })
            |> updateBoard (\b -> { b | cards = data.cards })
      in

      ( { model | board = updatedBoard }, Cmd.none )

    UpdateXAxis name ->
      let toMsg result =
            case result of
              Ok data ->
                NoOp

              Err err ->
                let _ = Debug.log "ERROR" err in
                Debug.todo "oh no"
      in
      let updatedBoard = model.board |> updateBoard (\board -> { board | xAxis = name }) in

      ({model | board = updatedBoard }, TwoByTwo.Client.update toMsg updatedBoard)

    UpdateYAxis name ->
      let toMsg result =
            case result of
              Ok data ->
                NoOp

              Err err ->
                let _ = Debug.log "ERROR" err in
                Debug.todo "oh no"
      in
      let updatedBoard = model.board |> updateBoard (\board -> { board | yAxis = name }) in

      ({model | board = updatedBoard }, TwoByTwo.Client.update toMsg updatedBoard)

    ShowCardForm ->
      let updatedBoard = model.board |> updateBoard (\board -> { board | showCardForm = True }) in
      ({model | board = updatedBoard }, Cmd.none)

    SubmitCard text ->
      let toMsg result =
            case result of
              Ok card ->
                AddCard card

              Err err ->
                let _ = Debug.log "ERROR" err in
                Debug.todo "oh no"
      in

      (model, TwoByTwo.Client.createCard toMsg model.board.uuid text)

    AddCard card ->
      let updatedBoard =
            model.board
            |> updateBoard (\b -> { b | showCardForm = False })
            |> updateBoard (\b -> { b | cards = card :: b.cards })
      in
      ({model | board = updatedBoard }, Cmd.none)


view : Model -> Document Msg
view model =
  let messages =
        { updateXAxis = UpdateXAxis
        , updateYAxis = UpdateYAxis
        , showCardForm = ShowCardForm
        , submitCard = SubmitCard
        }
  in
  { title = "it's a graph y'all"
  , body = [ TwoByTwo.View.render messages model.board ]
  }
