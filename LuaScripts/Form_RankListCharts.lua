local Form_RankListCharts = class("Form_RankListCharts", require("UI/UIFrames/Form_RankListChartsUI"))
local TeamMaxNum = 5

function Form_RankListCharts:SetInitParam(param)
end

function Form_RankListCharts:AfterInit()
  self.super.AfterInit(self)
  local goBackBtnRoot = self.m_csui.m_uiGameObject.transform:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1164)
  local initGiftGridData1 = {
    itemClkBackFun = handler(self, self.OnTabClk)
  }
  self.m_left_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_left_InfinityGrid, "RankList/UIRankTabItem", initGiftGridData1)
  local initGiftGridData2 = {
    itemClkBackFun = handler(self, self.OnRankItemClk)
  }
  self.m_RankList_InfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "RankList/UIRankListItem", initGiftGridData2)
  self.allRankInfoCfg = GlobalRankManager:GetAllRankInfoConfig()
  self.m_DoubleTrigger = self.m_btn_closeTips:GetComponent("ButtonTriggerDouble")
  if self.m_DoubleTrigger then
    self.m_DoubleTrigger.Clicked = handler(self, self.OnBtncloseTipsClicked)
  end
  self.FreshRecord = {}
  self.mRankListCache = {}
end

function Form_RankListCharts:OnActive()
  self.super.OnActive(self)
  self.curVHero = {}
  self:AddEventListeners()
  self:InitData()
  self.m_bg_tips:SetActive(false)
  self.lastReportTime = TimeUtil:GetServerTimeS()
end

function Form_RankListCharts:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:SendReport()
end

function Form_RankListCharts:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RankListCharts:AddEventListeners()
  self:addEventListener("eGameEvent_RankGetRank", handler(self, self.RefreshRankList))
  self:addEventListener("eGameEvent_RankGetRole", handler(self, self.RefreshRightTeamInfo))
end

function Form_RankListCharts:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_RankListCharts:InitData()
  local param = self.m_csui.m_param or {}
  self.m_CurSelectRankID = param.rankID or self.m_CurSelectRankID
  self:RefreshUI()
  self:RqsRankListData()
end

function Form_RankListCharts:RqsRankListData()
  local time = self.FreshRecord[self.m_CurSelectRankID] or 0
  local cur_time = TimeUtil:GetServerTimeS()
  if 30 <= cur_time - time then
    GlobalRankManager:RqsGetRankByiRankType(self.m_CurSelectRankID)
    self.FreshRecord[self.m_CurSelectRankID] = TimeUtil:GetServerTimeS()
  else
    self:RefreshRankList(self.mRankListCache[self.m_CurSelectRankID])
  end
end

function Form_RankListCharts:RefreshRankList(data)
  self.mRankListCache[self.m_CurSelectRankID] = data
  self.iSelfValue = data.iSelfValue
  self.curSelectRankIdx = 1
  self:RegisterOrUpdateRedDotItem(self.m_reddot, RedDotDefine.ModuleType.GlobalRankTab, {
    self.m_CurSelectRankID
  })
  local vRankRole = data.vRankRole
  if not vRankRole or #vRankRole <= 0 then
    self.m_scrollView:SetActive(false)
    self.m_pnl_right:SetActive(false)
    self.m_img_rank_item_mine:SetActive(false)
    self.m_empty:SetActive(true)
    local rankInfoCfg = self.allRankInfoCfg[self.curSelectIdx]
    self.m_txt_empty_Text.text = rankInfoCfg.m_mGetOnText
    return
  end
  self.m_img_rank_item_mine:SetActive(true)
  self.m_scrollView:SetActive(true)
  self.m_pnl_right:SetActive(true)
  self.m_empty:SetActive(false)
  local myRankInfo
  for i, v in ipairs(vRankRole) do
    if self.curSelectRankIdx == i then
      v.isSelect = true
    end
    if v.iRoleUid == RoleManager:GetUID() then
      myRankInfo = v
    end
    v.RankID = self.m_CurSelectRankID
  end
  self.rankData = vRankRole
  self.m_RankList_InfinityGrid:ShowItemList(vRankRole)
  self.m_RankList_InfinityGrid:LocateTo(0)
  local list = self.m_RankList_InfinityGrid:GetAllShownItemList()
  for k, v in ipairs(list) do
    v:RefreshItemFx((k - 1) * 0.1)
  end
  self:RefreshRightInfo()
  self:RefreshMyRankInfo(myRankInfo)
end

function Form_RankListCharts:RefreshMyRankInfo(myRankInfo)
  local playerHeadCom = self:createPlayerHead(self.m_circle_head)
  local valueType = GlobalRankManager.RankType2RankValueType[self.m_CurSelectRankID]
  if valueType == GlobalRankManager.RankValueType.MainLevel or valueType == GlobalRankManager.RankValueType.Tower then
    self.m_icon_achievement_mine:SetActive(true)
    self.m_icon_point_mine:SetActive(false)
  else
    self.m_icon_achievement_mine:SetActive(false)
    self.m_icon_point_mine:SetActive(true)
  end
  if myRankInfo then
    local rank = myRankInfo.iRank
    self.m_icon_rank1_mine:SetActive(rank == 1)
    self.m_icon_rank2_mine:SetActive(rank == 2)
    self.m_icon_rank3_mine:SetActive(rank == 3)
    self.m_icon_rank4_mine:SetActive(4 <= rank)
    self.m_z_txt_rank_st1own:SetActive(rank == 1)
    self.m_z_txt_rank_rd2own:SetActive(rank == 2)
    self.m_z_txt_rank_nd3own:SetActive(rank == 3)
    self.m_icon_rank5_mine:SetActive(false)
    self.m_z_txt_norank:SetActive(false)
    self.m_txt_rank_mine:SetActive(true)
    if rank == 1 then
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.first
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.first
    elseif rank == 2 then
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.second
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.second
    elseif rank == 3 then
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.third
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.third
    else
      self.m_txt_rank_mine_Text.color = RankManager.ColorEnum.normal
    end
    self.m_img_bg_titelown:SetActive(rank <= 3)
    self.m_txt_rank_mine_Text.text = rank
    if valueType == GlobalRankManager.RankValueType.MainLevel then
      local level_id = myRankInfo.iRankValue
      local MainLevelIns = ConfigManager:GetConfigInsByName("MainLevel")
      local levelCfg = MainLevelIns:GetValue_ByLevelID(level_id)
      if levelCfg:GetError() then
        return
      end
      self.m_txt_achievement_mine_Text.text = levelCfg.m_LevelName
    elseif valueType == GlobalRankManager.RankValueType.FactionDevelopment then
      self.m_txt_achievement_mine_Text.text = myRankInfo.iRankValue
    elseif valueType == GlobalRankManager.RankValueType.Tower then
      self.m_txt_achievement_mine_Text.text = LevelManager:GetLevelName(LevelManager.LevelType.Tower, myRankInfo.iRankValue)
    end
    myRankInfo.stRoleId = {
      iUid = myRankInfo.iRoleUid,
      iZoneId = myRankInfo.iZoneId
    }
    playerHeadCom:SetPlayerHeadInfo(myRankInfo)
  else
    self.m_icon_rank1_mine:SetActive(false)
    self.m_icon_rank2_mine:SetActive(false)
    self.m_icon_rank3_mine:SetActive(false)
    self.m_icon_rank4_mine:SetActive(false)
    self.m_icon_rank5_mine:SetActive(true)
    self.m_z_txt_norank:SetActive(true)
    self.m_txt_rank_mine:SetActive(false)
    self.m_img_bg_titelown:SetActive(false)
    myRankInfo = {
      iHeadId = RoleManager:GetHeadID(),
      iHeadFrameId = RoleManager:GetHeadFrameID(),
      iLevel = RoleManager:GetLevel(),
      stRoleId = {
        iUid = RoleManager:GetUID(),
        iZoneId = UserDataManager:GetZoneID()
      }
    }
    local rankInfoCfg = self.allRankInfoCfg[self.curSelectIdx]
    if valueType == GlobalRankManager.RankValueType.MainLevel then
      local m_GetOn = rankInfoCfg.m_GetOn
      local unlock = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, m_GetOn)
      local manager = LevelManager:GetLevelHelperByType(LevelManager.LevelType.MainLevel)
      local levelId = manager:GetLastPassLevelIDBySubType(LevelManager.MainLevelSubType.HardLevel)
      if levelId and levelId ~= 0 then
        local levelCfg = LevelManager:GetMainLevelCfgById(levelId)
        self.m_txt_achievement_mine_Text.text = levelCfg.m_LevelName
      else
        self.m_txt_achievement_mine_Text.text = ConfigManager:GetCommonTextById(100415)
      end
    elseif valueType == GlobalRankManager.RankValueType.FactionDevelopment then
      if self.iSelfValue and self.iSelfValue == 0 then
        self.m_txt_achievement_mine_Text.text = self.iSelfValue
      else
        self.m_txt_achievement_mine_Text.text = self.iSelfValue
      end
    elseif valueType == GlobalRankManager.RankValueType.Tower then
      local m_GetOn = rankInfoCfg.m_GetOn
      local manager = LevelManager:GetLevelHelperByType(LevelManager.LevelType.Tower)
      local subType
      if self.m_CurSelectRankID == MTTDProto.CmdRankType_TowerStageMain then
        subType = MTTDProto.FightTowerSubType_Main
      elseif self.m_CurSelectRankID == MTTDProto.CmdRankType_TowerStageTribe1 then
        subType = MTTDProto.FightTowerSubType_Tribe1
      elseif self.m_CurSelectRankID == MTTDProto.CmdRankType_TowerStageTribe2 then
        subType = MTTDProto.FightTowerSubType_Tribe2
      elseif self.m_CurSelectRankID == MTTDProto.CmdRankType_TowerStageTribe3 then
        subType = MTTDProto.FightTowerSubType_Tribe3
      elseif self.m_CurSelectRankID == MTTDProto.CmdRankType_TowerStageTribe4 then
        subType = MTTDProto.FightTowerSubType_Tribe4
      end
      local unlock = manager:IsLevelHavePass(m_GetOn)
      local levelId = manager:GetLastPassLevelIDBySubType(subType)
      if levelId and levelId ~= 0 then
        self.m_txt_achievement_mine_Text.text = LevelManager:GetLevelName(LevelManager.LevelType.Tower, levelId)
      else
        self.m_txt_achievement_mine_Text.text = ConfigManager:GetCommonTextById(100415)
      end
    end
  end
  self.m_txt_name_mine_Text.text = RoleManager:GetName()
  self.m_txt_guild_name_mine_Text.text = RoleManager:GetAllianceName()
  playerHeadCom:SetPlayerHeadInfo(myRankInfo)
end

function Form_RankListCharts:RefreshUI()
  self.tab_list = {}
  for i, cfg in ipairs(self.allRankInfoCfg) do
    local is_selected = cfg.m_RankID == self.m_CurSelectRankID
    self.tab_list[i] = {isSelect = is_selected, cfg = cfg}
    if is_selected then
      self.curSelectIdx = i
    end
  end
  self.m_left_InfinityGrid:ShowItemList(self.tab_list)
  self.m_left_InfinityGrid:LocateTo(self.curSelectIdx - 1)
end

function Form_RankListCharts:RefreshRightInfo()
  local data = self.rankData[self.curSelectRankIdx]
  local rank = data.iRank
  self.m_txt_right_name_Text.text = data.sName
  self.m_txt_right_guild_Text.text = data.sAllianceName ~= "" and data.sAllianceName or ConfigManager:GetCommonTextById(20111) or ""
  self.m_txt_teambattle_Text.text = ""
  if rank <= 3 then
    self.m_pnlrankingall:SetActive(true)
    self.m_pnl_txtrankother:SetActive(false)
    self.m_bgrank1:SetActive(rank == 1)
    self.m_bgrank2:SetActive(rank == 2)
    self.m_bgrank3:SetActive(rank == 3)
    self.m_txt_ranknum_Text.text = rank
  else
    self.m_pnlrankingall:SetActive(false)
    self.m_pnl_txtrankother:SetActive(true)
    self.m_txt_ranknumother_Text.text = rank
  end
  local rankInfoCfg = self.allRankInfoCfg[self.curSelectIdx]
  self.m_txt_info_Text.text = rankInfoCfg.m_mPowerText
  self.m_txt_title_Text.text = rankInfoCfg.m_mTitleText
  local valueType = GlobalRankManager.RankType2RankValueType[self.m_CurSelectRankID]
  if valueType == GlobalRankManager.RankValueType.FactionDevelopment then
    self.m_txt_teambattle_Text.text = data.iRankValue
    self.m_icon_power_right:SetActive(false)
    self.m_icon_point_right:SetActive(true)
  end
  GlobalRankManager:RqsRankGetRole(self.m_CurSelectRankID, data.iRoleUid)
end

function Form_RankListCharts:RefreshRightTeamInfo(data)
  local valueType = GlobalRankManager.RankType2RankValueType[self.m_CurSelectRankID]
  if valueType == GlobalRankManager.RankValueType.MainLevel or valueType == GlobalRankManager.RankValueType.Tower then
    self.m_txt_teambattle_Text.text = data.iPower or 0
    self.m_icon_power_right:SetActive(true)
    self.m_icon_point_right:SetActive(false)
  end
  local vHero = data.vHero
  self.curVHero = vHero
  for i = 1, TeamMaxNum do
    local heroData = vHero[i]
    if heroData then
      local hero_ID = heroData.iHeroId
      self["m_img_head" .. i]:SetActive(true)
      ResourceUtil:CreatHeroBust(self["m_img_head" .. i .. "_Image"], hero_ID)
    else
      self["m_img_head" .. i]:SetActive(false)
    end
  end
end

function Form_RankListCharts:OnRankItemClk(index, go)
  local idx = index + 1
  if self.curSelectRankIdx == idx then
    return
  end
  self.rankData[self.curSelectRankIdx].isSelect = false
  self.m_RankList_InfinityGrid:ReBind(self.curSelectRankIdx)
  self.rankData[idx].isSelect = true
  self.m_RankList_InfinityGrid:ReBind(idx)
  self.curSelectRankIdx = idx
  self:RefreshRightInfo()
end

function Form_RankListCharts:OnTabClk(index, go)
  local idx = index + 1
  if self.curSelectIdx == idx then
    return
  end
  local cfg = self.allRankInfoCfg[idx]
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(cfg.m_SystemID)
  if not openFlag then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  self:SendReport()
  self.tab_list[self.curSelectIdx].isSelect = false
  self.m_left_InfinityGrid:ReBind(self.curSelectIdx)
  local cfg = self.allRankInfoCfg[idx]
  self.curSelectIdx = idx
  self.m_CurSelectRankID = cfg.m_RankID
  self.tab_list[idx].isSelect = true
  self.m_left_InfinityGrid:ReBind(idx)
  self:RqsRankListData()
end

function Form_RankListCharts:OnBtnTargetClicked()
  StackFlow:Push(UIDefines.ID_FORM_RANKLISTGIFT, {
    rankID = self.m_CurSelectRankID
  })
end

function Form_RankListCharts:OnImgpic1Clicked()
  self:ClickShowHeroInfo(1)
end

function Form_RankListCharts:OnImgpic2Clicked()
  self:ClickShowHeroInfo(2)
end

function Form_RankListCharts:OnImgpic3Clicked()
  self:ClickShowHeroInfo(3)
end

function Form_RankListCharts:OnImgpic4Clicked()
  self:ClickShowHeroInfo(4)
end

function Form_RankListCharts:OnImgpic5Clicked()
  self:ClickShowHeroInfo(5)
end

function Form_RankListCharts:ClickShowHeroInfo(idx)
  local heroData = self.curVHero[idx]
  if heroData then
    local hero_ID = heroData.iHeroId
    StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = hero_ID})
  end
end

function Form_RankListCharts:OnBtnrankruleClicked()
  self.m_bg_tips:SetActive(true)
  local rankInfoCfg = self.allRankInfoCfg[self.curSelectIdx]
  self.m_txt_des_Text.text = rankInfoCfg.m_mGetOnText
end

function Form_RankListCharts:OnBtncloseTipsClicked()
  self.m_bg_tips:SetActive(false)
end

function Form_RankListCharts:OnBackClk()
  self:CloseForm()
end

function Form_RankListCharts:SendReport()
  local stayTime = TimeUtil:GetServerTimeS() - self.lastReportTime
  if 5 <= stayTime then
    RankManager:SendRankReport(self.m_CurSelectRankID, RankManager.RankPanelReportType.RankList, stayTime)
  end
  self.lastReportTime = TimeUtil:GetServerTimeS()
end

function Form_RankListCharts:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RankListCharts", Form_RankListCharts)
return Form_RankListCharts
