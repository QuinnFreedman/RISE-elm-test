module View.PageView exposing (viewPage, viewSelectedPage)

import Css exposing (..)
import DragHelpers exposing (handleDragWithStartPos)
import Html.Styled exposing (Html, div, text)
import Html.Styled.Attributes exposing (css)
import Messages exposing (Msg(..))
import Model exposing (..)
import Set exposing (Set)
import Util exposing (normalizeRect, onDrop)
import View.MyButton exposing (button)
import View.WidgetView exposing (renderDraggableWidget)


viewSelectedPage : Model -> Html Msg
viewSelectedPage model =
    div
        [ css
            [ position absolute
            , width (pct 100)
            , height (pct 100)
            ]
        ]
        [ div
            [ css
                [ width (pct 100)
                , height (pct 100)
                , position relative
                , overflow scroll
                , backgroundColor (hex "#eeeeee")
                , boxSizing borderBox
                ]
            ]
            [ viewPage (getSelectedPage model)
                model.book.aspectRatio
                (toFloat model.zoom / 100)
                model.myDragState
                model.selectedWidgets
            ]
        , zoomControls model
        ]


zoomControls : Model -> Html Msg
zoomControls model =
    div
        [ css
            [ position absolute
            , bottom (px 24)
            , right (px 24)
            ]
        ]
        [ button "-" ZoomOut
        , text <| String.fromInt model.zoom ++ "%"
        , button "+" ZoomIn
        ]


viewPage :
    Page
    -> AspectRatio
    -> Float
    -> Maybe MyDragState
    -> Set String
    -> Html Msg
viewPage page aspectRatio scale dragState selectedWidgetIds =
    div
        [ css
            [ width <| px (aspectRatio.width * scale)
            , height <| px (aspectRatio.height * scale)
            , marginLeft auto
            , marginRight auto
            , position relative
            , boxShadow5 zero zero (px 12) zero (rgba 0 0 0 0.1)
            ]
        ]
        [ div
            [ css
                [ backgroundColor (rgb 255 255 255)
                , width <| px aspectRatio.width
                , height <| px aspectRatio.height
                , transform (Css.scale scale)
                , property "transform-origin" "top left"
                , overflow hidden
                ]
            , handleDragWithStartPos (\pos -> DraggingSelection { x = pos.x, y = pos.y, width = 0, height = 0 })
            ]
            (renderSelectionRect dragState
                :: (page.widgets
                        |> List.map
                            (\w ->
                                renderDraggableWidget w
                                    dragState
                                    selectedWidgetIds
                            )
                   )
            )
        ]


renderSelectionRect : Maybe MyDragState -> Html Msg
renderSelectionRect dragState =
    case dragState of
        Just (DraggingSelection irregularRect) ->
            let
                rect =
                    normalizeRect irregularRect
            in
            div
                [ css
                    [ borderStyle dashed
                    , borderWidth (px 4)
                    , borderColor (rgb 0 255 255)
                    , position absolute
                    , boxSizing borderBox
                    , top (px rect.y)
                    , left (px rect.x)
                    , width (px rect.width)
                    , height (px rect.height)
                    ]
                ]
                []

        _ ->
            div [] []
