module Messages exposing (BookUpdate(..), Msg(..))

import Draggable
import Keyboard exposing (KeyEvent)
import Model exposing (MyDragState, Position, Widget)


type Msg
    = OnDragBy Draggable.Delta
    | OnDragStart (Draggable.Msg ()) MyDragState
    | OnDragEnd
    | DragMsg (Draggable.Msg ())
    | UpdateBook BookUpdate
    | KeyPressed KeyEvent
    | SelectWidget String
    | NoOp


type BookUpdate
    = PutWidget Widget
