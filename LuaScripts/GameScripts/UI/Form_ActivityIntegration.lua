local Form_ActivityIntegration = class("Form_ActivityIntegration", require("UI/UIFrames/Form_ActivityIntegrationUI"))
local ShowType = {
  UpActivity = 1,
  UpSubActivity = 2,
  GMActivity = 3,
  GachaType = 4,
  MainChapter = 5,
  FourteenUpTask = 6,
  AllianceRaid = 7,
  Night = 8,
  TrialActivity = 9
}
local curMaxUpAct = 5

function Form_ActivityIntegration:SetInitParam(param)
end

function Form_ActivityIntegration:AfterInit()
  self.super.AfterInit(self)
  self.m_actJumpData = {}
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/m_btn_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome))
  self.m_upActData = {}
  self.m_downActData = {}
end

function Form_ActivityIntegration:OnBackClk()
  self:CloseForm()
end

function Form_ActivityIntegration:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
end

function Form_ActivityIntegration:OnActive()
  self.super.OnActive(self)
  local params = self.m_csui.m_param
  self.isFromPushFace = false
  self.isFromPushFace = params and params.IsFormPushFace
  self.m_act = ActivityManager:GetActivityByType(MTTD.ActivityType_OperationActivityGuide)
  if not self.m_act then
    self:CloseForm()
    return
  end
  self.m_actJumpData = self.m_act:GetActJumpList()
  self:FreshData()
  local initGridData = {
    itemClkBackFun = handler(self, self.OnJumpClicked)
  }
  self.m_pnl_downActInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_pnl_downAct_InfinityGrid, "ActivityIntegration/ActivityIntegrationItem", initGridData)
  self:FreshUI()
end

function Form_ActivityIntegration:FreshData()
  self.m_upActData = {}
  self.m_downActData = {}
  if self.m_actJumpData then
    for index, value in pairs(self.m_actJumpData) do
      value.act = self.m_act
      value.Index = index
      if value.iPos == 1 then
        self.m_upActData[#self.m_upActData + 1] = value
      else
        self.m_downActData[#self.m_downActData + 1] = value
      end
    end
    table.sort(self.m_upActData, self.SortDataWithPriority)
    table.sort(self.m_downActData, self.SortDataWithPriority)
  end
end

function Form_ActivityIntegration:FreshUI()
  self:FreshUpAct()
  self:FreshDownAct()
end

function Form_ActivityIntegration:FreshUpAct()
  for index = 1, curMaxUpAct do
    local data = self.m_upActData[index]
    if not utils.isNull(self["m_pnl_Act0" .. index]) then
      if data then
        UILuaHelper.SetActive(self["m_pnl_Act0" .. index], true)
        if index == 1 then
          UILuaHelper.SetUITexture(self["m_pnl_actBg0" .. index .. "_Image"], data.sActivityPic)
        else
          UILuaHelper.SetAtlasSprite(self["m_pnl_actBg0" .. index .. "_Image"], data.sActivityPic)
        end
        self["m_txt_upActName0" .. index .. "_Text"].text = self.m_act:getLangText(data.sActivityName)
        local isOpen = TimeUtil:IsInTime(data.iOpenTime, data.iCloseTime)
        local isEnd = TimeUtil:GetServerTimeS() > data.iCloseTime and data.iCloseTime ~= 0
        local isShowTime = true
        if data.iOpenTime == 0 or data.iCloseTime == 0 or isOpen or isEnd then
          isShowTime = false
        end
        UILuaHelper.SetActive(self["m_end0" .. index], isEnd)
        if isShowTime then
          self["m_txt_upActTime0" .. index .. "_Text"].text = TimeUtil:ServerTimerToServerString2(data.iOpenTime)
        end
        UILuaHelper.SetActive(self["m_txt_upActTime0" .. index], isShowTime)
        UILuaHelper.SetActive(self["m_lock0" .. index], isShowTime)
        local isNormalRed, specialRed = self.m_act:DealRedWithAct(data.Index)
        UILuaHelper.SetActive(self["m_red0" .. index], isNormalRed and not specialRed)
        UILuaHelper.SetActive(self["m_new0" .. index], specialRed)
        UILuaHelper.SetActive(self["m_upObj0" .. index], data.iActivityType == ShowType.GachaType)
        UILuaHelper.SetActive(self["m_ZenObj0" .. index], data.iActivityType == ShowType.FourteenUpTask)
        local btn = self["m_btn_upActJump0" .. index].transform:GetComponent(T_Button)
        UILuaHelper.BindButtonClickManual(btn, function()
          if not isOpen and not isEnd then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(40059), TimeUtil:ServerTimerToServerString2(data.iOpenTime)))
            return
          end
          if isEnd then
            StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40060)
            return
          end
          self.m_act:DealJump(data)
          self:CloseForm()
        end)
      else
        UILuaHelper.SetActive(self["m_pnl_Act0" .. index], false)
      end
    end
  end
end

function Form_ActivityIntegration:FreshDownAct()
  if self.m_pnl_downActInfinityGrid then
    self.m_pnl_downActInfinityGrid:ShowItemList(self.m_downActData)
  end
end

function Form_ActivityIntegration.SortDataWithPriority(a, b)
  if a and b then
    return a.iPosParam < b.iPosParam
  end
  return false
end

function Form_ActivityIntegration:OnInactive()
  self.super.OnInactive(self)
  if self.isFromPushFace then
    PushFaceManager:CheckShowNextPopPanel()
  end
end

function Form_ActivityIntegration:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityIntegration:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityIntegration", Form_ActivityIntegration)
return Form_ActivityIntegration
