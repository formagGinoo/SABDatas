local UISubPanelBase = require("UI/Common/UISubPanelBase")
local GuildNewsSubPanel = class("GuildNewsSubPanel", UISubPanelBase)

function GuildNewsSubPanel:OnInit()
end

function GuildNewsSubPanel:OnFreshData()
  self:refreshLoopScroll()
end

function GuildNewsSubPanel:refreshLoopScroll()
  local data = GuildManager:GetGuildHistory()
  local all_cell_size = {}
  for i, v in ipairs(data or {}) do
    if v.showTime then
      all_cell_size[i] = Vector2.New(1166, 148)
    else
      all_cell_size[i] = Vector2.New(1166, 80)
    end
  end
  if self.m_loop_scroll_view == nil then
    local loopscroll = self.m_new_list
    local params = {
      show_data = data,
      one_line_count = 1,
      loop_scroll_object = loopscroll,
      all_cell_size = all_cell_size,
      update_cell = function(index, cell_object, cell_data)
        self:updateScrollViewCell(index, cell_object, cell_data)
      end
    }
    self.m_loop_scroll_view = LoopScrollViewUtil.new(params)
  else
    self.m_loop_scroll_view:reloadData(data, nil, all_cell_size)
  end
end

function GuildNewsSubPanel:updateScrollViewCell(index, cell_object, cell_data)
  local transform = cell_object.transform
  local luaBehaviour = UIUtil.findLuaBehaviour(transform)
  LuaBehaviourUtil.setObjectVisible(luaBehaviour, "bg_days", cell_data.showTime)
  if cell_data.showTime then
    local time = TimeUtil:TimerToString2(cell_data.iTime)
    LuaBehaviourUtil.setTextMeshPro(luaBehaviour, "txt_days", time)
  end
  LuaBehaviourUtil.setText(luaBehaviour, "txt_news", self:GetGuildNewsByType(cell_data))
end

function GuildNewsSubPanel:GetGuildNewsByType(cell_data)
  local tips = ""
  local id = GuildManager.AllianceHistoryTypeStr[cell_data.iType]
  if id then
    tips = ConfigManager:GetClientMessageTextById(id)
    if cell_data.iType == GuildManager.AllianceHistoryType.KickAlliance then
      tips = string.gsubnumberreplace(tips, cell_data.sOperatorName, cell_data.sMemberName)
    elseif cell_data.iType == GuildManager.AllianceHistoryType.LevelUp then
      tips = string.gsubnumberreplace(tips, cell_data.iLevel)
    elseif cell_data.iType == GuildManager.AllianceHistoryType.PostToLeader or cell_data.iType == GuildManager.AllianceHistoryType.PostToNormal or cell_data.iType == GuildManager.AllianceHistoryType.JoinAlliance then
      tips = string.gsubnumberreplace(tips, cell_data.sMemberName)
    elseif cell_data.iType == GuildManager.AllianceHistoryType.Transfer then
      tips = string.gsubnumberreplace(tips, cell_data.sMemberName)
    else
      tips = string.gsubnumberreplace(tips, cell_data.sOperatorName)
    end
  end
  return tips
end

return GuildNewsSubPanel
