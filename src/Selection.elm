module Selection exposing (handleStopDraggingSelection)

import Model exposing (Model, MyDragState(..), Rect)
import SelectList
import Set
import Util exposing (normalizeRect)
import WidgetUtils exposing (getBoundingRect)


handleStopDraggingSelection : MyDragState -> Model -> ( Model, Cmd msg )
handleStopDraggingSelection dragState model =
    case dragState of
        DraggingSelection rect ->
            ( updateSelected rect model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateSelected : Rect -> Model -> Model
updateSelected selection model =
    let
        rect =
            normalizeRect selection

        page =
            SelectList.selected model.book.pages

        selected =
            page.widgets
                |> List.filter (getBoundingRect >> intersects rect)
                |> List.map (\w -> w.id)
    in
    { model | selectedWidgets = Set.fromList selected }


intersects : Rect -> Rect -> Bool
intersects a b =
    not
        (a.x
            + a.width
            < b.x
            || a.x
            > b.x
            + b.width
            || a.y
            + a.height
            < b.y
            || a.y
            > b.y
            + b.height
        )
