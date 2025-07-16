local Form_GuildCreateLogo = class("Form_GuildCreateLogo", require("UI/UIFrames/Form_GuildCreateLogoUI"))

function Form_GuildCreateLogo:SetInitParam(param)
end

function Form_GuildCreateLogo:AfterInit()
  self.super.AfterInit(self)
  local guildGridData = {
    itemClkBackFun = handler(self, self.OnGuildItemClk)
  }
  self.m_guildIconListInfinityGrid = require("UI/Common/UICommonItemInfinityGrid").new(self.m_guild_icon_list_InfinityGrid, "Guild/UIGuildIconListItem", guildGridData)
  self.m_guildIconListInfinityGrid:RegisterButtonCallback("c_img_guild_bg", handler(self, self.OnGuildItemClk))
end

function Form_GuildCreateLogo:OnActive()
  self.super.OnActive(self)
  self.m_selItemIndex = 1
  self.m_chooseIconId = nil
  self.m_guildIconList = self:GetIconDataList()
  self.m_guildIconListInfinityGrid:ShowItemList(self.m_guildIconList)
  self.m_guildIconListInfinityGrid:LocateTo(0)
  local index = self:GetChooseLogoIndex() or self.m_selItemIndex
  self:OnGuildItemClk(index - 1)
end

function Form_GuildCreateLogo:OnInactive()
  self.super.OnInactive(self)
  self.m_chooseIconId = nil
  if self.m_guildIconListInfinityGrid and self.m_selItemIndex then
    self.m_guildIconListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
  end
  self.m_selItemIndex = nil
end

function Form_GuildCreateLogo:GetChooseLogoIndex()
  local guildData = GuildManager:GetOwnerGuildDetail()
  if guildData then
    for i, v in ipairs(self.m_guildIconList) do
      if v.m_BadgeID == guildData.stBriefData.iBadgeId then
        return i
      end
    end
  end
  return
end

function Form_GuildCreateLogo:GetIconDataList()
  local _, allianceLevel = RoleManager:GetRoleAllianceInfo()
  local GuildBadgeIns = ConfigManager:GetConfigInsByName("GuildBadge")
  local cfgAll = GuildBadgeIns:GetAll()
  local iconList = {}
  allianceLevel = tonumber(allianceLevel or 0)
  for i, v in pairs(cfgAll) do
    iconList[#iconList + 1] = {
      m_BadgeID = v.m_BadgeID,
      lockFlag = allianceLevel < v.m_UnlockLevel,
      unlockLevel = v.m_UnlockLevel
    }
  end
  
  local function sortFun(data1, data2)
    return data1.m_BadgeID < data2.m_BadgeID
  end
  
  table.sort(iconList, sortFun)
  return iconList
end

function Form_GuildCreateLogo:OnGuildItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local chooseFJItemData = self.m_guildIconList[fjItemIndex]
  if chooseFJItemData then
    if chooseFJItemData.lockFlag then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.gsubnumberreplace(ConfigManager:GetCommonTextById(20054), chooseFJItemData.unlockLevel))
      return
    end
    self.m_guildIconListInfinityGrid:OnChooseItem(self.m_selItemIndex, false)
    self.m_guildIconListInfinityGrid:OnChooseItem(fjItemIndex, true)
    self.m_selItemIndex = fjItemIndex
    self.m_chooseIconId = chooseFJItemData.m_BadgeID
  end
end

function Form_GuildCreateLogo:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildCreateLogo:OnBtnemptyClicked()
  self:OnBtnReturnClicked()
end

function Form_GuildCreateLogo:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDCREATELOGO)
end

function Form_GuildCreateLogo:OnBtnyesClicked()
  local memberData = GuildManager:GetOwnerGuildMemberDataByUID(RoleManager:GetUID())
  if memberData and memberData.iPost == GuildManager.AlliancePost.Member then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10244)
    self:OnBtnReturnClicked()
    return
  end
  if self.m_chooseIconId then
    self:broadcastEvent("eGameEvent_Alliance_ChangeGuildIcon", self.m_chooseIconId)
  end
  self:OnBtnReturnClicked()
end

function Form_GuildCreateLogo:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuildCreateLogo", Form_GuildCreateLogo)
return Form_GuildCreateLogo
