module Main exposing (main)

import Browser
import Css exposing (..)
import Drag
import DragHelpers exposing (dragStopped, dragged, handleDrag, handleDragWithStartPos)
import Html
import Html.Styled exposing (toUnstyled)
import Json.Decode as Decode exposing (Decoder)
import Keyboard exposing (subscribeKeyPressed)
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


dragConfig : Drag.DragConfig MyDragState Msg
dragConfig =
    { onDragStart = OnDragStart
    , onDragged = OnDragBy
    , onDragStopped = OnDragEnd
    , onClick = OnClickDraggable
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnDragBy delta ->
            ( { model | myDragState = dragged model.myDragState ( delta.x, delta.y ) }
            , Cmd.none
            )

        OnDragStart dragState ->
            ( { model | myDragState = Just dragState }, Cmd.none )

        OnDragEnd ->
            dragStopped msg model

        DragMsg dragMsg ->
            let
                ( newDragState, cmd ) =
                    Drag.update dragMsg dragConfig model.drag
            in
            ( { model | drag = newDragState }, cmd )

        OnClickDraggable myDragState mouseEvent ->
            case myDragState of
                MovingWidget w ->
                    ( { model | selectedWidgets = Set.singleton w.id }, Cmd.none )

                DraggingSelection _ ->
                    ( { model | selectedWidgets = Set.empty }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

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
        [ Drag.subscriptions drag DragMsg
        , subscribeKeyPressed KeyPressed
        ]
