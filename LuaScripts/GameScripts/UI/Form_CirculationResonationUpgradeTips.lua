local Form_CirculationResonationUpgradeTips = class("Form_CirculationResonationUpgradeTips", require("UI/UIFrames/Form_CirculationResonationUpgradeTipsUI"))
local MaxAttrNum = 4
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")

function Form_CirculationResonationUpgradeTips:SetInitParam(param)
end

function Form_CirculationResonationUpgradeTips:AfterInit()
  self.super.AfterInit(self)
  self.m_lastLv = nil
  self.m_newLv = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
end

function Form_CirculationResonationUpgradeTips:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_CirculationResonationUpgradeTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_CirculationResonationUpgradeTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CirculationResonationUpgradeTips:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_careerID = tParam.resonationID
    self.m_lastLv = tParam.lastLv
    self.m_newLv = tParam.newLv
    self.m_csui.m_param = nil
  end
end

function Form_CirculationResonationUpgradeTips:FreshUI()
  self.m_txt_lv_after_num_Text.text = self.m_newLv
  local beforeAttrTab = self.m_heroAttr:GetResonationBaseAttr(self.m_careerID, self.m_lastLv)
  local afterAttrTab = self.m_heroAttr:GetResonationBaseAttr(self.m_careerID, self.m_newLv)
  for i = 1, MaxAttrNum do
    if i <= MaxAttrNum then
      UILuaHelper.SetActive(self["m_attr" .. i], true)
      local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
      self[string.format("m_txt_attr_name%d_Text", i)].text = propertyIndexCfg.m_mCNName
      local paramStr = propertyIndexCfg.m_ENName
      self[string.format("m_txt_attr_before%d_Text", i)].text = BigNumFormat(beforeAttrTab[paramStr])
      self[string.format("m_txt_attr_after%d_Text", i)].text = BigNumFormat(afterAttrTab[paramStr])
    else
      UILuaHelper.SetActive(self["m_attr" .. i], false)
    end
  end
end

function Form_CirculationResonationUpgradeTips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CirculationResonationUpgradeTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CirculationResonationUpgradeTips", Form_CirculationResonationUpgradeTips)
return Form_CirculationResonationUpgradeTips
