module View.MyButton exposing (button, buttonBase)

import Css exposing (..)
import Html.Styled exposing (div, styled, text)
import Html.Styled.Events exposing (onClick)


button string msg =
    buttonBase
        [ onClick msg ]
        [ text string ]


buttonBase =
    styled div
        [ lineHeight (px 34)
        , padding2 zero (px 24)
        , borderRadius (px 4)
        , border3 (px 1) solid (hex "#dddddd")
        , display inlineBlock
        , margin2 (px 4) (px 4)
        , cursor pointer
        , property "background-image" "linear-gradient(to bottom, #fff, #f0f0f0)"
        , active
            [ property "background-image" "linear-gradient(to top, #fff, #f0f0f0)"
            ]
        ]
