local Form_HallActivity = class("Form_HallActivity", require("UI/UIFrames/Form_HallActivityUI"))
local DefaultToggleIndex = 1
local ArenaToggleIndex = 2

function Form_HallActivity:SetInitParam(param)
end

function Form_HallActivity:AfterInit()
  self.super.AfterInit(self)
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  self.m_widgetTaskEnter = self:createTaskBar(self.m_common_task_enter)
  self.m_PvPEnterSubPanelCom = nil
  self.m_PvpReplaceSubPanelCom = nil
  self.m_curToggleIndex = DefaultToggleIndex
  self:CheckRegisterRedDot()
end

function Form_HallActivity:OnActive()
  self.super.OnActive(self)
  local param = self.m_csui.m_param or {}
  local tab = param.tab
  local showIndex = tab and tab or self.m_curToggleIndex
  local isNeedReqArena = param.isNeedReqArena
  self.m_csui.m_param = nil
  if isNeedReqArena then
    self:ClearArenaReqStatus()
  end
  self:FreshChangeToggle(showIndex)
  self:AddEventListeners()
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base3, RedDotDefine.ModuleType.GlobalRankEntry)
end

function Form_HallActivity:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_HallActivity:OnUpdate(dt)
  if self.m_PvPEnterSubPanelCom then
    self.m_PvPEnterSubPanelCom:Update()
  end
  if self.m_PvpReplaceSubPanelCom then
    self.m_PvpReplaceSubPanelCom:Update()
  end
end

function Form_HallActivity:AddEventListeners()
  self:addEventListener("eGameEvent_RankGetList", handler(self, self.OnEventRankGetList))
end

function Form_HallActivity:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HallActivity:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_img_RedDot_Base2, RedDotDefine.ModuleType.LevelEntry, BattleFlowManager.ArenaType.Arena)
end

function Form_HallActivity:RefreshHallActivityList()
  local HallEventIns = ConfigManager:GetConfigInsByName("HallEvent")
  local activityInfoAll = HallEventIns:GetAll()
  self.m_img_RedDot_Base:SetActive(false)
  for i, v in pairs(activityInfoAll) do
    local cfg = UnlockSystemUtil:GetSystemUnlockConfig(v.m_SystemID)
    local redPoint = ActivityManager:CheckHallActivityHaveRedPointBySystemID(v.m_SystemID) or 0
    if not cfg:GetError() then
      if v.m_Tab == self.m_curToggleIndex then
        self:RefreshActiveLockUI(v.m_SystemID)
      end
      self:ShowRedPoint(v.m_SystemID, redPoint)
    end
  end
end

function Form_HallActivity:ShowRedPoint(systemID, redPoint)
  local showFlag1 = 0 < redPoint
  if systemID == GlobalConfig.SYSTEM_ID.Dungeon then
    self.m_redpoint_boss:SetActive(showFlag1)
  elseif systemID == GlobalConfig.SYSTEM_ID.Tower then
    if showFlag1 then
      local nextShowRedTime = LocalDataManager:GetIntSimple("TowerEnterRed", 0)
      if nextShowRedTime == 0 or nextShowRedTime < TimeUtil:GetServerTimeS() then
        self.m_redpoint_tower:SetActive(true)
      else
        self.m_redpoint_tower:SetActive(false)
      end
    else
      self.m_redpoint_tower:SetActive(false)
    end
  elseif systemID == GlobalConfig.SYSTEM_ID.Goblin then
    self.m_redpoint_material:SetActive(showFlag1)
  elseif systemID == GlobalConfig.SYSTEM_ID.LegacyLevel then
    self.m_redpoint_legacy:SetActive(showFlag1)
  end
  if showFlag1 then
    self.m_img_RedDot_Base:SetActive(true)
  end
end

function Form_HallActivity:RefreshActiveLockUI(systemID)
  local isOpen = UnlockSystemUtil:IsSystemOpen(systemID)
  if systemID == GlobalConfig.SYSTEM_ID.Dungeon then
    self.m_pnl_boss_lock:SetActive(not isOpen)
  elseif systemID == GlobalConfig.SYSTEM_ID.Tower then
    self.m_pnl_tower_lock:SetActive(not isOpen)
  elseif systemID == GlobalConfig.SYSTEM_ID.Goblin then
    self.m_pnl_material_lock:SetActive(not isOpen)
  elseif systemID == GlobalConfig.SYSTEM_ID.LegacyLevel then
    self.m_pnl_legacy_lock:SetActive(not isOpen)
  end
end

function Form_HallActivity:ShowActivityEntry(systemID, isShow)
  if systemID == GlobalConfig.SYSTEM_ID.Dungeon then
    self.m_pnl_boss:SetActive(isShow == 1)
  elseif systemID == GlobalConfig.SYSTEM_ID.Tower then
    self.m_pnl_tower:SetActive(isShow == 1)
  elseif systemID == GlobalConfig.SYSTEM_ID.Goblin then
    self.m_pnl_material:SetActive(isShow == 1)
  elseif systemID == GlobalConfig.SYSTEM_ID.LegacyLevel then
    self.m_pnl_legacy:SetActive(isShow == 1)
  end
end

function Form_HallActivity:FreshChangeToggle(toggleIndex)
  if toggleIndex then
    for i = 1, 2 do
      UILuaHelper.SetActive(self["m_scrollview" .. i], i == toggleIndex)
      UILuaHelper.SetActive(self["m_tab_select" .. i], i == toggleIndex)
      UILuaHelper.SetActive(self["m_tab_unselect" .. i], i ~= toggleIndex)
    end
  end
  self.m_curToggleIndex = toggleIndex
  if toggleIndex == ArenaToggleIndex then
    if self.m_PvPEnterSubPanelCom == nil then
      self.m_PvPEnterSubPanelCom = self:CreateSubPanel("PvPEnterSubPanel", self.m_Btn_Card_PvP, self, nil, nil, nil)
    end
    if self.m_PvpReplaceSubPanelCom == nil then
      self.m_PvpReplaceSubPanelCom = self:CreateSubPanel("PvPReplaceSubPanel", self.m_PvP_Replace_Node, self, nil, nil, nil)
    end
    self:CheckReqArenaSeason()
  end
  self:RefreshHallActivityList()
end

function Form_HallActivity:ClearArenaReqStatus()
  if self.m_PvPEnterSubPanelCom then
    self.m_PvPEnterSubPanelCom:ClearArenaReqStatus()
  end
  if self.m_PvpReplaceSubPanelCom then
    self.m_PvpReplaceSubPanelCom:ClearFreshStatus()
  end
end

function Form_HallActivity:CheckReqArenaSeason()
  if self.m_PvPEnterSubPanelCom then
    self.m_PvPEnterSubPanelCom:CheckReqArenaSeason()
  end
  if self.m_PvpReplaceSubPanelCom then
    self.m_PvpReplaceSubPanelCom:CheckFreshArena()
  end
end

function Form_HallActivity:OnPnlbossClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Dungeon)
end

function Form_HallActivity:OnPnltowerClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Tower)
  LocalDataManager:SetIntSimple("TowerEnterRed", TimeUtil:GetServerNextCommonResetTime())
end

function Form_HallActivity:OnPnlmaterialClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.Goblin)
end

function Form_HallActivity:OnPnllegacyClicked()
  self:GotoSystem(GlobalConfig.SYSTEM_ID.LegacyLevel)
end

function Form_HallActivity:GotoSystem(systemId)
  local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(systemId)
  if isOpen then
    local cfg = ActivityManager:GetHallEventCfgBySystemId(systemId)
    if cfg.m_Jump then
      QuickOpenFuncUtil:OpenFunc(cfg.m_Jump)
    end
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
end

function Form_HallActivity:OnBackHome()
  ArenaManager:ClearCacheMineSeasonInfo()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
end

function Form_HallActivity:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  ArenaManager:ClearCacheMineSeasonInfo()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
end

function Form_HallActivity:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_HallActivity:OnBtnToggle1Clicked()
  self:FreshChangeToggle(1)
end

function Form_HallActivity:OnBtnToggle2Clicked()
  self:FreshChangeToggle(2)
end

function Form_HallActivity:OnBtnranklistClicked()
  local time = self.iLastRqsTime or 0
  local cur_time = TimeUtil:GetServerTimeS()
  if 30 <= cur_time - time then
    GlobalRankManager:RqsRankGetList()
    self.iLastRqsTime = TimeUtil:GetServerTimeS()
  else
    StackFlow:Push(UIDefines.ID_FORM_RANKLISTMAIN)
  end
end

function Form_HallActivity:OnEventRankGetList()
  StackFlow:Push(UIDefines.ID_FORM_RANKLISTMAIN)
end

function Form_HallActivity:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_HallActivity", Form_HallActivity)
return Form_HallActivity
