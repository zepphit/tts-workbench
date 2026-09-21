diceNum= 0
math.randomseed(os.time())

math.random(1,6)
math.random(1,6)
math.random(1,6)

function onload()
    self.createButton(
        {click_function='rolldice',
        function_owner=self,
        tooltip='Roll 1d6',
        label='Roll\n1d6\n\n(1-6)',
        position={0.25,1.14,0}, -- {1,1.44,-0}
        rotation={0,90,-21.8}, -- {0,90,-21.8}
        width=1600,
        height=1800,
        font_size=400}
                      )
end

function rolldice(objButton, playerColor)

    local diceNum= math.random(1,6)

    local playerName =  "Player"

    if playerColor == nil then
        playerColor= "White"
    end

--    if Player[playerColor].steam_name ~= nil then
--        playerName = Player[rollingPlayerColor].steam_name
--    end

    	broadcastToAll('1d6 roll = ' .. diceNum, playerColor)

end