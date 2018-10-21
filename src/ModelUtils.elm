module ModelUtils exposing (getWidgetById)

import Model exposing (Model, Widget, getSelectedPage)


getWidgetById : Model -> String -> Maybe Widget
getWidgetById model id =
    (getSelectedPage model).widgets
        |> List.filter (\w -> w.id == id)
        |> List.head
