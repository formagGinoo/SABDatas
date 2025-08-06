local Form_GuildElevatorMain = class("Form_GuildElevatorMain", require("UI/UIFrames/Form_GuildElevatorMainUI"))

function Form_GuildElevatorMain:SetInitParam(param)
end

function Form_GuildElevatorMain:AfterInit()
  self.super.AfterInit(self)
end

function Form_GuildElevatorMain:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_requestFlag = tParam.requestFlag
  self.m_cfgList = {}
  self:RefreshUI()
  self:AddEventListeners()
  if self.m_requestFlag then
    local allianceId = RoleManager:GetRoleAllianceInfo()
    GuildManager:ReqGetOwnerAllianceDetailOnExitRaidMan(allianceId)
  end
end

function Form_GuildElevatorMain:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_GuildElevatorMain:AddEventListeners()
  self:addEventListener("eGameEvent_Ancient_ChangeHero", handler(self, self.OnChangeHero))
  self:addEventListener("eGameEvent_Alliance_Leave", handler(self, self.OnEventLeaveAlliance))
end

function Form_GuildElevatorMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildElevatorMain:OnChangeHero()
  StackFlow:Push(UIDefines.ID_FORM_GUILDELEVATORCALL)
  self:CloseForm()
end

function Form_GuildElevatorMain:RefreshUI()
  self.m_cfgList = self:GetAncientCharacterInfo()
  for i = 1, 3 do
    local cfg = self.m_cfgList[i]
    if not utils.isNull(self["m_pnl_normal_0" .. i]) then
      if cfg then
        local unlock = AncientManager:CheckHeroIsUnlockById(cfg.m_HeroID)
        UILuaHelper.SetActive(self["m_pnl_normal_0" .. i], cfg.m_Display == 1 and unlock)
        UILuaHelper.SetActive(self["m_pnl_txttips0" .. i], true)
        local flag = LocalDataManager:GetIntSimple("GuildElevatorMain_Unlock_" .. tostring(cfg.m_HeroID), 0)
        if cfg.m_Display == 1 and unlock and flag == 0 and not utils.isNull(self["m_btn_0" .. i]) then
          UILuaHelper.SetActive(self["m_img_bg_lock_0" .. i], true)
          UILuaHelper.SetActive(self["m_pnl_txttips0" .. i], false)
          LocalDataManager:SetIntSimple("GuildElevatorMain_Unlock_" .. tostring(cfg.m_HeroID), 1)
          local animationTime = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, "UIFX_GuideElevatorMain_in")
          local sequence = Tweening.DOTween.Sequence()
          sequence:AppendInterval(animationTime)
          sequence:OnComplete(function()
            if not utils.isNull(self["m_btn_0" .. i]) then
              UILuaHelper.PlayAnimationByName(self["m_btn_0" .. i], "UIFX_GuideElevatorMain_Unlock")
              GlobalManagerIns:TriggerWwiseBGMState(290)
            end
          end)
          sequence:SetAutoKill(true)
        else
          UILuaHelper.SetActive(self["m_img_bg_lock_0" .. i], cfg.m_Display ~= 1 or not unlock)
        end
        if cfg.m_Display == 1 and unlock then
          local summonHero = AncientManager:GetAncientSummonHeroById(cfg.m_HeroID)
          local heroCfg = HeroManager:GetHeroConfigByID(cfg.m_HeroID)
          if summonHero and summonHero.iSummonTimes and summonHero.iSummonTimes < cfg.m_Limit then
            local summonEnergyMax = summonHero.iSummonTimes == 0 and cfg.m_SummonHero or cfg.m_SummonChip
            local percent = summonHero.iCurEnergy / summonEnergyMax
            local value = math.floor(percent * 100)
            if value == 0 and 0 < summonHero.iCurEnergy then
              value = 1
            end
            self["m_img_bg_process_0" .. i .. "_Image"].fillAmount = percent
            self["m_txt_heroprocess_0" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(100009), value)
            UILuaHelper.SetActive(self["m_finish_0" .. i], summonHero.iSummonTimes >= cfg.m_Limit)
          else
            self["m_img_bg_process_0" .. i .. "_Image"].fillAmount = 0
            self["m_txt_heroprocess_0" .. i .. "_Text"].text = string.format(ConfigManager:GetCommonTextById(100009), 0)
            UILuaHelper.SetActive(self["m_finish_0" .. i], false)
          end
          if heroCfg then
            self["m_txt_heroname_0" .. i .. "_Text"].text = heroCfg.m_mShortname
            local careerCfg = HeroManager:GetCharacterCareerCfgByCareer(heroCfg.m_Career)
            if careerCfg then
              UILuaHelper.SetAtlasSprite(self["m_icon_career0" .. i .. "_Image"], careerCfg.m_CareerIcon)
            end
            local moonType = heroCfg.m_MoonType
            for m = 1, 3 do
              UILuaHelper.SetActive(self["m_img_moon" .. i .. "_" .. m], moonType == m)
            end
          end
        else
          local unlockList = utils.changeCSArrayToLuaTable(cfg.m_Unlock)
          for m = 1, 2 do
            if unlockList[m] and unlockList[m][1] and cfg.m_Display == 1 then
              UILuaHelper.SetActive(self["m_locktips" .. i .. "_" .. m], true)
              local heroCfg = HeroManager:GetHeroConfigByID(unlockList[m][1])
              if heroCfg then
                local name = heroCfg.m_mShortname
                local num = unlockList[m][2]
                local gachaNum = 0
                local summonHero = AncientManager:GetAncientSummonHeroById(unlockList[m][1])
                if summonHero and summonHero.iSummonTimes then
                  gachaNum = summonHero.iSummonTimes
                end
                local str = string.gsubnumberreplace(ConfigManager:GetCommonTextById(100810), name, num, gachaNum, num)
                self["m_txt_unlocktips" .. i .. "_" .. m .. "_Text"].text = str
                UILuaHelper.SetActive(self["m_img_down" .. i .. "_" .. m], num <= gachaNum)
              end
            else
              UILuaHelper.SetActive(self["m_locktips" .. i .. "_" .. m], false)
            end
          end
        end
      else
        UILuaHelper.SetActive(self["m_img_bg_lock_0" .. i], true)
        UILuaHelper.SetActive(self["m_pnl_normal_0" .. i], false)
        UILuaHelper.SetActive(self["m_pnl_txttips0" .. i], false)
      end
    end
  end
end

function Form_GuildElevatorMain:GetAncientCharacterInfo()
  local cfgList = {}
  local characterIns = ConfigManager:GetConfigInsByName("AncientCharacter")
  local characterAll = characterIns:GetAll()
  for i, v in pairs(characterAll) do
    cfgList[v.m_Position] = v
  end
  return cfgList
end

function Form_GuildElevatorMain:ChooseHeroByIndex(index)
  if self.m_cfgList[index] and self.m_cfgList[index].m_HeroID then
    local heroId = AncientManager:GetCurHeroID()
    if heroId == self.m_cfgList[index].m_HeroID then
      self:CloseForm()
    else
      AncientManager:ReqAncientChangeHeroCS(self.m_cfgList[index].m_HeroID)
    end
  end
end

function Form_GuildElevatorMain:OnPnlnormal01Clicked()
  self:ChooseHeroByIndex(1)
end

function Form_GuildElevatorMain:OnPnlnormal02Clicked()
  self:ChooseHeroByIndex(2)
end

function Form_GuildElevatorMain:OnPnlnormal03Clicked()
  self:ChooseHeroByIndex(3)
end

function Form_GuildElevatorMain:OnBtnsymbolClicked()
  utils.popUpDirectionsUI({tipsID = 1036})
end

function Form_GuildElevatorMain:OnEventLeaveAlliance()
  if GuideManager:CheckGuideIsActive(300) then
    GuideManager:SkipCurrentGuide()
  end
  self:OnBtnhomeClicked()
end

function Form_GuildElevatorMain:OnBtnbackClicked()
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUILD)
  if form == nil then
    StackFlow:Push(UIDefines.ID_FORM_GUILD)
  end
  self:CloseForm()
end

function Form_GuildElevatorMain:OnBtnhomeClicked()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_GuildElevatorMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_GuildElevatorMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_GuildElevatorMain", Form_GuildElevatorMain)
return Form_GuildElevatorMain
