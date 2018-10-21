module DragHelpers exposing
    ( dragStopped
    , dragged
    , handleDrag
    , handleDragWithStartPos
    , transformWidget
    )

import Drag
import Html.Styled
import Html.Styled.Attributes as Attributes
import Messages exposing (BookUpdate(..), Msg(..))
import Model exposing (Model, MyDragState(..), Position, Widget)
import ModelUtils exposing (getWidgetById)
import Selection exposing (handleStopDraggingSelection)
import Util exposing (chainUpdate, equalsMaybe, filterMaybe, thenFire)
import WidgetUtils exposing (getDraggedWidgets, getWidgetId)


handleDrag : MyDragState -> Html.Styled.Attribute Msg
handleDrag dragState =
    Attributes.fromUnstyled <|
        Drag.handleDrag (\_ -> dragState) DragMsg


handleDragWithStartPos : (Position -> MyDragState) -> Html.Styled.Attribute Msg
handleDragWithStartPos initDragState =
    Attributes.fromUnstyled <|
        Drag.handleDrag
            (\e -> initDragState { x = e.offsetX, y = e.offsetY })
            DragMsg


updateDragState : MyDragState -> ( Float, Float ) -> MyDragState
updateDragState oldDragState ( dx, dy ) =
    case oldDragState of
        MovingWidget s ->
            MovingWidget { s | dx = s.dx + dx, dy = s.dy + dy }

        ResizingWidgetUp s ->
            ResizingWidgetUp { s | delta = s.delta + dy }

        ResizingWidgetDown s ->
            ResizingWidgetDown { s | delta = s.delta + dy }

        ResizingWidgetRight s ->
            ResizingWidgetRight { s | delta = s.delta + dx }

        ResizingWidgetLeft s ->
            ResizingWidgetLeft { s | delta = s.delta + dx }

        DraggingSelection s ->
            DraggingSelection
                { s
                    | width = s.width + dx
                    , height = s.height + dy
                }


dragged : Maybe MyDragState -> ( Float, Float ) -> Maybe MyDragState
dragged oldDragState delta =
    oldDragState |> Maybe.map (\dragState -> updateDragState dragState delta)


dragStopped : Msg -> Model -> ( Model, Cmd Msg )
dragStopped msg model =
    case model.myDragState of
        Just dragState ->
            ( model, Cmd.none )
                |> chainUpdate (\m -> handleStopDraggingWidget dragState m)
                |> chainUpdate (\m -> handleStopDraggingSelection dragState m)

        Nothing ->
            ( model, Cmd.none )


handleStopDraggingWidget : MyDragState -> Model -> ( Model, Cmd Msg )
handleStopDraggingWidget dragState model =
    let
        widgetId =
            getWidgetId dragState

        maybeWidget =
            widgetId |> Maybe.andThen (getWidgetById model)
    in
    case maybeWidget of
        Just widget ->
            ( { model | myDragState = Nothing }
            , thenFire
                (UpdateBook
                    (getDraggedWidgets model
                        |> List.map (transformWidget dragState)
                        |> UpdateWidgets
                    )
                )
            )

        Nothing ->
            ( { model | myDragState = Nothing }, Cmd.none )


transformWidget : MyDragState -> Widget -> Widget
transformWidget drag widget =
    case drag of
        MovingWidget { dx, dy } ->
            { widget | x = widget.x + dx, y = widget.y + dy }

        ResizingWidgetUp { delta } ->
            { widget | y = widget.y + delta, height = widget.height - delta }

        ResizingWidgetDown { delta } ->
            { widget | height = widget.height + delta }

        ResizingWidgetRight { delta } ->
            { widget | width = widget.width + delta }

        ResizingWidgetLeft { delta } ->
            { widget | x = widget.x + delta, width = widget.width - delta }

        _ ->
            widget
