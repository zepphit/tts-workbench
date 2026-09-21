<!-- vendored from https://api.tabletopsimulator.com/grid/ — do not edit, regenerate with scripts/fetch_api_docs.py -->

# Grid

Grid, a static global class, controls the in-game grid. It allows you to manipulate the placement and appearance of the grid in the same way as the in-game interface.

Example usage: `Grid.show_lines = true`.

## Member Variables

| Variable | Description | Type |
| --- | --- | --- |
| type | The type of the grid. 1 = Rectangles, 2 = Horizontal hexes, 3 = Vertical hexes. | *int* |
| show_lines | Visibility of the grid lines. | *bool* |
| color | Color of the grid lines. | *color* |
| opacity | Opacity of the grid lines. | *float* |
| thick_lines | Thickness of the grid lines. false = Thin, true = Thick. | *bool* |
| snapping | Method of snapping objects to the grid. 1 = Off, 2 = Lines, 3 = Center, 4 = Both. | *int* |
| offsetX | X offset of the grid origin. | *float* |
| offsetY | Y offset of the grid origin. | *float* |
| sizeX | Width of the grid cells. | *float* |
| sizeY | Height of the grid cells. | *float* |
