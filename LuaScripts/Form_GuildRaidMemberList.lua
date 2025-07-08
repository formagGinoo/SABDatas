local Form_GuildRaidMemberList = class("Form_GuildRaidMemberList", require("UI/UIFrames/Form_GuildRaidMemberListUI"))
local vFilterTabConfig = {
  {iIndex = 1, sTitle = 20066},
  {iIndex = 2, sTitle = 20067}
}

function Form_GuildRaidMemberList:SetInitParam(param)
end

function Form_GuildRaidMemberList:AfterInit()
  self.super.AfterInit(self)
  local guildGridData = {
    itemClkBackFun = handler(self, self.OnRecordItemClk)
  }
  self.m_listInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_record_list_InfinityGrid, "Guild/UGuildBossRecordItem", guildGridData)
  self.m_listInfinityGrid:RegisterButtonCallback("c_btn_search", handler(self, self.OnRecordItemClk))
  self.m_widgetBtnFilter = self:createFilterButton(self.m_common_filter)
end

function Form_GuildRaidMemberList:OnActive()
  self.super.OnActive(self)
  self.m_personalHistoryList = {}
  self.m_personalHistoryTab = {}
  self.m_curFilterIndex = 1
  self.m_bFilterDown = false
  self.m_personalHistoryList, self.m_personalHistoryTab = GuildManager:GetPersonalHistory()
  self.m_widgetBtnFilter:RefreshTabConfig(vFilterTabConfig, self.m_curFilterIndex, self.m_bFilterDown, handler(self, self.OnFilterChanged))
  self:OnFilterChanged(self.m_curFilterIndex, self.m_bFilterDown)
  GlobalManagerIns:TriggerWwiseBGMState(15)
  self.m_txt_membernum_Text.text = string.format(ConfigManager:GetCommonTextById(20048), table.getn(self.m_personalHistoryList), GuildManager:GetGuildMemberCount())
end

function Form_GuildRaidMemberList:OnInactive()
  self.super.OnInactive(self)
  self.m_personalHistoryList = {}
  self.m_personalHistoryTab = {}
end

function Form_GuildRaidMemberList:OnFilterChanged(iIndex, bDown)
  self.m_curFilterIndex = iIndex
  self.m_bFilterDown = bDown
  self.m_personalHistoryList = self:SortPersonalHistory(self.m_personalHistoryList, self.m_curFilterIndex, self.m_bFilterDown)
  self:RefreshUI()
end

function Form_GuildRaidMemberList:SortPersonalHistory(historyList, filterIndex, filterDown)
  local sortFun
  if self.m_curFilterIndex == 1 then
    function sortFun(data1, data2)
      if data1.iRealDamage == data2.iRealDamage then
        if data1.battleCount == data2.battleCount then
          return data1.iPower > data2.iPower
        else
          return data1.battleCount > data2.battleCount
        end
      elseif filterDown == false then
        return data1.iRealDamage > data2.iRealDamage
      else
        return data1.iRealDamage < data2.iRealDamage
      end
    end
  else
    function sortFun(data1, data2)
      if data1.battleCount == data2.battleCount then
        if data1.iRealDamage == data2.iRealDamage then
          return data1.iPower > data2.iPower
        else
          return data1.iRealDamage > data2.iRealDamage
        end
      elseif filterDown == false then
        return data1.battleCount > data2.battleCount
      else
        return data1.battleCount < data2.battleCount
      end
    end
  end
  table.sort(historyList, sortFun)
  return historyList
end

function Form_GuildRaidMemberList:RefreshUI()
  self.m_listInfinityGrid:ShowItemList(self.m_personalHistoryList)
  if table.getn(self.m_personalHistoryList) > 0 then
    self.m_listInfinityGrid:LocateTo(0)
  end
  UILuaHelper.SetActive(self.m_common_empty, table.getn(self.m_personalHistoryList) <= 0)
end

function Form_GuildRaidMemberList:OnRecordItemClk(index, go)
  local selIndex = index + 1
  if not self.m_personalHistoryList[selIndex] then
    return
  end
  local info = self.m_personalHistoryList[selIndex]
  if self.m_personalHistoryTab[info.stRoleId.iUid] then
    StackPopup:Push(UIDefines.ID_FORM_GUILDRAIDRECORDLIST, self.m_personalHistoryTab[info.stRoleId.iUid])
  end
end

function Form_GuildRaidMemberList:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildRaidMemberList:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuildRaidMemberList", Form_GuildRaidMemberList)
return Form_GuildRaidMemberList
