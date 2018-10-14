module View exposing (view)

import Css exposing (..)
import DragHelpers exposing (dragStopped, dragged, handleDrag, handleDragWithStartPos)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Messages exposing (Msg(..))
import Model exposing (..)
import SelectList
import Util exposing (styleSheet)
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
        , handleDragWithStartPos (\pos -> DraggingSelection { initialX = pos.x, initialY = pos.y, dx = 0, dy = 0 })
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
                        (\w -> renderDraggableWidget w model.myDragState)
               )
        )


renderSelectionRect : Maybe MyDragState -> Html Msg
renderSelectionRect dragState =
    case dragState of
        Just (DraggingSelection { initialX, initialY, dx, dy }) ->
            div
                [ css
                    [ borderStyle dashed
                    , borderWidth (px 4)
                    , borderColor (rgb 0 255 255)
                    , position absolute
                    , boxSizing borderBox
                    , top (px initialY)
                    , left (px initialX)
                    , width (px dx)
                    , height (px dy)
                    ]
                ]
                []

        _ ->
            div [] []
