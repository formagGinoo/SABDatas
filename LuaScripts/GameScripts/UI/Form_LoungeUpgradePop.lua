local Form_LoungeUpgradePop = class("Form_LoungeUpgradePop", require("UI/UIFrames/Form_LoungeUpgradePopUI"))

function Form_LoungeUpgradePop:SetInitParam(param)
end

function Form_LoungeUpgradePop:AfterInit()
  self.super.AfterInit(self)
end

function Form_LoungeUpgradePop:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_level = tParam.level or 0
  self.m_propertyIDList = tParam.propertyIDList or {}
  self:RefreshUI()
end

function Form_LoungeUpgradePop:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoungeUpgradePop:RefreshUI()
  local attrList = LoungeManager:GetLoungeAttrByPropertyIDs(self.m_propertyIDList)
  for i = 1, 4 do
    local attrInfo = attrList[i]
    if attrInfo then
      ResourceUtil:CreatePropertyImg(self["m_before_attr_icon" .. i .. "_Image"], attrInfo.id)
      self["m_before_attr_name" .. i .. "_Text"].text = tostring(attrInfo.cfg.m_mCNName)
      self["m_after_attr_num" .. i .. "_Text"].text = tostring(attrInfo.num)
    end
  end
  self.m_txt_LV_Text.text = self.m_level
end

function Form_LoungeUpgradePop:IsOpenGuassianBlur()
  return true
end

function Form_LoungeUpgradePop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_LoungeUpgradePop", Form_LoungeUpgradePop)
return Form_LoungeUpgradePop
