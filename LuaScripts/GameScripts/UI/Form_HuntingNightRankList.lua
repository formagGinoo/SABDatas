local Form_HuntingNightRankList = class("Form_HuntingNightRankList", require("UI/UIFrames/Form_HuntingNightRankListUI"))
local __TAB_NUM = 3
local __TAB = {
  Rank = 1,
  Reward = 2,
  Regulation = 3
}
local NEW_RANK_PAGE_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("HuntingRaidRankPagecnt")) or 0
local NEW_RANK_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("HuntingRaidRanklist")) or 0

function Form_HuntingNightRankList:SetInitParam(param)
end

function Form_HuntingNightRankList:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnTabItemClk)
  }
  self.m_scrollView_tab = self:CreateInfinityGrid(self.m_pnl_left_InfinityGrid, "HuntingRaid/UIHuntingRaidRankTabItem", initGridData)
  self.m_scrollView_tab:RegisterButtonCallback("c_pnl_itemrank", handler(self, self.OnTabItemClk))
end

function Form_HuntingNightRankList:OnActive()
  self.super.OnActive(self)
  self.m_load_end = false
  self.m_changeRankTab = true
  self.m_selTabIndex = 1
  self.m_selRankTabIndex = 0
  self.m_PlayerHeadCache = {}
  self.m_myRewardCommonItemList = {}
  self.m_ruleDataList = self:GenerateRuleData()
  self.m_rewardDataList = self:GenerateRewardData()
  self.m_rankTabList, self.m_rankTab = self:GenerateRankTabData()
  self.m_activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  local tParam = self.m_csui.m_param
  if tParam and tParam.bossId then
    self.m_selRankTabIndex = self:GetStageOpenIndex(tParam.bossId)
    if self.m_rankTabList[self.m_selRankTabIndex] then
      self.m_rankTabList[self.m_selRankTabIndex].isSelect = true
    end
  end
  self.m_RankDataList = HuntingRaidManager:GetTotalRankListData()
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_HuntingNightRankList:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_PlayerHeadCache = {}
  self.m_myRewardCommonItemList = {}
  self.m_load_end = false
  self.m_changeRankTab = nil
end

function Form_HuntingNightRankList:AddEventListeners()
  self:addEventListener("eGameEvent_UpDataRankList", handler(self, self.OnBossRankReqCB))
end

function Form_HuntingNightRankList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_HuntingNightRankList:GetStageOpenIndex(bossId)
  for i, v in ipairs(self.m_rankTabList) do
    if v.iBossId == bossId then
      local showTime = self.m_activity:CheckBossInShowAndChallengeTime(bossId)
      if showTime ~= 0 then
        return i
      end
    end
  end
  return 0
end

function Form_HuntingNightRankList:RefreshUI()
  self:RefreshTabUI()
  if self.m_selTabIndex == __TAB.Regulation then
    self.m_txt_rankrule_title_Text.text = ConfigManager:GetCommonTextById(20335)
    self:refreshRuleLoopScroll()
  elseif self.m_selTabIndex == __TAB.Reward then
    self.m_txt_rankreward_title_Text.text = ConfigManager:GetCommonTextById(20334)
    self:refreshRewardLoopScroll()
    self:RefreshOwnerRankRewardInfo()
  elseif self.m_selTabIndex == __TAB.Rank then
    self.m_scrollView_tab:ShowItemList(self.m_rankTabList)
    self.m_scrollView_tab:LocateTo(0)
    self:RefreshRankTabUI()
  end
end

function Form_HuntingNightRankList:RefreshTabUI()
  for i = 1, __TAB_NUM do
    UILuaHelper.SetActive(self["m_img_sel" .. i], self.m_selTabIndex == i)
    UILuaHelper.SetActive(self["m_z_txt_nml" .. i], self.m_selTabIndex ~= i)
  end
  UILuaHelper.SetActive(self.m_pnl_ranklist, self.m_selTabIndex == __TAB.Rank)
  UILuaHelper.SetActive(self.m_pnl_rewardlist, self.m_selTabIndex == __TAB.Reward)
  UILuaHelper.SetActive(self.m_pnl_rulelist, self.m_selTabIndex == __TAB.Regulation)
end

function Form_HuntingNightRankList:GenerateRankTabData()
  local dataTab = {}
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_Hunting)
  if not activity then
    return dataTab
  end
  local bossList = activity:GetHuntingRaidBossList()
  local bossTab = {}
  for i, v in ipairs(bossList) do
    local cfg = HuntingRaidManager:GetHuntingRaidBossCfgById(v.iBossId) or {}
    dataTab[#dataTab + 1] = {
      iBossId = v.iBossId,
      title = cfg.m_mName,
      index = i,
      title1 = cfg.m_mTitle1
    }
    bossTab[v.iBossId] = {
      iBossId = v.iBossId,
      title = cfg.m_mName,
      index = i,
      title1 = cfg.m_mTitle1
    }
  end
  return dataTab, bossTab
end

function Form_HuntingNightRankList:RefreshRankTabUI()
  UILuaHelper.SetActive(self.m_tab_ranksel, self.m_selRankTabIndex == 0)
  UILuaHelper.SetActive(self.m_tab_ranknor, self.m_selRankTabIndex ~= 0)
  local title = self.m_selRankTabIndex == 0 and ConfigManager:GetCommonTextById(20345) or ConfigManager:GetCommonTextById(20346)
  self.m_txt_title_Text.text = title
  if self.m_selRankTabIndex == 0 then
    self.m_RankDataList = HuntingRaidManager:GetTotalRankListData()
    if 0 < table.getn(self.m_RankDataList) then
      UILuaHelper.SetActive(self.m_rank_empty, false)
      UILuaHelper.SetActive(self.m_scrollViewrank, true)
      self:refreshRankLoopScroll()
      if not utils.isNull(self.m_rank_loop_scroll_view) then
        self.m_rank_loop_scroll_view:moveToCellIndex(1)
      end
    else
      UILuaHelper.SetActive(self.m_rank_empty, true)
      UILuaHelper.SetActive(self.m_scrollViewrank, false)
    end
    self:RefreshOwnerRankInfo()
  elseif self.m_rankTabList and self.m_rankTabList[self.m_selRankTabIndex] then
    local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
    RankManager:ReqArenaRankListCS(RankManager.RankType.HuntingRaid, 1, NEW_RANK_PAGE_CNT, bossId)
    if self.m_rankTab and self.m_rankTab[bossId] then
      self.m_txt_power_Text.text = self.m_rankTab[bossId].title1
    end
  end
  UILuaHelper.SetActive(self.m_z_txt_totalpoints, self.m_selRankTabIndex == 0)
  UILuaHelper.SetActive(self.m_txt_power, self.m_selRankTabIndex ~= 0)
  UILuaHelper.SetActive(self.m_z_txt_levelpoints, self.m_selRankTabIndex ~= 0)
end

function Form_HuntingNightRankList:OnBossRankReqCB()
  if not self or utils.isNull(self.m_scrollViewrank) then
    return
  end
  self.m_load_end = true
  if self.m_rankTabList and self.m_rankTabList[self.m_selRankTabIndex] then
    local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
    self.m_RankDataList = RankManager:GetRankDataListBySystemIdAndRankKey(RankManager.RankType.HuntingRaid, bossId)
    if table.getn(self.m_RankDataList) > 0 then
      UILuaHelper.SetActive(self.m_rank_empty, false)
      UILuaHelper.SetActive(self.m_scrollViewrank, true)
      self:refreshRankLoopScroll()
      if not utils.isNull(self.m_scrollViewrank) and self.m_changeRankTab then
        self.m_rank_loop_scroll_view:moveToCellIndex(1)
        self.m_changeRankTab = nil
        UILuaHelper.PlayAnimationByName(self.m_scrollViewrank, "pnl_huntingnight_ranklist_in2")
      end
    else
      UILuaHelper.SetActive(self.m_rank_empty, true)
      UILuaHelper.SetActive(self.m_scrollViewrank, false)
    end
    self:RefreshOwnerRankInfo()
  else
    log.error("OnBossRankReqCB is error !!!")
  end
end

function Form_HuntingNightRankList:refreshRankLoopScroll()
  local data = self.m_RankDataList
  if self.m_rank_loop_scroll_view == nil then
    local loopScroll = self.m_scrollViewrank
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateRankScrollViewCell(index, cell_object, cell_data)
      end,
      pull_refresh = function()
        if self.m_rankTabList and self.m_selRankTabIndex and self.m_selRankTabIndex ~= HuntingRaidManager.RankType.All then
          self.last_offsety = self.m_rank_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
          local count = NEW_RANK_PAGE_CNT
          local curCount = table.getn(self.m_RankDataList)
          if curCount < NEW_RANK_CNT then
            count = math.min(NEW_RANK_CNT - curCount, NEW_RANK_PAGE_CNT)
            if self.m_rankTabList and self.m_rankTabList[self.m_selRankTabIndex] then
              local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
              RankManager:ReqArenaRankListCS(RankManager.RankType.HuntingRaid, curCount + 1, curCount + count, bossId)
            end
          end
        end
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if cell_data.stRoleSimple.stRoleId.iZoneId ~= 0 and cell_data.stRoleSimple.stRoleId.iUid ~= "0" then
          if click_name == "btn_head" then
            StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD, {
              zoneID = cell_data.stRoleSimple.stRoleId.iZoneId,
              otherRoleID = cell_data.stRoleSimple.stRoleId.iUid
            })
          elseif click_name == "m_btn_checklist" and self.m_rankTabList and self.m_rankTabList[self.m_selRankTabIndex] then
            local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
            StackPopup:Push(UIDefines.ID_FORM_HUNTINGNIGHTBATTLEINFO, {
              stTargetId = cell_data.stRoleSimple.stRoleId,
              bossId = bossId
            })
          end
        end
      end
    }
    self.m_rank_loop_scroll_view = LoopScrollViewUtil.new(params)
    self.m_rank_loop_scroll_view:moveToCellIndex(1)
  else
    self.m_rank_loop_scroll_view:reloadData(data)
    if self.m_load_end == true then
      self:PullRefreshListOffset()
    end
  end
end

function Form_HuntingNightRankList:PullRefreshListOffset()
  if self.last_offsety then
    local now_offsety = self.m_rank_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
    local position = (self.last_offsety - now_offsety) / self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_rank_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_load_end = false
  end
end

function Form_HuntingNightRankList:UpdateRankScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_st1", cell_data.iRank == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_rd2", cell_data.iRank == 2)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_nd3", cell_data.iRank == 3)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_battle_rank4", cell_data.iRank > 3)
  for i = 1, 3 do
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_battle_rank" .. i, cell_data.iRank == i)
  end
  local rankBg = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_title")
  if cell_data.iRank == 1 then
    rankBg.color = RankManager.ColorEnum.first
  elseif cell_data.iRank == 2 then
    rankBg.color = RankManager.ColorEnum.second
  elseif cell_data.iRank == 3 then
    rankBg.color = RankManager.ColorEnum.third
  end
  rankBg.gameObject:SetActive(cell_data.iRank <= 3)
  local bg = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_rank")
  bg.color = cell_data.iRank <= 3 and RankManager.ColorEnum.firstbg or RankManager.ColorEnum.normalbg
  local iRankSize = 0
  if self.m_selRankTabIndex ~= 0 then
    local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
    local data = RankManager:GetOwnerRankDataListBySystemIdAndRankKey(RankManager.RankType.HuntingRaid, bossId)
    iRankSize = data.iRankSize
  else
    local data = HuntingRaidManager:GetTotalRankOwnerDate()
    iRankSize = data.iRankSize
  end
  if iRankSize == nil then
    return
  end
  local showRank, point = HuntingRaidManager:GetHuntingRaidRankStrAndPointsByRank(cell_data.iRank, iRankSize)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank", showRank)
  LuaBehaviourUtil.setText(luaBehaviour, "m_txt_name", cell_data.stRoleSimple.sName)
  local guildName = cell_data.stRoleSimple.sAlliance ~= "" and cell_data.stRoleSimple.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
  LuaBehaviourUtil.setText(luaBehaviour, "m_txt_guild_name", guildName)
  if self.m_selRankTabIndex ~= 0 then
    local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
    local damage = HuntingRaidManager:GetBossRealDamageByIdAndServerDamage(bossId, cell_data.iValue)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_damage", damage)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_levelpoints02", point)
  else
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_totalpoints02", cell_data.iValue)
  end
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_totalpoints02", self.m_selRankTabIndex == 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_damage", self.m_selRankTabIndex ~= 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_btn_checklist", self.m_selRankTabIndex ~= 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_line", self.m_selRankTabIndex ~= 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_txt_levelpoints02", self.m_selRankTabIndex ~= 0)
  local c_circle_headTrans = transform:Find("m_img_rank_item/m_circle_head")
  if c_circle_headTrans then
    local headObj = c_circle_headTrans.gameObject
    local gameObjectHashCode = headObj:GetHashCode()
    local tempPlayerHeadCom = self.m_PlayerHeadCache[gameObjectHashCode]
    if not tempPlayerHeadCom then
      tempPlayerHeadCom = self:createPlayerHead(headObj)
      tempPlayerHeadCom:SetStopClkStatus(true)
      self.m_PlayerHeadCache[gameObjectHashCode] = tempPlayerHeadCom
    end
    tempPlayerHeadCom:SetPlayerHeadInfo(cell_data.stRoleSimple)
  end
end

function Form_HuntingNightRankList:RefreshOwnerRankInfo()
  local rank = 0
  local rankSize = 0
  local iMyValue = 0
  if self.m_rankTabList[self.m_selRankTabIndex] and self.m_selRankTabIndex ~= 0 then
    local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
    local data = RankManager:GetOwnerRankDataListBySystemIdAndRankKey(RankManager.RankType.HuntingRaid, bossId)
    rank = data.iMyRank
    rankSize = data.iRankSize
    iMyValue = data.iMyValue
  else
    local data = HuntingRaidManager:GetTotalRankOwnerDate()
    rank = data.iMyRank
    rankSize = data.iRankSize
    iMyValue = data.iMyValue
  end
  local playerHeadCom = self:createPlayerHead(self.m_circle_head)
  playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
  self.m_txt_name_mine_Text.text = tostring(RoleManager:GetName())
  self.m_txt_guild_name_mine_Text.text = RoleManager:GetAllianceName()
  if rank and 0 < rank then
    self.m_icon_rank_mine1:SetActive(rank == 1)
    self.m_icon_rank_mine2:SetActive(rank == 2)
    self.m_icon_rank_mine3:SetActive(rank == 3)
    self.m_icon_rank_mine4:SetActive(3 < rank)
    self.m_icon_rank_mine5:SetActive(false)
    local num, point = HuntingRaidManager:GetHuntingRaidRankStrAndPointsByRank(rank, rankSize)
    if num == 0 or num == "0" then
      self.m_txt_rank_mine_Text.text = ""
    else
      self.m_txt_rank_mine_Text.text = num
    end
    self.m_pnl_ranking_mine:SetActive(true)
    self.m_z_txt_rank_ownst1:SetActive(rank == 1)
    self.m_z_txt_rank_ownnd2:SetActive(rank == 2)
    self.m_z_txt_rank_ownrd3:SetActive(rank == 3)
    if self.m_selRankTabIndex ~= 0 then
      local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
      local damage = HuntingRaidManager:GetBossRealDamageByIdAndServerDamage(bossId, iMyValue)
      self.m_txt_damage_mine_Text.text = damage
      self.m_txt_mine_levelpoints_Text.text = point
    else
      self.m_txt_mine_minepoints_Text.text = iMyValue
    end
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
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.normal
    end
    self.m_img_bg_titelown:SetActive(rank <= 3)
    self.m_z_txt_norank:SetActive(rank == 0)
  else
    self.m_txt_damage_mine_Text.text = ""
    self.m_txt_mine_levelpoints_Text.text = ""
    self.m_txt_mine_minepoints_Text.text = ""
    self.m_txt_rank_mine_Text.text = ""
    self.m_z_txt_norank:SetActive(true)
    self.m_pnl_ranking_mine:SetActive(false)
    self.m_icon_rank_mine1:SetActive(false)
    self.m_icon_rank_mine2:SetActive(false)
    self.m_icon_rank_mine3:SetActive(false)
    self.m_icon_rank_mine4:SetActive(false)
    self.m_icon_rank_mine5:SetActive(true)
  end
  local isShow = self.m_selRankTabIndex ~= 0 and rank and 0 < rank
  UILuaHelper.SetActive(self.m_txt_damage_mine, isShow)
  UILuaHelper.SetActive(self.m_btn_checklistmine, isShow)
  UILuaHelper.SetActive(self.m_img_line02, isShow)
  UILuaHelper.SetActive(self.m_txt_mine_levelpoints, isShow)
  UILuaHelper.SetActive(self.m_txt_mine_minepoints, self.m_selRankTabIndex == 0 and rank and 0 < rank)
end

function Form_HuntingNightRankList:GenerateRewardData()
  local configInstance = ConfigManager:GetConfigInsByName("HuntingRaidReward")
  local rankAllCfg = configInstance:GetAll()
  local ruleDataList = {}
  local ruleData = {}
  local rankNum = false
  local rankPercent = false
  for i, v in pairs(rankAllCfg) do
    ruleDataList[#ruleDataList + 1] = v
  end
  
  local function sortFun(data1, data2)
    return data1.m_ID < data2.m_ID
  end
  
  table.sort(ruleDataList, sortFun)
  for i, v in ipairs(ruleDataList) do
    if v.m_Rank and v.m_Rank.Length > 0 then
      ruleData[#ruleData + 1] = {
        showNumTitle = not rankNum,
        cfg = v
      }
      rankNum = true
    elseif v.m_RankPercent and 0 < v.m_RankPercent.Length then
      ruleData[#ruleData + 1] = {
        showPercentTitle = not rankPercent,
        cfg = v
      }
      rankPercent = true
    end
  end
  return ruleData
end

function Form_HuntingNightRankList:refreshRewardLoopScroll()
  local data = self.m_rewardDataList
  local all_cell_size = {}
  for i, v in ipairs(data or {}) do
    if v.showNumTitle or v.showPercentTitle then
      all_cell_size[i] = Vector2.New(1516, 228)
    else
      all_cell_size[i] = Vector2.New(1516, 115)
    end
  end
  if self.m_reward_loop_scroll_view == nil then
    local loopScroll = self.m_scrollView_reward
    local params = {
      show_data = data,
      one_line_count = 1,
      all_cell_size = all_cell_size,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateRewardScrollViewCell(index, cell_object, cell_data)
      end
    }
    self.m_reward_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_reward_loop_scroll_view:reloadData(data)
  end
end

function Form_HuntingNightRankList:UpdateRewardScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local cfg = cell_data.cfg
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_title", cell_data.showNumTitle or cell_data.showPercentTitle)
  if cell_data.showNumTitle then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rankreward_title01", ConfigManager:GetCommonTextById(20336))
  elseif cell_data.showPercentTitle then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rankreward_title01", ConfigManager:GetCommonTextById(20337))
  end
  local bgType = index % 2
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_bg_type", bgType == 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_bg_type02", bgType == 1)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank", self:GetRankStr(cfg))
  local rewardList = utils.changeCSArrayToLuaTable(cfg.m_Award)
  for i = 1, 3 do
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_reward_item0" .. i, rewardList[i])
    if rewardList[i] then
      local common_item = LuaBehaviourUtil.findGameObject(luaBehaviour, "m_reward_item0" .. i)
      local item = self:createCommonItem(common_item)
      item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end)
      local processData = ResourceUtil:GetProcessRewardData(rewardList[i])
      item:SetItemInfo(processData)
    end
  end
end

function Form_HuntingNightRankList:RefreshOwnerRankRewardInfo()
  local data = HuntingRaidManager:GetTotalRankOwnerDate()
  local playerHeadCom = self:createPlayerHead(self.m_circle_head1)
  playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
  self.m_txt_reward_mine_Text.text = tostring(RoleManager:GetName())
  self.m_txt_reward_guild_mine_Text.text = RoleManager:GetAllianceName()
  if table.getn(data) > 0 and data.iMyRank ~= 0 then
    self.m_icon_rank_reward1:SetActive(data.iMyRank == 1)
    self.m_icon_rank_reward2:SetActive(data.iMyRank == 2)
    self.m_icon_rank_reward3:SetActive(data.iMyRank == 3)
    self.m_icon_rank_reward4:SetActive(data.iMyRank > 3)
    local num = HuntingRaidManager:GetHuntingRaidRankStrAndPointsByRank(data.iMyRank, data.iRankSize)
    if num == 0 or num == "0" then
      self.m_txt_rank_rewardnum_Text.text = ""
    else
      self.m_txt_rank_rewardnum_Text.text = num
    end
    self.m_pnl_reward_mine:SetActive(true)
    self.m_z_txt_rewsrdst1:SetActive(data.iMyRank == 1)
    self.m_z_txt_rewsrdsnd2:SetActive(data.iMyRank == 2)
    self.m_z_txt_rewsrdrd3:SetActive(data.iMyRank == 3)
    if data.iMyRank == 1 then
      self.m_txt_rank_rewardnum_Text.color = RankManager.ColorEnum.first
      self.m_img_reward_bg_own_Image.color = RankManager.ColorEnum.first
    elseif data.iMyRank == 2 then
      self.m_txt_rank_rewardnum_Text.color = RankManager.ColorEnum.second
      self.m_img_reward_bg_own_Image.color = RankManager.ColorEnum.second
    elseif data.iMyRank == 3 then
      self.m_txt_rank_rewardnum_Text.color = RankManager.ColorEnum.third
      self.m_img_reward_bg_own_Image.color = RankManager.ColorEnum.third
    else
      self.m_txt_rank_rewardnum_Text.color = RankManager.ColorEnum.normal
    end
    self.m_img_reward_bg_own:SetActive(data.iMyRank <= 3)
    self.m_z_txt_rewardnorank:SetActive(data.iMyRank == 0)
    self.m_pnl_rewarditem_mine:SetActive(data.iMyRank ~= 0)
    local rewardList = HuntingRaidManager:GetHuntingRaidRewardByRank(data.iMyRank, data.iRankSize)
    if table.getn(rewardList) > 0 then
      for i = 1, 3 do
        if rewardList[i] then
          if not self.m_myRewardCommonItemList[i] then
            self.m_myRewardCommonItemList[i] = self:createCommonItem(self["m_reward_item_mine0" .. i])
          end
          local item = self.m_myRewardCommonItemList[i]
          item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
            utils.openItemDetailPop({iID = itemID, iNum = itemNum})
          end)
          local processData = ResourceUtil:GetProcessRewardData(rewardList[i])
          item:SetItemInfo(processData)
        end
        UILuaHelper.SetActive(self["m_reward_item_mine0" .. i], rewardList[i])
      end
    end
  else
    self.m_txt_rank_rewardnum_Text.text = ""
    self.m_z_txt_rewardnorank:SetActive(true)
    self.m_pnl_rewarditem_mine:SetActive(false)
    self.m_icon_rank_reward1:SetActive(false)
    self.m_icon_rank_reward2:SetActive(false)
    self.m_icon_rank_reward3:SetActive(false)
    self.m_icon_rank_reward4:SetActive(false)
    self.m_icon_rank_reward5:SetActive(true)
    self.m_pnl_reward_mine:SetActive(false)
  end
end

function Form_HuntingNightRankList:refreshRuleLoopScroll()
  local data = self.m_ruleDataList
  local all_cell_size = {}
  for i, v in ipairs(data or {}) do
    if v.showNumTitle or v.showPercentTitle then
      all_cell_size[i] = Vector2.New(1516, 228)
    else
      all_cell_size[i] = Vector2.New(1516, 115)
    end
  end
  if self.m_rule_loop_scroll_view == nil then
    local loopScroll = self.m_scrollView_rule
    local params = {
      show_data = data,
      one_line_count = 1,
      all_cell_size = all_cell_size,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateRuleScrollViewCell(index, cell_object, cell_data)
      end
    }
    self.m_rule_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_rule_loop_scroll_view:reloadData(data)
  end
end

function Form_HuntingNightRankList:UpdateRuleScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local cfg = cell_data.cfg
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_title", cell_data.showNumTitle or cell_data.showPercentTitle)
  if cell_data.showNumTitle then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rankrule_title01", ConfigManager:GetCommonTextById(20338))
  elseif cell_data.showPercentTitle then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rankrule_title01", ConfigManager:GetCommonTextById(20339))
  end
  local bgType = index % 2
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_bg_ruletype", bgType == 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_bg_ruletype02", bgType == 1)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rule", self:GetRankStr(cfg))
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_integration", tostring(cfg.m_Points))
end

function Form_HuntingNightRankList:GetRankStr(cfg)
  local rankName = ""
  local minStr = 0
  local maxStr = 0
  if cfg.m_Rank and 0 < cfg.m_Rank.Length then
    minStr = cfg.m_Rank[0]
    maxStr = cfg.m_Rank.Length == 1 and cfg.m_Rank[0] or cfg.m_Rank[1]
    rankName = minStr == maxStr and maxStr or string.format(ConfigManager:GetCommonTextById(100016), tostring(minStr), tostring(maxStr))
  elseif cfg.m_RankPercent and 0 < cfg.m_RankPercent.Length then
    minStr = cfg.m_RankPercent[0] / 100
    maxStr = cfg.m_RankPercent[1] / 100
    rankName = minStr == maxStr and maxStr or string.gsubNumberReplace(ConfigManager:GetCommonTextById(100306), tostring(minStr), tostring(maxStr))
  end
  return rankName
end

function Form_HuntingNightRankList:GenerateRuleData()
  local configInstance = ConfigManager:GetConfigInsByName("HuntingRaidRank")
  local rankAllCfg = configInstance:GetAll()
  local ruleDataList = {}
  local ruleData = {}
  local rankNum = false
  local rankPercent = false
  for i, v in pairs(rankAllCfg) do
    ruleDataList[#ruleDataList + 1] = v
  end
  
  local function sortFun(data1, data2)
    return data1.m_RankID < data2.m_RankID
  end
  
  table.sort(ruleDataList, sortFun)
  for i, v in ipairs(ruleDataList) do
    if v.m_Rank and v.m_Rank.Length > 0 then
      ruleData[#ruleData + 1] = {
        showNumTitle = not rankNum,
        cfg = v
      }
      rankNum = true
    elseif v.m_RankPercent and 0 < v.m_RankPercent.Length then
      ruleData[#ruleData + 1] = {
        showPercentTitle = not rankPercent,
        cfg = v
      }
      rankPercent = true
    end
  end
  return ruleData
end

function Form_HuntingNightRankList:OnTabItemClk(idx)
  local index = idx + 1
  if index == self.m_selRankTabIndex then
    return
  end
  if self.m_selRankTabIndex ~= 0 then
    self.m_rankTabList[self.m_selRankTabIndex].isSelect = false
    self.m_scrollView_tab:ReBind(self.m_selRankTabIndex)
  end
  self.m_rankTabList[index].isSelect = true
  self.m_scrollView_tab:ReBind(index)
  self.m_selRankTabIndex = index
  CS.GlobalManager.Instance:TriggerWwiseBGMState(62)
  self.m_changeRankTab = true
  self:RefreshRankTabUI()
end

function Form_HuntingNightRankList:OnTabrankClicked()
  if self.m_selRankTabIndex == 0 then
    return
  end
  self.m_rankTabList[self.m_selRankTabIndex].isSelect = false
  self.m_scrollView_tab:ReBind(self.m_selRankTabIndex)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(62)
  self.m_selRankTabIndex = 0
  self.m_changeRankTab = true
  self:RefreshRankTabUI()
end

function Form_HuntingNightRankList:OnTab1Clicked()
  if self.m_selTabIndex == 1 then
    return
  end
  self.m_selTabIndex = 1
  self:RefreshUI()
end

function Form_HuntingNightRankList:OnTab2Clicked()
  if self.m_selTabIndex == 2 then
    return
  end
  self.m_selTabIndex = 2
  self:RefreshUI()
end

function Form_HuntingNightRankList:OnTab3Clicked()
  if self.m_selTabIndex == 3 then
    return
  end
  self.m_selTabIndex = 3
  self:RefreshUI()
end

function Form_HuntingNightRankList:OnBtnchecklistmineClicked()
  if self.m_rankTabList[self.m_selRankTabIndex] and self.m_selRankTabIndex ~= 0 then
    local bossId = self.m_rankTabList[self.m_selRankTabIndex].iBossId
    local stRoleId = {
      iZoneId = UserDataManager:GetZoneID(),
      iUid = RoleManager:GetUID()
    }
    StackPopup:Push(UIDefines.ID_FORM_HUNTINGNIGHTBATTLEINFO, {stTargetId = stRoleId, bossId = bossId})
  end
end

function Form_HuntingNightRankList:IsOpenGuassianBlur()
  return true
end

function Form_HuntingNightRankList:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_HuntingNightRankList", Form_HuntingNightRankList)
return Form_HuntingNightRankList
