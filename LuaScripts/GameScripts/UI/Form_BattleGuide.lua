local Form_BattleGuide = class("Form_BattleGuide", require("UI/UIFrames/Form_BattleGuideUI"))

function Form_BattleGuide:SetInitParam(param)
end

function Form_BattleGuide:AfterInit()
  self.m_nMapID = 1
  self.m_nBattleIndex = 1
  self.m_nGuideId = 1
  self.m_nCurrentIndex = 1
end

function Form_BattleGuide:OnActive()
  log.info("Form_BattleGuide:OnActive")
  self:RefreshData()
end

function Form_BattleGuide:RefreshData()
  self.m_Guide1:SetActive(false)
  self.m_Guide2:SetActive(false)
  self.m_nMapID = CS.BattleGameManager.Instance:GetCurrentMapID()
  self.m_nBattleIndex = CS.BattleGameManager.Instance:GetCurrentPassIndex()
  local mapSlkData = ConfigManager:GetBattleWorldCfgById(self.m_nMapID)
  if mapSlkData:GetError() then
    return
  end
  if self.m_nBattleIndex > mapSlkData.m_BattleConfigID.Length then
    return
  end
  local nGuidId = tonumber(mapSlkData.m_BattleConfigID[self.m_nBattleIndex - 1])
  local battleConfigData = CS.CData_BattleConfig.GetInstance():GetValue_ByID(nGuidId)
  if battleConfigData == nil then
    return
  end
  self.m_nGuideId = battleConfigData.m_GuideID
  local slkData = CS.CData_BattleGuide.GetInstance():GetValue_ByID(self.m_nGuideId)
  for k, v in pairs(slkData) do
    if self.m_nCurrentIndex == v.m_SubID then
      if v.m_ShowType == eBattleGuideTypeLua.eLeft then
        self.m_Guide1:SetActive(true)
        CS.UI.UILuaHelper.SetAtlasSprite(self.m_ImageRoleHead1_Image, v.m_HeadPath)
        self.m_TextDialouge1_Text.text = v.m_Dialogue
      elseif v.m_ShowType == eBattleGuideTypeLua.eRight then
        self.m_Guide2:SetActive(true)
        CS.UI.UILuaHelper.SetAtlasSprite(self.m_ImageRoleHead2_Image, v.m_HeadPath)
        self.m_TextDialouge2_Text.text = v.m_Dialogue
      end
    end
  end
end

function Form_BattleGuide:OnBgbuttonClicked()
  self.m_nCurrentIndex = self.m_nCurrentIndex + 1
  local slkData = CS.CData_BattleGuide.GetInstance():GetValue_ByID(self.m_nGuideId)
  if self.m_nCurrentIndex > table.getn(slkData) then
    self.m_nCurrentIndex = 1
    self:CloseForm()
  else
    self:RefreshData()
  end
end

function Form_BattleGuide:OnBtnBackClicked()
  local function cb(handler)
    CS.BattleGameManager.Instance:ResetCurrentPassID()
  end
  
  local function cb2(handler)
  end
end

local fullscreen = true
ActiveLuaUI("Form_BattleGuide", Form_BattleGuide)
return Form_BattleGuide
