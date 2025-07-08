local Form_GuildNameChange = class("Form_GuildNameChange", require("UI/UIFrames/Form_GuildNameChangeUI"))

function Form_GuildNameChange:SetInitParam(param)
end

function Form_GuildNameChange:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_TMP_InputField.onValueChanged:AddListener(function()
    self:ResetTips()
  end)
end

function Form_GuildNameChange:OnActive()
  self.super.OnActive(self)
  self.m_canChangeName = false
  self.m_needItemId = nil
  self:AddEventListeners()
  self.m_inputfield_TMP_InputField.text = ""
  self:RefreshUI()
end

function Form_GuildNameChange:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildNameChange:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildNameChange:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_ChangeName", handler(self, self.SetRoleName))
  self:addEventListener("eGameEvent_Rename_SetNameNotOnly", handler(self, self.SetNameNotOnly))
end

function Form_GuildNameChange:RefreshUI()
  local itemId = MTTDProto.SpecialItem_FreeDiamond
  local needItemNum = 0
  local costStr = ConfigManager:GetGlobalSettingsByKey("GuildChangeNameCost")
  local costTab = utils.changeStringRewardToLuaTable(costStr)
  if costTab and costTab[1] then
    itemId = tonumber(costTab[1][1])
    needItemNum = tonumber(costTab[1][2])
    self.m_needItemId = itemId
  end
  local userItemNum = ItemManager:GetItemNum(itemId, true)
  ResourceUtil:CreateItemIcon(self.m_img_icon_diamond_Image, itemId)
  self.m_diamond_num_Text.text = needItemNum
  if needItemNum > userItemNum then
    self.m_canChangeName = false
    UILuaHelper.SetColor(self.m_diamond_num_Text, table.unpack(GlobalConfig.COMMON_COLOR.Red))
  else
    self.m_canChangeName = true
    UILuaHelper.SetColor(self.m_diamond_num_Text, table.unpack(GlobalConfig.COMMON_COLOR.Normal))
  end
  UILuaHelper.SetActive(self.m_btn_rename_light, needItemNum <= userItemNum)
  UILuaHelper.SetActive(self.m_btn_rename_gray, needItemNum > userItemNum)
  self:ChangeRandomNameTips(true)
end

function Form_GuildNameChange:RefreshRandomName(nameStr)
  self.m_inputfield_TMP_InputField.text = tostring(nameStr)
end

function Form_GuildNameChange:ChangeRandomNameTips(flag)
  UILuaHelper.SetActive(self.m_z_txt_cue_a, flag)
  UILuaHelper.SetActive(self.m_z_txt_cue_b, not flag)
end

function Form_GuildNameChange:OnBtnrenamelightClicked()
  local nameStr = self.m_inputfield_TMP_InputField.text
  if nameStr ~= "" then
    if not self.m_canChangeName and self.m_needItemId then
      local itemCfg = ItemManager:GetItemConfigById(self.m_needItemId)
      local str = ConfigManager:GetCommonTextById(20026)
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.format(str, tostring(itemCfg.m_mItemName)))
      return
    end
    local bDirty = DirtyCharManager:FilterString(nameStr)
    if bDirty then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30013)
      return
    end
    local spacing = string.checkFirstCharIsSpacing(nameStr)
    if spacing then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30020)
      return
    end
    GuildManager:ReqAllianceChangeName(string.trim(nameStr))
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10236)
  end
end

function Form_GuildNameChange:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDNAMECHANGE)
end

function Form_GuildNameChange:SetRoleName()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_GUILDNAMECHANGE)
end

function Form_GuildNameChange:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_GuildNameChange:ResetTips()
  self:CheckStrIsCorrect()
  self:ChangeRandomNameTips(true)
end

function Form_GuildNameChange:SetNameNotOnly()
  self:ChangeRandomNameTips(false)
end

function Form_GuildNameChange:CheckStrIsCorrect()
  local text = self.m_inputfield_TMP_InputField.text
  if text ~= "" then
    local str = string.GetTextualNorms(text)
    self.m_inputfield_TMP_InputField.text = str
  end
end

function Form_GuildNameChange:IsOpenGuassianBlur()
  return true
end

function Form_GuildNameChange:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildNameChange", Form_GuildNameChange)
return Form_GuildNameChange
