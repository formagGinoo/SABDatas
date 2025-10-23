local Form_ActivityReturnee = class("Form_ActivityReturnee", require("UI/UIFrames/Form_ActivityReturneeUI"))

function Form_ActivityReturnee:SetInitParam(param)
end

function Form_ActivityReturnee:AfterInit()
  self.super.AfterInit(self)
end

function Form_ActivityReturnee:OnActive()
  self.super.OnActive(self)
  local params = self.m_csui.m_param
  self.isFromPushFace = params and params.IsFormPushFace
  self.m_csui.m_param = nil
  if self.isFromPushFace then
    local activity = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
    if activity then
      activity:SetPushFaceRemind()
    end
    local avgCfg = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("PlayersReturnAVG")
    if not avgCfg:GetError() and avgCfg.m_Value ~= "" then
      self:broadcastEvent("eGameEvent_PlayAVG", avgCfg.m_Value, function()
        self.lockClickEnd = TimeUtil:GetServerTimeS() + 2
        CS.UI.UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "", 1, 0)
        self:broadcastEvent("eGameEvent_PlayHallBGM")
      end)
    end
    self.lockClickEnd = TimeUtil:GetServerTimeS() + 2
  end
  self.returnTaskJumpID = 0
  self.signJumpID = 0
  local returnTaskItems = {}
  local signItems = {}
  local showTaskRed = false
  local showSignRed = false
  local returnTaskAct = ActivityManager:GetActivityByType(MTTD.ActivityType_ReturnTask)
  if returnTaskAct and returnTaskAct.m_stSdpConfig ~= nil then
    self.returnTaskJumpID = tonumber(returnTaskAct.m_stSdpConfig.stCommonCfg.sJumpId)
    local items = string.split(returnTaskAct.m_stSdpConfig.stCommonCfg.sShowItem, ";")
    for i, v in ipairs(items) do
      table.insert(returnTaskItems, tonumber(v))
    end
    if returnTaskAct:checkShowRed() then
      showTaskRed = true
    end
  end
  self.m_gift_redpoint:SetActive(showTaskRed)
  local signAct = ActivityManager:GetActivityInShowTimeByType(MTTD.ActivityType_ReturnSign)
  if signAct and signAct.m_stSdpConfig ~= nil then
    self.signJumpID = tonumber(signAct.m_stSdpConfig.stCommonCfg.sJumpId)
    local items = string.split(signAct.m_stSdpConfig.stCommonCfg.sShowItem, ";")
    for i, v in ipairs(items) do
      table.insert(signItems, tonumber(v))
    end
    if signAct:checkShowRed() then
      showSignRed = true
    end
  end
  self.m_sign_redpoint:SetActive(showSignRed)
  local signCount = #signItems
  local signItemRoot = self.m_sign_item.transform.parent
  self.m_sign_item:SetActive(false)
  while signCount > signItemRoot.childCount do
    CS.UnityEngine.Object.Instantiate(self.m_sign_item, signItemRoot)
  end
  for i, v in ipairs(signItems) do
    local signItem = signItemRoot:GetChild(i - 1)
    signItem.gameObject:SetActive(true)
    local icon = signItem:Find("img_item")
    local img = icon:GetComponent(T_Image)
    ResourceUtil:CreatIconById(img, v)
    local btn = icon:GetComponent(T_Button)
    btn.onClick:RemoveAllListeners()
    local item = {iID = v, iNum = 0}
    btn.onClick:AddListener(function()
      utils.openItemDetailPop(item)
    end)
  end
  local giftCount = #returnTaskItems
  local giftItemRoot = self.m_gift_item.transform.parent
  self.m_gift_item:SetActive(false)
  while giftCount > giftItemRoot.childCount do
    CS.UnityEngine.Object.Instantiate(self.m_gift_item, giftItemRoot)
  end
  for i, v in ipairs(returnTaskItems) do
    local giftItem = giftItemRoot:GetChild(i - 1)
    giftItem.gameObject:SetActive(true)
    local icon = giftItem:Find("img_item")
    local img = icon:GetComponent(T_Image)
    ResourceUtil:CreatIconById(img, v)
    local btn = icon:GetComponent(T_Button)
    btn.onClick:RemoveAllListeners()
    local item = {iID = v, iNum = 0}
    btn.onClick:AddListener(function()
      utils.openItemDetailPop(item)
    end)
  end
end

function Form_ActivityReturnee:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityReturnee:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityReturnee:ClickLockCheck()
  if self.lockClickEnd ~= nil and TimeUtil:GetServerTimeS() - self.lockClickEnd < 2 then
    return true
  end
  return false
end

function Form_ActivityReturnee:OnBtnsignClicked()
  if self:ClickLockCheck() then
    return
  end
  if self.signJumpID == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13010)
    return
  end
  QuickOpenFuncUtil:OpenFunc(self.signJumpID)
  self:CloseForm()
end

function Form_ActivityReturnee:OnBtngiftClicked()
  if self:ClickLockCheck() then
    return
  end
  if self.returnTaskJumpID == 0 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13010)
    return
  end
  QuickOpenFuncUtil:OpenFunc(self.returnTaskJumpID)
  self:CloseForm()
end

function Form_ActivityReturnee:OnBgbackClicked()
  if self:ClickLockCheck() then
    return
  end
  self:CloseForm()
end

function Form_ActivityReturnee:CloseForm()
  if self.isFromPushFace then
    PushFaceManager:CheckShowNextPopPanel()
    self.isFromPushFace = false
  end
  self.super.CloseForm(self)
end

function Form_ActivityReturnee:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_ActivityReturnee", Form_ActivityReturnee)
return Form_ActivityReturnee
