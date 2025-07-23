local Form_Activity102DalcaroMain = class("Form_Activity102DalcaroMain", require("UI/UIFrames/Form_Activity102DalcaroMainUI"))
local AudiobnkId = {
  115,
  116,
  117,
  118,
  119,
  120,
  121,
  122,
  123,
  124
}

function Form_Activity102DalcaroMain:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity102DalcaroMain:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(115)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(116)
end

function Form_Activity102DalcaroMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102DalcaroMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity102DalcaroMain:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

function Form_Activity102DalcaroMain:GetDownloadResourceExtra(tParam)
  local _vPackage, _vResourceExtra = Form_Activity102DalcaroMain.super.GetDownloadResourceExtra(self, tParam)
  local vPackage = {}
  local vResourceExtra = {}
  for i, v in ipairs(AudiobnkId) do
    local temptable = utils.changeCSArrayToLuaTable(UILuaHelper.GetAudioResById(v))
    if temptable then
      for _, value in pairs(temptable) do
        vResourceExtra[#vResourceExtra + 1] = {
          sName = value,
          eType = DownloadManager.ResourceType.Audio
        }
      end
    end
  end
  for i, v in ipairs(_vPackage) do
    vPackage[#vPackage + 1] = v
  end
  for i, v in ipairs(_vResourceExtra) do
    vResourceExtra[#vResourceExtra + 1] = v
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Activity102DalcaroMain", Form_Activity102DalcaroMain)
return Form_Activity102DalcaroMain
