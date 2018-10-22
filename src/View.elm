module View exposing (view)

import Css exposing (..)
import Css.Global
import DragHelpers exposing (dragStopped, dragged, handleDrag, handleDragWithStartPos)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes as Attributes exposing (css, href, src)
import Messages exposing (Msg(..))
import Model exposing (..)
import Util exposing (styleSheet)
import View.PageView exposing (viewPage)
import View.PropertiesPaneView exposing (viewPropertiesPane)


view : Model -> Html Msg
view model =
    div
        [ css
            [ height (pct 100)
            , width (pct 100)
            , display table
            ]
        ]
        [ --styles
          Css.Global.global
            [ Css.Global.body
                [ width (pct 100)
                , height (pct 100)
                ]
            , Css.Global.html
                [ width (pct 100)
                , height (pct 100)
                ]
            ]
        , styleSheet "/reset.css"
        , styleSheet "/markdown.css"

        --header
        , div
            [ css
                [ display tableRow
                , height (px 100)
                ]
            ]
            [ viewHeader model ]
        , div
            [ css
                [ height (pct 100)
                , width (pct 100)
                , display table
                ]
            ]
            [ -- left sidebar
              div
                [ css
                    [ display tableCell
                    , width (px 200)
                    , verticalAlign top
                    ]
                ]
                [ viewPagesSidebar model
                ]

            -- center content
            , div
                [ css [ display tableCell ] ]
                [ viewPage model
                ]

            -- right sidebar
            , div
                [ css
                    [ display tableCell
                    , width (px 300)
                    , verticalAlign top
                    ]
                ]
                [ viewPropertiesPane model
                ]
            ]

        --footer
        , div
            [ css
                [ display tableRow
                , height (px 100)
                ]
            ]
            [ text "footer" ]
        ]


viewHeader : Model -> Html msg
viewHeader model =
    text "Header"


viewPagesSidebar : Model -> Html msg
viewPagesSidebar model =
    text "Pages"
