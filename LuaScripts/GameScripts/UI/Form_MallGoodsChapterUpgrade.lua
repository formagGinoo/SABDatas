local Form_MallGoodsChapterUpgrade = class("Form_MallGoodsChapterUpgrade", require("UI/UIFrames/Form_MallGoodsChapterUpgradeUI"))

function Form_MallGoodsChapterUpgrade:SetInitParam(param)
end

function Form_MallGoodsChapterUpgrade:AfterInit()
  self.super.AfterInit(self)
end

function Form_MallGoodsChapterUpgrade:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(73)
end

function Form_MallGoodsChapterUpgrade:OnInactive()
  self.super.OnInactive(self)
end

function Form_MallGoodsChapterUpgrade:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MallGoodsChapterUpgrade:OnBtncloseClicked()
  self:CloseForm()
  if self.m_csui.m_param.call_back then
    self.m_csui.m_param.call_back()
  end
end

function Form_MallGoodsChapterUpgrade:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MallGoodsChapterUpgrade", Form_MallGoodsChapterUpgrade)
return Form_MallGoodsChapterUpgrade
