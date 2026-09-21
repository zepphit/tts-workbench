-- set to a color to have the tray return a static color, otherwise it
-- will compute on based on the cards' back color
local trayStaticColor = nil

-- this function is used to detect if a game object is a card or deck
function isCard(o)
   if not o then
      return false
   end
   return o.type == "Card"
end

function isDeck(o)
   if not o then
      return false
   end
   return o.type == "Deck"
end

local trayCount = 0

function onLoad(saved_data)

   if saved_data and saved_data ~= "" then
      local loaded_data = JSON.decode(saved_data)
      for k, guid in ipairs(loaded_data) do
         local obj = getObjectFromGUID(guid)
         if obj ~= nil then
            obj.addContextMenuItem(
               "Fan Deck",
               function (player)
                  explodeStack(
                     {
                        player=Player[player],
                        triggerObj=obj
                     }
                  )
               end
            )
         end
      end
   end

   addHotkey("fan deck", function (player, obj)
                if (obj ~= nil) and (isDeck(obj) or isCard(obj)) then
                   explodeStack({player=Player[player], triggerObj=obj})
                end
   end)
   
end

function onObjectSpawn(obj)
   if isDeck(obj) or isCard(obj) then
      obj.addContextMenuItem("Fan Deck", function (player)
                                explodeStack({player=Player[player], triggerObj=obj})
      end)
   end
end

function onSave()
   local decks = {}
   for k, obj in ipairs(getAllObjects()) do
      if isDeck(obj) or isCard(obj) then
         table.insert(decks, obj.getGUID())
      end
   end
   saved_data = JSON.encode(decks)
   return saved_data
end

function getTrayCards(tray)
   local bounds = tray.getBounds()
   local objs = findRight(
      {
         pos = {
            (bounds.center.x-bounds.size.x/2),
            bounds.center.y+5,
            bounds.center.z
         },
         size = {
            0.1,
            10,
            bounds.size.z,
         },
         distance = bounds.size.x
      }
   )
   
   table.sort(
      objs,
      function(a, b)
         local posA = a.getBounds().center
         local posB = b.getBounds().center
         if posA.x == posB.x or (math.abs(posA.x - posB.x) <= 0.1) then
            return posA.y < posB.y
         end
         return posA.x > posB.x
      end
   )

   return objs
end

function repack (player, value)
   local tray = getObjectFromGUID(value)
   if tray then
      local placeholder = getObjectFromGUID(tray.getVar("placeholder"))
      if placeholder then
         placeholder.destruct()
      end
      local btn = getObjectFromGUID(tray.getVar("btn"))
      if btn then
         btn.destruct()
      end

      local origin = tray.getTable("stackOrigin")

      local objs = getTrayCards(tray)

      -- Store card rotations and face-up/down states
      local cardData = {}
      for i, o in ipairs(objs) do
         if isCard(o) then
            table.insert(cardData, {
               card = o,
               rotation = o.getRotation(),
               isFaceDown = o.is_face_down
            })
         end
      end

      if #cardData > 0 then
         -- Position for the new deck
         local pos = {
            x = origin.x,
            y = origin.y + 1,
            z = origin.z,
         }
         
         -- Move cards back to original position while preserving rotation
         for i, data in ipairs(cardData) do
            local cardPos = {
               x = pos.x,
               y = pos.y + ((i-1) * 0.2),
               z = pos.z
            }
            data.card.setPositionSmooth(cardPos, false, true)
            data.card.setRotationSmooth(data.rotation, false, true)
         end
      end
      
      tray.destruct()
      trayCount = trayCount - 1
   end
end

function spawnRepackButton(tray)

   local trayBounds = tray.getBounds()

   local pos = tray.positionToWorld(Vector(0, 0, 0))
   
   local btn = spawnObject({
         type              = "BlockSquare",
         position          = pos - Vector(0, 0, trayBounds.size.z/4),
         rotation          = {0, 0, 0},
         scale             = {1, 0.1, 1},
         callback_function = function (o)
            o.setLock(true)
            o.setColorTint({0, 0, 0, 0})
            o.interactable = false
            tray.setVar("btn", o.getGUID())
            local trayNumber = tray.getVar("number")
            o.UI.setXmlTable({
                  {
                     tag = "Panel",
                     attributes = {
                        id = tray.getGUID() .. "-panel",
                        width = "200.0",
                        height = 125,
                        position = "0 -90 -100",
                        allowDragging = true,
                        rectAlignment = "MiddleCenter",
                        onEndDrag = "d34970/move(".. tray.getGUID() .. ")"
                     },
                     children = {
                        {
                           tag = "VerticalLayout",
                           children = {
                              {
                                 tag = "Text",
                                 attributes = {
                                    color="#dcdccc",
                                    resizeTextForBestFit = true,
                                 },
                                 value = "#" .. tostring(trayNumber)
                              },
                              {
                                 tag = "Button",
                                 attributes = {
                                    color="#1c1c1c",
                                    textColor="#dcdccc",
                                    resizeTextForBestFit = true,
                                    onClick= "d34970/repack(".. tray.getGUID() .. ")"
                                 },
                                 value = "Repack"
                              },
                              {
                                 tag = "Button",
                                 attributes = {
                                    color="#1c1c1c",
                                    textColor="#dcdccc",
                                    resizeTextForBestFit = true,
                                    onClick = "d34970/move(".. tray.getGUID() .. ")"
                                 },
                                 value = "Drag to Move"
                              }
                        }}

                     }

            }})
         end
   })

   return btn
end


function move(player, value, panelID)
   local tray = getObjectFromGUID(value)

   if tray == nil then
      return
   end

   local btn = getObjectFromGUID(tray.getVar("btn"))
   if btn == nil then
      return
   end

   local cursorPos = player.getPointerPosition()
   local curPos = tray.getPosition()
   local trayBounds = tray.getBounds()

   local objs = getTrayCards(tray)

   local trayScale = getTrayScale(objs)

   tray.setScale(trayScale)

   
   local trayPos = Vector(cursorPos.x, curPos.y, cursorPos.z+1)
   local trayScale = tray.getScale().x

   local testTrayCollision = function ()

      local objList = Physics.cast({
            origin=trayPos - Vector(trayBounds.size.x/2, 0, 0), direction={1, 0, 0}, type=3,
            size={0.1, 0.15, trayBounds.size.z + 1.25}, max_distance=trayBounds.size.x,
            debug=false
      })
      if #objList > 0 then
         local needsMove = false
         for i, hit in ipairs(objList) do
            if not isCard(hit.hit_object) then
               local hitGUID = hit.hit_object.getGUID()
               if hitGUID ~= tray.getGUID() and hitGUID ~= btn.getGUID() then
                  needsMove = true
               end
            end
         end
         if needsMove then
            trayPos:setAt('z', trayPos.z + 0.5)
            return false
         end
         return true
      end
      return true
   end

   local moveTray = function (pos)
      
      tray.setPosition(pos, false, true)

      btn.setPosition(pos - Vector(0, 0, trayBounds.size.z/4), false, true)

      layoutCards(reverseTable(objs), tray, {
                        x = pos.x,
                        y = pos.y,
                        z = pos.z,
      })

   end

   Wait.condition(
      function ()
         moveTray(trayPos)
      end,
      function ()
         return testTrayCollision(tray.getGUID(), trayPos, trayBounds.size)
      end
   )
   
end

function reverseTable ( tab )
   local size = #tab
   local newTable = {}

   for i,v in ipairs ( tab ) do
      newTable[size-(i-1)] = v
   end

   return newTable
end

function getTrayScale(objs)
   local objWidth = 0
   local objHeight = 0
   for i, o in ipairs(objs) do
      local oSize = o.getBounds().size
      objWidth = objWidth + oSize.x
      if oSize.z > objHeight then
         objHeight = oSize.z
      end
   end

   return Vector(objWidth + (0.25*(#objs+1)), 0.1, objHeight * 1.5)
end

function explodeStack(params)
   local player = params.player
   local triggerObj = params.triggerObj
   
   if (not isDeck(triggerObj) and not isCard(triggerObj)) or triggerObj.getVar("exploded") then
      return
   end

   local bounds = triggerObj.getBounds()
   local objs = {}

   -- If it's a deck, take all cards out
   if isDeck(triggerObj) then
      local deckPos = triggerObj.getPosition()
      local cardObjs = triggerObj.getObjects()
      
      -- Take cards from deck one by one
      for i = 1, #cardObjs do
         local card = triggerObj.takeObject({
            position = {deckPos.x, deckPos.y + (i * 0.2), deckPos.z},
            flip = false
         })
         table.insert(objs, card)
      end
   else
      -- Single card
      table.insert(objs, triggerObj)
   end

   if #objs < 1 then
      return
   end

   Wait.frames(function()
      
      local trayScale = getTrayScale(objs)

      local trayPos = Vector(bounds.center.x+0.5+ (trayScale.x/2), bounds.center.y + 3, bounds.center.z)

      local testCollision = function ()
         local objList = Physics.cast({
               origin=trayPos, direction={1, 0, 0}, type=3,
               size={trayScale.x, 0.15, trayScale.z+1.25}, max_distance = 0.01,
               debug=false
         })
         if #objList > 0 then
            trayPos:setAt('z', trayPos.z + 0.5)
            return false
         end
         return true
      end

      local spawnTray = function()

         trayCount = trayCount + 1
         local trayNumber = trayCount
         
         local tray = spawnObject({
               type              = "BlockSquare",
               position          = trayPos,
               rotation          = {0, 0, 0},
               scale             = trayScale,
               callback_function = function (o)
                  o.setLock(true)
                  o.setColorTint({0, 0, 0, 0})
                  o.setTable("stackOrigin", bounds.center)
                  o.setTable("stackObjs", objs)
                  o.setVar("number", trayNumber)
                  o.interactable = false
                  local tray = o

                  spawnRepackButton(o)

                  local trayColor = layoutCards(objs, tray, trayPos)

                  tray.setColorTint(trayColor)

                  local placeholderY = bounds.center.y
                  local placeholderPos = Vector(bounds.center.x, placeholderY, bounds.center.z)
                  
                  spawnPlaceholder(tray, placeholderPos)

               end,
               sound             = false,
               snap_to_grid      = false,
         })

      end

      Wait.condition(spawnTray, testCollision)
      
   end, 10)

end

function layoutCards(objs, tray, trayPos)
   local traySnaps = {}

   local traySize = tray.getBounds().size
   local posX = (trayPos.x-(traySize.x/2))+0.25

   local colorTotals = {r = 0, g = 0, b = 0}
   local cardCount = 0
   
   for i, o in ipairs(objs) do
      if isCard(o) then
         -- Flip card face up
         if o.is_face_down then
            o.flip()
         end
         
         local oSize = o.getBounds().size
         posX = posX + (oSize.x/2)
         local pos = {
            x = posX,
            y = trayPos.y + 0.5,
            z = trayPos.z,
         }
         cardCount = cardCount + 1
         
         -- Get color from card back
         local cColor = Color(0.5, 0.5, 0.5) -- Default gray
         colorTotals.r = colorTotals.r + cColor.r
         colorTotals.g = colorTotals.g + cColor.g
         colorTotals.b = colorTotals.b + cColor.b
         
         table.insert(traySnaps, {position=tray.positionToLocal({pos.x, trayPos.y, pos.z})})
         o.setPositionSmooth(pos, false, true)
         o.use_snap_points = true
         o.use_grid = true
         o.removeFromPlayerSelection(table.concat(o.getSelectingPlayers(), "|"))
         
         posX = posX + (oSize.x/2) + 0.25
      end
   end

   tray.setSnapPoints(traySnaps)

   if trayStaticColor ~= nil then
      return trayStaticColor
   end
   
   local tint = Color(colorTotals.r/cardCount, colorTotals.g/cardCount, colorTotals.b/cardCount, 0.75)
   local threshold = 0.5
   local reduction = 0.25
   while tint.r > threshold or tint.g > threshold or tint.b > threshold do
      tint:setAt('r', tint.r * (1-reduction))
      tint:setAt('g', tint.g * (1-reduction))
      tint:setAt('b', tint.b * (1-reduction))
   end
   
   return tint
end

function spawnPlaceholder(tray, pos)
   local placeholderRot = Vector(0, 0, 0)
   if Grid.type == 3 then
      placeholderRot:setAt("y", 90)
   end
   local placeholderMesh = "https://steamusercontent-a.akamaihd.net/ugc/1188335830309261147/116300B0EF693BCDCCC7B85E688FBCCDD420AF5A/"
   local placeholder = spawnObject({
         type              = "Custom_Model",
         position          = pos,
         rotation          = placeholderRot,
         scale             = {0.3, 0.3, 0.3},
         callback_function = function (o)
            o.setLock(true)
            o.setColorTint(tray.getColorTint())
            tray.setVar("placeholder", o.getGUID())
            o.interactable = false
            local trayNumber = tray.getVar("number")
            o.UI.setXmlTable({
                  {
                     tag = "Panel",
                     attributes = {
                        width = "200",
                        padding = 7,
                        height = 200,
                        position = "0 0 -20",
                     },
                     children = {
                        {
                           tag = "VerticalLayout",
                           children = {
                              {
                                 tag = "Text",
                                 attributes = {
                                    color="#dcdccc",
                                    fontSize="100",
                                    fontStyle="Bold",
                                 },
                                 value = "#" .. tostring(trayNumber)
                              }
                        }}
                     }

            }})
         end,
         sound = false,
         snap_to_grid = false,
   })

   placeholder.setCustomObject({
         mesh = placeholderMesh,
         type = 1,
         material = 3,
   })
end

function findRight(params)
   local pos = params.pos
   local size = params.size
   local distance = params.distance
   local objList = Physics.cast({
         origin=pos, direction={1,0,0}, type=3,
         size=size, max_distance=distance,
         debug=false
   })

   local refinedList = {}
   for _, obj in ipairs(objList) do
      if isCard(obj.hit_object) then
         table.insert(refinedList, obj.hit_object)
      end
   end

   return refinedList
end