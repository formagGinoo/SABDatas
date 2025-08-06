local Form_PersonalRaidRankList = class("Form_PersonalRaidRankList", require("UI/UIFrames/Form_PersonalRaidRankListUI"))
local PVP_NEW_RANK_PAGE_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewRankPagecnt")) or 0
local PVP_NEW_RANK_CNT = tonumber(ConfigManager:GetGlobalSettingsByKey("SoloRaidRanklist")) or 0
local RankTabType = {Grade = 1, Reward = 2}
local TOP_COLOR = CS.UnityEngine.Color(1, 1, 1, 1)
local NORMAL_COLOR = CS.UnityEngine.Color(0.32941176470588235, 0.3058823529411765, 0.2784313725490196, 1)

function Form_PersonalRaidRankList:SetInitParam(param)
end

function Form_PersonalRaidRankList:AfterInit()
  self.super.AfterInit(self)
  self.TabCfg = {
    [RankTabType.Grade] = {
      selectNode = self.m_img_sel1,
      unSelectNode = self.m_z_txt_nml1,
      panelNode = self.m_pnl_ranklist
    },
    [RankTabType.Reward] = {
      selectNode = self.m_img_sel2,
      unSelectNode = self.m_z_txt_nml2,
      panelNode = self.m_pnl_rewardlist
    }
  }
  self.m_battleRankList = nil
  self.m_battleMineInfo = nil
  self.m_curRankTabType = RankTabType.Grade
  self.m_txt_lv_mine_Text = self.m_circle_head1.transform:Find("bg_lv/c_txt_lv"):GetComponent("TMPPro")
  self.m_playerHeadCom = self:createPlayerHead(self.m_circle_head)
  self.m_playerHeadCom1 = self:createPlayerHead(self.m_circle_head1)
end

function Form_PersonalRaidRankList:OnActive()
  self.super.OnActive(self)
  self.m_load_end = false
  self.m_firstOpenFlag = true
  self.m_PlayerHeadCache = {}
  self:RefreshUI()
  self:OnTab1Clicked()
  self:AddEventListeners()
end

function Form_PersonalRaidRankList:OnInactive()
  self.super.OnInactive(self)
  self.m_rewardAnimFlag = false
  self.m_load_end = false
  self.m_PlayerHeadCache = {}
  self:RemoveAllEventListeners()
end

function Form_PersonalRaidRankList:PullRefreshUI()
  if self.m_firstOpenFlag then
    self.m_firstOpenFlag = false
    return
  end
  self.m_load_end = true
  self:RefreshUI()
end

function Form_PersonalRaidRankList:AddEventListeners()
  self:addEventListener("eGameEvent_UpDataRankList", handler(self, self.PullRefreshUI))
end

function Form_PersonalRaidRankList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalRaidRankList:RefreshUI()
  self.m_battleRankList = RankManager:GetRankDataListBySystemId(RankManager.RankType.PersonalRaid) or {}
  if #self.m_battleRankList > 0 then
    self.m_rank_empty:SetActive(false)
    self.m_scrollView2:SetActive(true)
    self:refreshRankLoopScroll()
  else
    self.m_rank_empty:SetActive(true)
    self.m_scrollView2:SetActive(false)
  end
  self:RefreshOwnerRankRewardInfo()
  self:RefreshOwnerRankInfo()
  self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
  self.m_playerHeadCom1:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
end

function Form_PersonalRaidRankList:refreshRankLoopScroll()
  local data = self.m_battleRankList
  if self.m_rank_loop_scroll_view == nil then
    local loopScroll = self.m_scrollView2
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
          RankManager:ReqArenaRankListCS(RankManager.RankType.PersonalRaid, curCount + 1, curCount + count)
        end
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if cell_data.stRoleSimple.stRoleId.iZoneId ~= 0 and cell_data.stRoleSimple.stRoleId.iUid ~= "0" then
          if click_name == "btn_head" then
            StackPopup:Push(UIDefines.ID_FORM_PERSONALCARD, {
              zoneID = cell_data.stRoleSimple.stRoleId.iZoneId,
              otherRoleID = cell_data.stRoleSimple.stRoleId.iUid
            })
          elseif click_name == "m_btn_checklist" then
            StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDBATTLEINFO, {
              stTargetId = cell_data.stRoleSimple.stRoleId,
              from_rank = true
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

function Form_PersonalRaidRankList:PullRefreshListOffset()
  if self.last_offsety then
    local now_offsety = self.m_rank_loop_scroll_view.m_scroll_rect.viewport.rect.height - self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
    local position = (self.last_offsety - now_offsety) / self.m_rank_loop_scroll_view.m_scroll_rect.content.rect.height
    self.m_rank_loop_scroll_view:setVerticalNormalizedPosition(position)
    self.m_load_end = false
  end
end

function Form_PersonalRaidRankList:UpdateRankScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_st1", cell_data.iRank == 1)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_rd2", cell_data.iRank == 2)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_rank_nd3", cell_data.iRank == 3)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_battle_rank4", cell_data.iRank > 3)
  for i = 1, 3 do
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_icon_battle_rank" .. i, cell_data.iRank == i)
  end
  local textMeshPro = LuaBehaviourUtil.FindTextMeshProUGUI(luaBehaviour, "m_txt_rank2")
  local rankBg = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_title")
  if cell_data.iRank == 1 then
    rankBg.color = RankManager.ColorEnum.first
    textMeshPro.color = RankManager.ColorEnum.first
  elseif cell_data.iRank == 2 then
    rankBg.color = RankManager.ColorEnum.second
    textMeshPro.color = RankManager.ColorEnum.second
  elseif cell_data.iRank == 3 then
    rankBg.color = RankManager.ColorEnum.third
    textMeshPro.color = RankManager.ColorEnum.third
  else
    textMeshPro.color = RankManager.ColorEnum.normal
  end
  rankBg.gameObject:SetActive(cell_data.iRank <= 3)
  local bg = LuaBehaviourUtil.findImg(luaBehaviour, "m_img_bg_rank")
  bg.color = cell_data.iRank <= 3 and RankManager.ColorEnum.firstbg or RankManager.ColorEnum.normalbg
  local data = RankManager:GetOwnerRankDataListBySystemId(RankManager.RankType.PersonalRaid)
  local showRank = PersonalRaidManager:GetRankNameByRankAndTotal(cell_data.iRank, data.iRankSize)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank2", showRank)
  LuaBehaviourUtil.setText(luaBehaviour, "m_txt_name2", cell_data.stRoleSimple.sName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_damage", cell_data.iScore)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_power2", cell_data.stRoleSimple.mSimpleData[MTTDProto.CmdSimpleDataType_TopFiveHeroPower] or 0)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_guild_name", cell_data.stRoleSimple.mSimpleData[MTTDProto.CmdSimpleDataType_TopFiveHeroPower] or 0)
  local guildName = cell_data.stRoleSimple.sAlliance ~= "" and cell_data.stRoleSimple.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
  LuaBehaviourUtil.setText(luaBehaviour, "m_txt_guild_name2", guildName)
  local c_circle_headTrans = transform:Find("m_img_rank_item2/m_circle_head2")
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

function Form_PersonalRaidRankList:RefreshOwnerRankInfo()
  local data = RankManager:GetOwnerRankDataListBySystemId(RankManager.RankType.PersonalRaid)
  UIUtil.CreateRoleHeadInfo(self.m_circle_head, nil, tostring(RoleManager:GetLevel()))
  self.m_txt_name_battle_mine_Text.text = tostring(RoleManager:GetName())
  self.m_txt_guild_name_battle_mine_Text.text = RoleManager:GetAllianceName()
  self.m_txt_power_battle_mine_Text.text = HeroManager:GetTopFiveHeroPower()
  if data then
    self.m_icon_rank_battle_mine1:SetActive(data.iMyRank == 1)
    self.m_icon_rank_battle_mine2:SetActive(data.iMyRank == 2)
    self.m_icon_rank_battle_mine3:SetActive(data.iMyRank == 3)
    self.m_icon_rank_battle_mine4:SetActive(data.iMyRank > 3)
    self.m_z_txt_rank_ownst1:SetActive(data.iMyRank == 1)
    self.m_z_txt_rank_ownnd2:SetActive(data.iMyRank == 2)
    self.m_z_txt_rank_ownrd3:SetActive(data.iMyRank == 3)
    if data.iMyRank == 1 then
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.first
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.first
    elseif data.iMyRank == 2 then
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.second
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.second
    elseif data.iMyRank == 3 then
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.third
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.third
    else
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.normal
    end
    self.m_img_bg_titelown:SetActive(data.iMyRank <= 3)
    self.m_pnl_rankingmine:SetActive(data.iMyRank ~= 0)
    self.m_z_txt_norank:SetActive(data.iMyRank == 0)
    self.m_icon_rank_battle_mine5:SetActive(data.iMyRank == 0)
    self.m_txt_rank_battle_mine_Text.text = PersonalRaidManager:GetRankNameByRankAndTotal(data.iMyRank, data.iRankSize)
    self.m_txt_damage_battle_mine_Text.text = data.iMyScore or 0
    self.m_btn_checklistmine:SetActive(true)
  else
    self.m_pnl_rankingmine:SetActive(false)
    self.m_z_txt_norank:SetActive(true)
    self.m_icon_rank_battle_mine5:SetActive(true)
    self.m_txt_damage_battle_mine_Text.text = 0
    self.m_btn_checklistmine:SetActive(false)
  end
end

function Form_PersonalRaidRankList:RefreshOwnerRankRewardInfo()
  local data = RankManager:GetOwnerRankDataListBySystemId(RankManager.RankType.PersonalRaid)
  UIUtil.CreateRoleHeadInfo(self.m_circle_head1, nil, tostring(RoleManager:GetLevel()))
  self.m_txt_name_battle_minereward_Text.text = tostring(RoleManager:GetName())
  if data then
    self.m_icon_rank_battle_mine1reward:SetActive(data.iMyRank == 1)
    self.m_icon_rank_battle_mine2reward:SetActive(data.iMyRank == 2)
    self.m_icon_rank_battle_mine3reward:SetActive(data.iMyRank == 3)
    self.m_icon_rank_battle_mine4reward:SetActive(data.iMyRank > 3)
    self.m_txt_rank_battle_minereward_Text.text = PersonalRaidManager:GetRankNameByRankAndTotal(data.iMyRank, data.iRankSize)
    self.m_z_txt_rewsrdst1:SetActive(data.iMyRank == 1)
    self.m_z_txt_rewsrdsnd2:SetActive(data.iMyRank == 2)
    self.m_z_txt_rewsrdrd3:SetActive(data.iMyRank == 3)
    if data.iMyRank == 1 then
      self.m_txt_rank_battle_minereward_Text.color = RankManager.ColorEnum.first
      self.m_img_reward_bg_own_Image.color = RankManager.ColorEnum.first
    elseif data.iMyRank == 2 then
      self.m_txt_rank_battle_minereward_Text.color = RankManager.ColorEnum.second
      self.m_img_reward_bg_own_Image.color = RankManager.ColorEnum.second
    elseif data.iMyRank == 3 then
      self.m_txt_rank_battle_minereward_Text.color = RankManager.ColorEnum.third
      self.m_img_reward_bg_own_Image.color = RankManager.ColorEnum.third
    else
      self.m_txt_rank_battle_minereward_Text.color = RankManager.ColorEnum.normal
    end
    self.m_img_reward_bg_own:SetActive(data.iMyRank <= 3)
    self.m_z_txt_norankrewardlist:SetActive(data.iMyRank == 0)
    self.m_pnl_rewardlistownreward:SetActive(data.iMyRank ~= 0)
    if data.iMyRank <= 3 then
      UILuaHelper.SetColor(self.m_txt_rank_mine_Text, 246, 238, 193, 1)
    else
      UILuaHelper.SetColor(self.m_txt_rank_mine_Text, 215, 214, 208, 1)
    end
    if not data.iMyRank or data.iMyRank == 0 then
      self.m_item_rewad1:SetActive(false)
      self.m_icon_rank_battle_mine5reward:SetActive(true)
    else
      self.m_item_rewad1:SetActive(true)
      self["m_itemreward" .. 1]:SetActive(false)
      self["m_itemreward" .. 2]:SetActive(false)
      local reward = utils.changeCSArrayToLuaTable(self:GetRewardByRank(data.iMyRank))
      if reward then
        for i, v in ipairs(reward) do
          self["m_itemreward" .. i]:SetActive(true)
          ResourceUtil:CreatIconById(self["m_icon_rewardown" .. i .. "_Image"], reward[i][1])
          self["m_txt_numreward" .. i .. "_Text"].text = reward[i][2]
        end
      end
    end
  else
    self.m_item_rewad1:SetActive(false)
    self.m_txt_rank_battle_minereward_Text.text = ""
    self.m_z_txt_norankrewardlist:SetActive(true)
    self.m_pnl_rewardlistownreward:SetActive(false)
    self.m_icon_rank_battle_mine5reward:SetActive(true)
  end
end

function Form_PersonalRaidRankList:GetRewardByRank(rank)
  local configInstance = ConfigManager:GetConfigInsByName("SoloRaidReward")
  local data = RankManager:GetOwnerRankDataListBySystemId(RankManager.RankType.PersonalRaid)
  if not data then
    return
  end
  local pvpRankAll = configInstance:GetAll()
  for i, v in pairs(pvpRankAll) do
    local minStr = 0
    local maxStr = 0
    if v.m_Rank and 0 < v.m_Rank.Length then
      minStr = v.m_Rank[0]
      maxStr = v.m_Rank.Length == 1 and v.m_Rank[0] or v.m_Rank[1]
      if rank >= minStr and rank <= maxStr then
        return v.m_Award
      end
    elseif v.m_RankPercent and 0 < v.m_RankPercent.Length then
      minStr = v.m_RankPercent[0] / 10000
      maxStr = v.m_RankPercent[1] / 10000
      local num = rank / data.iRankSize
      if minStr <= num and maxStr >= num then
        return v.m_Award
      end
    end
  end
end

function Form_PersonalRaidRankList:GeneratedPvpReward()
  local configInstance = ConfigManager:GetConfigInsByName("SoloRaidReward")
  local pvpRankAll = configInstance:GetAll()
  local rewardList = {}
  for i, v in pairs(pvpRankAll) do
    local minStr = 0
    local maxStr = 0
    local rankName = ""
    if v.m_Rank and 0 < v.m_Rank.Length then
      minStr = v.m_Rank[0]
      maxStr = v.m_Rank[1]
      rankName = minStr == maxStr and maxStr or string.format(ConfigManager:GetCommonTextById(100016), tostring(minStr), tostring(maxStr))
    elseif v.m_RankPercent and 0 < v.m_RankPercent.Length then
      minStr = v.m_RankPercent[0] / 100
      maxStr = v.m_RankPercent[1] / 100
      rankName = minStr == maxStr and maxStr or string.gsubNumberReplace(ConfigManager:GetCommonTextById(100306), tostring(minStr), tostring(maxStr))
    end
    rewardList[#rewardList + 1] = {
      ID = v.m_ID,
      rankName = rankName,
      dailyReward = v.m_Award
    }
  end
  
  local function sortFun(data1, data2)
    return data1.ID < data2.ID
  end
  
  table.sort(rewardList, sortFun)
  return rewardList
end

function Form_PersonalRaidRankList:refreshLoopScroll()
  local data = self:GeneratedPvpReward()
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_scrollView
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
        local dailyClickIndex = 1
        if click_name == "m_item1" or click_name == "m_item2" or click_name == "m_item3" then
          local dailyReward = utils.changeCSArrayToLuaTable(cell_data.dailyReward)
          if click_name == "m_item1" then
            dailyClickIndex = 1
          end
          if click_name == "m_item2" then
            dailyClickIndex = 2
          end
          if click_name == "m_item3" then
            dailyClickIndex = 3
          end
          utils.openItemDetailPop({
            iID = dailyReward[dailyClickIndex][1],
            iNum = dailyReward[dailyClickIndex][2]
          })
        elseif click_name == "m_seasonitem1" or click_name == "m_seasonitem2" or click_name == "m_seasonitem3" then
          local seasonReward = utils.changeCSArrayToLuaTable(cell_data.seasonReward)
          if click_name == "m_seasonitem1" then
            dailyClickIndex = 1
          end
          if click_name == "m_seasonitem2" then
            dailyClickIndex = 2
          end
          if click_name == "m_seasonitem3" then
            dailyClickIndex = 3
          end
          utils.openItemDetailPop({
            iID = seasonReward[dailyClickIndex][1],
            iNum = seasonReward[dailyClickIndex][2]
          })
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
  self.m_rewardAnimFlag = true
end

function Form_PersonalRaidRankList:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  local dailyReward = utils.changeCSArrayToLuaTable(cell_data.dailyReward)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_rank", cell_data.rankName)
  for i = 1, 3 do
    if dailyReward[i] then
      local m_icon_reward = UIUtil.findImage(transform, "pnl_item/m_item_dayreward/m_item" .. i .. "/m_txt_num" .. i .. "/m_icon_reward" .. i)
      ResourceUtil:CreatIconById(m_icon_reward, dailyReward[i][1])
      UIUtil.setTextMeshProText(transform, dailyReward[i][2], "pnl_item/m_item_dayreward/m_item" .. i .. "/m_txt_num" .. i)
    end
    UIUtil.setObjectVisible(transform, dailyReward[i] ~= nil, "pnl_item/m_item_dayreward/m_item" .. i)
  end
  local item_img_type = cell_data.ID % 2
  UIUtil.setObjectVisible(transform, cell_data.rankName == "1", "pnl_item/m_pnl_rankingreward/m_img_bg_rankingnum")
  LuaBehaviourUtil.setTextMeshProColor(luaBehaviour, "m_txt_rank", cell_data.rankName == "FIRST_COLOR" and TOP_COLOR or NORMAL_COLOR)
  UIUtil.setObjectVisible(transform, item_img_type == 0, "pnl_item/m_img_type2")
  UIUtil.setObjectVisible(transform, 0 < item_img_type, "pnl_item/m_img_type1")
  if not self.m_rewardAnimFlag then
    LuaBehaviourUtil.runAnim(luaBehaviour, "RewardList_ScrollView_in")
  end
end

function Form_PersonalRaidRankList:ChangeFreshRankShow(rankTabType)
  self.m_rewardAnimFlag = false
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
  if rankTabType == RankTabType.Reward then
    self:refreshLoopScroll()
  end
  self.m_curRankTabType = rankTabType
end

function Form_PersonalRaidRankList:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PersonalRaidRankList:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_PersonalRaidRankList:OnTab1Clicked()
  self:OnTabClk(RankTabType.Grade)
end

function Form_PersonalRaidRankList:OnTab2Clicked()
  self:OnTabClk(RankTabType.Reward)
end

function Form_PersonalRaidRankList:OnTabClk(rewardType)
  if not rewardType then
    return
  end
  self:ChangeFreshRankShow(rewardType)
end

function Form_PersonalRaidRankList:OnBtnchecklistmineClicked()
  StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDBATTLEINFO, {
    stTargetId = {
      iZoneId = UserDataManager:GetZoneID(),
      iUid = RoleManager:GetUID()
    },
    from_rank = true
  })
end

function Form_PersonalRaidRankList:IsOpenGuassianBlur()
  return true
end

function Form_PersonalRaidRankList:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRaidRankList", Form_PersonalRaidRankList)
return Form_PersonalRaidRankList
