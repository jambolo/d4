# d4
Diablo 4 analysis tools

## process_paragon_board_data
Reads raw xml paragon board data and outputs a JSON file containing useful data about the boards.

#### Command syntax

	combine_board_data

## draw_paragon_board
Draws a paragon board using text

#### Command Syntax:

    draw_board.coffee [--file <path>] <class> <board>

#### Class
One of barbarian, b, druid, d, necromancer, n, rogue, r, sorcerer, sorceress, s

#### Board
Name (case insensitive) of the board to draw

#### Options

| Option         | Description |
|----------------|-------------|
| --file <path>  | the path to the JSON file containing the board data (default: data/paragonBoards.json) |
