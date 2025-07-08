local M = {}

function M.setText(luaBehaviour, key, text_msg)
  local text = luaBehaviour:FindText(key)
  if text and text_msg then
    text.text = text_msg
  end
  return text
end

function M.setTextMeshPro(luaBehaviour, key, text_msg)
  local text = luaBehaviour:FindTextMeshProUGUI(key)
  if text and text_msg then
    text.text = text_msg
  end
  return text
end

function M.FindTextMeshProUGUI(luaBehaviour, key)
  local tmppro = luaBehaviour:FindTextMeshProUGUI(key)
  return tmppro
end

function M.setImg(luaBehaviour, key, img_name, img_atlas)
  local img = luaBehaviour:FindImage(key)
  if img then
    CS.UI.UILuaHelper.SetAtlasSprite(img, img_name, nil, nil, true)
  end
  return img
end

function M.setImgFillAmount(luaBehaviour, key, num)
  local img = luaBehaviour:FindImage(key)
  if img then
    img.fillAmount = num
  end
  return img
end

function M.findGameObject(luaBehaviour, key)
  local obj = luaBehaviour:FindGameObject(key)
  return obj
end

function M.findImg(luaBehaviour, key)
  local img = luaBehaviour:FindImage(key)
  return img
end

function M.setObjectVisible(luaBehaviour, key, visible)
  local obj = luaBehaviour:FindGameObject(key)
  if obj then
    obj:SetActive(visible)
  end
  return obj
end

function M.addAnimEvent(luaBehaviour, event)
  luaBehaviour:AddAnimEvent(event)
end

function M.setAnimSpeed(luaBehaviour, animName, speed)
  luaBehaviour:setAnimSpeed(animName, speed)
end

function M.setTextColor(luaBehaviour, key, color)
  local text = luaBehaviour:FindText(key)
  if text then
    text.color = color
  end
  return text
end

function M.setTextMeshProColor(luaBehaviour, key, color)
  local text = luaBehaviour:FindTextMeshProUGUI(key)
  if text then
    text.color = color
  end
  return text
end

function M.setSliderValue(luaBehaviour, key, value)
  local slider = luaBehaviour:FindSlider(key)
  if slider then
    slider.value = value or 0
  end
  return slider
end

function M.runAnim(luaBehaviour, anim_name, end_call_func)
  if luaBehaviour then
    luaBehaviour:RunAnim(anim_name, end_call_func, 1)
  end
end

function M.setImgAlpha(luaBehaviour, key, alpha)
  local img = luaBehaviour:FindImage(key)
  if img then
    local star_color = img.color
    star_color.a = alpha or 0
    img.color = star_color
  end
  return img
end

return M
