local Form_Activity103Luoleilai_DialogueFastPass = class("Form_Activity103Luoleilai_DialogueFastPass", require("UI/UIFrames/Form_Activity103Luoleilai_DialogueFastPassUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum

function Form_Activity103Luoleilai_DialogueFastPass:SetInitParam(param)
end

function Form_Activity103Luoleilai_DialogueFastPass:AfterInit()
  self.super.AfterInit(self)
  self.m_txt_bonus_MCC = self.m_txt_bonus:GetComponent("MultiColorChange")
  self.m_z_txt_bonus_tips_MCC = self.m_z_txt_bonus_tips:GetComponent("MultiColorChange")
end

function Form_Activity103Luoleilai_DialogueFastPass:OnActive()
  self.super.OnActive(self)
end

function Form_Activity103Luoleilai_DialogueFastPass:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity103Luoleilai_DialogueFastPass:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity103Luoleilai_DialogueFastPass:FreshHeroBonusShow()
  local totalLen = #self.m_heroTopBonus
  local addBonusNum = 0
  local isEmpty = totalLen <= 0
  UILuaHelper.SetActive(self.m_heroNo, isEmpty)
  UILuaHelper.SetActive(self.m_hero_list, not isEmpty)
  if not isEmpty then
    for i = 1, FormPlotMaxNum do
      local tempBonusData = self.m_heroTopBonus[i]
      UILuaHelper.SetActive(self["m_common_hero_middle" .. i], tempBonusData ~= nil)
      if tempBonusData then
        local heroNode = self.m_heroNodes[i]
        heroNode.heroIconWidget:SetHeroData(tempBonusData.heroData.serverData, nil, true)
        heroNode.txtBonus.text = tempBonusData.rate .. "%"
        addBonusNum = addBonusNum + tempBonusData.rate
      end
    end
  end
  self.m_curAddBonus = 100 < addBonusNum and 100 or addBonusNum
  UILuaHelper.SetActive(self.m_bonus_normal, true)
  self.m_txt_bonus_Text.text = self.m_curAddBonus .. "%"
  local idx = self.m_curAddBonus == 0 and 2 or self.m_curAddBonus >= 100 and 0 or 1
  self.m_txt_bonus_MCC:SetColorByIndex(idx)
  self.m_z_txt_bonus_tips_MCC:SetColorByIndex(idx)
end

function Form_Activity103Luoleilai_DialogueFastPass:FreshStepperShow()
  if not self.m_numStepper then
    return
  end
  local totalLeftNum = self:GetTotalLeftTimes()
  self.m_numStepper:SetNumShowMax(true)
  self.m_numStepper:SetNumMax(totalLeftNum)
  self.m_numStepper:SetNumCur(self.m_curSweepNum)
end

function Form_Activity103Luoleilai_DialogueFastPass:OnBtncheckClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity103Luoleilai_DialogueFastPass", Form_Activity103Luoleilai_DialogueFastPass)
return Form_Activity103Luoleilai_DialogueFastPass
