local UISubPanelBase = require("UI/Common/UISubPanelBase")
local PushJumpFaceActivity = class("PushJumpFaceActivity", UISubPanelBase)
local SpineStrCfg = {
  ui_activity_lamiaface = "empusae_final",
  ui_activity_huntingnightface = "cidhall_base"
}

function PushJumpFaceActivity:OnInit()
end

function PushJumpFaceActivity:OnHidePanel()
  self:clearEventListener()
end

function PushJumpFaceActivity:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_PushFaceReserve", handler(self, self.OnEventGetReward))
end

function PushJumpFaceActivity:OnFreshData()
  self:AddEventListeners()
  self.openTime = TimeUtil:GetServerTimeS()
  self.activity = ActivityManager:GetActivityByID(self.m_initData)
  self.activityData = self.activity:OnGetActData()
  self.clientData = self.activity:OnGetClientConfig()
  if not self.clientData then
    return
  end
  self.m_actStatue = self.activity:GetActStatueInCurTime()
  self:RefreshUI()
  self:RefreshTime()
  self:IsGetReward()
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  local isShowSpine = self.clientData.iHasSpine or 0
  if not self.m_curHeroSpineObj and self.m_root_hero and isShowSpine and isShowSpine == 1 and self.clientData.sSpineName then
    self:LoadHeroSpine(self.clientData.sSpineName)
  end
end

function PushJumpFaceActivity:IsGetReward()
  if self.activity:IsCanGetReward() then
    self.activity:RequestReserveReward()
  end
end

function PushJumpFaceActivity:RefreshUI()
  if self.m_txt_desc_Text then
    self.m_txt_desc_Text.text = self.activity:getLangText(self.activityData.sBriefDesc)
  end
  local isGetReward = self.activity:IsGetReserveState()
  if self.m_z_txt_noReward then
    UILuaHelper.SetActive(self.m_z_txt_noReward, not isGetReward)
  end
  if self.m_z_txt_getReward then
    UILuaHelper.SetActive(self.m_z_txt_getReward, isGetReward)
  end
  if self.m_icon_done then
    UILuaHelper.SetActive(self.m_icon_done, isGetReward)
  end
  if self.m_z_txt_reserve then
    UILuaHelper.SetActive(self.m_z_txt_reserve, self.m_actStatue ~= ActivityManager.ActPushFaceStatue.Jump)
  end
  if self.m_z_txt_go then
    UILuaHelper.SetActive(self.m_z_txt_go, self.m_actStatue == ActivityManager.ActPushFaceStatue.Jump)
  end
  local reward = self.activity:GetActReserveReward()
  if reward and 1 <= #reward then
    local itemId = reward[1].iID
    local processItemData = ResourceUtil:GetProcessRewardData({
      iID = itemId,
      iNum = reward[1].iNum
    })
    if self.m_txt_tips_num_Text and itemId then
      self.m_txt_tips_num_Text.text = "X" .. tostring(reward[1].iNum)
    end
    if self.m_icon_Image and processItemData.icon_name then
      UILuaHelper.SetAtlasSprite(self.m_icon_Image, processItemData.icon_name)
    end
  end
end

function PushJumpFaceActivity:RefreshTime()
  if self.m_txt_time then
    local endTime = self.activityData.iEndTime
    self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
    self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_iTimeTick)
    self.tickTimer = TimeService:SetTimer(1, -1, function()
      self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
      self.m_txt_time_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(self.m_iTimeTick)
      if self.m_iTimeTick <= 0 and self.tickTimer then
        TimeService:KillTimer(self.tickTimer)
        self.tickTimer = nil
      end
    end)
  end
end

function PushJumpFaceActivity:OnBtnenterClicked()
  if self.m_actStatue == ActivityManager.ActPushFaceStatue.Jump then
    local poPTime = TimeUtil:GetServerTimeS() - self.openTime
    ReportManager:ReportGachaPushFace(self.m_initData, self.activityData.sDesignerRemark, 1, 1, self.openTime, poPTime)
    QuickOpenFuncUtil:OpenFunc(self.clientData.iJumpId)
  elseif self.m_actStatue == ActivityManager.ActPushFaceStatue.Reserve then
  else
    self.activity:SetActReserveRewardState(ActivityManager.ActPushFaceStatue.Reserve)
    self.activity:ReserveDownload()
  end
  self:OnCloseGachaPushface()
end

function PushJumpFaceActivity:OnBtncloseClicked()
  local poPTime = TimeUtil:GetServerTimeS() - self.openTime
  ReportManager:ReportGachaPushFace(self.m_initData, self.activityData.sDesignerRemark, 1, 0, self.openTime, poPTime)
  self:OnCloseGachaPushface()
end

function PushJumpFaceActivity:OnBtnsearchClicked()
  if self.clientData and self.clientData.iHeroId and self.clientData.iHeroId > 0 then
    StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
      heroID = self.clientData.iHeroId
    })
  end
end

function PushJumpFaceActivity:OnCloseGachaPushface()
  if self.tickTimer then
    TimeService:KillTimer(self.tickTimer)
    self.tickTimer = nil
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_ACTIVITYFACEMAIN)
  self:OnHidePanel()
end

function PushJumpFaceActivity:LoadHeroSpine(prefabName)
  if not prefabName then
    return
  end
  self:DestroySpine()
  self.m_HeroSpineDynamicLoader:GetObjectByName(prefabName, function(backStr, spineSomethingObj)
    self:DestroySpine()
    self.m_curHeroSpineObj = spineSomethingObj
    self.m_heroSpineStr = backStr
    UILuaHelper.SetParent(self.m_curHeroSpineObj, self.m_root_hero, true)
    UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    if self.clientData.sSpineAnimSting and self.clientData.sSpineAnimSting ~= "" then
      UILuaHelper.SpinePlayAnim(self.m_curHeroSpineObj, 0, self.clientData.sSpineAnimSting, true)
    end
  end)
end

function PushJumpFaceActivity:GetDownloadResourceExtra(subPanelCfg)
  local spineStr = SpineStrCfg[subPanelCfg.PrefabPath]
  local vPackage = {}
  local vResourceExtra = {}
  if spineStr then
    vResourceExtra[#vResourceExtra + 1] = {
      sName = spineStr,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

function PushJumpFaceActivity:DestroySpine()
  if self.m_curHeroSpineObj and self.m_heroSpineStr then
    self.m_HeroSpineDynamicLoader:RecycleObjectByName(self.m_heroSpineStr, self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
    self.m_heroSpineStr = nil
  end
end

function PushJumpFaceActivity:OnInactive()
  self:DestroySpine()
  if self.tickTimer then
    TimeService:KillTimer(self.tickTimer)
    self.tickTimer = nil
  end
end

function PushJumpFaceActivity:OnEventGetReward(stParam)
  utils.popUpRewardUI(stParam.vReward)
  self.m_actStatue = self.activity:GetActStatueInCurTime()
  self:RefreshUI()
end

return PushJumpFaceActivity
