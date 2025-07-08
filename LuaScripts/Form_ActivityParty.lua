local Form_ActivityParty = class("Form_ActivityParty", require("UI/UIFrames/Form_ActivityPartyUI"))

function Form_ActivityParty:SetInitParam(param)
end

function Form_ActivityParty:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.m_btn_symbol:SetActive(false)
  self.timerList = {}
end

function Form_ActivityParty:OnActive()
  self.super.OnActive(self)
  self.m_stActivity = self.m_csui.m_param.m_stActivity
  self:RefreshUI()
end

function Form_ActivityParty:OnUncoverd()
  self:RefreshUI()
end

function Form_ActivityParty:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityParty:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityParty:RefreshUI()
  if self.m_stActivity == nil then
    return
  end
  local bNeedShow = self.m_stActivity:checkShowActivity()
  if not bNeedShow then
    self:CloseForm()
    return
  end
  self.m_txt_title_Text.text = self.m_stActivity:getLangText(self.m_stActivity:getTitle())
  local cfg = self.m_stActivity:GetWelfareCfg()
  local mSystemList = cfg.vSystem
  for i, v in ipairs(mSystemList) do
    self["m_txt_titlegift0" .. i .. "_Text"].text = self.m_stActivity:getLangText(v.sContent)
    local strList = string.split(v.sJumpParam, ";")
    local act_id
    if ActivityManager.JumpType.Activity == v.iJumpType then
      act_id = strList[1]
    elseif v.iJumpType == ActivityManager.JumpType.System then
      act_id = strList[3]
    end
    if self["m_txt_time0" .. i .. "_Text"] then
      if v.sDate and self.m_stActivity:getLangText(v.sDate) ~= "" then
        self["m_txt_time0" .. i .. "_Text"].text = self.m_stActivity:getLangText(v.sDate)
      elseif act_id then
        if self.timerList[i] then
          TimeService:KillTimer(self.timerList[i])
          self.timerList[i] = nil
        end
        local actIns = ActivityManager:GetActivityByID(tonumber(act_id))
        if actIns then
          local startTime = actIns:getActivityBeginTime()
          local endTime = actIns:getActivityEndTime()
          local iCurTime = TimeUtil:GetServerTimeS()
          if startTime == 0 or endTime == 0 then
            self["m_txt_time0" .. i .. "_Text"].text = ""
          elseif startTime > iCurTime then
            self["m_txt_time0" .. i .. "_Text"].text = ConfigManager:GetCommonTextById(20068)
          elseif endTime < iCurTime then
            self["m_txt_time0" .. i .. "_Text"].text = ""
          else
            local iLeftTime = endTime - iCurTime
            self.timerList[i] = TimeService:SetTimer(1, -1, function()
              iLeftTime = iLeftTime - 1
              if iLeftTime <= 0 then
                TimeService:KillTimer(self.timerList[i])
                self.timerList[i] = nil
                self:RefreshUI()
              else
                self["m_txt_time0" .. i .. "_Text"].text = TimeUtil:SecondsToFormatStrDHOrHMS(iLeftTime)
              end
            end)
          end
        else
          self["m_txt_time0" .. i .. "_Text"].text = ConfigManager:GetCommonTextById(20068)
        end
      else
        self["m_txt_time0" .. i .. "_Text"].text = ""
      end
    end
    local actState = self.m_stActivity:GetActState(i)
    self["m_pnl_soldoutmask0" .. i]:SetActive(actState == ActivityManager.ActStateEnum.Finished)
    self["m_pnl_normal0" .. i]:SetActive(actState == ActivityManager.ActStateEnum.Normal)
    self["m_pnl_soldoutmask0" .. i .. "_black"]:SetActive(actState == ActivityManager.ActStateEnum.Locked or actState == ActivityManager.ActStateEnum.NotOpen)
    if self["m_red0" .. i] then
      self["m_red0" .. i]:SetActive(false)
      if act_id then
        local actIns = ActivityManager:GetActivityByID(tonumber(act_id))
        if actIns and actIns.checkShowRed then
          local bShowRed = actIns:checkShowRed()
          self["m_red0" .. i]:SetActive(bShowRed)
        end
      end
    end
  end
end

function Form_ActivityParty:OnBtntouchClicked()
  self:OnClickJump2System(1)
end

function Form_ActivityParty:OnBtntouch02Clicked()
  self:OnClickJump2System(2)
end

function Form_ActivityParty:OnBtntouch03Clicked()
  self:OnClickJump2System(3)
end

function Form_ActivityParty:OnBtntouch04Clicked()
  self:OnClickJump2System(4)
end

function Form_ActivityParty:OnBtntouch05Clicked()
  self:OnClickJump2System(5)
end

function Form_ActivityParty:OnBtntouch06Clicked()
  local cfg = self.m_stActivity:GetWelfareCfg()
  local mSystemList = cfg.vSystem
  local info = mSystemList[6]
  local is_open, is_finish = self.m_stActivity:IsSystemOpen(tonumber(info.sJumpParam), true)
  if is_open and is_finish then
    return
  end
  self:OnClickJump2System(6)
end

function Form_ActivityParty:OnClickJump2System(idx)
  local actState = self.m_stActivity:GetActState(idx)
  if actState == ActivityManager.ActStateEnum.Locked then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 56004)
    return
  end
  if actState == ActivityManager.ActStateEnum.Finished then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 56005)
    return
  end
  local cfg = self.m_stActivity:GetWelfareCfg()
  local mSystemList = cfg.vSystem
  local info = mSystemList[idx]
  if info and info.iJumpType and info.sJumpParam then
    ActivityManager:DealJump(info.iJumpType, info.sJumpParam)
  end
end

function Form_ActivityParty:OnBackClk()
  LocalDataManager:SetIntSimple("WelfareShowActivity_Red_Point", TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime()), true)
  self:CloseForm()
end

function Form_ActivityParty:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityParty", Form_ActivityParty)
return Form_ActivityParty
