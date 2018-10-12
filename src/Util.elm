module Util exposing (equalsMaybe, filterMaybe, styleSheet, thenFire, updateSelected)

import Html exposing (node)
import Html.Attributes exposing (href, rel)
import Html.Styled exposing (Html, fromUnstyled)
import SelectList exposing (Position(..), SelectList)
import Task


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
