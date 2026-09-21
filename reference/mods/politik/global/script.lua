function onLoad()
    -- Create UI buttons that are always visible on screen
    Global.UI.setXml([[
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -300">
            <Button id="firstActionButton"
                    onClick="onFirstActionClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#D9D9C1"
                    width="85"
                    height="42">
                Conclude
1st Action
            </Button>
        </Panel>
        
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -350">
            <Button id="secondActionButton"
                    onClick="onSecondActionClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#D9D9C1"
                    width="85"
                    height="42">
                Conclude
2nd Action
            </Button>
        </Panel>
        
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -400">
            <Button id="thirdActionButton"
                    onClick="onThirdActionClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#989898"
                    width="85"
                    height="42">
                Conclude
3rd Action
            </Button>
        </Panel>
        
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -450">
            <Button id="powerGrabButton"
                    onClick="onPowerGrabClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#D9D9C1"
                    width="85"
                    height="45">
                Check 
Power Grab
            </Button>
        </Panel>
    ]])
end

function onFirstActionClick(player, value, id)
    local clickingPlayer = Player[player.color]
    
    if clickingPlayer then
        local playerName = clickingPlayer.steam_name
        local colorString = player.color
        local message = playerName .. " concludes 1st action"
        
        broadcastToAll(message, stringColorToRGB(colorString))
        Global.UI.setAttribute("firstActionButton", "color", "#808080")
    end
end

function onSecondActionClick(player, value, id)
    local clickingPlayer = Player[player.color]
    
    if clickingPlayer then
        local playerName = clickingPlayer.steam_name
        local colorString = player.color
        local message = playerName .. " concludes 2nd action"
        
        broadcastToAll(message, stringColorToRGB(colorString))
        Global.UI.setAttribute("secondActionButton", "color", "#808080")
    end
end

function onThirdActionClick(player, value, id)
    local clickingPlayer = Player[player.color]
    
    if clickingPlayer then
        local playerName = clickingPlayer.steam_name
        local colorString = player.color
        local message = playerName .. " concludes 3rd action"
        
        broadcastToAll(message, stringColorToRGB(colorString))
        Global.UI.setAttribute("thirdActionButton", "color", "#808080")
    end
end

function onPowerGrabClick(player, value, id)
    local clickingPlayer = Player[player.color]
    
    if clickingPlayer then
        local playerName = clickingPlayer.steam_name
        local colorString = player.color
        local message = playerName .. " concludes Power Grab"
        
        broadcastToAll(message, stringColorToRGB(colorString))
        
        -- Reset the action buttons back to original colors
        Wait.frames(function()
            Global.UI.setAttribute("firstActionButton", "color", "#222222")
            Global.UI.setAttribute("firstActionButton", "textColor", "#D9D9C1")
            Global.UI.setAttribute("secondActionButton", "color", "#222222")
            Global.UI.setAttribute("secondActionButton", "textColor", "#D9D9C1")
            Global.UI.setAttribute("thirdActionButton", "color", "#222222")
            Global.UI.setAttribute("thirdActionButton", "textColor", "#989898")
        end, 1)
    end
end

-- Camera button click functions
function onCameraBoardClick(player)
    Player[player.color].lookAt({position = {0.00, -3, 2.50}, pitch = 90, yaw = 0, distance = 25})
end

function onCameraBrownClick(player)
    Player[player.color].lookAt({position = {32.00, -3, 28.00}, pitch = 90, yaw = 0, distance = 25})
end

function onCameraYellowClick(player)
    Player[player.color].lookAt({position = {-32.00, -3, 3.00}, pitch = 90, yaw = 0, distance = 25})
end

function onCameraBlueClick(player)
    Player[player.color].lookAt({position = {32.00, -3, 3.00}, pitch = 90, yaw = 0, distance = 25})
end

function onCameraGreenClick(player)
    Player[player.color].lookAt({position = {-32.00, -3, -22.00}, pitch = 90, yaw = 0, distance = 25})
end

function onCameraRedClick(player)
    Player[player.color].lookAt({position = {0, -3, -22.00}, pitch = 90, yaw = 0, distance = 25})
end

function onCameraPurpleClick(player)
    Player[player.color].lookAt({position = {32.00, -3, -22.00}, pitch = 90, yaw = 0, distance = 25})
end

-- Function to create camera buttons based on seated players
function createCameraButtons()
    local seatedPlayers = getSeatedPlayers()
    local seatedColors = {}
    
    -- Create a lookup table for seated colors
    for _, color in ipairs(seatedPlayers) do
        seatedColors[color] = true
    end
    
    -- Camera button configurations
    local cameraButtons = {
        {name = "Board", color = "#FFFFFF", yOffset = -200, onClick = "onCameraBoardClick", alwaysShow = true},
        {name = "Brown", color = "#834A25", yOffset = 100, onClick = "onCameraBrownClick", playerColor = "Brown"},
        {name = "Yellow", color = "#E7E52C", yOffset = 50, onClick = "onCameraYellowClick", playerColor = "Yellow"},
        {name = "Blue", color = "#1E87FFF", yOffset = 0, onClick = "onCameraBlueClick", playerColor = "Blue"},
        {name = "Green", color = "#00FF00", yOffset = -50, onClick = "onCameraGreenClick", playerColor = "Green"},
        {name = "Red", color = "#FF0000", yOffset = -100, onClick = "onCameraRedClick", playerColor = "Red"},
        {name = "Purple", color = "#A041DC", yOffset = -150, onClick = "onCameraPurpleClick", playerColor = "Purple"}
    }
    
    local xmlString = ""
    
    for _, btn in ipairs(cameraButtons) do
        -- Show button if it's always shown OR if that player color is seated
        if btn.alwaysShow or seatedColors[btn.playerColor] then
            xmlString = xmlString .. [[
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 ]] .. btn.yOffset .. [[">
            <Button id="camera]] .. btn.name .. [[Button"
                    onClick="]] .. btn.onClick .. [["
                    fontSize="12"
                    color="#222222"
                    textColor="]] .. btn.color .. [["
                    width="85"
                    height="42">
                ]] .. btn.name .. [[
            </Button>
        </Panel>
]]
        end
    end
    
    -- Add existing action buttons
    xmlString = xmlString .. [[
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -300">
            <Button id="firstActionButton"
                    onClick="onFirstActionClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#D9D9C1"
                    width="85"
                    height="42">
                Conclude
1st Action
            </Button>
        </Panel>
        
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -350">
            <Button id="secondActionButton"
                    onClick="onSecondActionClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#D9D9C1"
                    width="85"
                    height="42">
                Conclude
2nd Action
            </Button>
        </Panel>
        
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -400">
            <Button id="thirdActionButton"
                    onClick="onThirdActionClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#989898"
                    width="85"
                    height="42">
                Conclude
3rd Action
            </Button>
        </Panel>
        
        <Panel position="0 0 -50" 
               rotation="0 0 0" 
               width="200" 
               height="115"
               offsetXY="885 -450">
            <Button id="powerGrabButton"
                    onClick="onPowerGrabClick"
                    fontSize="12"
                    color="#222222"
                    textColor="#D9D9C1"
                    width="85"
                    height="45">
                Check 
Power Grab
            </Button>
        </Panel>
]]
    
    Global.UI.setXml(xmlString)
end