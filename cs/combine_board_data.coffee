fs = require "fs"

boardFileNamesByClass = [
  {
    name: "necromancer"
    files: [
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
]

boardsByClass = {}

for c in boardFileNamesByClass
  classBoards = []

  for file in c.files
    try
      input = fs.readFileSync(file)
    catch e
      console.error e
      process.exit()

    rawDb = JSON.parse(input)

    # Extract tile types and build a board with a name and array of tiles
    name = rawDb.name
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
          throw "Unknown tile type in " + file + ": " + JSON.stringify(rawTile)
        row.push tile
      tiles.push row

    classBoards.push
      name: name
      tiles: tiles

  boardsByClass[c.name] = classBoards

try
  fs.writeFileSync 'data/paragonBoards.json', JSON.stringify(boardsByClass)
catch e
  console.error e
