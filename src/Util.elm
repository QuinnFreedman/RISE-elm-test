module Util exposing
    ( chainUpdate
    , colorFromHex
    , colorToHex
    , equalsMaybe
    , filterMaybe
    , normalizeRect
    , onDrop
    , selectFirst
    , styleSheet
    , thenFire
    , updateSelected
    )

import Css exposing (Color, rgb, rgba)
import Hex
import Html exposing (node)
import Html.Attributes exposing (href, rel)
import Html.Styled exposing (Attribute, Html, div, fromUnstyled)
import Html.Styled.Events exposing (custom)
import Json.Decode as Decode exposing (list, string)
import Json.Decode.Pipeline exposing (requiredAt)
import Model exposing (Rect)
import SelectList exposing (Position(..), SelectList)
import Task
import Tuple exposing (first, second)


styleSheet : String -> Html msg
styleSheet path =
    fromUnstyled <| node "link" [ rel "stylesheet", href path ] []



-- match : (a -> b) -> Maybe b -> Maybe a
-- match constructor maybe =
--     maybe |> Maybe.andThen (\thing ->
--         case thing of
--         a x -> Just x
--         _ -> Nothing
--     )


filterMaybe : (a -> Bool) -> Maybe a -> Maybe a
filterMaybe condition maybe =
    maybe
        |> Maybe.andThen
            (\x ->
                if condition x then
                    Just x

                else
                    Nothing
            )


equalsMaybe : a -> Maybe a -> Bool
equalsMaybe x maybe =
    maybe
        |> Maybe.map (\y -> y == x)
        |> Maybe.withDefault False


thenFire : msg -> Cmd msg
thenFire msg =
    Task.perform identity (Task.succeed msg)


updateSelected : (a -> a) -> SelectList a -> SelectList a
updateSelected f =
    SelectList.mapBy
        (\listPosition item ->
            case listPosition of
                Selected ->
                    f item

                _ ->
                    item
        )


normalizeRect : Rect -> Rect
normalizeRect rect =
    let
        fixedY =
            if rect.height < 0 then
                { rect | y = rect.y + rect.height, height = -rect.height }

            else
                rect
    in
    if fixedY.width < 0 then
        { fixedY | x = fixedY.x + fixedY.width, width = -fixedY.width }

    else
        fixedY


chainUpdate : (modelType -> ( modelType, Cmd msg )) -> ( modelType, Cmd msg ) -> ( modelType, Cmd msg )
chainUpdate update old =
    let
        new =
            update (first old)

        newModel =
            first new

        newCmd =
            Cmd.batch [ second old, second new ]
    in
    ( newModel, newCmd )


onDrop : (List String -> msg) -> msg -> List (Attribute msg)
onDrop message noOp =
    let
        decoder =
            Decode.succeed identity
                |> requiredAt [ "dataTransfer", "files" ] (list string)
    in
    [ custom
        "drop"
        (Decode.map
            (alwaysPreventDefaultAndStopPropagation << message)
            decoder
        )
    , onWithOptions "dragover"
        { stopPropagation = True, preventDefault = True }
        (Decode.succeed noOp)
    ]


alwaysPreventDefaultAndStopPropagation :
    msg
    ->
        { message : msg
        , stopPropagation : Bool
        , preventDefault : Bool
        }
alwaysPreventDefaultAndStopPropagation msg =
    { message = msg, stopPropagation = True, preventDefault = True }


{-| polyfill for onWithOptions
-}
onWithOptions :
    String
    ->
        { stopPropagation : Bool
        , preventDefault : Bool
        }
    -> Decode.Decoder msg
    -> Attribute msg
onWithOptions name { stopPropagation, preventDefault } decoder =
    decoder
        |> Decode.map
            (\msg ->
                { message = msg
                , stopPropagation = stopPropagation
                , preventDefault = preventDefault
                }
            )
        |> custom name


padl : Int -> Char -> String -> String
padl len pad str =
    let
        padSize =
            len - String.length str
    in
    if padSize > 0 then
        (List.repeat padSize pad |> String.fromList) ++ str

    else
        str


twoDigitHex : Int -> String
twoDigitHex i =
    padl 2 '0' (Hex.toString i)


colorToHex : Color -> String
colorToHex color =
    List.foldl (\a b -> b ++ a)
        "#"
        [ twoDigitHex color.red
        , twoDigitHex color.green
        , twoDigitHex color.blue
        , if color.alpha /= 1 then
            twoDigitHex (round (color.alpha * 255))

          else
            ""
        ]


colorFromHex : String -> Maybe Color
colorFromHex hex =
    case String.toList hex of
        '#' :: r1 :: r2 :: g1 :: g2 :: b1 :: b2 :: [] ->
            let
                red =
                    Hex.fromString <| String.fromList <| r1 :: r2 :: []

                green =
                    Hex.fromString <| String.fromList <| g1 :: g2 :: []

                blue =
                    Hex.fromString <| String.fromList <| b1 :: b2 :: []
            in
            Result.map3 rgb red green blue
                |> Result.toMaybe

        '#' :: r1 :: r2 :: g1 :: g2 :: b1 :: b2 :: a1 :: a2 :: [] ->
            let
                red =
                    Hex.fromString <| String.fromList <| r1 :: r2 :: []

                green =
                    Hex.fromString <| String.fromList <| g1 :: g2 :: []

                blue =
                    Hex.fromString <| String.fromList <| b1 :: b2 :: []

                alpha =
                    (b1 :: b2 :: [])
                        |> String.fromList
                        |> Hex.fromString
                        |> Result.map (\x -> toFloat x / 255.0)
            in
            Result.map4 rgba red green blue alpha
                |> Result.toMaybe

        _ ->
            Nothing


selectFirst : List a -> SelectList a
selectFirst x =
    case x of
        [] ->
            Debug.todo "This should return an error type"

        head :: rest ->
            SelectList.fromLists [] head rest
