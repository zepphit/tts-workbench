function onObjectLeaveContainer(bag, obj)
    if bag~=self then return end
    obj.setRotation({0,math.random(0,5)*60,0})
end