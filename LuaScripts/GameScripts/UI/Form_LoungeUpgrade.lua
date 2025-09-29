local Form_LoungeUpgrade = class("Form_LoungeUpgrade", require("UI/UIFrames/Form_LoungeUpgradeUI"))

function Form_LoungeUpgrade:SetInitParam(param)
end

function Form_LoungeUpgrade:AfterInit()
  self.super.AfterInit(self)
  self.m_loungeInfinityGrid = self:CreateInfinityGrid(self.m_lounge_scrollView_InfinityGrid, "Lounge/UILoungeItem")
end

function Form_LoungeUpgrade:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_level = tParam.level or 0
  self.m_propertyIDList = tParam.propertyIDList or {}
  self.m_newPropertyIDList = tParam.newPropertyIDList or {}
  self:RefreshUI()
end

function Form_LoungeUpgrade:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoungeUpgrade:RefreshUI()
  local attrList = {}
  local oldAttrList = {}
  local list = {}
  attrList = LoungeManager:GetLoungeAttrByPropertyIDs(self.m_newPropertyIDList)
  oldAttrList = LoungeManager:GetLoungeAttrByPropertyIDs(self.m_propertyIDList)
  for i, v in ipairs(attrList) do
    list[#list + 1] = {newAttr = v}
  end
  for i, v in ipairs(list) do
    for m, n in ipairs(oldAttrList) do
      if v.newAttr and v.newAttr.id == n.id then
        list[i].oldAttr = n
      end
    end
  end
  self.m_loungeInfinityGrid:ShowItemList(list)
  self.m_txt_LV_Text.text = self.m_level
end

function Form_LoungeUpgrade:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_LoungeUpgrade", Form_LoungeUpgrade)
return Form_LoungeUpgrade
