module Serialization.Deserialize exposing (deserialize)

import Css exposing (Color, hex)
import Json.Decode as Decode exposing (Decoder, float, int, list, string)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Model exposing (..)
import SelectList
import Util exposing (colorFromHex, selectFirst)


deserialize : Decoder Book
deserialize =
    decode Book
        |> required "pages" (Decode.map selectFirst (list page))
        |> required "aspectRatio" aspectRatio
        |> required "idCounter" int


aspectRatio : Decoder AspectRatio
aspectRatio =
    decode AspectRatio
        |> required "width" float
        |> required "height" float


page : Decoder Page
page =
    decode Page
        |> required "id" string
        |> required "widgets" (list widget)


color : String -> Color
color =
    colorFromHex >> Maybe.withDefault (hex "#ffffff")


widget : Decoder Widget
widget =
    decode Widget
        |> required "id" string
        |> required "x" float
        |> required "y" float
        |> required "width" float
        |> required "height" float
        |> required "backgroundColor" (Decode.map color string)
        |> required "borderColor" (Decode.map color string)
        |> required "borderWidth" float
        |> required "borderRadius" float
        |> required "padding" float
        |> hardcoded (TextShapeWidget "")
        |> required "zIndex" int


widgetType : Decoder WidgetType
widgetType =
    Decode.field "type" string |> Decode.andThen widgetInfo


widgetInfo : String -> Decoder WidgetType
widgetInfo type_ =
    case type_ of
        "TextShapeWidget" ->
            Decode.map TextShapeWidget (Decode.field "text" string)

        "ImageWidget" ->
            Decode.map ImageWidget (Decode.field "src" string)

        "VideoWidget" ->
            Decode.map ImageWidget (Decode.field "src" string)

        _ ->
            Decode.fail (type_ ++ "is not a supported widget type")


decode =
    Decode.succeed
