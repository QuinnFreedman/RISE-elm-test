module View.TabPane exposing (tabPane)

import Css exposing (..)
import Html.Styled as Html exposing (Attribute, Html, div, li, styled, text, ul)
import Html.Styled.Events as Events exposing (onClick)
import SelectList exposing (Position(..), SelectList)


navBar =
    styled ul
        [ paddingLeft zero
        , marginBottom zero
        , marginTop zero
        , padding4 (px 8) (px 8) zero (px 8)
        , borderBottom3 (px 1) solid (hex "#dddddd")
        , display inlineBlock
        , width (pct 100)
        , boxSizing borderBox
        ]


tabStyle =
    Css.batch
        [ float left
        , position relative
        , display block
        , marginBottom (px -1)
        , marginRight (px 2)
        , padding2 (px 10) (px 15)
        , borderRadius4 (px 4) (px 4) zero zero
        , borderWidth (px 1)
        , borderStyle solid
        , cursor pointer
        ]


inactiveTab =
    styled li
        [ tabStyle
        , borderColor transparent
        , hover
            [ backgroundColor (hex "#eeeeee")
            ]
        ]


activeTab =
    styled li
        [ tabStyle
        , borderColor (hex "#dddddd")
        , borderBottomColor transparent
        , backgroundColor (hex "#ffffff")
        ]


tabPane :
    SelectList a
    -> (a -> String)
    -> (a -> Html msg)
    -> (a -> msg)
    -> Html msg
tabPane tabs getTabName renderPanel message =
    div []
        [ navBar []
            (SelectList.mapBy
                (\pos a ->
                    case pos of
                        Selected ->
                            activeTab [] [ text (getTabName a) ]

                        _ ->
                            inactiveTab
                                [ onClick (message a) ]
                                [ text (getTabName a) ]
                )
                tabs
                |> SelectList.toList
            )
        , renderPanel (SelectList.selected tabs)
        ]
