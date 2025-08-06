local Form_Activity105Main = class("Form_Activity105Main", require("UI/UIFrames/Form_Activity105MainUI"))

function Form_Activity105Main:SetInitParam(param)
end

function Form_Activity105Main:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity105Main:OnActive()
  self.super.OnActive(self)
  self:RegisterOrUpdateRedDotItem(self.m_minigame_redpoint, RedDotDefine.ModuleType.HeroActMiniGamePuzzleEntry, {
    actId = self.act_id
  })
  CS.GlobalManager.Instance:TriggerWwiseBGMState(330)
end

function Form_Activity105Main:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity105Main:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity105Main:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

function Form_Activity105Main:OnBtnminigameClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  })
end

function Form_Activity105Main:GetDownloadResourceExtra(tParam)
  local _vPackage, _vResourceExtra = Form_Activity105Main.super.GetDownloadResourceExtra(self, tParam)
  local vPackage = {}
  local vResourceExtra = {}
  for i, v in ipairs(_vPackage) do
    vPackage[#vPackage + 1] = v
  end
  for i, v in ipairs(_vResourceExtra) do
    vResourceExtra[#vResourceExtra + 1] = v
  end
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "Form_Activity105Plotclock",
    eType = DownloadManager.ResourceType.UI
  }
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Activity105Main", Form_Activity105Main)
return Form_Activity105Main
