local Form_GuildCreate = class("Form_GuildCreate", require("UI/UIFrames/Form_GuildCreateUI"))
local GuildCreateCostStr = ConfigManager:GetGlobalSettingsByKey("GuildCreateCost")
local GuildMemberLevelStr = ConfigManager:GetGlobalSettingsByKey("GuildMemberLevel")
local __GuildJoinLevel = {
  {
    iIndex = 1,
    sTitle = 2000,
    level = 5
  }
}
local Default_Filter_Index = 1

function Form_GuildCreate:SetInitParam(param)
end

function Form_GuildCreate:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_InputField.onEndEdit:AddListener(function()
    self:CheckStrIsCorrect()
  end)
  self.m_inputfield_InputField.onValueChanged:AddListener(function()
    self:CheckStrIsCorrect()
  end)
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
  self:createResourceBar(self.m_top_resource)
end

function Form_GuildCreate:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_curJoinTypeFilterIndex = Default_Filter_Index
  self.m_curJoinLevelFilterIndex = Default_Filter_Index
  self.m_needItemId = nil
  self.m_needCost = nil
  self.m_guildIconId = self:GetDefaultGuildIcon()
  self:RefreshUI()
end

function Form_GuildCreate:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_inputfield_InputField.text = ""
end

function Form_GuildCreate:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_ChangeGuildIcon", handler(self, self.OnEventChangeGuildIcon))
  self:addEventListener("eGameEvent_Alliance_Create_Detail", handler(self, self.OnBtnReturnClicked))
  self:addEventListener("eGameEvent_Item_Jump", handler(self, self.OnBtnReturnClicked))
end

function Form_GuildCreate:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildCreate:GetDefaultGuildIcon()
  local GuildBadgeIns = ConfigManager:GetConfigInsByName("GuildBadge")
  local cfgAll = GuildBadgeIns:GetAll()
  local iconList = {}
  for i, v in pairs(cfgAll) do
    iconList[#iconList + 1] = v.m_BadgeID
  end
  
  local function sortFun(data1, data2)
    return data1 < data2
  end
  
  table.sort(iconList, sortFun)
  return iconList[1]
end

function Form_GuildCreate:RefreshUI()
  self.m_widgetBtnJoinTypeFilter:RefreshTabConfig(GuildManager.GuildJoinType, self.m_curJoinTypeFilterIndex, nil, handler(self, self.OnJoinTypeChanged), nil, nil, handler(self, self.OnJoinTypeFilterOpenCB))
  self.m_widgetBtnJoinLevelFilter:RefreshTabConfig(__GuildJoinLevel, self.m_curJoinLevelFilterIndex, nil, handler(self, self.OnJoinLevelChanged), handler(self, self.OnJoinLvBindCB), handler(self, self.OnJoinLvBindSelectCB), handler(self, self.OnJoinLevelFilterOpenCB))
  ResourceUtil:CreateGuildIconById(self.m_img_logo_Image, self.m_guildIconId)
  local vInfo = string.split(GuildCreateCostStr, ",")
  self.m_needItemId = tonumber(vInfo[1])
  self.m_needCost = tonumber(vInfo[2])
  ResourceUtil:CreatIconById(self.m_consume_icon_Image, self.m_needItemId)
  self.m_consume_quantity_Text.text = self.m_needCost
end

function Form_GuildCreate:OnJoinLvBindCB(goFilterTab, stTabConfig)
  goFilterTab.transform:Find("common_filter_tab_name"):GetComponent(T_TextMeshProUGUI).text = stTabConfig.sTitle
  local selectedObj = goFilterTab.transform:Find("c_img_seleted")
  if not utils.isNull(selectedObj) then
    local selectedText = selectedObj.transform:Find("c_txt_selected"):GetComponent(T_TextMeshProUGUI)
    selectedText.text = stTabConfig.sTitle
  end
end

function Form_GuildCreate:OnJoinLvBindSelectCB(stTagConfig)
  return stTagConfig.sTitle
end

function Form_GuildCreate:OnJoinTypeFilterOpenCB()
  self.m_widgetBtnJoinLevelFilter:OnBtnCloseClicked()
end

function Form_GuildCreate:OnJoinLevelFilterOpenCB()
  self.m_widgetBtnJoinTypeFilter:OnBtnCloseClicked()
end

function Form_GuildCreate:OnJoinTypeChanged(iIndex, bDown)
  self.m_curJoinTypeFilterIndex = iIndex
end

function Form_GuildCreate:OnJoinLevelChanged(iIndex, bDown)
  self.m_curJoinLevelFilterIndex = iIndex
end

function Form_GuildCreate:CheckStrIsCorrect()
  local text = self.m_inputfield_InputField.text
  if text ~= "" then
    local str = string.GetTextualNorms(text)
    self.m_inputfield_InputField.text = str
  end
end

function Form_GuildCreate:OnEventChangeGuildIcon(iconId)
  ResourceUtil:CreateGuildIconById(self.m_img_logo_Image, iconId)
  self.m_guildIconId = iconId
end

function Form_GuildCreate:OnBtnchangelogoClicked()
  StackPopup:Push(UIDefines.ID_FORM_GUILDCREATELOGO)
end

function Form_GuildCreate:OnBtnconsumeClicked()
  local nameStr = self.m_inputfield_InputField.text
  if nameStr ~= "" then
    local ownerNum = ItemManager:GetItemNum(self.m_needItemId, true)
    if ownerNum < self.m_needCost then
      utils.CheckAndPushCommonTips({
        tipsID = 1222,
        func1 = function()
          QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
          StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDCREATE)
        end
      })
      return
    end
    local spacing = string.checkFirstCharIsSpacing(nameStr)
    if spacing then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30020)
      return
    end
    local joinTypeData = GuildManager.GuildJoinType[self.m_curJoinTypeFilterIndex]
    local joinLevelData = __GuildJoinLevel[self.m_curJoinLevelFilterIndex]
    GuildManager:ReqCreateAlliance(nameStr, self.m_guildIconId, joinTypeData.joinType, joinLevelData.level)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10236)
  end
end

function Form_GuildCreate:OnBtnemptyClicked()
  self:OnBtnReturnClicked()
end

function Form_GuildCreate:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDCREATE)
end

function Form_GuildCreate:IsOpenGuassianBlur()
  return true
end

function Form_GuildCreate:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildCreate", Form_GuildCreate)
return Form_GuildCreate
