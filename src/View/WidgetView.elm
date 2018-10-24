module View.WidgetView exposing (renderDraggableWidget)

import Css exposing (..)
import DragHelpers exposing (handleDrag, transformWidget)
import Html.Attributes
import Html.Styled exposing (..)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events as Events exposing (onClick)
import Markdown
import Messages exposing (Msg(..))
import Model exposing (..)
import Set exposing (Set)
import Util exposing (equalsMaybe, filterMaybe)
import WidgetUtils exposing (isBeingDragged)


dragMargin =
    5


renderDraggableWidget : Widget -> Maybe MyDragState -> Set String -> Html Msg
renderDraggableWidget w maybeDrag selectedWidgets =
    let
        isSelected =
            Set.member w.id selectedWidgets
    in
    maybeDrag
        |> filterMaybe (\drag -> isBeingDragged selectedWidgets drag w)
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
            , zIndex <|
                int
                    (if isDragged then
                        999

                     else
                        w.zIndex
                    )
            ]
        ]
        [ dragBar w Up
        , dragBar w Down
        , dragBar w Left
        , dragBar w Right
        , div
            [ css
                ([ width (pct 100)
                 , height (pct 100)
                 , boxSizing borderBox
                 , backgroundColor w.backgroundColor
                 , borderColor w.borderColor
                 , borderStyle solid
                 , borderWidth (px w.borderWidth)
                 , borderRadius (px w.borderRadius)
                 , padding (px w.padding)
                 , overflow hidden
                 ]
                    ++ (if isDragged then
                            [ cursor grabbing
                            , boxShadow5 zero zero (px 14) (px 2) (rgba 0 0 0 0.3)
                            ]

                        else
                            []
                       )
                    ++ (if isSelected then
                            [ boxShadow5 zero zero (px 4) (px 2) (rgb 0 180 255)
                            ]

                        else
                            []
                       )
                )
            , handleDrag (MovingWidget { id = w.id, dx = 0, dy = 0 })
            ]
            [ getWidgetContent w
            ]
        ]


getWidgetContent : Widget -> Html msg
getWidgetContent widget =
    case widget.widgetType of
        TextShapeWidget innerHtml ->
            Html.Styled.fromUnstyled <|
                Markdown.toHtml [ Html.Attributes.class "markdown" ] innerHtml

        ImageWidget src ->
            if String.startsWith "http" src then
                img
                    [ Attributes.src src
                    , css
                        [ property "object-fit" "contain"
                        , width (pct 100)
                        , height (pct 100)
                        ]
                    ]
                    []

            else
                div
                    [ css
                        [ backgroundColor (rgba 100 100 100 0.3)
                        , width (pct 100)
                        , height (pct 100)
                        , color (rgb 50 50 50)
                        , padding (px 12)
                        , fontFamily sansSerif
                        , boxSizing borderBox
                        ]
                    ]
                    [ div
                        [ css [ fontSize (px 24), paddingBottom (px 8) ] ]
                        [ text
                            (if String.isEmpty src then
                                "No Source"

                             else
                                src
                            )
                        ]
                    , div
                        [ css [ fontSize (px 12) ] ]
                        [ text "For security, it is impossible to acces the local file stystem from javascript in the browser. However, once we switch to Electron, it will be easy." ]
                    ]

        _ ->
            div
                [ css
                    [ width (pct 100)
                    , height (pct 100)
                    , backgroundColor (hex "#ff0000")
                    ]
                ]
                [ text "TODO"
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
