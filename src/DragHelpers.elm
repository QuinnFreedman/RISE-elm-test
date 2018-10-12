module DragHelpers exposing (dragStopped, dragged, getWidgetId, handleDrag, transformWidget)

import Draggable
import Html.Styled
import Html.Styled.Attributes as Attributes
import Json.Decode as Decode exposing (Decoder)
import Messages exposing (BookUpdate(..), Msg(..))
import Model exposing (Model, MyDragState(..), Widget)
import ModelUtils exposing (getWidgetById)
import Util exposing (equalsMaybe, filterMaybe, thenFire)


type alias Position =
    { x : Float
    , y : Float
    }


mouseOffsetDecoder : Decoder Position
mouseOffsetDecoder =
    Decode.map2 Position
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


handleDrag : MyDragState -> Html.Styled.Attribute Msg
handleDrag dragState =
    Attributes.fromUnstyled <| Draggable.mouseTrigger dragState DragMsg



{-
   handleCustomDrag : MyDragState -> Html.Styled.Attribute Msg
   handleCustomDrag dragState =
       Attributes.fromUnstyled <| Draggable.customMouseTrigger dragState DragMsg
           , Draggable. mouseOffsetDecoder StartPathAndDrag
-}


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
            DraggingSelection { s | dx = s.dx + dx, dy = s.dy + dy }


dragged : Maybe MyDragState -> ( Float, Float ) -> Maybe MyDragState
dragged oldDragState delta =
    oldDragState |> Maybe.map (\dragState -> updateDragState dragState delta)


dragStopped : Msg -> Model -> ( Model, Cmd Msg )
dragStopped msg model =
    case model.myDragState of
        Just dragState ->
            let
                widgetId =
                    getWidgetId dragState

                maybeWidget =
                    widgetId |> Maybe.andThen (getWidgetById model)
            in
            case maybeWidget of
                Just widget ->
                    ( { model | myDragState = Nothing }
                    , thenFire (UpdateBook (PutWidget (transformWidget dragState widget)))
                    )

                Nothing ->
                    ( { model | myDragState = Nothing }, Cmd.none )

        Nothing ->
            ( model, Cmd.none )


getWidgetId : MyDragState -> Maybe String
getWidgetId drag =
    case drag of
        MovingWidget { id } ->
            Just id

        ResizingWidgetUp { id } ->
            Just id

        ResizingWidgetDown { id } ->
            Just id

        ResizingWidgetRight { id } ->
            Just id

        ResizingWidgetLeft { id } ->
            Just id

        DraggingSelection _ ->
            Nothing


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
