port module Ports exposing (debugExperementalElectromMsg, debugExperementalSendElectromMsg, fileDropped)


port fileDropped : (String -> msg) -> Sub msg


port debugExperementalElectromMsg : (String -> msg) -> Sub msg


port debugExperementalSendElectromMsg : String -> Cmd msg
