local Form_CirculationUpgradeTips = class("Form_CirculationUpgradeTips", require("UI/UIFrames/Form_CirculationUpgradeTipsUI"))
local MaxAttrNum = 2
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")
local CirculationTypeIns = ConfigManager:GetConfigInsByName("CirculationType")

function Form_CirculationUpgradeTips:SetInitParam(param)
end

function Form_CirculationUpgradeTips:AfterInit()
  self.super.AfterInit(self)
  self.m_curCirculationID = nil
  self.m_lastLv = nil
  self.m_newLv = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_curCirculationTypeCfg = nil
end

function Form_CirculationUpgradeTips:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_CirculationUpgradeTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_CirculationUpgradeTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CirculationUpgradeTips:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_curCirculationID = tParam.circulationID
    self.m_lastLv = tParam.lastLv
    self.m_newLv = tParam.newLv
    self.m_csui.m_param = nil
  end
end

function Form_CirculationUpgradeTips:FreshUI()
  local circulationTypeCfg = CirculationTypeIns:GetValue_ByCirculationTypeID(self.m_curCirculationID)
  if circulationTypeCfg:GetError() then
    return
  end
  self.m_curCirculationTypeCfg = circulationTypeCfg
  self.m_txt_lv_after_num_Text.text = self.m_newLv
  local beforeAttrTab = self.m_heroAttr:GetCirculationBaseAttr(self.m_curCirculationID, self.m_lastLv)
  local afterAttrTab = self.m_heroAttr:GetCirculationBaseAttr(self.m_curCirculationID, self.m_newLv)
  local propertyIDArray = self.m_curCirculationTypeCfg.m_PropertyIndexID
  local propertyIDLen = propertyIDArray.Length
  for i = 1, MaxAttrNum do
    if i <= propertyIDLen then
      UILuaHelper.SetActive(self["m_attr" .. i], true)
      local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(propertyIDArray[i - 1])
      self[string.format("m_txt_attr_name%d_Text", i)].text = propertyIndexCfg.m_mCNName
      local paramStr = propertyIndexCfg.m_ENName
      self[string.format("m_txt_attr_before%d_Text", i)].text = BigNumFormat(beforeAttrTab[paramStr])
      self[string.format("m_txt_attr_after%d_Text", i)].text = BigNumFormat(afterAttrTab[paramStr])
    else
      UILuaHelper.SetActive(self["m_attr" .. i], false)
    end
  end
end

function Form_CirculationUpgradeTips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CirculationUpgradeTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CirculationUpgradeTips", Form_CirculationUpgradeTips)
return Form_CirculationUpgradeTips
