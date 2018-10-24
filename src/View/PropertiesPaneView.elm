module View.PropertiesPaneView exposing (viewPropertiesPane)

import Css exposing (..)
import Html.Styled as Html exposing (Attribute, Html, div, fieldset, h1, label, span, styled, text, textarea)
import Html.Styled.Attributes as Attributes exposing (css, for, href, id, src, type_, value)
import Html.Styled.Events exposing (onInput)
import Messages exposing (BookUpdate(..), Msg(..))
import Model exposing (..)
import ModelUtils exposing (getWidgetById)
import Set
import Util exposing (colorFromHex, colorToHex)


menuContainer =
    styled div
        [ position relative
        , width (pct 100)
        , height (pct 100)
        , padding (px 12)
        , boxSizing borderBox
        , overflowY auto
        , overflowX hidden
        ]


viewPropertiesPane : Model -> Html Msg
viewPropertiesPane model =
    case Set.toList model.selectedWidgets of
        [] ->
            menuContainer
                [ css [ paddingTop (px 32) ]
                ]
                [ text "Click on a widget to see its properties" ]

        id :: [] ->
            case getWidgetById model id of
                Just widget ->
                    menuContainer []
                        [ viewPropertiesForWidget widget
                        ]

                Nothing ->
                    text "Something went wrong"

        _ ->
            menuContainer [] [ text "I haven't implemented properties for multiple widgets yet" ]


viewSectionTitle : String -> Html Msg
viewSectionTitle title =
    h1
        [ css
            [ position relative
            , zIndex (int 1)
            , fontSize (px 20)
            , color (hex "#444444")
            , textAlign center
            , margin2 (px 12) zero
            , before
                [ property "content" "''"
                , borderTop3 (px 2) solid (hex "#dfdfdf")
                , margin2 zero auto
                , position absolute
                , top (pct 50)
                , left zero
                , right zero
                , bottom zero
                , width (pct 100)
                , zIndex (int -1)
                ]
            ]
        ]
        [ span
            [ css
                [ backgroundColor (hex "#ffffff")
                , padding2 zero (px 15)
                ]
            ]
            [ text title
            ]
        ]


propertyLabel id str =
    styled label
        [ marginLeft (px 12)
        ]
        [ for id ]
        [ text str ]


styledInput =
    styled Html.input
        [ width (px 47)
        , boxSizing borderBox
        ]


input : String -> List (Attribute msg) -> Html msg
input label attrs =
    div [ css [ marginBottom (px 12) ] ]
        [ styledInput
            (attrs
                ++ [ id label ]
            )
            []
        , propertyLabel label label
        ]


numberInput : String -> Float -> (Float -> Widget) -> Html Msg
numberInput label val updateFun =
    input
        label
        [ type_ "number"
        , Attributes.min "0"
        , value (String.fromFloat val)
        , onInput
            (\str ->
                case String.toFloat str of
                    Just x ->
                        UpdateBook <| UpdateWidget (updateFun x)

                    Nothing ->
                        NoOp
            )
        ]


colorInput : String -> Color -> (Color -> Widget) -> Html Msg
colorInput label val updateFun =
    input
        label
        [ type_ "color"
        , value (colorToHex val)
        , onInput
            (\hexString ->
                case colorFromHex hexString of
                    Just color ->
                        UpdateBook <| UpdateWidget (updateFun color)

                    Nothing ->
                        NoOp
            )
        ]


viewPropertiesForWidget : Widget -> Html Msg
viewPropertiesForWidget widget =
    div []
        [ viewGenericProperties widget
        , case widget.widgetType of
            TextShapeWidget text ->
                viewTextProperties widget text

            ImageWidget src ->
                viewImageProperties widget src

            VideoWidget src ->
                viewImageProperties widget src
        ]


viewTextProperties : Widget -> String -> Html Msg
viewTextProperties widget text =
    div []
        [ viewSectionTitle "Content"
        , textarea
            [ css
                [ resize none
                , width (pct 100)
                , height (px 300)
                ]
            , onInput
                (\str ->
                    UpdateBook <|
                        UpdateWidget
                            { widget | widgetType = TextShapeWidget str }
                )
            ]
            [ Html.text text
            ]
        ]


viewImageProperties : Widget -> String -> Html Msg
viewImageProperties widget src =
    div []
        [ viewSectionTitle "Image/Video"
        , div []
            [ label [ for "src" ] [ text "Source:" ]
            , Html.input
                [ type_ "text"
                , value src
            , css [ marginLeft (px 12) ]
                , onInput
                    (\str ->
                        UpdateBook <|
                            UpdateWidget
                                { widget | widgetType = ImageWidget str }
                    )
                ]
                []
            ]
        ]


viewGenericProperties : Widget -> Html Msg
viewGenericProperties widget =
    div []
        [ viewSectionTitle "Basic Controls"
        , fieldset []
            [ colorInput
                "Background Color"
                widget.backgroundColor
                (\color -> { widget | backgroundColor = color })
            , numberInput
                "Border Width"
                widget.borderWidth
                (\x -> { widget | borderWidth = x })
            , colorInput
                "Border Color"
                widget.borderColor
                (\color -> { widget | borderColor = color })
            , numberInput
                "Rounded Corners"
                widget.borderRadius
                (\x -> { widget | borderRadius = x })
            , numberInput
                "Margins"
                widget.padding
                (\x -> { widget | padding = x })
            , numberInput
                "Width"
                widget.width
                (\x -> { widget | width = x })
            , numberInput
                "Height"
                widget.height
                (\x -> { widget | height = x })
            , numberInput
                "X Position"
                widget.x
                (\x -> { widget | x = x })
            , numberInput
                "Y Position"
                widget.y
                (\x -> { widget | y = x })
            , numberInput
                "Layer"
                (toFloat widget.zIndex)
                (\x -> { widget | zIndex = Basics.floor x })
            ]
        ]
