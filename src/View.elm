module View exposing (view)

import Css exposing (..)
import Css.Global
import DragHelpers exposing (dragStopped, dragged, handleDrag, handleDragWithStartPos)
import Html.Styled as Html exposing (Html, div, text)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Html.Styled.Events as Events
import Messages exposing (Msg(..))
import Model exposing (..)
import Util exposing (styleSheet)
import View.MenuBarView exposing (viewMenuBar)
import View.PageView exposing (viewSelectedPage)
import View.PagesPreviewView exposing (pagesPreview)
import View.PropertiesPaneView exposing (viewPropertiesPane)


view : Model -> Html Msg
view model =
    div
        [ css
            [ height (pct 100)
            , width (pct 100)
            , displayFlex
            , flexWrap noWrap
            , flexFlow1 column
            , alignItems stretch
            ]
        ]
        [ --styles
          styleSheet "/css/reset.css"
        , styleSheet "/css/markdown.css"
        , Css.Global.global
            [ Css.Global.body
                [ width (pct 100)
                , height (pct 100)
                ]
            , Css.Global.html
                [ width (pct 100)
                , height (pct 100)
                , fontFamilies [ "Robot", "sans-serif", "sans" ]
                ]
            , Css.Global.div
                [ property "-moz-user-select" "none"
                , property "-webkit-user-select" "none"
                , property "-ms-user-select" "none"
                , property "user-select" "none"
                , property "-o-user-select" "none"
                , property "unselectable='on' onselectstart='return false';" ""
                ]
            ]
        , renderDebugOutput model

        --header
        , div
            [ css
                [ flexGrow (int 0)
                , flexShrink (int 0)
                , height (px 100)
                ]
            ]
            [ viewMenuBar model ]
        , div
            [ css
                [ height (pct 100)
                , width (pct 100)
                , flexGrow (int 1)
                , flexShrink (int 1)
                , displayFlex
                , flexDirection row
                , flexWrap noWrap
                , alignItems stretch
                ]
            ]
            [ -- left sidebar
              div
                [ css
                    [ flexGrow (int 0)
                    , flexShrink (int 0)
                    , width (px 200)
                    ]
                ]
                [ pagesPreview model.book.pages model.book.aspectRatio
                ]

            -- center content
            , div
                [ css
                    [ flexGrow (int 1)
                    , flexShrink (int 1)
                    , flexBasis (px 0)
                    , position relative
                    ]
                ]
                [ viewSelectedPage model
                ]

            -- right sidebar
            , div
                [ css
                    [ flexGrow (int 0)
                    , flexShrink (int 0)
                    , width (px 300)
                    ]
                ]
                [ viewPropertiesPane model
                ]
            ]

        --footer
        -- , div
        --     [ css
        --         [ display tableRow
        --         , height (px 100)
        --         ]
        --     ]
        --     [ text "footer" ]
        ]


renderDebugOutput : Model -> Html Msg
renderDebugOutput model =
    if model.debugShowWindow then
        div
            [ css
                [ width (pct 100)
                , height (pct 100)
                , backgroundColor (rgba 0 0 0 0.5)
                , position fixed
                , top zero
                , left zero
                , zIndex (int 9999999)
                ]
            ]
            [ div
                [ css
                    [ position absolute
                    , top (pct 50)
                    , left (pct 50)
                    , transform (translate2 (pct -50) (pct -50))
                    , backgroundColor (rgb 255 255 255)
                    , borderRadius (px 12)
                    , padding (px 12)
                    , width (px 600)
                    , height (px 400)
                    , overflow auto
                    ]
                ]
                [ Html.input
                    [ Attributes.value model.debugCommand
                    , Events.onInput DebugUpdateCmd
                    ]
                    []
                , Html.button [ Events.onClick DebugSubmitCmd ] [ text "Run" ]
                , div []
                    [ text model.debugResult
                    ]
                , Html.button
                    [ css
                        [ position absolute
                        , top (px 12)
                        , right (px 12)
                        ]
                    , Events.onClick ToggleDebug
                    ]
                    [ text "X" ]
                ]
            ]

    else
        div [] []
