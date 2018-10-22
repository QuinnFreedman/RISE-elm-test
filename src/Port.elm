port module Port exposing (fileDropped)


port fileDropped : (String -> msg) -> Sub msg
