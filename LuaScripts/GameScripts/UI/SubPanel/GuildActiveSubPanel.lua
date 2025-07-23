local UISubPanelBase = require("UI/Common/UISubPanelBase")
local GuildActiveSubPanel = class("GuildActiveSubPanel", UISubPanelBase)

function GuildActiveSubPanel:OnInit()
  self.m_guildData = nil
end

function GuildActiveSubPanel:OnFreshData()
  self.m_guildEventList = GuildManager:GetOpenedGuildEventList()
  self.m_guildData = GuildManager:GetOwnerGuildDetail()
  self.m_isGuildBossOpen = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_AllianceBattle) ~= nil
  self:RefreshTime()
  self:refreshLoopScroll()
end

function GuildActiveSubPanel:dispose()
  GuildActiveSubPanel.super.dispose(self)
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
    self.m_cutDownTime = nil
  end
end

function GuildActiveSubPanel:RefreshTime()
  if self.m_downTimer then
    TimeService:KillTimer(self.m_downTimer)
    self.m_downTimer = nil
  end
  local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_AllianceBattle)
  if self.m_isGuildBossOpen and activity and activity.GetGuildBossBattleEndTime then
    local actBattleEndTime = activity:GetGuildBossBattleEndTime()
    local serverTime = TimeUtil:GetServerTimeS()
    self.m_cutDownTime = actBattleEndTime - serverTime
  end
end

function GuildActiveSubPanel:GetGuildEventData()
end

function GuildActiveSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_Sign", handler(self, self.OnFreshData))
  self:addEventListener("eGameEvent_Alliance_RefreshTransformGuild", handler(self, self.OnFreshData))
end

function GuildActiveSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function GuildActiveSubPanel:refreshLoopScroll()
  local data = self.m_guildEventList
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_event_list
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end,
      click_func = function(index, cell_object, cell_data, click_object, click_name)
        if click_name == "c_btn_event" then
          local isOpen, tips_id = UnlockSystemUtil:IsSystemOpen(cell_data.m_SystemUnlockID)
          if isOpen then
            QuickOpenFuncUtil:OpenFunc(cell_data.m_JumpID)
          else
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
          end
        end
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data)
  end
end

function GuildActiveSubPanel:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "c_txt_event_name", cell_data.m_mEventName)
  local c_img_event_bg = UIUtil.findImage(transform, "offset/mask_bg/c_img_event_bg")
  CS.UI.UILuaHelper.SetAtlasSprite(c_img_event_bg, cell_data.m_Path, nil, nil, true)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_redpoint", false)
  if cell_data.m_SystemUnlockID == GlobalConfig.SYSTEM_ID.GuildSign then
    local _, time = GuildManager:GetGuildSignNum()
    local flag = TimeUtil:CheckTimeIsToDay(time)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_redpoint", not flag)
  end
  local isOpen = UnlockSystemUtil:IsSystemOpen(cell_data.m_SystemUnlockID)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "mask_event_lock", not isOpen)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_raid_time_over", false)
  if cell_data.m_SystemUnlockID == GlobalConfig.SYSTEM_ID.GuildBattle then
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_close", not self.m_isGuildBossOpen)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_open", self.m_isGuildBossOpen)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_time", self.m_isGuildBossOpen)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_redpoint", GuildManager:GuildBossIsHaveRedDot() > 0)
    if self.m_guildData and GuildManager:IsGuildRankDataActive(self.m_guildData.stBriefData) then
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_rank", not self.m_isGuildBossOpen)
      local rank = GuildManager:GetGuildBossRankNumStr(self.m_guildData.stBriefData.iLastBattleRank, self.m_guildData.stBriefData.iLastBattleRankCount)
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_raid_rank", string.gsubnumberreplace(ConfigManager:GetCommonTextById(20069), rank))
    else
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_rank", false)
    end
    if self.m_downTimer == nil and self.m_cutDownTime and 0 < self.m_cutDownTime then
      self.m_downTimer = TimeService:SetTimer(1, -1, function()
        self.m_cutDownTime = self.m_cutDownTime - 1
        if self.m_cutDownTime <= 0 then
          LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_raid_time_nml", "")
          LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_open", false)
          LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_raid_time_over", true)
          return
        end
        local time = string.gsubNumberReplace(ConfigManager:GetCommonTextById(10009), TimeUtil:SecondsToFormatCNStr(self.m_cutDownTime))
        LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_raid_time_nml", time)
      end)
    else
      LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "m_txt_raid_time_nml", "")
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "m_z_txt_raid_time_over", true)
      LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_open", false)
    end
  else
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_close", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_open", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_time", false)
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_bg_raid_rank", false)
  end
  if cell_data.m_SystemUnlockID == GlobalConfig.SYSTEM_ID.Ancient then
    local flag = AncientManager:CheckAncientEnterRedDot()
    LuaBehaviourUtil.setObjectVisible(luaBehaviour, "c_common_redpoint", flag ~= 0)
  end
end

return GuildActiveSubPanel
