local Form_PersonalRename = class("Form_PersonalRename", require("UI/UIFrames/Form_PersonalRenameUI"))

function Form_PersonalRename:SetInitParam(param)
end

function Form_PersonalRename:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_TMP_InputField.onEndEdit:AddListener(function()
    self:CheckNameDuplication()
  end)
  self.m_inputfield_TMP_InputField.onValueChanged:AddListener(function()
    self:ResetTips()
  end)
end

function Form_PersonalRename:OnActive()
  self.super.OnActive(self)
  self.m_canChangeName = false
  self.m_needItemId = nil
  self:AddEventListeners()
  self.m_inputfield_TMP_InputField.text = ""
  self:RefreshUI()
  self.guideReName = self.m_csui.m_param
  RoleManager:ReqGetRandomNameFirst()
end

function Form_PersonalRename:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_PersonalRename:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalRename:AddEventListeners()
  self:addEventListener("eGameEvent_Rename_GetRename", handler(self, self.RefreshRandomName))
  self:addEventListener("eGameEvent_Rename_SetName", handler(self, self.SetRoleName))
  self:addEventListener("eGameEvent_Rename_SetNameNotOnly", handler(self, self.SetNameNotOnly))
end

function Form_PersonalRename:RefreshUI()
  local itemId = MTTDProto.SpecialItem_FreeDiamond
  local needItemNum = 0
  local costStr = ConfigManager:GetGlobalSettingsByKey("RenameItem0")
  local costTab = utils.changeStringRewardToLuaTable(costStr)
  if costTab and costTab[1] then
    itemId = costTab[1][1]
  end
  local userItemNum = ItemManager:GetItemNum(itemId, true)
  if 0 < userItemNum then
    needItemNum = 1
    self.m_needItemId = itemId
  else
    local costStr2 = ConfigManager:GetGlobalSettingsByKey("RenameItem")
    local costTab2 = utils.changeStringRewardToLuaTable(costStr2)
    if costTab2 and costTab2[1] then
      itemId = costTab2[1][1]
      needItemNum = costTab2[1][2]
      self.m_needItemId = itemId
    else
      log.error("GlobalSettings  AccountnameCost  can not find")
    end
  end
  ResourceUtil:CreateItemIcon(self.m_icon_diamond_Image, itemId)
  ResourceUtil:CreateItemIcon(self.m_img_icon_diamond_Image, itemId)
  userItemNum = ItemManager:GetItemNum(itemId, true)
  self.m_num_resource_Text.text = userItemNum
  self.m_diamond_num_Text.text = needItemNum
  if needItemNum > userItemNum then
    self.m_canChangeName = false
    UILuaHelper.SetColor(self.m_diamond_num_Text, table.unpack(GlobalConfig.COMMON_COLOR.Red))
  else
    self.m_canChangeName = true
    UILuaHelper.SetColor(self.m_diamond_num_Text, table.unpack(GlobalConfig.COMMON_COLOR.Normal))
  end
  UILuaHelper.SetActive(self.m_node_rename_light, needItemNum <= userItemNum)
  UILuaHelper.SetActive(self.m_node_rename_gray, needItemNum > userItemNum)
  self:ChangeRandomNameTips(true)
end

function Form_PersonalRename:RefreshRandomName(nameStr)
  self.m_inputfield_TMP_InputField.text = tostring(nameStr)
end

function Form_PersonalRename:ChangeRandomNameTips(flag)
  UILuaHelper.SetActive(self.m_z_txt_cue_a, flag)
  UILuaHelper.SetActive(self.m_z_txt_cue_b, not flag)
end

function Form_PersonalRename:OnBtnrenameClicked()
  local nameStr = self.m_inputfield_TMP_InputField.text
  if nameStr ~= "" then
    self.guideReName = false
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
    local isdigit = string.isdigit(nameStr)
    if isdigit then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30018)
      return
    end
    RoleManager:ReqRoleSetName(string.trim(nameStr))
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetCommonTextById(20022))
  end
end

function Form_PersonalRename:OnBtnCloseClicked()
  if self.guideReName then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_PersonalRename:SetRoleName()
  self:CloseForm()
end

function Form_PersonalRename:OnRandobtnClicked()
  RoleManager:ReqGetRandomName()
end

function Form_PersonalRename:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_PersonalRename:CheckNameDuplication()
  if self.m_inputfield_TMP_InputField.text ~= "" then
    self:CheckStrIsCorrect()
    RoleManager:ReqVerifyNameIsOnly(self.m_inputfield_TMP_InputField.text)
  end
end

function Form_PersonalRename:ResetTips()
  self:CheckStrIsCorrect()
  self:ChangeRandomNameTips(true)
end

function Form_PersonalRename:SetNameNotOnly()
  self:ChangeRandomNameTips(false)
end

function Form_PersonalRename:CheckStrIsCorrect()
  local text = self.m_inputfield_TMP_InputField.text
  if text ~= "" then
    local str = string.GetTextualNorms(text)
    self.m_inputfield_TMP_InputField.text = str
  end
end

function Form_PersonalRename:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PersonalRename", Form_PersonalRename)
return Form_PersonalRename
