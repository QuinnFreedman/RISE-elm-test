module Serialization.Serialize exposing (serialize)

import Json.Encode as Encode exposing (Value, encode, float, int, list, object, string)
import Model exposing (..)
import SelectList
import Util exposing (colorToHex)


serialize : Model -> String
serialize model =
    encode 4 (book model.book)


book : Book -> Value
book b =
    object
        [ ( "pages", list page (SelectList.toList b.pages) )
        , ( "aspectRatio", aspectRatio b.aspectRatio )
        , ( "idCounter", int b.widgetIdCounter )
        ]


aspectRatio : AspectRatio -> Value
aspectRatio a =
    object
        [ ( "width", float a.width )
        , ( "height", float a.height )
        ]


page : Page -> Value
page p =
    object
        [ ( "id", string p.id )
        , ( "widgets", list widget p.widgets )
        ]


widget : Widget -> Value
widget w =
    object
        [ ( "id", string w.id )
        , ( "x", float w.x )
        , ( "y", float w.y )
        , ( "width", float w.width )
        , ( "height", float w.height )
        , ( "backgroundColor", string (colorToHex w.backgroundColor) )
        , ( "borderColor", string (colorToHex w.borderColor) )
        , ( "borderWidth", float w.borderWidth )
        , ( "borderRadius", float w.borderRadius )
        , ( "padding", float w.padding )
        , ( "widgetType", widgetType w.widgetType )
        , ( "zIndex", int w.zIndex )
        ]


widgetType : WidgetType -> Value
widgetType x =
    case x of
        TextShapeWidget text ->
            object
                [ ( "type", string "TextShapeWidget" )
                , ( "content", string text )
                ]

        ImageWidget src ->
            object
                [ ( "type", string "ImageWidget" )
                , ( "content", string src )
                ]

        VideoWidget src ->
            object
                [ ( "type", string "VideoWidget" )
                , ( "content", string src )
                ]
