--CHILD BAG
function onObjectLeaveContainer(bag, obj)
    if bag~=self then return end
    if not (string.find(obj.getGMNotes(), "Private")) then
        obj.setGMNotes(self.getGUID())
    end
    setDisplay()
end

function onLoad()
    setDisplay()
end

function onObjectEnterContainer(bag, obj)
    if bag~=self then return end
    setDisplay()
end

function setDisplay()
    if self.getButtons() == nil then
        self.createButton({
            click_function = "asdfasdfq",
            label          = self.getQuantity(),
            position       = {-0.8, 2.125, -2},
            rotation       = {0, 180, 0},
            width          = 0,
            height         = 0,
            font_size      = 1000,
            color          = {0.5, 0.5, 0.5},
            font_color     = {1, 1, 1},
            tooltip        = "This text appears on mouseover.",
        })
    else
        self.editButton({index=0,label = self.getQuantity()})
    end
end