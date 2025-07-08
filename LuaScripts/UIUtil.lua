local M = {}
local LuaBehaviour = CS.UI.LuaBehaviour
local VerticalLayoutGroup = CS.UnityEngine.UI.VerticalLayoutGroup

function M.getChild(trans, index)
  return trans:GetChild(index)
end

function M.findComponent(trans, ctype, path)
  assert(trans ~= nil)
  assert(ctype ~= nil)
  local targetTrans = trans
  if path ~= nil and type(path) == "string" and 0 < #path then
    targetTrans = trans:Find(path)
  end
  if targetTrans == nil then
    return nil
  end
  local cmp = targetTrans:GetComponent(ctype)
  if cmp ~= nil then
    return cmp
  end
  return targetTrans:GetComponentInChildren(ctype)
end

function M.findTrans(trans, path)
  if path == nil then
    return trans
  end
  return trans:Find(path)
end

function M.findText(trans, path)
  return M.findComponent(trans, T_Text, path)
end

function M.findTextMeshPro(trans, path)
  return M.findComponent(trans, T_TextMeshProUGUI, path)
end

function M.findImage(trans, path)
  return M.findComponent(trans, T_Image, path)
end

function M.findButton(trans, path)
  return M.findComponent(trans, T_Button, path)
end

function M.findInput(trans, path)
  return M.findComponent(trans, T_InputField, path)
end

function M.findAnimation(trans, path)
  return M.findComponent(trans, T_Animation, path)
end

function M.findLuaBehaviour(trans, path)
  return M.findComponent(trans, typeof(LuaBehaviour), path)
end

function M.findSlider(trans, path, func)
  local slider = M.findComponent(trans, T_Slider, path)
  if func then
    slider.onValueChanged:RemoveAllListeners()
    slider.onValueChanged:AddListener(func)
  end
  return slider
end

function M.findToggle(trans, path)
  return M.findComponent(trans, T_Toggle, path)
end

function M.findScrollRect(trans, path)
  return M.findComponent(trans, T_ScrollRect, path)
end

function M.findRectTransform(trans, path)
  return M.findComponent(trans, T_RectTransform, path)
end

function M.findContentSizeFitter(trans, path)
  return M.findComponent(trans, T_ContentSizeFitter, path)
end

function M.findCamera(trans, path)
  return M.findComponent(trans, T_Camera, path)
end

function M.setLocalPosition(trans, x, y, z)
  local rtrans = M.findComponent(trans, T_RectTransform)
  local lpos = rtrans.localPosition
  if x then
    lpos.x = x
  end
  if y then
    lpos.y = y
  end
  if z then
    lpos.z = z
  end
  rtrans.localPosition = lpos
  return rtrans
end

function M.setLocalScale(trans, x, y, z)
  local rtrans = M.findComponent(trans, T_RectTransform)
  local lscale = rtrans.localScale
  if x then
    lscale.x = x
  end
  if y then
    lscale.y = y
  end
  if z then
    lscale.z = z
  end
  rtrans.localScale = lscale
  return rtrans
end

function M:setLocalDelta(trans, width, height)
  local rect = M.findComponent(trans, T_RectTransform)
  if rect then
    rect.sizeDelta = Vector2.New(width, height)
  end
end

function M.setButtonClick(trans, func, params, path, ui_name)
  local btn = M.findButton(trans, path)
  if btn then
    btn.onClick:RemoveAllListeners()
    if params then
      btn.onClick:AddListener(function()
        func(trans, params)
        ui_name = ui_name or ""
      end)
    else
      btn.onClick:AddListener(func)
    end
  end
  return btn
end

function M.setText(trans, text_msg, path)
  local text = M.findText(trans, path)
  if text and text_msg then
    text.text = text_msg
  end
  return text
end

function M.setTextMeshProText(trans, text_msg, path)
  local text = M.findTextMeshPro(trans, path)
  if text and text_msg then
    text.text = text_msg
  end
  return text
end

function M.setTextColor(trans, color, path)
  local text = M.findText(trans, path)
  if text then
    text.color = color
  end
  return text
end

function M.setTextMeshProColor(trans, color, path)
  local text = M.findTextMeshPro(trans, path)
  if text then
    text.color = color
  end
  return text
end

function M.setScale(trans, scale1, scale2)
  scale1 = scale1 or 1
  if scale2 then
    trans.localScale = Vector3.New(scale1, scale2, 1)
  else
    trans.localScale = Vector3.New(scale1, scale1, 1)
  end
end

function M.setObjectVisible(trans, visible, path)
  local obj = M.findTrans(trans, path)
  if obj then
    obj.gameObject:SetActive(visible)
  end
  return obj
end

function M.setOpacity(trans, opacity)
  local canvas_group = M.findComponent(trans, T_CanvasGroup)
  if canvas_group then
    canvas_group.alpha = opacity or 1
  end
end

function M:findGroup(trans)
  local canvas_group = M.findComponent(trans, T_CanvasGroup)
  return canvas_group
end

function M.setToggleIsOn(trans, visible)
  local togBtn = M.findComponent(trans, T_Toggle)
  togBtn.isOn = visible
  return togBtn
end

function M.addToggleListener(toggle_btn, func, params, ui_name)
  toggle_btn.onValueChanged:RemoveAllListeners()
  toggle_btn.onValueChanged:AddListener(function(check)
    func(check, params)
    if check then
      ui_name = ui_name or ""
    end
  end)
end

function M.addInputFieldListener(trans, func)
  local input = M.findComponent(trans, T_InputField)
  input.onValueChanged:RemoveAllListeners()
  input.onValueChanged:AddListener(func)
  return input
end

function M.addInputFieldEndListener(trans, func)
  local input = M.findComponent(trans, T_InputField)
  input.onEndEdit:RemoveAllListeners()
  input.onEndEdit:AddListener(func)
  return input
end

function M.setVerticalLayoutGroupSpacing(trans, num)
  local obj = M.findComponent(trans, typeof(VerticalLayoutGroup))
  if obj then
    obj.spacing = num
  end
end

function M.setContentSizeFitterLayoutVertical(trans, path)
  local csf = M.findContentSizeFitter(trans, path)
  if csf then
    csf:SetLayoutVertical()
  end
end

function M.setContentSizeFitterLayoutHorizontal(trans, path)
  local csf = M.findContentSizeFitter(trans, path)
  if csf then
    csf:SetLayoutHorizontal()
  end
end

function M.setImgAlpha(obj, alpha)
  local img = UIUtil.findImage(obj)
  local star_color = img.color
  star_color.a = alpha or 0
  img.color = star_color
end

function M.setButtonClickable(btn, isClickable)
  btn.interactable = isClickable
  btn.image.raycastTarget = isClickable
end

function M.destroyAllChild(trans)
  local count = trans.childCount
  if 0 < count then
    UILuaHelper.DestroyChildren(trans)
  end
end

function M.Get_EventTriggerType(type_name)
  if type_name == "PointerDown" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerDown
  elseif type_name == "PointerUp" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerUp
  elseif type_name == "PointerEnter" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerEnter
  elseif type_name == "PointerExit" then
    return CS.UnityEngine.EventSystems.EventTriggerType.PointerExit
  elseif type_name == "Drag" then
    return CS.UnityEngine.EventSystems.EventTriggerType.Drag
  end
end

M.RomaValues = {
  1,
  4,
  5,
  9,
  10,
  40,
  50,
  90,
  100,
  400,
  500,
  900,
  1000
}
M.RomaSymbols = {
  "Ⅰ",
  "Ⅳ",
  "Ⅴ",
  "Ⅸ",
  "Ⅹ",
  "XL",
  "L",
  "XC",
  "C",
  "CD",
  "D",
  "CM",
  "M"
}

function M:ArabToRomaNum(num)
  local roman = ""
  for i = #M.RomaValues, 1, -1 do
    while num >= M.RomaValues[i] do
      num = num - M.RomaValues[i]
      roman = roman .. M.RomaSymbols[i]
    end
  end
  return roman
end

function M.CreateRoleHeadInfo(rootObj, headId, roleLv)
  if utils.isNull(rootObj) then
    log.error("CreateRoleHeadInfo  rootObj == nil")
    return
  end
  local txtLv_Text = rootObj.transform:Find("bg_lv/c_txt_lv"):GetComponent("TextMeshProUGUI")
  txtLv_Text.text = tostring(roleLv)
  local img_head = rootObj.transform:Find("pnl_head_mask/c_img_head"):GetComponent("Image")
end

return M
