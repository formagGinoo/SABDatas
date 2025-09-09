local UISubPanelBase = require("UI/Common/UISubPanelBase")
local HeroTrialActivitySubPanel = class("HeroTrialActivitySubPanel", UISubPanelBase)
local Attr_Icon_Str = "m_attr_icon_"
local BattleType = MTTDProto.FightType_HeroTrial
local EndTimeStr = ConfigManager:GetCommonTextById(220018)
local PanelOut = "ui_activity_panel_role_trial_out"
local CardSelect1 = "ui_activity_panel_role_trial_select_in"
local CardSelect2 = "ui_activity_panel_role_trial_select_in1"

function HeroTrialActivitySubPanel:OnInit()
  self.CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
  self.m_levelData = {}
  self.m_curChooseIndex = 1
  if self.m_initData.subPanelTabIndex then
    self.m_initData_HeroId = self.m_initData.subPanelTabIndex
  end
  local initItemData = {
    itemClkBackFun = handler(self, self.OnItemClk)
  }
  self.m_roleCardLoopScrollView = self:CreateLoopScrollView(self.m_role_card_list:GetComponent(T_LoopScrollView), "HeroTrial/UIHeroTrialItem", initItemData)
  self.m_rewardLoopScrollView = self:CreateInfinityGrid(self.m_reward_list_InfinityGrid, "HeroTrial/UIHeroTrialRewardItem")
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self:BindCB()
  self:AddEventListeners()
  LocalDataManager:SetIntSimple("HeroTrialActivity_Red_Point", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
  self.m_parentLua:RefreshTableButtonList()
end

function HeroTrialActivitySubPanel:OnItemClk(index)
  if index == self.m_curChooseIndex then
    return
  end
  self.m_curChooseIndex = index
  self:FreshLevelData()
  self:SetLevelClicked()
  self:ReFreshUI()
  UILuaHelper.PlayAnimationByName(self.m_right_info, CardSelect2)
end

function HeroTrialActivitySubPanel:OnInactive()
  self:CheckRecycleSpine()
  UILuaHelper.PlayAnimationByName(self.m_rootObj, PanelOut)
end

function HeroTrialActivitySubPanel:SetLevelClicked()
  local chooseLevelData = self.m_levelData[self.m_curChooseIndex]
  if chooseLevelData then
    local isClick = LocalDataManager:GetIntSimple("Activity_HeroTrialItem_Red_Point" .. chooseLevelData.LevelID, 0)
    if isClick == 0 then
      chooseLevelData.RedShow = false
      LocalDataManager:SetIntSimple("Activity_HeroTrialItem_Red_Point" .. chooseLevelData.LevelID, 1, true)
      self.m_parentLua:RefreshTableButtonList()
    end
  end
end

function HeroTrialActivitySubPanel:OnClickTab(heroId)
  local index = self:GetSubTabIndexByHeroId(heroId)
  if index ~= 0 then
    self:OnItemClk(index)
  end
end

function HeroTrialActivitySubPanel:SetCurTabIdx(heroId)
  local index = self:GetSubTabIndexByHeroId(heroId)
  if index ~= 0 and index ~= self.m_curChooseIndex then
    self.m_curChooseIndex = index
  end
end

function HeroTrialActivitySubPanel:GetSubTabIndexByHeroId(heroId)
  for i, v in pairs(self.m_levelData) do
    if v.HeroCfg.m_HeroID == heroId then
      return i
    end
  end
  return 0
end

function HeroTrialActivitySubPanel:BindCB()
  for i = 1, 4 do
    if self[Attr_Icon_Str .. i] then
      UILuaHelper.BindButtonClickManual(self[Attr_Icon_Str .. i].transform.parent:GetComponent(T_Button), function()
        local chooseLevelData = self.m_levelData[self.m_curChooseIndex]
        if chooseLevelData then
          StackPopup:Push(chooseLevelData.AttrPathData[i].formId, {
            heroCfg = chooseLevelData.HeroCfg
          })
        end
      end)
    end
  end
  UILuaHelper.BindButtonClickManual(self.m_icon_moon1.transform.parent:GetComponent(T_Button), function()
    local chooseLevelData = self.m_levelData[self.m_curChooseIndex]
    if chooseLevelData then
      StackPopup:Push(UIDefines.ID_FORM_HEROEQUIPTYPEDETAIL, {
        heroCfg = chooseLevelData.HeroCfg,
        isMoonType = true
      })
    end
  end)
end

function HeroTrialActivitySubPanel:OnUpdate(dt)
  if utils.isNull(self.m_end_time_Text) then
    return
  end
  if not self.m_iTimeTick then
    return
  end
  self.m_iTimeTick = self.m_iTimeTick - dt
  self.m_iTimeDurationOneSecond = self.m_iTimeDurationOneSecond - dt
  if self.m_iTimeDurationOneSecond <= 0 then
    self.m_iTimeDurationOneSecond = 1
    local lastTimeCur = TimeUtil:SecondsToFormatCNStr3(self.m_iTimeTick)
    self.m_end_time_Text.text = string.gsubnumberreplace(EndTimeStr, lastTimeCur)
  end
  if self.m_iTimeTick <= 0 and self.m_stActivity then
    self.m_stActivity:RemoveLevelDataByIndex()
    self.m_curChooseIndex = 1
    self:FreshLevelData()
    self:ReFreshUI()
  end
end

function HeroTrialActivitySubPanel:OnFreshData()
  self.m_stActivity = self.m_panelData.activity
  if not self.m_stActivity then
    return
  end
  self:FreshLevelData()
  self:CheckReward()
  self:ReFreshUI()
end

function HeroTrialActivitySubPanel:CheckReward()
  for _, v in pairs(self.m_levelData) do
    if self.m_stActivity:GeStatusByLevelId(v.LevelID) == 1 then
      self.m_stActivity:RequestGetReward(v.LevelID)
    end
  end
end

function HeroTrialActivitySubPanel:FreshLevelData()
  self.m_levelData = self.m_stActivity:GetOpenLevelData()
  if self.m_initData_HeroId then
    local index = self:GetSubTabIndexByHeroId(self.m_initData_HeroId)
    if index ~= 0 then
      self.m_initData_HeroId = nil
      self.m_curChooseIndex = index
    end
  end
  if self.m_roleCardLoopScrollView then
    local data = self:GeneratedRoleCardData()
    self.m_roleCardLoopScrollView:ShowItemList(data, true)
  end
  if self.m_rewardLoopScrollView then
    local data = self:GeneratedRewardData()
    self.m_rewardLoopScrollView:ShowItemList(data, true)
  end
end

function HeroTrialActivitySubPanel:ReFreshUI()
  local chooseLevelData = self.m_levelData[self.m_curChooseIndex]
  if chooseLevelData and chooseLevelData.HeroCfg then
    self:LoadHeroSpine(chooseLevelData.HeroCfg.m_Spine)
    self.m_txt_name_Text.text = chooseLevelData.HeroCfg.m_mName
    for i = 1, 4 do
      if self[Attr_Icon_Str .. i] then
        UILuaHelper.SetAtlasSprite(self[Attr_Icon_Str .. i .. "_Image"], chooseLevelData.AttrPathData[i].path)
      end
    end
    local moonType = chooseLevelData.HeroCfg.m_MoonType
    UILuaHelper.SetActive(self.m_icon_moon1, moonType == 1)
    UILuaHelper.SetActive(self.m_icon_moon2, moonType == 2)
    UILuaHelper.SetActive(self.m_icon_moon3, moonType == 3)
    self.m_iTimeDurationOneSecond = 1
    local endTime = chooseLevelData.EndTime
    if 0 < endTime then
      UILuaHelper.SetActive(self.m_end_time, true)
      self.m_iTimeTick = endTime - TimeUtil:GetServerTimeS()
      local lastTimeCur = TimeUtil:SecondsToFormatCNStr3(self.m_iTimeTick)
      self.m_end_time_Text.text = string.gsubnumberreplace(EndTimeStr, lastTimeCur)
    else
      self.m_iTimeTick = nil
      UILuaHelper.SetActive(self.m_end_time, false)
    end
  end
end

function HeroTrialActivitySubPanel:GeneratedRoleCardData()
  local data = {}
  for _, v in pairs(self.m_levelData) do
    data[#data + 1] = {
      selectIndex = self.m_curChooseIndex,
      isFinish = v.IsFinish,
      iShowRed = v.RedShow,
      iShowHourglass = v.EndTime and v.EndTime ~= 0,
      headPath = v.HeroCfg.m_ItemIcon:gsub(".$", "3")
    }
    if self.m_curChooseIndex == #data then
      self:SetLevelClicked()
      data[#data].iShowRed = false
    end
  end
  return data
end

function HeroTrialActivitySubPanel:GeneratedRewardData()
  local chooseLevelData = self.m_levelData[self.m_curChooseIndex]
  if chooseLevelData and chooseLevelData.FirstRewards then
    local data = {}
    for _, v in pairs(chooseLevelData.FirstRewards) do
      data[#data + 1] = {
        rewardData = v,
        isHaveGet = chooseLevelData.IsFinish
      }
    end
    return data
  end
  return nil
end

function HeroTrialActivitySubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_HeroTrialUpdate", handler(self, self.OnEventHeroTrialUpdate))
end

function HeroTrialActivitySubPanel:OnEventHeroTrialUpdate(iActivityId)
  if iActivityId == self.m_stActivity:getID() then
    self:FreshLevelData()
    self:ReFreshUI()
    self.m_parentLua:RefreshTableButtonList()
  end
end

function HeroTrialActivitySubPanel:OnBtnsearchClicked()
  local chooseLevelData = self.m_levelData[self.m_curChooseIndex]
  if chooseLevelData and chooseLevelData.HeroCfg then
    StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
      heroID = chooseLevelData.HeroCfg.m_HeroID
    })
  end
end

function HeroTrialActivitySubPanel:OnBtnuseClicked()
  local chooseLevelData = self.m_levelData[self.m_curChooseIndex]
  if chooseLevelData then
    BattleFlowManager:StartEnterBattle(BattleType, chooseLevelData.LevelID, true, tonumber(self.m_stActivity:getID()))
  end
end

function HeroTrialActivitySubPanel:LoadHeroSpine(prefabName)
  if not prefabName then
    return
  end
  self:CheckRecycleSpine()
  local typeStr = SpinePlaceCfg.ActivityHeroTrial
  self.m_HeroSpineDynamicLoader:LoadHeroSpine(prefabName, typeStr, self.m_player_root, function(spineLoadObj)
    self:CheckRecycleSpine()
    self.m_curHeroSpineObj = spineLoadObj
    UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
    local spineObj = spineLoadObj.spineObj
    UILuaHelper.SetSpineTimeScale(spineObj, 1)
    self:CheckShowSpineAnim()
  end)
end

function HeroTrialActivitySubPanel:CheckShowSpineAnim()
  if not self.m_curHeroSpineObj then
    return
  end
  local heroSpineObj = self.m_curHeroSpineObj.spineObj
  if utils.isNull(heroSpineObj) then
    log.error("Form_HeroShow CheckShowSpineAnim is error ")
    return
  end
  if UILuaHelper.CheckIsHaveSpineAnim(heroSpineObj, "idle2") then
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle2", true)
  else
    UILuaHelper.SpinePlayAnim(heroSpineObj, 0, "idle", true)
  end
  UILuaHelper.PlayAnimationByName(self.m_player_root, CardSelect1)
end

function HeroTrialActivitySubPanel:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function HeroTrialActivitySubPanel:GetDownloadResourceExtra(param)
  local vPackage = {}
  local vResourceExtra = {}
  local heroCfgList = {}
  local actCur
  local activityList = ActivityManager:GetActivityListByType(MTTD.ActivityType_HeroTrial)
  for _, act in pairs(activityList) do
    if act:getSubPanelName() == ActivityManager.ActivitySubPanelName.ActivitySPName_HeroTrialActivity then
      actCur = act
      break
    end
  end
  if not actCur then
    return
  end
  local levelData = actCur:GetOpenLevelData()
  for _, v in pairs(levelData) do
    heroCfgList[#heroCfgList + 1] = v
  end
  for i, v in pairs(heroCfgList) do
    local spineStr = v.HeroCfg.m_Spine
    if spineStr then
      vResourceExtra[#vResourceExtra + 1] = {
        sName = spineStr,
        eType = DownloadManager.ResourceType.UI
      }
    end
  end
  return vPackage, vResourceExtra
end

function HeroTrialActivitySubPanel:OnDestroy()
  HeroTrialActivitySubPanel.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
  self.m_roleCardLoopScrollView:dispose()
  self.m_rewardLoopScrollView:dispose()
end

return HeroTrialActivitySubPanel
