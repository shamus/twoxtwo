module TwoByTwo exposing (Model, Msg (..), create, init, update, view)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html)
import Http
import Result exposing (Result)

import TwoByTwo.Board exposing (Board)
import TwoByTwo.Client exposing (BoardData)
import TwoByTwo.View

type Msg
  = NoOp
  | InitializeBoard BoardData
  | UpdateXAxis String
  | UpdateYAxis String

type alias Model =
  { navKey : Nav.Key
  , board : Board
  }

create : (Result Http.Error BoardData -> msg) -> Cmd msg
create toMsg =
  TwoByTwo.Client.create toMsg

init : Nav.Key -> String -> (Model, Cmd Msg)
init navKey uuid =
  let toMsg result =
        case result of
          Ok data ->
            InitializeBoard data

          Err err ->
            Debug.todo "oh no"
  in
  let board = TwoByTwo.Board.default uuid in
  ({ navKey = navKey, board = board } , TwoByTwo.Client.find toMsg uuid )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    InitializeBoard data ->
      let updateBoard board = { board | xAxis = data.xAxis, yAxis = data.yAxis } in

      ( { model | board = updateBoard model.board }, Cmd.none )

    UpdateXAxis name ->
      let updateBoard board = { board | xAxis = name } in
      let toMsg result =
            case result of
              Ok data ->
                NoOp

              Err err ->
                Debug.todo "oh no"
      in
      let updatedBoard = updateBoard model.board in

      ({model | board = updatedBoard }, TwoByTwo.Client.update toMsg updatedBoard)

    UpdateYAxis name ->
      let updateBoard board = { board | yAxis = name } in
      let toMsg result =
            case result of
              Ok data ->
                NoOp

              Err err ->
                Debug.todo "oh no"
      in
      let updatedBoard = updateBoard model.board in

      ({model | board = updatedBoard }, TwoByTwo.Client.update toMsg updatedBoard)


view : Model -> Document Msg
view model =
  { title = "it's a graph y'all"
  , body = [ TwoByTwo.View.render {updateXAxis = UpdateXAxis, updateYAxis = UpdateYAxis} model.board ]
  }
