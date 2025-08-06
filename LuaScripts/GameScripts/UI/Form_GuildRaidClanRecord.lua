local Form_GuildRaidClanRecord = class("Form_GuildRaidClanRecord", require("UI/UIFrames/Form_GuildRaidClanRecordUI"))

function Form_GuildRaidClanRecord:SetInitParam(param)
end

function Form_GuildRaidClanRecord:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnTabItemClk)
  }
  self.m_TabInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_tab_list_InfinityGrid, "Guild/UGuildBossClanRecordTabItem", initGridData)
  self.m_TabInfinityGrid:RegisterButtonCallback("c_tabItem", handler(self, self.OnTabItemClk))
end

function Form_GuildRaidClanRecord:OnActive()
  self.super.OnActive(self)
  self.m_iSelectedDay = 1
  self:RefreshUI()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(15)
end

function Form_GuildRaidClanRecord:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuildRaidClanRecord:RefreshUI()
  self.m_TabData = self:GenerateTabData()
  self.m_TabInfinityGrid:ShowItemList(self.m_TabData)
  self.m_TabInfinityGrid:LocateTo(0)
  self.m_BattleInfoList = self:GeneratePlayerData()
  self:RefreshBattleCount()
  self:refreshLoopScroll()
end

function Form_GuildRaidClanRecord:RefreshBattleCount()
  local maxNum = GuildManager:GetGuildBossBattleMaxNum()
  local battleCount = table.getn(self.m_BattleInfoList[self.m_iSelectedDay] or {})
  self.m_txt_battlenum02_Text.text = string.format(ConfigManager:GetCommonTextById(20048), battleCount, maxNum)
end

function Form_GuildRaidClanRecord:refreshLoopScroll()
  local data = self.m_BattleInfoList[self.m_iSelectedDay] or {}
  if table.getn(data) > 0 then
    local function sortFun(data1, data2)
      return data1.iTime > data2.iTime
    end
    
    table.sort(data, sortFun)
  end
  local all_cell_size = {}
  for i, v in ipairs(data or {}) do
    if self.m_selTabIndex == i then
      all_cell_size[i] = Vector2.New(1360.1, 386)
    else
      all_cell_size[i] = Vector2.New(1360.1, 226)
    end
  end
  self.m_img_empty:SetActive(table.getn(data) == 0)
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_task_list
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopScroll,
      all_cell_size = all_cell_size,
      update_cell = function(index, cell_object, cell_data)
        self:UpdateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "m_btn_launched" then
          CS.GlobalManager.Instance:TriggerWwiseBGMState(62)
          if self.m_selTabIndex == index then
            self.m_selTabIndex = nil
          else
            self.m_selTabIndex = index
          end
          self.m_move_to_id = cell_data.iTime
          self:refreshLoopScroll()
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  elseif self.m_move_to_id then
    local move_index = 1
    for k, v in ipairs(data) do
      if v.iTime == self.m_move_to_id then
        move_index = k
        break
      end
    end
    self.m_loop_scroll_view:reloadData(data, nil, all_cell_size)
    self.m_loop_scroll_view:moveToCellIndex(move_index)
    self.m_move_to_id = nil
  else
    self.m_loop_scroll_view:reloadData(data, nil, all_cell_size)
  end
end

function Form_GuildRaidClanRecord:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "img_bg_defeated", cell_data.bKill)
  local time = TimeUtil:TimerToString4(cell_data.iTime)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_cleartime02", time)
  local cfg = GuildManager:GetGuildBattleBossCfgByID(cell_data.iBossId)
  if cfg then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_boss", cfg.m_mName)
    local m_img_head = UIUtil.findImage(transform, "m_pnl_title/item_recordnormal/item_content/m_circle_head/pnl_head_mask/m_img_head")
    ResourceUtil:CreateGuildBossIconByName(m_img_head, cfg.m_Avatar)
    local levelCfg = GuildManager:GetGuildBossLevelInfoByBossId(cell_data.iBossId, cell_data.iRound)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_lv", string.format(ConfigManager:GetCommonTextById(20033), tostring(levelCfg.m_BossLevel)))
  end
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_round", string.gsubNumberReplace(ConfigManager:GetCommonTextById(10006), cell_data.iRound))
  LuaBehaviourUtil.setText(luaBehaviour, "m_txt_playername", cell_data.sName)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_damage", cell_data.iRealDamage)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_pnl_titlelaunched", self.m_selTabIndex == index)
  local heroList = cell_data.vHero
  for i = 1, 5 do
    local common_hero_middle = LuaBehaviourUtil.findGameObject(luaBehaviour, "c_hero_" .. i)
    local commonHeroItem = self:createHeroIcon(common_hero_middle)
    if heroList[i] then
      commonHeroItem:SetHeroData(heroList[i], nil, true)
    end
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_hero_" .. i, heroList[i])
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_heroempty_" .. i, not heroList[i])
  end
end

function Form_GuildRaidClanRecord:GeneratePlayerData()
  local historyTab = GuildManager:GetGuildBossHistory()
  local dayTab = {}
  local list = {}
  for i, v in pairs(historyTab) do
    dayTab[#dayTab + 1] = {time = i, infoList = v}
  end
  
  local function sortFun(data1, data2)
    return data1.time > data2.time
  end
  
  table.sort(dayTab, sortFun)
  for i, v in ipairs(dayTab) do
    list[i] = v.infoList
  end
  return list
end

function Form_GuildRaidClanRecord:GenerateTabData()
  local historyTab = GuildManager:GetGuildBossHistory()
  local dayTab = {}
  for i, v in pairs(historyTab) do
    dayTab[#dayTab + 1] = {time = i, isSelect = false}
  end
  
  local function sortFun(data1, data2)
    return data1.time > data2.time
  end
  
  table.sort(dayTab, sortFun)
  local index = 0
  for i = #dayTab, 1, -1 do
    index = index + 1
    dayTab[index].day = i
  end
  if dayTab[1] then
    dayTab[1].isSelect = true
  end
  return dayTab
end

function Form_GuildRaidClanRecord:OnTabItemClk(idx)
  local index = idx + 1
  if index == self.m_iSelectedDay then
    return
  end
  self.m_TabData[self.m_iSelectedDay].isSelect = false
  self.m_TabData[index].isSelect = true
  self.m_TabInfinityGrid:ReBind(self.m_iSelectedDay)
  self.m_TabInfinityGrid:ReBind(index)
  self.m_iSelectedDay = index
  self.m_move_to_id = nil
  self.m_selTabIndex = nil
  self:refreshLoopScroll()
  self:RefreshBattleCount()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(62)
end

function Form_GuildRaidClanRecord:IsOpenGuassianBlur()
  return true
end

function Form_GuildRaidClanRecord:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidClanRecord", Form_GuildRaidClanRecord)
return Form_GuildRaidClanRecord
