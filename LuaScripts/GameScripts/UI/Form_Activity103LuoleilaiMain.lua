local Form_Activity103LuoleilaiMain = class("Form_Activity103LuoleilaiMain", require("UI/UIFrames/Form_Activity103LuoleilaiMainUI"))

function Form_Activity103LuoleilaiMain:SetInitParam(param)
end

function Form_Activity103LuoleilaiMain:AfterInit()
  Form_Activity103LuoleilaiMain.super.AfterInit(self)
  self.miniGameIsOpen = false
  UILuaHelper.SetActive(self.m_challenge_redpointhammersiren, false)
end

function Form_Activity103LuoleilaiMain:OnActive()
  Form_Activity103LuoleilaiMain.super.OnActive(self)
  if self.m_btn_activity then
    self.m_eff2:SetActive(true)
  end
  local open_state = HeroActivityManager:GetActOpenState(self.act_id, true)
  if open_state == HeroActivityManager.ActOpenState.Normal then
    local key = self.act_id .. "FirstUnlockSecondHalf"
    local is_played = LocalDataManager:GetIntSimple(key, 0) == 1
    if self.m_btn_activity2 then
      self.m_eff1:SetActive(true)
      if not is_played then
        UILuaHelper.PlayAnimationByName(self.m_btn_activity2, "Activity103_Luoleilai_Main_unlock")
        LocalDataManager:SetIntSimple(key, 1, true)
      end
    end
  end
  self.m_pnl_right:SetActive(true)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(297)
end

function Form_Activity103LuoleilaiMain:OnInactive()
  Form_Activity103LuoleilaiMain.super.OnInactive(self)
end

function Form_Activity103LuoleilaiMain:OnDestroy()
  Form_Activity103LuoleilaiMain.super.OnDestroy(self)
end

function Form_Activity103LuoleilaiMain:FreshUI()
  Form_Activity103LuoleilaiMain.super.FreshUI(self)
  UILuaHelper.SetActive(self.m_z_txt_hammersiren_name, self.miniGameIsOpen)
  UILuaHelper.SetActive(self.m_img_lockhammersiren, not self.miniGameIsOpen)
end

function Form_Activity103LuoleilaiMain:RegisterRedDot()
  Form_Activity103LuoleilaiMain.super.RegisterRedDot(self)
  self:RegisterOrUpdateRedDotItem(self.m_challenge_redpointhammersiren, RedDotDefine.ModuleType.HeroActMiniGameEntry, {
    actId = self.act_id,
    whackMoleActivityId = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  })
end

function Form_Activity103LuoleilaiMain:OnBtnheroClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST, {
    activityID = self.act_id
  })
end

function Form_Activity103LuoleilaiMain:OnBtnhammersirenClicked()
  HeroActivityManager:GotoHeroActivity({
    main_id = self.act_id,
    sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
  })
end

function Form_Activity103LuoleilaiMain:GetDownloadResourceExtra(tParam)
  local _vPackage, _vResourceExtra = Form_Activity103LuoleilaiMain.super.GetDownloadResourceExtra(self, tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local AudiobnkId = {
    297,
    300,
    149,
    303,
    21,
    17,
    34,
    318,
    308,
    310,
    312,
    311,
    21,
    315,
    314,
    313
  }
  for i, v in ipairs(AudiobnkId) do
    local temptable = utils.changeCSArrayToLuaTable(UILuaHelper.GetAudioResById(v))
    if temptable then
      for _, value in pairs(temptable) do
        vResourceExtra[#vResourceExtra + 1] = {
          sName = value,
          eType = DownloadManager.ResourceType.Audio
        }
      end
    end
  end
  local sEventNames = {
    "Play_UI_WhackMole_MonsterBorn",
    "Play_UI_WhackMole_MonsterDie",
    "Play_UI_WhackMole_HitMonster",
    "Play_UI_WhackMole_HitBoss",
    "Play_UI_WhackMole_HitShiled",
    "Play_UI_WhackMole_BreakShiled",
    "Play_UI_WhackMole_CreatShiled",
    "Play_UI_WhackMole_Ink",
    "Play_UI_WhackMole_Electric",
    "Stop_UI_WhackMole_Electric"
  }
  for _, value in pairs(sEventNames) do
    vResourceExtra[#vResourceExtra + 1] = {
      sName = value,
      eType = DownloadManager.ResourceType.Audio
    }
  end
  for i, v in ipairs(_vPackage) do
    vPackage[#vPackage + 1] = v
  end
  for i, v in ipairs(_vResourceExtra) do
    vResourceExtra[#vResourceExtra + 1] = v
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Activity103LuoleilaiMain", Form_Activity103LuoleilaiMain)
return Form_Activity103LuoleilaiMain
