# Process paragon board data scraped from https://diablo4.wiki.fextralife.com/Paragon+Boards
# and converted from XML to JSON using https://jsonformatter.org/xml-to-json

fs = require "fs"

boardFileNamesByClass = {
    necromancer: [
      "data/boardNecromancerBasic.json"
      "data/boardNecromancerBloodbath.json"
      "data/boardNecromancerBloodBegetsBlood.json"
      "data/boardNecromancerBoneGraft.json"
      "data/boardNecromancerCultLeader.json"
      "data/boardNecromancerFleshEater.json"
      "data/boardNecromancerHulkingMonstrosity.json"
      "data/boardNecromancerScentOfDeath.json"
      "data/boardNecromancerWither.json"
    ]
  }

nodeFileNamesByClass = {
  barbarian:   "data/barbarian_nodes.json"
  necromancer: "data/necromancer_nodes.json"
}

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

# Loads boards
loadBoards = (fileNamesByClass) ->
  boardsByClass = {}

  # Load boards for each class
  for className, fileNames of fileNamesByClass
    boards = {}

    # Load each board
    for f in fileNames
      try
        input = fs.readFileSync(f)
      catch e
        console.error e
        process.exit(1)

      rawDb = JSON.parse(input)

      # Extract tile types and build a board with a name and array of tiles
      boardName = rawDb.name
      tiles = []

      # For each row extract each tile
      for rawRow in rawDb.table.tbody.tr
        row = []
        for rawTile in rawRow.td
          if rawTile.img?
            tile = "empty"
          else if rawTile.span.a?
            tile = rawTile.span.a._title
          else
            throw Error("Unknown tile type in " + file + ": " + JSON.stringify(rawTile, null, 2))
          row.push tile
        tiles.push row

      boards[boardName] = tiles
    boardsByClass[className] = boards
  return boardsByClass

# Loads node data for each class
loadNodeInfo = (fileNamesByClass) ->
  nodeInfoByClass = {}

  # Load node data for each class
  for className, fileName of fileNamesByClass
    try
      input = fs.readFileSync(fileName)
    catch e
      console.error e
      process.exit(1)

    rawNodeDb = JSON.parse(input)
    nodes = []

    # Extract the info for a node type from each row
    for rawRow in rawNodeDb.table.tbody.tr
      # Extract the node name
      if not rawRow.td[0]? or not rawRow.td[0].h5? or not rawRow.td[0].h5.a? or not rawRow.td[0].h5.a.__text?
        throw Error("Missing node name in " + JSON.stringify(rawRow, null, 2))
      nodeName = rawRow.td[0].h5.a._title

      # Extract the rarity
      if not rawRow.td[1]? or not rawRow.td[1].span? or not rawRow.td[1].span.__text?
        throw Error("Missing node type in " + JSON.stringify(rawRow, null, 2))
      nodeType = rawRow.td[1].span.__text

      # Extract the boards that it is on
      if not rawRow.td[2]? or (not rawRow.td[2].__text? and (not rawRow.td[2].ul? or not rawRow.td[2].ul.li?))
        throw Error("Missing board names in " + JSON.stringify(rawRow, null, 2))
      if rawRow.td[2].__text?
        nodeBoards = rawRow.td[2].__text
      else
        nodeBoards = if typeIsArray(rawRow.td[2].ul.li) then rawRow.td[2].ul.li else [ rawRow.td[2].ul.li ]

      # Extract the description
      nodeDescription = rawRow.td[3]

      # Extract the bonus
      nodeBonus = if rawRow.td[4].__text? then rawRow.td[4].__text else rawRow.td[4]

      nodes.push
        name: nodeName
        type: nodeType
        boards: nodeBoards
        description: nodeDescription
        bonus: nodeBonus

    nodeInfoByClass[className] = nodes
  return nodeInfoByClass


# Load boards
boardsByClass = loadBoards(boardFileNamesByClass)

# Load node data
nodesByClass = loadNodeInfo(nodeFileNamesByClass)

# Combine all the data
paragonBoardDataByClass = {}
for className, boards of boardsByClass
  paragonBoardDataByClass[className] = {} if not paragonBoardDataByClass[className]?
  paragonBoardDataByClass[className].boards = boards
for className, nodes of nodesByClass
  paragonBoardDataByClass[className] = {} if not paragonBoardDataByClass[className]?
  paragonBoardDataByClass[className].nodes = nodes

console.info "Successfully processed paragon board data"

# Write the data to a file
console.info "Writing paragon board data to data/paragonBoards.json"
try
  fs.writeFileSync 'data/paragonBoards.json', JSON.stringify(paragonBoardDataByClass)
catch e
  console.error e
  process.exit(1)
  