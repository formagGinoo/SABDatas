local Form_GuildRaidRankPop = class("Form_GuildRaidRankPop", require("UI/UIFrames/Form_GuildRaidRankPopUI"))
local PVP_NEW_RANK_PAGE_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewRankPagecnt")) or 0
local PVP_NEW_RANK_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildBattleRanklist"))
local RankTabType = {Grade = 1, Reward = 2}

function Form_GuildRaidRankPop:SetInitParam(param)
end

function Form_GuildRaidRankPop:AfterInit()
  self.super.AfterInit(self)
  self.TabCfg = {
    [RankTabType.Grade] = {
      selectNode = self.m_img_sel1,
      unSelectNode = self.m_z_txt_nml1,
      panelNode = self.m_pnl_rank
    },
    [RankTabType.Reward] = {
      selectNode = self.m_img_sel2,
      unSelectNode = self.m_z_txt_nml2,
      panelNode = self.m_pnl_reward
    }
  }
  self.m_battleRankList = nil
  self.m_battleMineInfo = nil
  self.m_curRankTabType = RankTabType.Grade
end

function Form_GuildRaidRankPop:OnActive()
  self.super.OnActive(self)
  self.m_load_end = false
  self.m_firstOpenFlag = true
  self.m_battleRankList = GuildManager:GetGuildBossRankList()
  self.m_guildBossData = GuildManager:GetGuildBossData()
  self.m_myBossRank, self.m_myBossScore, self.m_myBossRankSize = GuildManager:GetGuildBossMyRank()
  self:RefreshUI()
  self:AddEventListeners()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(15)
end

function Form_GuildRaidRankPop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_load_end = false
end

function Form_GuildRaidRankPop:PullRefreshUI(rankList)
  if self.m_firstOpenFlag then
    self.m_firstOpenFlag = false
    return
  end
  self.m_load_end = true
  if table.getn(rankList) > 0 then
    table.insertto(self.m_battleRankList, rankList)
  end
  self:refreshRankLoopScroll()
end

function Form_GuildRaidRankPop:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Detail", handler(self, self.OnEventAllianceDetail))
  self:addEventListener("eGameEvent_UpDataGuildBossRankList", handler(self, self.PullRefreshUI))
end

function Form_GuildRaidRankPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildRaidRankPop:RefreshUI()
  UILuaHelper.SetActive(self.m_common_empty, #self.m_battleRankList <= 0)
  self:refreshLoopScroll()
  self:refreshRankLoopScroll()
  self:RefreshOwnerRankRewardInfo()
  self:RefreshOwnerRankInfo()
end

function Form_GuildRaidRankPop:GeneratedRankReward()
  local configInstance = ConfigManager:GetConfigInsByName("GuildBattleReward")
  local rankAllCfg = configInstance:GetAll()
  local rewardList = {}
  for i, v in pairs(rankAllCfg) do
    local minStr = 0
    local maxStr = 0
    local rankName = ""
    if v.m_Rank and 0 < v.m_Rank.Length then
      minStr = v.m_Rank[0]
      maxStr = v.m_Rank.Length == 1 and v.m_Rank[0] or v.m_Rank[1]
      rankName = minStr == maxStr and maxStr or string.format(ConfigManager:GetCommonTextById(100016), tostring(minStr), tostring(maxStr))
    elseif v.m_RankPercent and 0 < v.m_RankPercent.Length then
      minStr = string.format("%.2f", v.m_RankPercent[0] / 100)
      maxStr = string.format("%.2f", v.m_RankPercent[1] / 100)
      rankName = minStr == maxStr and maxStr or string.gsubNumberReplace(ConfigManager:GetCommonTextById(100306), tostring(minStr), tostring(maxStr))
    end
    rewardList[#rewardList + 1] = {
      ID = v.m_ID,
      rankName = rankName,
      dailyReward = v.m_Award,
      gradeId = v.m_GradeID
    }
  end
  
  local function sortFun(data1, data2)
    return data1.ID < data2.ID
  end
  
  table.sort(rewardList, sortFun)
  return rewardList
end

function Form_GuildRaidRankPop:refreshRankLoopScroll()
  local data = self.m_battleRankList
  if self.m_rank_loop_scroll_view == nil then
    local loopScroll = self.m_rank_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateRankScrollViewCell(index, cell_object, cell_data)
      end,
      pull_refresh = function()
        self.last_offsety = self.m_rank_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
        local count = PVP_NEW_RANK_PAGE_CNT
        local curCount = table.getn(self.m_battleRankList)
        if curCount < PVP_NEW_RANK_CNT then
          count = math.min(PVP_NEW_RANK_CNT - curCount, PVP_NEW_RANK_PAGE_CNT)
          GuildManager:ReqAllianceGetBattleBossRankList(self.m_guildBossData.iActivityId, curCount + 1, curCount + count)
        end
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        GlobalManagerIns:TriggerWwiseBGMState(36)
        if click_name == "m_btn_show_guild" then
          GuildManager:ReqDetailAlliance(cell_data.stBriefInfo.iAllianceId)
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

function Form_GuildRaidRankPop:PullRefreshListOffset()
  if self.last_offsety then
    local now_offsety = self.m_rank_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
    local position = (self.last_offsety - now_offsety) / self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_rank_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_load_end = false
  end
end

function Form_GuildRaidRankPop:UpdateRankScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local guildInfo = cell_data.stBriefInfo
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank1", cell_data.iRank == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank2", cell_data.iRank == 2)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank3", cell_data.iRank == 3)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_rank4", cell_data.iRank >= 4)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_st1", cell_data.iRank == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_rd2", cell_data.iRank == 2)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_nd3", cell_data.iRank == 3)
  local textMeshPro = LuaBehaviourUtil.FindTextMeshProUGUI(luaBehaviour, "m_txt_ranknum")
  local rankBg1 = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_title")
  rankBg1.gameObject:SetActive(cell_data.iRank <= 3)
  if cell_data.iRank == 1 then
    textMeshPro.color = RankManager.ColorEnum.first
    rankBg1.color = RankManager.ColorEnum.first
  elseif cell_data.iRank == 2 then
    textMeshPro.color = RankManager.ColorEnum.second
    rankBg1.color = RankManager.ColorEnum.second
  elseif cell_data.iRank == 3 then
    textMeshPro.color = RankManager.ColorEnum.third
    rankBg1.color = RankManager.ColorEnum.third
  else
    textMeshPro.color = RankManager.ColorEnum.normal
  end
  local bg = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_rank")
  bg.color = cell_data.iRank <= 3 and RankManager.ColorEnum.firstbg or RankManager.ColorEnum.normalbg
  local grade, gradeCfg = GuildManager:GetGuildBossGradeByRank(cell_data.iRank, self.m_myBossRankSize)
  local showRank = GuildManager:GetGuildBossRankNumStr(cell_data.iRank, self.m_myBossRankSize)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_ranknum", showRank)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_name", guildInfo.sName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_power", cell_data.iScore)
  local m_img_sword = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_sword")
  ResourceUtil:CreateGuildIconById(m_img_sword, guildInfo.iBadgeId)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_rankmodel", grade ~= 0)
  if grade ~= 0 then
    local img = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_rankmodel")
    ResourceUtil:CreateGuildGradeIconById(img, grade)
  end
end

function Form_GuildRaidRankPop:refreshLoopScroll()
  local data = self:GeneratedRankReward()
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_reward_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function Form_GuildRaidRankPop:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local dailyReward = utils.changeCSArrayToLuaTable(cell_data.dailyReward)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_ranknum", cell_data.rankName)
  for i = 1, 3 do
    local panelRewardItem = luaBehaviour:FindGameObject("m_btn_seasonreward" .. i)
    local common_item = self:createCommonItem(panelRewardItem.gameObject)
    if dailyReward[i] then
      local processItemData = ResourceUtil:GetProcessRewardData({
        iID = dailyReward[i][1],
        iNum = dailyReward[i][2]
      })
      common_item:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        utils.openItemDetailPop({iID = itemID, iNum = itemNum})
      end)
      common_item:SetItemInfo(processItemData)
      panelRewardItem.gameObject:SetActive(true)
    else
      panelRewardItem.gameObject:SetActive(false)
    end
  end
  local item_img_type = cell_data.ID % 2
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_bg2", item_img_type == 0)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_bg1", 0 < item_img_type)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_img_rewardmodel", cell_data.gradeId ~= 0)
  if cell_data.gradeId ~= 0 then
    local img = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_rewardmodel")
    ResourceUtil:CreateGuildGradeIconById(img, cell_data.gradeId)
  end
end

function Form_GuildRaidRankPop:RefreshOwnerRankRewardInfo()
  local rankStr = GuildManager:GetGuildBossRankNumStr(self.m_myBossRank, self.m_myBossRankSize)
  self.m_reward_item_ranking:SetActive(self.m_myBossRank ~= 0)
  self.m_pnl_empty:SetActive(self.m_myBossRank == 0)
  if self.m_myBossRank ~= 0 then
    self.m_txt_rank_reward_num02_Text.text = self.m_myBossRank == 0 and "" or rankStr
    local grade = GuildManager:GetGuildBossGradeByRank(self.m_myBossRank, self.m_myBossRankSize)
    if grade ~= 0 then
      ResourceUtil:CreateGuildGradeIconById(self.m_img_rewardmodel02_Image, grade)
    end
    self.m_img_rewardmodel02:SetActive(grade ~= 0)
  end
  local reward = self:GetRewardByRank(self.m_myBossRank)
  if reward then
    for i = 1, 3 do
      if self["m_MyRewardItem" .. i] == nil then
        self["m_MyRewardItem" .. i] = self:createCommonItem(self["m_btn_owner_reward" .. i])
      end
      if reward[i] then
        self["m_btn_owner_reward" .. i]:SetActive(true)
        local processItemData = ResourceUtil:GetProcessRewardData({
          iID = reward[i][1],
          iNum = reward[i][2]
        })
        self["m_MyRewardItem" .. i]:SetItemIconClickCB(function(itemID, itemNum, itemCom)
          utils.openItemDetailPop({iID = itemID, iNum = itemNum})
        end)
        self["m_MyRewardItem" .. i]:SetItemInfo(processItemData)
      else
        self["m_btn_owner_reward" .. i]:SetActive(false)
      end
    end
  end
end

function Form_GuildRaidRankPop:GetRewardByRank(rank)
  local configInstance = ConfigManager:GetConfigInsByName("GuildBattleReward")
  local pvpRankAll = configInstance:GetAll()
  local _, _, m_myBossRankSize = GuildManager:GetGuildBossMyRank()
  for i, v in pairs(pvpRankAll) do
    local minStr = 0
    local maxStr = 0
    if v.m_Rank and 0 < v.m_Rank.Length then
      minStr = v.m_Rank[0]
      maxStr = v.m_Rank.Length == 1 and v.m_Rank[0] or v.m_Rank[1]
      if rank >= minStr and rank <= maxStr then
        return utils.changeCSArrayToLuaTable(v.m_Award)
      end
    elseif v.m_RankPercent and 0 < v.m_RankPercent.Length then
      minStr = v.m_RankPercent[0] / 10000
      maxStr = v.m_RankPercent[1] / 10000
      local num = rank / m_myBossRankSize
      if minStr <= num and maxStr >= num then
        return utils.changeCSArrayToLuaTable(v.m_Award)
      end
    end
  end
  return {}
end

function Form_GuildRaidRankPop:RefreshOwnerRankInfo()
  local ownerGuild = GuildManager:GetOwnerGuildDetail()
  if self.m_myBossRank and self.m_myBossRank ~= 0 then
    self.m_icon_rank_01:SetActive(self.m_myBossRank == 1)
    self.m_icon_rank_02:SetActive(self.m_myBossRank == 2)
    self.m_icon_rank_03:SetActive(self.m_myBossRank == 3)
    self.m_icon_rank_04:SetActive(self.m_myBossRank > 3)
    self.m_z_txt_rank_st1own:SetActive(self.m_myBossRank == 1)
    self.m_z_txt_rank_rd2own:SetActive(self.m_myBossRank == 2)
    self.m_z_txt_rank_nd3own:SetActive(self.m_myBossRank == 3)
    self.m_icon_rank_05:SetActive(false)
    local grade, gradeCfg = GuildManager:GetGuildBossGradeByRank(self.m_myBossRank, self.m_myBossRankSize)
    local showRank = GuildManager:GetGuildBossRankNumStr(self.m_myBossRank, self.m_myBossRankSize)
    self.m_txt_ranknum02_Text.text = showRank
    if grade ~= 0 then
      ResourceUtil:CreateGuildGradeIconById(self.m_img_rankmodel02_Image, grade)
      self.m_img_rankmodel02:SetActive(true)
    else
      self.m_img_rankmodel02:SetActive(false)
    end
    self.m_pnl_rankown:SetActive(true)
    if self.m_myBossRank == 1 then
      self.m_txt_ranknum02_Text.color = RankManager.ColorEnum.first
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.first
    elseif self.m_myBossRank == 2 then
      self.m_txt_ranknum02_Text.color = RankManager.ColorEnum.second
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.second
    elseif self.m_myBossRank == 3 then
      self.m_txt_ranknum02_Text.color = RankManager.ColorEnum.third
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.third
    else
      self.m_txt_ranknum02_Text.color = RankManager.ColorEnum.normal
    end
    self.m_img_bg_titelown:SetActive(self.m_myBossRank <= 3)
  else
    self.m_pnl_rankown:SetActive(false)
    self.m_icon_rank_01:SetActive(false)
    self.m_icon_rank_02:SetActive(false)
    self.m_icon_rank_03:SetActive(false)
    self.m_icon_rank_04:SetActive(false)
    self.m_icon_rank_05:SetActive(true)
    self.m_z_txt_norank:SetActive(true)
  end
  self.m_txt_rolename_Text.text = ownerGuild.stBriefData.sName or ""
  self.m_txt_power02_Text.text = self.m_myBossScore or 0
  ResourceUtil:CreateGuildIconById(self.m_img_sword02_Image, ownerGuild.stBriefData.iBadgeId)
end

function Form_GuildRaidRankPop:ChangeFreshRankShow(rankTabType)
  if self.m_curRankTabType then
    local lastNode = self.TabCfg[self.m_curRankTabType]
    if lastNode then
      UILuaHelper.SetActive(lastNode.selectNode, false)
      UILuaHelper.SetActive(lastNode.unSelectNode, true)
      UILuaHelper.SetActive(lastNode.panelNode, false)
    end
  end
  local curNode = self.TabCfg[rankTabType]
  if curNode then
    UILuaHelper.SetActive(curNode.selectNode, true)
    UILuaHelper.SetActive(curNode.unSelectNode, false)
    UILuaHelper.SetActive(curNode.panelNode, true)
  end
  self.m_curRankTabType = rankTabType
end

function Form_GuildRaidRankPop:OnTab1Clicked()
  self:OnTabClk(RankTabType.Grade)
end

function Form_GuildRaidRankPop:OnTab2Clicked()
  self:OnTabClk(RankTabType.Reward)
end

function Form_GuildRaidRankPop:OnTabClk(rewardType)
  if not rewardType then
    return
  end
  self:ChangeFreshRankShow(rewardType)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
end

function Form_GuildRaidRankPop:OnGuildItemClick()
  log.error("OnGuildItemClick-------")
end

function Form_GuildRaidRankPop:OnEventAllianceDetail(stData)
  self.m_selGuildId = stData.stBriefData.iAllianceId
  StackPopup:Push(UIDefines.ID_FORM_GUILDDETAILPOP, {guildData = stData, hideJoinBtn = true})
end

function Form_GuildRaidRankPop:IsOpenGuassianBlur()
  return true
end

function Form_GuildRaidRankPop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidRankPop", Form_GuildRaidRankPop)
return Form_GuildRaidRankPop
