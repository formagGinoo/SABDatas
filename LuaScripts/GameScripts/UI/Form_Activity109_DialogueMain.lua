local Form_Activity109_DialogueMain = class("Form_Activity109_DialogueMain", require("UI/UIFrames/Form_Activity109_DialogueMainUI"))
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree

function Form_Activity109_DialogueMain:SetInitParam(param)
end

function Form_Activity109_DialogueMain:AfterInit()
  Form_Activity109_DialogueMain.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick),
    parentLua = self
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UI109NormalLevelItem", initGridData)
  self.DegreeCfgTab[LevelDegree.Normal].activitySubIndex = 2
  self.sSubPanelName = "LevelDetail109SubPanel"
end

function Form_Activity109_DialogueMain:OnActive()
  Form_Activity109_DialogueMain.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(361)
end

function Form_Activity109_DialogueMain:OnInactive()
  Form_Activity109_DialogueMain.super.OnInactive(self)
end

function Form_Activity109_DialogueMain:OnDestroy()
  Form_Activity109_DialogueMain.super.OnDestroy(self)
end

function Form_Activity109_DialogueMain:FreshUI()
  Form_Activity109_DialogueMain.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self.m_curDegreeIndex = self.m_curDegreeIndex or self:GetChooseIndex() or 1
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity109_DialogueMain:FreshLevelTab(index)
  Form_Activity109_DialogueMain.super.FreshLevelTab(self, index)
  self.m_bg_nml:SetActive(index == LevelDegree.Normal)
  self.m_hard_bg:SetActive(index == LevelDegree.Hard)
  self.m_img_line_down:SetActive(index == LevelDegree.Normal)
  self.m_img_line_down_hard:SetActive(index == LevelDegree.Hard)
end

function Form_Activity109_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  self:FreshLevelTab(LevelDegree.Normal)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Acticity104_Level_Main_cut2")
end

function Form_Activity109_DialogueMain:OnBtnHardClicked()
  if self.m_curDegreeIndex == LevelDegree.Hard then
    return
  end
  if self.m_isHarLock then
    local clientMsgStr = ConfigManager:GetClientMessageTextById(40039)
    clientMsgStr = string.CS_Format(clientMsgStr, self:GetHardLevelUnlockStr(), self:GetHardTimeUnlockStr())
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, clientMsgStr)
    return
  end
  LevelHeroLamiaActivityManager:SetActivitySubEnter(self.DegreeCfgTab[LevelDegree.Hard].activitySubID)
  self:FreshLevelTab(LevelDegree.Hard)
  LocalDataManager:SetIntSimple("HeroActDialogueMainHardEntry" .. self.m_activityID, 1, true)
  self.m_hard_new:SetActive(false)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Acticity104_Level_Main_cut")
end

function Form_Activity109_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity109_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY108_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID,
    bIsSecondHalf = true
  })
end

function Form_Activity109_DialogueMain:GetDownloadResourceExtra(tParam)
  local _vPackage, _vResourceExtra = Form_Activity109_DialogueMain.super.GetDownloadResourceExtra(self, tParam)
  local vPackage = {}
  local vResourceExtra = {}
  if tParam.main_id then
    local act_id = tParam.main_id
    local subActivityID = HeroActivityManager:GetSubFuncID(act_id, HeroActivityManager.SubActTypeEnum.NormalLevel, 2)
    local subActivityInfoCfg = HeroActivityManager:GetSubInfoByID(subActivityID)
    if subActivityInfoCfg then
      local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(subActivityInfoCfg.m_SubPrefab)
      if vPackageSub ~= nil then
        for m = 1, #vPackageSub do
          vPackage[#vPackage + 1] = vPackageSub[m]
        end
      end
      if vResourceExtraSub ~= nil then
        for n = 1, #vResourceExtraSub do
          vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[n]
        end
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
ActiveLuaUI("Form_Activity109_DialogueMain", Form_Activity109_DialogueMain)
return Form_Activity109_DialogueMain
