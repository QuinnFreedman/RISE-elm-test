module View exposing (view)

import Css exposing (..)
import DragHelpers exposing (dragStopped, dragged, handleDrag, handleDragWithStartPos)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Model exposing (..)
import SelectList
import Util exposing (normalizeRect, styleSheet)
import Widget exposing (renderDraggableWidget)


view : Model -> Html Msg
view model =
    div
        [ css
            [ backgroundColor (rgb 255 255 255)
            , width (pct 100)
            , height (pct 100)
            , position absolute
            ]
        , handleDragWithStartPos (\pos -> DraggingSelection { x = pos.x, y = pos.y, width = 0, height = 0 })
        ]
        ([ styleSheet "/reset.css"
         , renderSelectionRect model.myDragState
         , div
            [ css
                [ position absolute
                , fontFamily monospace
                ]
            ]
            [ text (Debug.toString model)
            ]
         ]
            ++ ((SelectList.selected model.book.pages).widgets
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
