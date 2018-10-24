module View.PagesPreviewView exposing (pagesPreview)

import Css exposing (..)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Messages exposing (BookUpdate(..), Msg(..))
import Model exposing (..)
import SelectList exposing (SelectList)
import Set
import View.PageView exposing (viewPage)
import View.Shadows exposing (..)


pagesPreview : SelectList Page -> AspectRatio -> Html Msg
pagesPreview pages aspectRatio =
    div
        [ css
            [ width (pct 100)
            , height (pct 100)
            , backgroundColor (hex "#dddddd")
            , position relative

            -- , boxShadow6 inset zero zero (px 6) zero (rgba 0 0 0 0.05)
            , overflowY auto
            , overflowX hidden
            ]
        ]
        ([ insideLeft (shadow Right) 12
         , insideRight (shadow Left) 12
         , insideBottom (shadow Up) 12
         ]
            ++ (pages
                    |> SelectList.mapBy
                        (\selected page ->
                            miniPageView page
                                aspectRatio
                                (selected == SelectList.Selected)
                        )
                    |> SelectList.toList
               )
        )


miniPageView : Page -> AspectRatio -> Bool -> Html Msg
miniPageView page aspectRatio selected =
    div
        [ css
            [ marginLeft auto
            , marginRight auto
            , paddingTop (px 18)
            , position relative
            ]
        ]
        [ div
            [ css
                ([ padding2 (px 12) zero
                 ]
                    ++ (if selected then
                            [ backgroundColor (hex "#cccccc") ]

                        else
                            []
                       )
                )
            ]
            [ viewPage page aspectRatio 0.12 Nothing Set.empty ]
        , div
            [ css
                [ width (pct 100)
                , height (pct 100)
                , position absolute
                , top (px 0)
                , left (px 0)
                , cursor pointer
                ]
            , onClick (UpdateBook (SelectPage page.id))
            ]
            []
        ]
