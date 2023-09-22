# Draws a paragon board using text
#
# Command Syntax:
#
#   draw_board.coffee [--file <path>] <class> <board>
#
# Class:
#   one of: barbarian, b, druid, d, necromancer, n, rogue, r, sorcerer, sorceress, s
#
# Board:
#   the name of a board to draw
#
# Options:
#   --file <path> is the path to the JSON file containing the board data (default: data/paragonBoards.json)

fs = require 'fs'
yargs = require 'yargs'

args = yargs
	.usage '$0 [--file <path>] <class> <board>', 'Draw a paragon board using text', (yargs) ->
    yargs
      .positional 'class', {
         type: 'string'
         choices: ['barbarian', 'b', 'druid', 'd', 'necromancer', 'n', 'rogue', 'r', 'sorcerer', 'sorceress', 's']
         describe: 'Class name'
      }
      .positional 'board', {
         type: 'string'
         describe: 'Board name'
      }
  .help()
  .version()
  .option 'file', {
    type: 'string'
    default: 'data/paragonBoards.json'
    alias: 'f'
    describe: 'Path to board data'
  }
  .argv

findNode = (element, nodes) ->
  for node in nodes
    if node.name == element
      return node
  throw Error("Could not find node \"#{element}\"")
  
rareOrLegendarySymbol = (element, nodes) ->
  return '?' if not nodes?

  node = findNode(element, nodes)
  symbol = switch
    when node.type == 'Rare' then 'R'
    when node.type == 'Legendary' then 'L'
    else throw Error("Unknown rarity: \"#{node.type}\"")
  return symbol

drawBoard = (tiles, nodes) ->
  height = tiles.length
  width = tiles[0].length
  process.stdout.write '+' + '-'.repeat(2 * width) + '-+\n'

  for row in tiles
    line = '|'
    for element in row
      symbol = switch
        when element == 'empty' then ' '
        when element.indexOf('Gate Node') != -1 then 'G'
        when element.indexOf('Magic Node') != -1 then 'M'
        when element.indexOf('Dexterity') != -1 then 'd'
        when element.indexOf('Intelligence') != -1 then 'i'
        when element.indexOf('Strength') != -1 then 's'
        when element.indexOf('Willpower') != -1 then 'w'
        when element.indexOf('Glyph Socket') != -1 then 'O'
        when element.indexOf('Starting Paragon Node') != -1 then 'X'
        else rareOrLegendarySymbol(element, nodes)
      line += ' '
      line += symbol
    line += ' |\n'
    process.stdout.write line

  process.stdout.write '+' + '-'.repeat(2 * width) + '-+\n'

# Load the board data
boardsJson = fs.readFileSync(args.file)
boardsByClass = JSON.parse(boardsJson)

# Get the standardized class name from the class argument
className = switch
  when args['class'] == 'b' or args['class'] == 'barbarian' then 'barbarian'
  when args['class'] == 'd' or args['class'] == 'druid' then 'druid'
  when args['class'] == 'n' or args['class'] == 'necromancer' then 'necromancer'
  when args['class'] == 'r' or args['class'] == 'rogue' then 'rogue'
  when args['class'] == 's' or args['class'] == 'sorcerer' or args['class'] == 'sorceress' then 'sorcerer'
  else null
throw Error("Invalid class name: \"#{args['class']}\"") if className == null

# Make sure the database has the class and board we want
if not boardsByClass[className]?
  console.error "The file \"#{args.file}\" contains no #{className} paragon data. It only contains data for the following classes:",
                (k for k, v of boardsByClass)
  process.exit(1)
else if not boardsByClass[className].boards?
  console.error "The file \"#{args.file}\" contains no #{className} boards. It only contains boards for the following classes:",
                (k for k, v of boardsByClass when v.boards?)
  process.exit(1)

desiredBoardName = args.board.toLowerCase()

# Find the board we want
{ nodes, boards } = boardsByClass[className]

for k, v of boards
  if desiredBoardName == k.toLowerCase()
    boardName = k
    tiles = v
    break

if not boardName?
  console.error "The file \"#{args.file}\" does not contain a #{className} board named \"#{args.board}\". ",
                "It contains the following #{className} boards:", (k for k, v of boards)
  process.exit(2)

# Draw the board
drawBoard(tiles, nodes)
