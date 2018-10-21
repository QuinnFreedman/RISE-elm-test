module WidgetUtils exposing
    ( getBoundingRect
    , getDraggedWidgets
    , getWidgetId
    , isBeingDragged
    )

import Model exposing (Model, MyDragState(..), Rect, Widget)
import SelectList
import Set exposing (Set)


isBeingDragged : Set String -> MyDragState -> Widget -> Bool
isBeingDragged selectedWidgets dragState w =
    case getWidgetId dragState of
        Just id ->
            if Set.member id selectedWidgets then
                Set.member w.id selectedWidgets

            else
                w.id == id

        Nothing ->
            False


{-| this could be faster -- there's no need to iterate through all widgets
-}
getDraggedWidgets : Model -> List Widget
getDraggedWidgets model =
    case model.myDragState of
        Just dragState ->
            (SelectList.selected model.book.pages).widgets
                |> List.filter (isBeingDragged model.selectedWidgets dragState)

        Nothing ->
            []


getBoundingRect : Widget -> Rect
getBoundingRect widget =
    { x = widget.x
    , y = widget.y
    , width = widget.width
    , height = widget.height
    }


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
