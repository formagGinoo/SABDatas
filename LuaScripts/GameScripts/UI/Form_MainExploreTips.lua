local Form_MainExploreTips = class("Form_MainExploreTips", require("UI/UIFrames/Form_MainExploreTipsUI"))

function Form_MainExploreTips:SetInitParam(param)
end

function Form_MainExploreTips:AfterInit()
  self.super.AfterInit(self)
end

function Form_MainExploreTips:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(213)
  self.m_mainExploreType = nil
  local tParam = self.m_csui.m_param
  if tParam then
    local newUnlockCfg = tParam.newUnlockCfg
    if newUnlockCfg then
      self.m_mainExploreType = newUnlockCfg.m_Type
    end
    self.m_csui.m_param = nil
  end
  local isSea = false
  if self.m_mainExploreType == MainExploreManager.ExploreTipsType.Sea then
    isSea = true
  end
  UILuaHelper.SetActive(self.m_img_center_sea, isSea)
  UILuaHelper.SetActive(self.m_img_center_nml, not isSea)
end

function Form_MainExploreTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_MainExploreTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MainExploreTips:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_MainExploreTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_MainExploreTips", Form_MainExploreTips)
return Form_MainExploreTips
