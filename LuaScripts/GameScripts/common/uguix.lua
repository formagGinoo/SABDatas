local ugui = {}

function ugui.AddClickListenerWithParams(button, callback, prm1, prm2, prm3, prm4)
  local function onclick()
    callback(button, prm1, prm2, prm3, prm4)
  end
  
  if button then
    button.onClick:RemoveAllListeners()
    button.onClick:AddListener(onclick)
  end
end

function ugui.AddClickListener(button, callback, param)
  local function onclick()
    callback(button, param)
  end
  
  if button then
    button.onClick:RemoveAllListeners()
    button.onClick:AddListener(onclick)
  end
end

function ugui.AddToggleValueChangeCallback(toggle, cb, param)
  local function toggleCallback(isOn)
    cb(toggle, isOn, param)
  end
  
  if toggle then
    toggle.onValueChanged:RemoveAllListeners()
    toggle.onValueChanged:AddListener(toggleCallback)
  end
end

return ugui
