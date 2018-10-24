module View.Shadows exposing
    ( Direction(..)
    , belowBottom
    , insideBottom
    , insideLeft
    , insideRight
    , outsideLeft
    , shadow
    )

import Css exposing (..)
import Html.Styled as Html exposing (Attribute, Html, div, styled)
import Html.Styled.Attributes as Attributes exposing (css)


type Direction
    = Up
    | Down
    | Left
    | Right


shadow upDown =
    let
        dir =
            case upDown of
                Up ->
                    "to top"

                Down ->
                    "to bottom"

                Left ->
                    "to left"

                Right ->
                    "to right"
    in
    styled div
        [ property "background-image"
            ("linear-gradient("
                ++ dir
                ++ ", rgba(0,0,0,.05), rgba(0,0,0,0))"
            )
        , zIndex (int 9999)
        , position absolute
        ]


belowBottom shadow_ size =
    styled shadow_
        [ bottom (px -size)
        , height (px size)
        , width (pct 100)
        , left (px 0)
        ]
        []
        []


outsideLeft shadow_ size =
    styled shadow_
        [ left (px -size)
        , top (px 0)
        , width (px size)
        , height (pct 100)
        ]
        []
        []


insideLeft shadow_ size =
    styled shadow_
        [ left (px 0)
        , top (px 0)
        , width (px size)
        , height (pct 100)
        ]
        []
        []


insideRight shadow_ size =
    styled shadow_
        [ right (px 0)
        , top (px 0)
        , width (px size)
        , height (pct 100)
        ]
        []
        []


insideBottom shadow_ size =
    styled shadow_
        [ bottom (px 0)
        , height (px size)
        , width (pct 100)
        , left (px 0)
        ]
        []
        []
