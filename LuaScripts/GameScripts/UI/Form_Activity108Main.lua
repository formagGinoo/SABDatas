local Form_Activity108Main = class("Form_Activity108Main", require("UI/UIFrames/Form_Activity108MainUI"))

function Form_Activity108Main:SetInitParam(param)
end

function Form_Activity108Main:AfterInit()
  Form_Activity108Main.super.AfterInit(self)
end

function Form_Activity108Main:OnActive()
  Form_Activity108Main.super.OnActive(self)
  HeroActivityManager:CheckShowEnterAnim(self.m_csui.m_uiGameObject, "Form_Activity108Main_ShowAni", "Activity108_Main_in_DailyFirstOpen", "Activity108_Main_in", 368)
  self:RegisterOrUpdateRedDotItem(self.m_challenge_redpointhammersiren, RedDotDefine.ModuleType.MiniGame108, self.act_id)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(360)
end

function Form_Activity108Main:OnInactive()
  Form_Activity108Main.super.OnInactive(self)
  if self.m_switch_timer then
    TimeService:KillTimer(self.m_switch_timer)
    self.m_switch_timer = nil
  end
  UILuaHelper.SetChildIndex(self.m_img_top_icon01, 2)
  UILuaHelper.SetChildIndex(self.m_img_bom_icon01, 0)
  UILuaHelper.ResetAnimationByName(self.m_DoubleGacha, "Activity108Main_GachaBtn_switch1")
end

function Form_Activity108Main:OnDestroy()
  Form_Activity108Main.super.OnDestroy(self)
  if self.m_switch_timer then
    TimeService:KillTimer(self.m_switch_timer)
    self.m_switch_timer = nil
  end
end

function Form_Activity108Main:FreshGachaUI()
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  if not config then
    return
  end
  local gachaJumpIDArray = utils.changeCSArrayToLuaTable(config.m_GachaJumpID)
  if #gachaJumpIDArray <= 1 then
    return
  end
  if utils.isNull(self.m_DoubleGacha) or utils.isNull(self.m_Gacha) or utils.isNull(self.m_btn_convert) then
    return
  end
  local bIsSecondGachaOpen = HeroActivityManager:IsSecondGachaOpen(self.act_id)
  if not bIsSecondGachaOpen then
    self.m_DoubleGacha:SetActive(false)
    self.m_Gacha:SetActive(true)
    self.m_btn_convert:SetActive(false)
  else
    self.m_DoubleGacha:SetActive(true)
    self.m_Gacha:SetActive(false)
    self.m_btn_convert:SetActive(true)
  end
end

function Form_Activity108Main:OnBtnconvertClicked()
  if utils.isNull(self.m_DoubleGacha) then
    return
  end
  local config = HeroActivityManager:GetMainInfoByActID(self.act_id)
  local gachaJumpIDArray = utils.changeCSArrayToLuaTable(config.m_GachaJumpID)
  self.iCurGachaIndex = self.iCurGachaIndex + 1
  if self.iCurGachaIndex > #gachaJumpIDArray then
    self.iCurGachaIndex = 1
  end
  local bTop2Btm = self.iCurGachaIndex == 1
  local sAniName = bTop2Btm and "Activity108Main_GachaBtn_switch2" or "Activity108Main_GachaBtn_switch1"
  UILuaHelper.PlayAnimationByName(self.m_DoubleGacha, sAniName)
  if self.m_switch_timer then
    TimeService:KillTimer(self.m_switch_timer)
    self.m_switch_timer = nil
  end
  self.m_switch_timer = TimeService:SetTimer(0.15, 1, function()
    if utils.isNull(self.m_img_top_icon01) or utils.isNull(self.m_img_bom_icon01) then
      return
    end
    UILuaHelper.SetChildIndex(self.m_img_top_icon01, bTop2Btm and 2 or 0)
    UILuaHelper.SetChildIndex(self.m_img_bom_icon01, bTop2Btm and 0 or 2)
  end)
  local fAniLen = UILuaHelper.GetAnimationLengthByName(self.m_DoubleGacha, sAniName)
  self.m_UILockID = UILockIns:Lock(fAniLen)
  self:FreshGachaUI()
end

function Form_Activity108Main:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity108Main", Form_Activity108Main)
return Form_Activity108Main
