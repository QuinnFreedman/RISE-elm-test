module Update exposing (dragConfig, update)

import BookUpdateHelpers exposing (handleBookUpdate, handleCopy, handlePaste, handleRedo, handleUndo)
import Drag
import DragHelpers exposing (dragStopped, dragged, handleDrag, handleDragWithStartPos)
import Messages exposing (BookUpdate(..), Msg(..))
import Model exposing (..)
import Ports exposing (debugExperementalSendElectromMsg)
import SelectList
import Serialization.Serialize exposing (serialize)
import Set


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
            ( handleBookUpdate bookUpdate model, Cmd.none )

        Undo ->
            ( handleUndo model, Cmd.none )

        Redo ->
            ( handleRedo model, Cmd.none )

        Copy ->
            ( handleCopy model, Cmd.none )

        Paste ->
            ( handlePaste model, Cmd.none )

        Cut ->
            Debug.todo "Cut not implemented yet"

        KeyPressed { key, ctrlKey, shiftKey } ->
            case ( ctrlKey, shiftKey, key ) of
                ( False, False, "z" ) ->
                    ( handleUndo model, Cmd.none )

                ( False, False, "y" ) ->
                    ( handleRedo model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        MenuTabSelected tab ->
            ( { model
                | menuBarTabs = SelectList.select ((==) tab) model.menuBarTabs
              }
            , Cmd.none
            )

        ZoomIn ->
            ( { model | zoom = model.zoom + 25 }, Cmd.none )

        ZoomOut ->
            ( { model | zoom = model.zoom - 25 }, Cmd.none )

        SaveBook ->
            let
                _ =
                    Debug.log "JSON output" (serialize model)
            in
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        -- TODO DEBUG messages for interactive shell test
        ToggleDebug ->
            ( { model | debugShowWindow = not model.debugShowWindow }
            , Cmd.none
            )

        DebugOnRecieveResult s ->
            ( { model | debugResult = s }
            , Cmd.none
            )

        DebugUpdateCmd s ->
            ( { model | debugCommand = s }
            , Cmd.none
            )

        DebugSubmitCmd ->
            ( model, debugExperementalSendElectromMsg model.debugCommand )
