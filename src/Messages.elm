module Messages exposing (BookUpdate(..), Msg(..))

import Draggable
import Keyboard exposing (KeyEvent)
import Model exposing (MyDragState, Widget)


type Msg
    = OnDragBy Draggable.Delta
    | OnDragStart MyDragState
    | OnDragEnd
    | DragMsg (Draggable.Msg MyDragState)
    | UpdateBook BookUpdate
    | KeyPressed KeyEvent
    | NoOp


type BookUpdate
    = PutWidget Widget
