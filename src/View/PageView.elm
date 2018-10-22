module View.PageView exposing (viewPage)

import Css exposing (..)
import DragHelpers exposing (handleDragWithStartPos)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (css)
import Messages exposing (Msg(..))
import Model exposing (..)
import Util exposing (normalizeRect, onDrop)
import View.WidgetView exposing (renderDraggableWidget)


viewPage : Model -> Html Msg
viewPage model =
    div
        [ css
            [ backgroundColor (rgb 255 255 255)
            , width (pct 100)
            , height (pct 100)
            , position relative
            , overflow hidden
            ]
        , handleDragWithStartPos (\pos -> DraggingSelection { x = pos.x, y = pos.y, width = 0, height = 0 })
        ]
        (renderSelectionRect model.myDragState
            :: ((getSelectedPage model).widgets
                    |> List.map
                        (\w ->
                            renderDraggableWidget w
                                model.myDragState
                                model.selectedWidgets
                        )
               )
        )


renderSelectionRect : Maybe MyDragState -> Html Msg
renderSelectionRect dragState =
    case dragState of
        Just (DraggingSelection irregularRect) ->
            let
                rect =
                    normalizeRect irregularRect
            in
            div
                [ css
                    [ borderStyle dashed
                    , borderWidth (px 4)
                    , borderColor (rgb 0 255 255)
                    , position absolute
                    , boxSizing borderBox
                    , top (px rect.y)
                    , left (px rect.x)
                    , width (px rect.width)
                    , height (px rect.height)
                    ]
                ]
                []

        _ ->
            div [] []
