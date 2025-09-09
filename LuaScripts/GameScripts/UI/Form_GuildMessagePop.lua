local Form_GuildMessagePop = class("Form_GuildMessagePop", require("UI/UIFrames/Form_GuildMessagePopUI"))
local __GuildMessageCount = tonumber(ConfigManager:GetGlobalSettingsByKey("GuildMessageCount") or 0)

function Form_GuildMessagePop:SetInitParam(param)
end

function Form_GuildMessagePop:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_InputField.onValueChanged:AddListener(function()
    self:OnValueChangedRefresh()
  end)
  self.m_inputfield_InputField.characterLimit = __GuildMessageCount
  self.m_characterLimit = __GuildMessageCount
  self.m_top_toggle_Toggle.onValueChanged:AddListener(function()
    self:OnTopToggleValueChanged()
  end)
  self.m_notify_toggle_Toggle.onValueChanged:AddListener(function()
    self:OnNotifyToggleValueChanged()
  end)
  self.m_txtTopMultiColor = self.m_z_txt_top_Text:GetComponent("MultiColorChange")
  self.m_txtNotifyMultiColor = self.m_z_txt_notify_Text:GetComponent("MultiColorChange")
end

function Form_GuildMessagePop:OnActive()
  self.super.OnActive(self)
  self.m_inputfield_InputField.text = ""
  self.m_topFlag = false
  self.m_notifyFlag = false
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_GuildMessagePop:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildMessagePop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildMessagePop:AddEventListeners()
  self:addEventListener("eGameEvent_Alliance_MessageNoticeLeave", handler(self, self.OnBtnCloseClicked))
end

function Form_GuildMessagePop:RefreshUI()
  local broadcast = GuildManager:CheckOwnHaveBroadcastMessagePermission()
  local num = GuildManager:GetSendAllMessageTimesToday()
  local cfgNum = GuildManager:GetSendAllMessageDailyNum()
  self.m_canSendAllMessageFlag = num < cfgNum
  self.m_toggle_notify:SetActive(broadcast)
  local pin = GuildManager:CheckOwnHavePinMessagePermission()
  self.m_toggle_top:SetActive(pin)
  self.m_top_toggle_Toggle.isOn = false
  self.m_notify_toggle_Toggle.isOn = false
  self.m_txtTopMultiColor:SetColorByIndex(self.m_canSendAllMessageFlag and 1 or 0)
  self.m_txtNotifyMultiColor:SetColorByIndex(self.m_canSendAllMessageFlag and 1 or 0)
  self.m_notify_toggle_Toggle.interactable = self.m_canSendAllMessageFlag
  self.m_localNotifyFlag = LocalDataManager:GetIntSimple("GuildMessagePop_Notify_All", 0) == 1
  self:RefreshStrNum()
end

function Form_GuildMessagePop:OnValueChangedRefresh()
  self:CheckStrIsCorrect()
  self:RefreshStrNum()
end

function Form_GuildMessagePop:OnTopToggleValueChanged()
  self.m_topFlag = self.m_top_toggle_Toggle.isOn
  local topId = GuildManager:GetTopMessageId()
  if self.m_topFlag and topId and topId ~= 0 then
    utils.popUpDirectionsUI({
      tipsID = 1245,
      func1 = function()
      end,
      func2 = function()
        self.m_top_toggle_Toggle.isOn = false
        self.m_topFlag = false
      end
    })
  end
end

function Form_GuildMessagePop:OnNotifyToggleValueChanged()
  self.m_notifyFlag = self.m_notify_toggle_Toggle.isOn
  if self.m_notifyFlag and not self.m_localNotifyFlag then
    local cfgNum = GuildManager:GetSendAllMessageDailyNum()
    utils.popUpDirectionsUI({
      tipsID = 1247,
      fContentCB = function(content)
        return string.gsubnumberreplace(content, cfgNum)
      end,
      func1 = function()
      end,
      func2 = function()
        self.m_notify_toggle_Toggle.isOn = false
        self.m_notifyFlag = false
      end,
      showToggle = true,
      toggleText = ConfigManager:GetCommonTextById(2034),
      toggleCallBack = function(isOn)
        if isOn then
          LocalDataManager:SetIntSimple("GuildMessagePop_Notify_All", 1)
          self.m_localNotifyFlag = true
        end
      end
    })
  end
end

function Form_GuildMessagePop:CheckStrIsCorrect()
  local text = self.m_inputfield_InputField.text
  if text ~= "" then
    local str = string.GetTextualNormsGuildNotice(text)
    self.m_inputfield_InputField.text = str
  end
end

function Form_GuildMessagePop:RefreshStrNum()
  local num = string.utf8len_WordCount(self.m_inputfield_InputField.text)
  self.m_txt_notice_max_Text.text = num .. "/" .. self.m_characterLimit
  if num > self.m_characterLimit then
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 142, 38, 38, 200)
  else
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 0, 0, 0, 200)
  end
  self.m_btn_save:SetActive(0 < num)
  self.m_btn_save_grey:SetActive(num == 0)
end

function Form_GuildMessagePop:OnBtnsaveClicked()
  local text = self.m_inputfield_InputField.text
  if text == "" then
    return
  end
  local flag = GuildManager:CheckOwnHaveMessagePermission()
  if not flag then
    return
  end
  local iAllianceId = RoleManager:GetRoleAllianceInfo()
  if not iAllianceId then
    return
  end
  local iNoticeType = self.m_notifyFlag and 2 or 1
  GuildManager:ReqAllianceMessageNoticeLeaveCS(iAllianceId, text, iNoticeType, self.m_topFlag)
end

function Form_GuildMessagePop:IsOpenGuassianBlur()
  return true
end

function Form_GuildMessagePop:OnBtnCloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_GuildMessagePop:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_GuildMessagePop:OnDestroy()
  self.super.OnDestroy(self)
end

local fullscreen = true
ActiveLuaUI("Form_GuildMessagePop", Form_GuildMessagePop)
return Form_GuildMessagePop
