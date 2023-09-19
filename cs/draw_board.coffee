# Draws a paragon board using text
#

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

console.log 'args = ', JSON.stringify(args)

rareOrLegendarySymbol = (element) ->
  return '.'

# Load the board data

boardsJson = fs.readFileSync(args.file)
boardsByClass = JSON.parse(boardsJson)
console.log 'boardsByClass = ', boardsByClass

className = switch
  when args['class'] == 'b' or args['class'] == 'barbarian' then 'barbarian'
  when args['class'] == 'd' or args['class'] == 'druid' then 'druid'
  when args['class'] == 'n' or args['class'] == 'necromancer' then 'necromancer'
  when args['class'] == 'r' or args['class'] == 'rogue' then 'rogue'
  when args['class'] == 's' or args['class'] == 'sorcerer' or args['class'] == 'sorceress' then 'sorcerer'
  else null

throw "Invalid class name: " + args['class'] if className == null

console.log 'className = ', className

if not boardsByClass[className]?
  console.error "The file contains no #{className} paragon boards. It only contains boards for the following classes:",
                (k for k,v of boardsByClass)
  process.exit(1)

boards = boardsByClass[className]
desiredBoardName = args.board.toLowerCase()

for b in boards
  if desiredBoardName == b.name.toLowerCase()
    boardName = b.name
    tiles = b.tiles
    break

if not boardName?
  console.error "The file does not contain a #{className} board named \"#{args.board}\". It contains the following #{className} boards:",
                (b.name for b in boards)
  process.exit(2)

console.log "boardName = ", boardName

# Draw the board
height = tiles.length
width = tiles[0].length
console.log "width = #{width}, height = #{height}"

process.stdout.write '+' + '-'.repeat(2*width) + '-+\n'

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
      else rareOrLegendarySymbol(element)
    line += ' '
    line += symbol
  line += ' |\n'
  process.stdout.write line

process.stdout.write '+' + '-'.repeat(2*width) + '-+\n'

console.log "done"
