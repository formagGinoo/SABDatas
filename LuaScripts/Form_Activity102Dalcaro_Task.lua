local Form_Activity102Dalcaro_Task = class("Form_Activity102Dalcaro_Task", require("UI/UIFrames/Form_Activity102Dalcaro_TaskUI"))
local DefaultShowSpineName = "jacinta_base"

function Form_Activity102Dalcaro_Task:SetInitParam(param)
end

function Form_Activity102Dalcaro_Task:AfterInit()
  self.super.AfterInit(self)
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_Activity102Dalcaro_Task:OnActive()
  self.super.OnActive(self)
  self:LoadShowSpine()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(118)
end

function Form_Activity102Dalcaro_Task:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleSpine(true)
end

function Form_Activity102Dalcaro_Task:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function Form_Activity102Dalcaro_Task:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(DefaultShowSpineName, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_Activity102Dalcaro_Task:LoadShowSpine()
  if not self.m_HeroSpineDynamicLoader then
    return
  end
  self:CheckRecycleSpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(DefaultShowSpineName, function(nameStr, object)
    self:CheckRecycleSpine()
    UILuaHelper.SetParent(object, self.m_root_hero, true)
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SpineResetMatParam(object)
    self.m_curHeroSpineObj = object
  end)
end

function Form_Activity102Dalcaro_Task:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = DefaultShowSpineName,
    eType = DownloadManager.ResourceType.UI
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_Task", Form_Activity102Dalcaro_Task)
return Form_Activity102Dalcaro_Task
