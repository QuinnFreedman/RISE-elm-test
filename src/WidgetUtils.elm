module WidgetUtils exposing
    ( getBoundingRect
    , getDraggedWidgets
    , getWidgetId
    , initWidget
    , isBeingDragged
    )

import Css exposing (rgb)
import Model exposing (Model, MyDragState(..), Rect, Widget, WidgetType, getSelectedPage)
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
            (getSelectedPage model).widgets
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


initWidget : String -> WidgetType -> Float -> Float -> Float -> Float -> Widget
initWidget id widgetType x y width height =
    { id = id
    , x = x
    , y = y
    , width = width
    , height = height
    , backgroundColor = rgb 255 255 255
    , borderColor = rgb 0 0 0
    , borderWidth = 0
    , borderRadius = 0
    , padding = 0
    , widgetType = widgetType
    }
