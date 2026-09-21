--SORTING BAG
function filterObjectEnter(obj)
    local returnBag = getObjectFromGUID(obj.getGMNotes())
    if returnBag then
        if obj.getQuantity() > 1 then
            while(obj.getQuantity() > 1) do
                returnBag.putObject(obj.takeObject({}))
            end
        else
            returnBag.putObject(obj)
        end
        return false
    else
        return true
    end
end