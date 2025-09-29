local Form_CirculationLevelUp = class("Form_CirculationLevelUp", require("UI/UIFrames/Form_CirculationLevelUpUI"))
local MaxAttrNum = 4
local PropertyIndexIns = ConfigManager:GetConfigInsByName("PropertyIndex")

function Form_CirculationLevelUp:SetInitParam(param)
end

function Form_CirculationLevelUp:AfterInit()
  self.super.AfterInit(self)
  self.m_curCirculationID = nil
  self.m_lastLv = nil
  self.m_newLv = nil
  self.m_heroAttr = HeroManager:GetHeroAttr()
  self.m_curCirculationTypeCfg = nil
end

function Form_CirculationLevelUp:OnActive()
  self.super.OnActive(self)
  self:FreshData()
  self:FreshUI()
end

function Form_CirculationLevelUp:OnInactive()
  self.super.OnInactive(self)
end

function Form_CirculationLevelUp:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_CirculationLevelUp:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_careerID = tParam.resonationID
    self.m_beforeList = tParam.beforeList
    self.m_afterList = tParam.afterList
    self.m_csui.m_param = nil
  end
end

function Form_CirculationLevelUp:FreshUI()
  local beforeAttrTab = self.m_heroAttr:GetCareerLocationBaseAttr(self.m_beforeList)
  local afterAttrTab = self.m_heroAttr:GetCareerLocationBaseAttr(self.m_afterList)
  for i = 1, MaxAttrNum do
    if i <= MaxAttrNum then
      UILuaHelper.SetActive(self["m_item_ability" .. i], true)
      local propertyIndexCfg = PropertyIndexIns:GetValue_ByPropertyID(i)
      self[string.format("m_txt_Ability%d_Text", i)].text = propertyIndexCfg.m_mCNName
      local paramStr = propertyIndexCfg.m_ENName
      self[string.format("m_txt_before_num%d_Text", i)].text = BigNumFormat(beforeAttrTab[paramStr])
      self[string.format("m_txt_after_num_%d_Text", i)].text = BigNumFormat(afterAttrTab[paramStr])
      local colorArrow = self["m_img_arrow" .. i]:GetComponent("MultiColorChange")
      local colorTxt = self["m_txt_after_num_" .. i]:GetComponent("MultiColorChange")
      local upImg = self["m_img_level" .. i]
      if beforeAttrTab[paramStr] > afterAttrTab[paramStr] then
        colorArrow:SetColorByIndex(1)
        colorTxt:SetColorByIndex(1)
        upImg:SetActive(false)
      else
        colorArrow:SetColorByIndex(0)
        colorTxt:SetColorByIndex(0)
        upImg:SetActive(true)
      end
      self["m_img_arrow" .. i]:SetActive(beforeAttrTab[paramStr] ~= afterAttrTab[paramStr])
      self["m_txt_after_num_" .. i]:SetActive(beforeAttrTab[paramStr] ~= afterAttrTab[paramStr])
    else
      UILuaHelper.SetActive(self["m_item_ability" .. i], false)
    end
  end
end

function Form_CirculationLevelUp:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_CirculationLevelUp:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_CirculationLevelUp", Form_CirculationLevelUp)
return Form_CirculationLevelUp
