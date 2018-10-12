module ModelUtils exposing (getWidgetById)

import Model exposing (Model, Widget)
import SelectList


getWidgetById : Model -> String -> Maybe Widget
getWidgetById model id =
    (SelectList.selected model.book.pages).widgets
        |> List.filter (\w -> w.id == id)
        |> List.head
