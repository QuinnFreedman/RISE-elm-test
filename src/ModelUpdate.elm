module ModelUpdate exposing
    ( handleBookUpdate
    , handleCopy
    , handlePaste
    , handleRedo
    , handleUndo
    )

import Messages exposing (BookUpdate(..))
import Model exposing (Book, Model, Page, Widget, WidgetType(..))
import ModelUtils exposing (getWidgetById)
import SelectList exposing (Position(..))
import Set
import Util exposing (updateSelected)
import WidgetUtils exposing (initWidget)


handleBookUpdate : BookUpdate -> Model -> Model
handleBookUpdate msg model =
    updateBook (applyBookUpdateHelper msg model.book) model


applyBookUpdateHelper : BookUpdate -> Book -> Book
applyBookUpdateHelper msg book =
    case msg of
        UpdateWidgets widgets ->
            widgets |> List.foldl putWidget book

        UpdateWidget widget ->
            putWidget widget book

        InsertWidgetFromFile path ->
            insertWidgetFromFile path book


updateBook : Book -> Model -> Model
updateBook newBook model =
    { model
        | undoStack = model.book :: model.undoStack
        , redoStack = []
        , book = newBook
    }


handleUndo : Model -> Model
handleUndo model =
    case model.undoStack of
        head :: tail ->
            { model
                | book = head
                , undoStack = tail
                , redoStack = model.book :: model.redoStack
            }

        [] ->
            model


handleRedo : Model -> Model
handleRedo model =
    case model.redoStack of
        head :: tail ->
            { model
                | book = head
                , redoStack = tail
                , undoStack = model.book :: model.undoStack
            }

        [] ->
            model


handleCopy : Model -> Model
handleCopy model =
    let
        selectedWidgets =
            model.selectedWidgets
                |> Set.toList
                |> List.filterMap (getWidgetById model)
    in
    { model | clipboard = selectedWidgets }


handlePaste : Model -> Model
handlePaste model =
    let
        updatedBook =
            model.clipboard
                |> List.map (\w -> { w | x = w.x + 50, y = w.y + 50 })
                |> List.foldl
                    (\widget book ->
                        let
                            ( id, newBook ) =
                                getNewId book

                            newWidget =
                                { widget | id = id }
                        in
                        addWidgetsToCurrentPage [ newWidget ] newBook
                    )
                    model.book

        _ =
            Debug.log "" updatedBook.widgetIdCounter
    in
    updateBook updatedBook model


getNewId : Book -> ( String, Book )
getNewId book =
    let
        id =
            String.fromInt book.widgetIdCounter

        newBook =
            { book | widgetIdCounter = book.widgetIdCounter + 1 }
    in
    ( id, newBook )


insertWidgetFromFile : String -> Book -> Book
insertWidgetFromFile path book =
    let
        ( id, newBook ) =
            getNewId book

        newWidget =
            initWidget ("image-" ++ id) (ImageWidget path) 400 300 200 200
    in
    addWidgetsToCurrentPage [ newWidget ] newBook


addWidgetsToCurrentPage : List Widget -> Book -> Book
addWidgetsToCurrentPage widgets book =
    updateSelectedPage
        (\page ->
            { page
                | widgets = page.widgets ++ widgets
            }
        )
        book


putWidget : Widget -> Book -> Book
putWidget widget book =
    updateSelectedPage
        (\page ->
            { page
                | widgets =
                    List.map
                        (\w ->
                            if w.id == widget.id then
                                widget

                            else
                                w
                        )
                        page.widgets
            }
        )
        book


updateSelectedPage : (Page -> Page) -> Book -> Book
updateSelectedPage f book =
    { book
        | pages = book.pages |> updateSelected f
    }
