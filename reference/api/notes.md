<!-- vendored from https://api.tabletopsimulator.com/notes/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Notes

Notes, a static global class, allows access to the on-screen notes and the notebook.

Example function call: `Notes.setNotes()`

## Function Summary

### Notebook Functions

Functions that interact with the in-game notebook tabs.

| Function Name | Description | Return |
| --- | --- | --- |
| addNotebookTab(*table* parameters) | Adds a notebook tab, returning its index. | *returns int* |
| editNotebookTab(*table* parameters) | Edit an existing Tab in the notebook. | *returns bool* |
| getNotebookTabs() | Returns Table containing data on all tabs in the notebook. | *returns table* |
| removeNotebookTab(*int* index) | Remove a notebook tab. | *returns bool* |

### Notes Functions

Functions that interact with the on-screen notes (lower right corner of screen).

######

| Function Name | Description | Return |
| --- | --- | --- |
| getNotes()getNotes() | Returns the contents of the on-screen notes section. | *returns string* |
| setNotes(*string* notes) | Replace the text in the notes window with the string. | *returns bool* |

---

## Function Details

### Notebook Function Details

#### addNotebookTab(...)

*returns int*  Add a new notebook tab. If it failed to create a new tab, a -1 is returned instead. Indexes for notebook tabs begin at 0.

> **addNotebookTab(parameters)**
>
> - *table* **parameters**: A Table containing spawning parameters.
>
>   - *string* **parameters.title**: Title for the new tab.
>
>   - *string* **parameters.body**: Text to place into the body of the new tab.
>
>     - Optional, defaults to an empty string
>
>   - *string* **parameters.color**: [Player Color](player__instance.md) for the new tab's color.
>
>     - Optional, defaults to "Grey"

```
parameters = {
    title = "New Tab",
    body = "Body text example.",
    color = "Grey"
}
Notes.addNotebookTab(parameters)
```

---

#### editNotebookTab(...)

*returns bool*  Edit an existing Tab in the notebook. Indexes for notebook tabs begin at 0.

> **editNotebookTab(parameters)**
>
> - *table* **parameters**: A Table containing instructions for the notebook edit.
>
>   - *int* **parameters.index**: Index number for the tab.
>
>   - *string* **parameters.title**: Title for the tab.
>
>     - Optional, defaults to the current title of the tab begin edited.
>
>   - *string* **parameters.body**: Text for the body for the tab.
>
>     - Optional, defaults to the current body of the tab begin edited.
>
>   - *string* **parameters.color**: [Player Color](player__colors.md) for who the tab belongs to.
>
>     - Optional, defaults to the current color of the tab begin edited.

```
params = {
    index = 5,
    title = "Edited Title",
    body = "This tab was edited via script.",
    color = "Grey"
}
Notes.editNotebookTab(params)
```

---

#### getNotebookTabs()

*returns table*  Returns a Table containing data on all tabs in the notebook. Indexes for notebook tabs begin at 0.

```
--Example Usage
tabInfo = Notes.getNotebookTabs()
```

```
--Example Returned Table
{
    {index=0, title="", body="", color="Grey"},
    {index=1, title="", body="", color="Grey"},
    {index=2, title="", body="", color="Grey"},
}
```

---

#### removeNotebookTab(...)

*returns bool*  Remove a notebook tab. Notebook tab indexes begin at 0.

> **removeNotebookTab(index)**
>
> - *int* **index**: Index for the tab to remove.

```
Notes.removeNotebookTab(0)
```

---

### Notes Function Details

#### setNotes(...)

*returns bool*  Replace the text in the notes window with the string. The notes is an area which displays text in the lower-right corner of the screen.

> **setNotes(notes)**
>
> - *string* **notes**: What to place into the notes area.

```
Notes.setNotes("This appears in the notes section")
```

---
