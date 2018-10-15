module Widget exposing (renderDraggableWidget)

import Css exposing (..)
import DragHelpers exposing (getWidgetId, handleDrag, transformWidget)
import Draggable
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events as Events exposing (onClick)
import Messages exposing (Msg(..))
import Model exposing (..)
import Set exposing (Set)
import Util exposing (equalsMaybe, filterMaybe)


dragMargin =
    5


shouldBeDragged : Widget -> MyDragState -> Bool
shouldBeDragged w dragState =
    dragState
        |> getWidgetId
        |> Maybe.map (\id -> id == w.id)
        |> Maybe.withDefault False


renderDraggableWidget : Widget -> Maybe MyDragState -> Set String -> Html Msg
renderDraggableWidget w maybeDrag selectedWidgets =
    let
        isSelected =
            Set.member w.id selectedWidgets
    in
    maybeDrag
        |> filterMaybe (shouldBeDragged w)
        |> Maybe.map (\drag -> renderWidget (transformWidget drag w) True isSelected)
        |> Maybe.withDefault (renderWidget w False isSelected)


renderWidget : Widget -> Bool -> Bool -> Html Msg
renderWidget w isDragged isSelected =
    div
        [ css
            [ position absolute
            , left <| px (w.x - dragMargin)
            , top <| px (w.y - dragMargin)
            , width <| px (w.width + 2 * dragMargin)
            , height <| px (w.height + 2 * dragMargin)
            , padding (px dragMargin)
            , boxSizing borderBox
            ]
        ]
        [ dragBar w Up
        , dragBar w Down
        , dragBar w Left
        , dragBar w Right
        , div
            [ css
                ([ backgroundColor (rgb 0 255 255)
                 , width (pct 100)
                 , height (pct 100)
                 ]
                    ++ (if isSelected then
                            [ boxShadow5 zero zero (px 4) (px 2) (rgb 0 180 255)
                            ]

                        else if isDragged then
                            [ cursor grabbing
                            , boxShadow5 zero zero (px 14) (px 2) (rgba 0 0 0 0.3)
                            ]

                        else
                            []
                       )
                )
            , handleDrag (MovingWidget { id = w.id, dx = 0, dy = 0 })
            , onClick (SelectWidget w.id)
            ]
            [ text w.id
            ]
        ]


type Direction
    = Up
    | Down
    | Left
    | Right


getCursor : Direction -> Css.Cursor {}
getCursor dir =
    case dir of
        Up ->
            nsResize

        Down ->
            nsResize

        Left ->
            ewResize

        Right ->
            ewResize


resizeInDirection : Direction -> String -> MyDragState
resizeInDirection dir id =
    case dir of
        Up ->
            ResizingWidgetUp { id = id, delta = 0 }

        Down ->
            ResizingWidgetDown { id = id, delta = 0 }

        Left ->
            ResizingWidgetLeft { id = id, delta = 0 }

        Right ->
            ResizingWidgetRight { id = id, delta = 0 }


dragBar : Widget -> Direction -> Html Msg
dragBar w direction =
    let
        uniqueCss =
            case direction of
                Up ->
                    [ width (px w.width)
                    , height <| px (2 * dragMargin)
                    , top zero
                    ]

                Down ->
                    [ width (px w.width)
                    , height <| px (2 * dragMargin)
                    , bottom zero
                    ]

                Left ->
                    [ height (px w.height)
                    , width <| px (2 * dragMargin)
                    , left zero
                    ]

                Right ->
                    [ height (px w.height)
                    , width <| px (2 * dragMargin)
                    , right zero
                    ]
    in
    div
        [ css
            (uniqueCss
                ++ [ position absolute
                   , cursor (getCursor direction)
                   , hover
                        [ backgroundColor (rgba 0 0 0 0.2)
                        ]
                   ]
            )
        , handleDrag <| resizeInDirection direction w.id
        ]
        []
