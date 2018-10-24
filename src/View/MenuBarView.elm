module View.MenuBarView exposing (viewMenuBar)

import Css exposing (..)
import Html.Styled as Html exposing (Attribute, Html, div, li, styled, text, ul)
import Html.Styled.Attributes as Attributes exposing (css)
import Html.Styled.Events as Events exposing (onClick)
import Messages exposing (BookUpdate(..), Msg(..))
import Model exposing (..)
import SelectList exposing (Position(..), SelectList)
import View.MyButton exposing (button)
import View.Shadows exposing (..)
import View.TabPane exposing (tabPane)


viewMenuBar : Model -> Html Msg
viewMenuBar model =
    div [ css [ position relative, height (pct 100) ] ]
        [ tabPane model.menuBarTabs getTabTitle getTabContent MenuTabSelected
        , belowBottom (shadow Down) 12
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
                [ button "Undo" Undo
                , button "Redo" Redo
                , button "Cut" Cut
                , button "Copy" Copy
                , button "Paste" Paste
                ]

            Insert ->
                [ button "Page" (UpdateBook InsertPage)
                , button "Text Widget"
                    (UpdateBook (InsertWidget (TextShapeWidget "Hello")))
                , button "Image Widget"
                    (UpdateBook (InsertWidget (ImageWidget "")))
                , button "Video Widget"
                    (UpdateBook (InsertWidget (VideoWidget "")))
                ]
        )
