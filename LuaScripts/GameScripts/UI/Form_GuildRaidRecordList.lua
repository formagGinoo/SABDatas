local Form_GuildRaidRecordList = class("Form_GuildRaidRecordList", require("UI/UIFrames/Form_GuildRaidRecordListUI"))

function Form_GuildRaidRecordList:SetInitParam(param)
end

function Form_GuildRaidRecordList:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuildRaidRecordList:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_roleInfo = {}
  self.m_memberHistoryList = self:SortMemberByTime(tParam)
  self:RefreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(35)
end

function Form_GuildRaidRecordList:OnInactive()
  self.super.OnInactive(self)
end

function Form_GuildRaidRecordList:SortMemberByTime(list)
  if table.getn(list) == 0 then
    return {}
  end
  
  local function sortFun(data1, data2)
    return data1.iTime > data2.iTime
  end
  
  table.sort(list, sortFun)
  return list
end

function Form_GuildRaidRecordList:RefreshUI()
  if self.m_memberHistoryList[1] then
    self.m_roleInfo = GuildManager:GetOwnerGuildMemberDataByUID(self.m_memberHistoryList[1].stRoleId.iUid)
    self.m_txt_name_Text.text = self.m_roleInfo.sRoleName
  end
  self:refreshLoopScroll()
end

function Form_GuildRaidRecordList:refreshLoopScroll()
  local data = self.m_memberHistoryList
  if self.m_loop_scroll_view == nil then
    local loopScroll = self.m_record_list
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
    self.m_loop_scroll_view:reloadData(data, true)
  end
end

function Form_GuildRaidRecordList:UpdateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
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
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_rankingnum", index)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_recordround", string.gsubNumberReplace(ConfigManager:GetCommonTextById(10006), cell_data.iRound))
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_damage", cell_data.iRealDamage)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_img_bg_deafeated", cell_data.bKill)
  local cfg = GuildManager:GetGuildBattleBossCfgByID(cell_data.iBossId)
  if cfg then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_recordname", cfg.m_mName)
  end
  local levelCfg = GuildManager:GetGuildBossLevelInfoByBossId(cell_data.iBossId, cell_data.iRound)
  if levelCfg then
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_recordlevel", string.format(ConfigManager:GetCommonTextById(20033), tostring(levelCfg.m_BossLevel)))
  end
end

function Form_GuildRaidRecordList:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildRaidRecordList:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidRecordList", Form_GuildRaidRecordList)
return Form_GuildRaidRecordList
