local Form_GuildEditor = class("Form_GuildEditor", require("UI/UIFrames/Form_GuildEditorUI"))
local GuildMemberLevelStr = ConfigManager:GetGlobalSettingsByKey("GuildMemberLevel")
local __GuildJoinLevel = {
  {
    iIndex = 1,
    sTitle = 2000,
    level = 5
  }
}

function Form_GuildEditor:SetInitParam(param)
end

function Form_GuildEditor:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnJoinTypeFilter = self:createFilterButton(self.m_filter_type)
  self.m_widgetBtnJoinLevelFilter = self:createFilterButton(self.m_filter_rank)
  local vInfo = string.split(GuildMemberLevelStr, ",")
  for i, v in ipairs(vInfo) do
    local str = string.format(ConfigManager:GetCommonTextById(20033), v)
    if __GuildJoinLevel[i] then
      __GuildJoinLevel[i].iIndex = i
      __GuildJoinLevel[i].sTitle = str
      __GuildJoinLevel[i].level = tonumber(v)
    else
      __GuildJoinLevel[i] = {
        iIndex = i,
        sTitle = str,
        level = tonumber(v)
      }
    end
  end
end

function Form_GuildEditor:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:RefreshUI()
end

function Form_GuildEditor:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildEditor:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_ChangeGuildIcon", handler(self, self.OnEventChangeGuildIcon))
  self:addEventListener("eGameEvent_Alliance_ChangeRecruit", handler(self, self.RefreshNotice))
  self:addEventListener("eGameEvent_Alliance_Destroy", handler(self, self.OnGuildDestroy))
  self:addEventListener("eGameEvent_Alliance_ChangeSetting", handler(self, self.OnBtnReturnClicked))
  self:addEventListener("eGameEvent_Alliance_ChangeName", handler(self, self.RefreshRoleName))
end

function Form_GuildEditor:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildEditor:RefreshRoleName()
  local guildData = GuildManager:GetOwnerGuildDetail()
  self.m_txt_name_Text.text = guildData.stBriefData.sName
end

function Form_GuildEditor:RefreshUI()
  local guildData = GuildManager:GetOwnerGuildDetail()
  self.m_txt_name_Text.text = guildData.stBriefData.sName
  self.m_txt_notice_Text.text = guildData.stBriefData.sRecruit
  self.m_curJoinTypeFilterIndex = guildData.stBriefData.iJoinType + 1
  self.m_curJoinLevelFilterIndex = self:GetJoinLevelIndexByLevel(guildData.stBriefData.iJoinLevel)
  self.m_widgetBtnJoinTypeFilter:RefreshTabConfig(GuildManager.GuildJoinType, self.m_curJoinTypeFilterIndex, nil, handler(self, self.OnJoinTypeChanged), nil, nil, handler(self, self.OnJoinTypeFilterOpenCB))
  self.m_widgetBtnJoinLevelFilter:RefreshTabConfig(__GuildJoinLevel, self.m_curJoinLevelFilterIndex, nil, handler(self, self.OnJoinLevelChanged), handler(self, self.OnJoinLvBindCB), handler(self, self.OnJoinLvBindSelectCB), handler(self, self.OnJoinLevelFilterOpenCB))
  local memberData = GuildManager:GetOwnerGuildMemberDataByUID(RoleManager:GetUID())
  if memberData then
    self.m_btn_name_editor:SetActive(memberData.iPost == GuildManager.AlliancePost.Master)
    self.m_btn_change_logo:SetActive(memberData.iPost ~= GuildManager.AlliancePost.Member)
    self.m_btn_dissolution:SetActive(memberData.iPost == GuildManager.AlliancePost.Master)
    self.m_btn_name_notice_editor:SetActive(memberData.iPost ~= GuildManager.AlliancePost.Member)
  else
    self.m_btn_name_editor:SetActive(false)
    self.m_btn_change_logo:SetActive(false)
    self.m_btn_dissolution:SetActive(false)
    self.m_btn_name_notice_editor:SetActive(false)
  end
  local iconId = self.m_guildIconId or guildData.stBriefData.iBadgeId
  ResourceUtil:CreateGuildIconById(self.m_img_logo_Image, iconId)
end

function Form_GuildEditor:RefreshNotice()
  local guildData = GuildManager:GetOwnerGuildDetail()
  self.m_txt_notice_Text.text = guildData.stBriefData.sRecruit
end

function Form_GuildEditor:OnGuildDestroy()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDEDITOR)
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_GuildEditor:GetJoinLevelIndexByLevel(lv)
  for i, v in ipairs(__GuildJoinLevel) do
    if v.level == lv then
      return v.iIndex
    end
  end
  return 1
end

function Form_GuildEditor:GetJoinLevelByIndex(index)
  for i, v in ipairs(__GuildJoinLevel) do
    if v.iIndex == index then
      return v.level
    end
  end
  return 1
end

function Form_GuildEditor:OnJoinTypeFilterOpenCB()
  self.m_widgetBtnJoinLevelFilter:OnBtnCloseClicked()
end

function Form_GuildEditor:OnJoinLevelFilterOpenCB()
  self.m_widgetBtnJoinTypeFilter:OnBtnCloseClicked()
end

function Form_GuildEditor:OnJoinTypeChanged(iIndex, bDown)
  self.m_curJoinTypeFilterIndex = iIndex
end

function Form_GuildEditor:OnJoinLevelChanged(iIndex, bDown)
  self.m_curJoinLevelFilterIndex = iIndex
end

function Form_GuildEditor:OnJoinLvBindCB(goFilterTab, stTabConfig)
  goFilterTab.transform:Find("common_filter_tab_name"):GetComponent(T_TextMeshProUGUI).text = stTabConfig.sTitle
  local selectedObj = goFilterTab.transform:Find("c_img_seleted")
  if not utils.isNull(selectedObj) then
    local selectedText = selectedObj.transform:Find("c_txt_selected"):GetComponent(T_TextMeshProUGUI)
    selectedText.text = stTabConfig.sTitle
  end
end

function Form_GuildEditor:OnJoinLvBindSelectCB(stTagConfig)
  return stTagConfig.sTitle
end

function Form_GuildEditor:OnEventChangeGuildIcon(iconId)
  ResourceUtil:CreateGuildIconById(self.m_img_logo_Image, iconId)
  self.m_guildIconId = iconId
end

function Form_GuildEditor:OnBtnchangelogoClicked()
  StackPopup:Push(UIDefines.ID_FORM_GUILDCREATELOGO)
end

function Form_GuildEditor:OnBtnnamenoticeeditorClicked()
  local isInLimitTime, limitStr = ActivityManager:IsInForbidCustomLimitTime()
  if isInLimitTime == true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST_SPE, limitStr)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_GUILDNOTICECHANGE, {openType = 2})
end

function Form_GuildEditor:OnBtnnameeditorClicked()
  local isInLimitTime, limitStr = ActivityManager:IsInForbidCustomLimitTime()
  if isInLimitTime == true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST_SPE, limitStr)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_GUILDNAMECHANGE)
end

function Form_GuildEditor:OnBtndissolutionClicked()
  local inTime = GuildManager:IsGuildBossTime()
  if inTime then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10208)
    return
  end
  local guildData = GuildManager:GetOwnerGuildDetail()
  if table.getn(guildData.vMember) == 1 then
    utils.popUpDirectionsUI({
      tipsID = 1502,
      func1 = function()
        GuildManager:ReqAllianceDestroy()
      end
    })
  else
    utils.popUpDirectionsUI({tipsID = 1511})
  end
end

function Form_GuildEditor:OnBtnemptyClicked()
  self:OnBtnReturnClicked()
end

function Form_GuildEditor:OnBtnReturnClicked()
  local guildData = GuildManager:GetOwnerGuildDetail()
  local level = self:GetJoinLevelByIndex(self.m_curJoinLevelFilterIndex)
  if guildData then
    local iJoinType = self.m_curJoinTypeFilterIndex ~= guildData.stBriefData.iJoinType + 1 and self.m_curJoinTypeFilterIndex - 1 or nil
    local iBadgeId = self.m_guildIconId ~= guildData.stBriefData.iBadgeId and self.m_guildIconId or nil
    local iJoinLevel = guildData.stBriefData.iJoinLevel ~= level and level or nil
    local vChangeSettingsType = {}
    if iJoinType then
      table.insert(vChangeSettingsType, GuildManager.AllianceSettingsType.JoinType)
    end
    if iBadgeId then
      table.insert(vChangeSettingsType, GuildManager.AllianceSettingsType.Badge)
    end
    if iJoinLevel then
      table.insert(vChangeSettingsType, GuildManager.AllianceSettingsType.JoinLevel)
    end
    if iJoinType or iBadgeId or iJoinLevel then
      local param = {}
      param.vChangeSettingsType = vChangeSettingsType
      param.iBadgeId = iBadgeId
      param.iLanguageId = guildData.stBriefData.iLanguageId
      param.iJoinType = iJoinType
      param.iJoinLevel = level
      GuildManager:ReqAllianceChangeSetting(param)
    end
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDEDITOR)
end

function Form_GuildEditor:IsOpenGuassianBlur()
  return true
end

function Form_GuildEditor:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildEditor", Form_GuildEditor)
return Form_GuildEditor
