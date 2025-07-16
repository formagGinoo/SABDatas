local Form_InheritUpTips = class("Form_InheritUpTips", require("UI/UIFrames/Form_InheritUpTipsUI"))

function Form_InheritUpTips:SetInitParam(param)
end

function Form_InheritUpTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_InheritUpTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_okCallBack = tParam.callBack
  self.m_heroIconList = {}
  self:RefreshUI()
end

function Form_InheritUpTips:OnInactive()
  self.super.OnInactive(self)
  self.m_heroIconList = {}
end

function Form_InheritUpTips:RefreshUI()
  local heroList = InheritManager:GetTopFiveHero()
  for i = 1, 5 do
    if not self.m_heroIconList[i] then
      self.m_heroIconList[i] = self:createHeroIcon(self["m_hero" .. i])
    end
    local heroData = heroList[i]
    if heroData then
      self.m_heroIconList[i]:SetHeroData(heroData.serverData)
    end
  end
end

function Form_InheritUpTips:OnBtnyesClicked()
  if self.m_okCallBack then
    self.m_okCallBack()
  end
  self:OnBtnCloseClicked()
end

function Form_InheritUpTips:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_InheritUpTips:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_InheritUpTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_InheritUpTips:IsOpenGuassianBlur()
  return true
end

function Form_InheritUpTips:IsFullScreen()
  return false
end

local fullscreen = true
ActiveLuaUI("Form_InheritUpTips", Form_InheritUpTips)
return Form_InheritUpTips
