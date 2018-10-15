module Main exposing (main)

import Browser
import Css exposing (..)
import DragHelpers exposing (dragStopped, dragged, handleDrag, handleDragWithStartPos)
import Draggable
import Draggable.Events exposing (onDragBy, onDragEnd, onDragStart)
import Html
import Html.Styled exposing (toUnstyled)
import Json.Decode as Decode exposing (Decoder)
import Keyboard exposing (subscribeKeyPressed)
import Messages exposing (Msg(..))
import Model exposing (..)
import ModelUpdate exposing (redo, undo, updateBookAndPushUndo)
import SelectList
import Set
import Util exposing (styleSheet)
import View exposing (view)
import Widget exposing (renderDraggableWidget)


main =
    Browser.element
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd msg )
init flags =
    ( Model.init
    , Cmd.none
    )


dragConfig : Draggable.Config () Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragEnd OnDragEnd
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnDragBy delta ->
            ( { model | myDragState = dragged model.myDragState delta }
            , Cmd.none
            )

        OnDragStart dragMsg dragState ->
            let
                updatedModel =
                    { model | myDragState = Just dragState }
            in
            Draggable.update dragConfig dragMsg updatedModel

        OnDragEnd ->
            dragStopped msg model

        DragMsg dragMsg ->
            Draggable.update dragConfig dragMsg model

        SelectWidget id ->
            ( { model | selectedWidgets = Set.singleton id }, Cmd.none )

        UpdateBook bookUpdate ->
            ( updateBookAndPushUndo bookUpdate model, Cmd.none )

        KeyPressed { key, ctrlKey, shiftKey } ->
            case ( ctrlKey, shiftKey, key ) of
                ( False, False, "z" ) ->
                    ( undo model, Cmd.none )

                ( False, False, "y" ) ->
                    ( redo model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions { drag } =
    Sub.batch
        [ Draggable.subscriptions DragMsg drag
        , subscribeKeyPressed KeyPressed
        ]
