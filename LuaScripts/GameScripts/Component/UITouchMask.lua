local BaseComponent = require("Component/BaseComponent")
local meta = class("UITouchMask", BaseComponent)

function meta:OnLoad()
  self:resetMaskCount()
  self:bindFunction("setTouchMaskEnabled")
  self:bindFunction("resetMaskCount")
  self:bindFunction("resetMaskStatus")
  self:bindFunction("isTouchMaskEnabled")
end

function meta:OnDestroy()
  if self.m_panelTouchMask then
    CS.UnityEngine.GameObject.Destroy(self.m_panelTouchMask)
  end
end

function meta:setTouchMaskEnabled(bEnabled)
  if bEnabled then
    self.m_iMaskCount = self.m_iMaskCount + 1
  else
    self.m_iMaskCount = self.m_iMaskCount - 1
  end
  self:resetMaskStatus()
end

function meta:resetMaskCount()
  self.m_iMaskCount = 0
  self:resetMaskStatus()
end

function meta:resetMaskStatus()
  if self.m_panelTouchMask then
    self.m_panelTouchMask:SetActive(self.m_iMaskCount > 0)
  else
    local goRoot = self.m_target.m_csui.m_uiGameObject
    if goRoot then
      self.m_panelTouchMask = CS.UnityEngine.GameObject("UITouchMask")
      self.m_panelTouchMask.transform:SetParent(goRoot.transform)
      local rectTransform = self.m_panelTouchMask:AddComponent(typeof(CS.UnityEngine.RectTransform))
      rectTransform.anchorMin = Vector2.New(0, 0)
      rectTransform.anchorMax = Vector2.New(1, 1)
      rectTransform.offsetMin = Vector2.New(0, 0)
      rectTransform.offsetMax = Vector2.New(0, 0)
      self.m_panelTouchMask:AddComponent(typeof(CS.UnityEngine.UI.Empty4Raycast))
      self.m_panelTouchMask:AddComponent(typeof(CS.UnityEngine.CanvasRenderer))
      self.m_panelTouchMask:SetActive(self.m_iMaskCount > 0)
    end
  end
end

function meta:isTouchMaskEnabled()
  return self.m_iMaskCount > 0
end

return meta
