local Form_BondPhonePop = class("Form_BondPhonePop", require("UI/UIFrames/Form_BondPhonePopUI"))

function Form_BondPhonePop:SetInitParam(param)
end

function Form_BondPhonePop:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_phone_TMP_InputField.onEndEdit:AddListener(function()
    self:CheckButtonStatus()
  end)
  self.m_inputfield_code_TMP_InputField.onEndEdit:AddListener(function()
    self:CheckButtonStatus()
  end)
  QSDKManager:Initialize()
end

function Form_BondPhonePop:OnActive()
  self.super.OnActive(self)
  self.m_updateAdd = 0
  local tParam = self.m_csui.m_param
  if tParam.iType == 1 then
    self:RefreshInputView()
  elseif tParam.iType == 2 then
    self:RefreshSuccessView(tParam.phone)
  elseif tParam.iType == 3 then
    self:RefreshFailedView()
  end
end

function Form_BondPhonePop:RefreshInputView()
  self.m_pnl_input:SetActive(true)
  self.m_pnl_input_verification:SetActive(false)
  self.m_pnl_bond_fail:SetActive(false)
  self.m_z_txt_title_bond1:SetActive(true)
  self.m_z_txt_title_bond_success:SetActive(false)
  self.m_inputfield_phone_TMP_InputField.text = ""
  self.m_inputfield_code_TMP_InputField.text = ""
  self:CheckButtonStatus()
end

function Form_BondPhonePop:RefreshSuccessView(phone)
  self.m_pnl_input:SetActive(false)
  self.m_pnl_input_verification:SetActive(true)
  self.m_pnl_bond_fail:SetActive(false)
  self.m_z_txt_title_bond1:SetActive(false)
  self.m_z_txt_title_bond_success:SetActive(true)
  local _phone = "*******" .. string.sub(phone, -4)
  self.m_txt_phonenum_Text.text = _phone
  self.m_txt_account_Text.text = UserDataManager:GetAccountID()
end

function Form_BondPhonePop:RefreshFailedView()
  self.m_pnl_input:SetActive(false)
  self.m_pnl_input_verification:SetActive(false)
  self.m_pnl_bond_fail:SetActive(true)
  self.m_z_txt_title_bond1:SetActive(false)
  self.m_z_txt_title_bond_success:SetActive(false)
end

function Form_BondPhonePop:OnInactive()
  self.super.OnInactive(self)
end

function Form_BondPhonePop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_BondPhonePop:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_BondPhonePop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_BondPhonePop:OnUpdate(dt)
  if self.m_updateCode and self.m_updateCode > 0 then
    self.m_updateAdd = self.m_updateAdd + dt
    if self.m_updateAdd >= 1 then
      self.m_updateCode = self.m_updateCode - self.m_updateAdd
      if self.m_updateCode <= 0 then
        self.m_updateCode = nil
        self.m_btn_code:SetActive(true)
        self.m_btn_code_grey:SetActive(false)
      else
        self.m_txt_code_cd_Text.text = string.format("%d秒后重新获取", math.ceil(self.m_updateCode))
      end
      self.m_updateAdd = 0
    end
  end
end

function Form_BondPhonePop:CheckButtonStatus()
  local phone = self.m_inputfield_phone_TMP_InputField.text
  local code = self.m_inputfield_code_TMP_InputField.text
  local isEnabled = true
  if not self:isMobileNumber(phone) or code == "" then
    isEnabled = false
  end
  if isEnabled then
    self.m_btn_input_yes:SetActive(true)
    self.m_btn_input_gray:SetActive(false)
  else
    self.m_btn_input_yes:SetActive(false)
    self.m_btn_input_gray:SetActive(true)
  end
end

function Form_BondPhonePop:OnBtncodeClicked()
  local phone = self.m_inputfield_phone_TMP_InputField.text
  if not self:isMobileNumber(phone) then
    return
  end
  QSDKManager:GetPhoneVerifyCode(phone, function()
    self.m_updateCode = 60
    self.m_txt_code_cd_Text.text = string.format("%d秒后重新获取", math.ceil(self.m_updateCode))
    self.m_btn_code:SetActive(false)
    self.m_btn_code_grey:SetActive(true)
  end, function(message)
    if message and message ~= "" then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, message)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, "获取验证码失败")
    end
  end)
end

function Form_BondPhonePop:OnBtninputyesClicked()
  local phone = self.m_inputfield_phone_TMP_InputField.text
  if not self:isMobileNumber(phone) then
    return
  end
  local code = self.m_inputfield_code_TMP_InputField.text
  if code == "" then
    return
  end
  QSDKManager:LoginWithPhone(phone, code, function(data)
    log.info(table.serialize(data))
    local msg = MTTDProto.Cmd_Role_BindAccount_CS()
    msg.sAccountName = "quicksdk_134_" .. data.uid
    local authKey = {}
    authKey.quick_uid = data.uid
    authKey.quick_username = data.username
    authKey.token = data.authToken
    authKey.quick_parent_channel_code = QSDKManager:GetParentChannelType()
    authKey.quick_channel_code = QSDKManager:GetChannelType()
    authKey.quick_sub_channel_code = QSDKManager:GetSubChannelCode()
    
    local function encode_kv(tbl)
      local list = {}
      for k, v in pairs(tbl) do
        table.insert(list, string.format("%s=%s", k, tostring(v)))
      end
      return table.concat(list, "&")
    end
    
    msg.sAuthKey = encode_kv(authKey)
    
    local function OnRoleBindAccountSC(sc, msg)
      local vAccountInfo = UserDataManager:GetAccountInfo()
      if vAccountInfo then
        vAccountInfo[#vAccountInfo + 1] = sc.stAccountInfo
      end
      self:RefreshSuccessView(phone)
    end
    
    local function OnRoleBindAccountFailed(msg)
      log.error("OnRoleBindAccountFailed:" .. tostring(msg.rspcode))
      self:RefreshFailedView()
    end
    
    RPCS():Role_BindAccount(msg, OnRoleBindAccountSC, OnRoleBindAccountFailed)
  end, function(message)
    if message and message ~= "" then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, message)
    else
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, "绑定失败")
    end
  end)
end

function Form_BondPhonePop:OnBtnveryesClicked()
  self:CloseForm()
end

function Form_BondPhonePop:OnBtnfailyesClicked()
  self:CloseForm()
end

function Form_BondPhonePop:isMobileNumber(phone)
  if type(phone) ~= "string" then
    return false
  end
  phone = phone:match("^%s*(.-)%s*$")
  return phone:match("^1[3-9]%d%d%d%d%d%d%d%d%d$") ~= nil
end

function Form_BondPhonePop:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_BondPhonePop", Form_BondPhonePop)
return Form_BondPhonePop
