module View.MenuBarView exposing (viewMenuBar)

import Css exposing (..)
import Html.Styled as Html exposing (Attribute, Html, button, div, li, styled, text, ul)
import Html.Styled.Attributes as Attributes exposing (css)
import Html.Styled.Events as Events exposing (onClick)
import Messages exposing (Msg(..))
import Model exposing (MenuBarTab(..), Model)
import SelectList exposing (Position(..), SelectList)
import View.TabPane exposing (tabPane)


viewMenuBar : Model -> Html Msg
viewMenuBar model =
    div [ css [ position relative, height (pct 100) ] ]
        [ tabPane model.menuBarTabs getTabTitle getTabContent MenuTabSelected
        , bottomShadow 12
        ]


getTabTitle : MenuBarTab -> String
getTabTitle tab =
    case tab of
        File ->
            "File"

        Edit ->
            "Edit"

        Insert ->
            "Insert"


getTabContent : MenuBarTab -> Html Msg
getTabContent tab =
    div []
        (case tab of
            File ->
                [ text "File" ]

            Edit ->
                [ menuButton
                    [ onClick Undo ]
                    [ text "Undo"
                    ]
                , menuButton
                    [ onClick Redo ]
                    [ text "Redo" ]
                , menuButton []
                    [ text "Cut"
                    ]
                , menuButton []
                    [ text "Copy"
                    ]
                , menuButton []
                    [ text "Paste"
                    ]
                ]

            Insert ->
                [ text "File" ]
        )


menuButton =
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


bottomShadow size =
    div
        [ css
            [ position absolute
            , bottom (px -size)
            , height (px size)
            , property "background-image"
                "linear-gradient(to bottom, rgba(0,0,0,.05), rgba(0,0,0,0))"
            , width (pct 100)
            , zIndex (int 9999)
            ]
        ]
        []
