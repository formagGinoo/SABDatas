local Form_GuildElevatorcall = class("Form_GuildElevatorcall", require("UI/UIFrames/Form_GuildElevatorcallUI"))
local __TASK_NUM = 3
local __AncientResourceOnce = tonumber(ConfigManager:GetGlobalSettingsByKey("AncientResourceOnce") or 0)
local __AncientResourceContinue = tonumber(ConfigManager:GetGlobalSettingsByKey("AncientResourceContinue") or 0)
local __AncientResourceItem = tonumber(ConfigManager:GetGlobalSettingsByKey("AncientResourceItem") or 0)
local __AncientTaskRefresh = ConfigManager:GetGlobalSettingsByKey("AncientTaskRefresh")

function Form_GuildElevatorcall:SetInitParam(param)
end

function Form_GuildElevatorcall:AfterInit()
  self.super.AfterInit(self)
  local root_trans = self.m_csui.m_uiGameObject.transform
  self.m_widgetResourceBar = self:createResourceBar(self.m_common_top_resource)
  self.m_widgetItemIcon = self:createCommonItem(self.m_hero_icon)
  self:addActionLongPress(self.m_btn_schedule_Button, handler(self, self.LongPressClick), handler(self, self.LongPress))
  self:addTrigger(UIUtil.findLuaBehaviour(self.m_btn_schedule.transform), "m_btn_schedule", handler(self, self.PressEnter), handler(self, self.PressExit))
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_redCostStr = ConfigManager:GetCommonTextById(100812)
  self.m_greenCostStr = ConfigManager:GetCommonTextById(100813)
  self.m_scheduleTotalStr = ConfigManager:GetCommonTextById(20045)
  self.m_scheduleNumStr = ConfigManager:GetCommonTextById(100811)
end

function Form_GuildElevatorcall:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param or {}
  self.m_requestFlag = tParam.requestFlag
  self.m_scheduleNum = 0
  self.m_summonEnergyMax = 0
  self.m_curSummonEnergy = 0
  self.m_costNum = 0
  self.m_summonHeroCfg = nil
  if self.m_summon_sequence then
    self.m_summon_sequence:Kill()
    self.m_summon_sequence = nil
  end
  self:FreshShowSpine()
  self:RefreshUI()
  self:AddEventListeners()
  if self.m_requestFlag then
    local allianceId = RoleManager:GetRoleAllianceInfo()
    GuildManager:ReqGetOwnerAllianceDetailOnExitRaidMan(allianceId)
  end
  local ids = AncientManager:GetCanReceiveTaskIds()
  if 0 < table.getn(ids) then
    AncientManager:ReqAncientTakeQuestAwardCS(ids)
  end
end

function Form_GuildElevatorcall:OnInactive()
  self.super.OnInactive(self)
  self.m_scheduleNum = nil
  self.m_summonHeroCfg = nil
  self.m_summonEnergyMax = nil
  self.m_curSummonEnergy = nil
  self.m_costNum = nil
  self:CheckRecycleSpine()
  self:RemoveAllEventListeners()
  if self.m_summon_sequence then
    self.m_summon_sequence:Kill()
    self.m_summon_sequence = nil
  end
end

function Form_GuildElevatorcall:AddEventListeners()
  self:addEventListener("eGameEvent_Ancient_ChangeHero", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Ancient_TakeQuestAward", handler(self, self.OnTakeQuestAward))
  self:addEventListener("eGameEvent_Ancient_RefreshQuest", handler(self, self.RefreshTaskUI))
  self:addEventListener("eGameEvent_Ancient_AddEnergy", handler(self, self.OnAddEnergy))
  self:addEventListener("eGameEvent_Ancient_SummonHero", handler(self, self.OnSummonHero))
  self:addEventListener("eGameEvent_Alliance_Leave", handler(self, self.OnEventLeaveAlliance))
end

function Form_GuildElevatorcall:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_GuildElevatorcall:OnAddEnergy()
  self:RefreshRightUI()
end

function Form_GuildElevatorcall:OnSummonHero()
  StackFlow:Push(UIDefines.ID_FORM_GUILDELEVATORMAIN)
  self:CloseForm()
end

function Form_GuildElevatorcall:RefreshUI()
  local heroId = AncientManager:GetCurHeroID()
  if heroId and heroId ~= 0 then
    local cfg = HeroManager:GetHeroConfigByID(heroId)
    self.m_txt_heroname_Text.text = cfg.m_mName
    local itemData = ResourceUtil:GetProcessRewardData({iID = heroId, iNum = 0})
    self.m_widgetItemIcon:SetItemInfo(itemData)
  end
  UILuaHelper.SetActive(self.m_uifx_img_bg_bar03, true)
  self:RefreshTaskUI()
  self:RefreshRightUI()
end

function Form_GuildElevatorcall:RefreshResourceBar()
  self.m_widgetResourceBar:FreshChangeItems({__AncientResourceItem})
  ResourceUtil:CreatIconById(self.m_schedule_icon_Image, __AncientResourceItem)
  self:RefreshCostUI()
end

function Form_GuildElevatorcall:RefreshCostUI(haveNum)
  haveNum = haveNum or ItemManager:GetItemNum(__AncientResourceItem)
  local costStr = ""
  if not haveNum then
    local num = ItemManager:GetItemNum(__AncientResourceItem)
    costStr = num >= __AncientResourceOnce and self.m_greenCostStr or self.m_redCostStr
  else
    costStr = haveNum >= __AncientResourceOnce and self.m_greenCostStr or self.m_redCostStr
  end
  self.m_txt_coinnum_Text.text = string.gsubnumberreplace(costStr, BigNumFormat(haveNum), tostring(__AncientResourceOnce))
end

function Form_GuildElevatorcall:RefreshTaskUI()
  local taskDataList = AncientManager:GetTaskList()
  if table.getn(taskDataList) == 0 then
    log.error("AncientManager:GetTaskList error !!!")
    return
  end
  for i = 1, __TASK_NUM do
    local taskData = taskDataList[i]
    if taskData then
      local cfg = AncientManager:GetAncientTaskCfgById(taskData.iId)
      UILuaHelper.SetActive(self["m_img_finish0" .. i], taskData.iState == MTTDProto.QuestState_Over)
      UILuaHelper.SetActive(self["m_icon_star0" .. i], taskData.iState ~= MTTDProto.QuestState_Over)
      local name = AncientManager:GetTaskNameById(taskData.iId, cfg)
      self["m_txt_tasktips0" .. i .. "_Text"].text = tostring(name)
      local rewards = utils.changeCSArrayToLuaTable(cfg.m_Reward)
      if rewards and rewards[1] and rewards[1][1] then
        ResourceUtil:CreatIconById(self["m_icon_taskfinish" .. i .. "_Image"], rewards[1][1])
        local num = string.format(ConfigManager:GetCommonTextById(20049), tostring(rewards[1][2]))
        self["m_txt_taskreward0" .. i .. "_Text"].text = num
      end
      local index = taskData.iState == MTTDProto.QuestState_Over and 1 or 0
      local multiColorChange = self["m_txt_tasktips0" .. i]:GetComponent("MultiColorChange")
      if not utils.isNull(multiColorChange) then
        multiColorChange:SetColorByIndex(index)
      end
      local multiColorChange2 = self["m_txt_taskreward0" .. i]:GetComponent("MultiColorChange")
      if not utils.isNull(multiColorChange2) then
        multiColorChange2:SetColorByIndex(index)
      end
    end
  end
end

function Form_GuildElevatorcall:RefreshRightUI()
  self:RefreshResourceBar()
  local summonHero = AncientManager:GetAncientSummonHero()
  if summonHero then
    if not self.m_summonHeroCfg then
      self.m_summonHeroCfg = AncientManager:GetAncientCharacterCfgById(summonHero.iHeroId)
    end
    self.m_summonEnergyMax = summonHero.iSummonTimes == 0 and self.m_summonHeroCfg.m_SummonHero or self.m_summonHeroCfg.m_SummonChip
    self.m_curSummonEnergy = summonHero.iCurEnergy
    self.m_txt_scheduletotal_Text.text = string.format(self.m_scheduleTotalStr, self.m_curSummonEnergy, self.m_summonEnergyMax)
    local energy = summonHero.iCurEnergy / self.m_summonEnergyMax
    local value = string.format("%.0f", energy * 100)
    if 0 < energy and value == 0 then
      value = 1
    end
    self.m_txt_schedulenum_Text.text = string.gsubnumberreplace(self.m_scheduleNumStr, value)
    self.m_img_bg_bar02_Image.fillAmount = energy
    self.m_uifx_img_bg_bar03_Image.fillAmount = energy
    UILuaHelper.SetActive(self.m_img_lightstar, energy < 1)
    UILuaHelper.SetActive(self.m_img_lightstar_full, energy == 1)
    UILuaHelper.SetActive(self.m_pnl_right, true)
    UILuaHelper.SetActive(self.m_pnl_schedule, true)
    local haveNum = ItemManager:GetItemNum(__AncientResourceItem)
    local limit = self.m_summonHeroCfg.m_Limit
    self.m_txt_contentgray02_Text.text = ConfigManager:GetCommonTextById(100814)
    if limit > summonHero.iSummonTimes then
      UILuaHelper.SetActive(self.m_btn_schedule, haveNum >= __AncientResourceOnce and self.m_curSummonEnergy < self.m_summonEnergyMax)
      UILuaHelper.SetActive(self.m_btn_schedulegray, haveNum < __AncientResourceOnce and self.m_curSummonEnergy < self.m_summonEnergyMax)
      UILuaHelper.SetActive(self.m_btn_summon, self.m_curSummonEnergy >= self.m_summonEnergyMax)
      UILuaHelper.SetActive(self.m_pnl_schedule_close, false)
      UILuaHelper.SetActive(self.m_pnl_schedule, self.m_curSummonEnergy < self.m_summonEnergyMax)
      UILuaHelper.SetActive(self.m_txtnum, true)
      UILuaHelper.SetActive(self.m_txt_contentgray02, false)
    else
      UILuaHelper.SetActive(self.m_btn_schedule, false)
      UILuaHelper.SetActive(self.m_txtnum, false)
      UILuaHelper.SetActive(self.m_btn_schedulegray, true)
      UILuaHelper.SetActive(self.m_btn_summon, false)
      UILuaHelper.SetActive(self.m_pnl_schedule_close, true)
      UILuaHelper.SetActive(self.m_txt_contentgray02, true)
    end
  else
    UILuaHelper.SetActive(self.m_pnl_right, false)
  end
end

function Form_GuildElevatorcall:OnTakeQuestAward()
  self:RefreshRightUI()
  self:RefreshTaskUI()
end

function Form_GuildElevatorcall:GetShowSpine()
  local heroID = AncientManager:GetCurHeroID()
  local heroCfg
  if not heroID and heroID ~= 0 then
    return
  end
  heroCfg = HeroManager:GetHeroConfigByID(heroID)
  if not heroCfg then
    return
  end
  local spineStr = heroCfg.m_Spine
  if not spineStr then
    return
  end
  return spineStr
end

function Form_GuildElevatorcall:FreshShowSpine()
  self:CheckRecycleSpine()
  local spineStr = self:GetShowSpine()
  if not spineStr then
    return
  end
  self:LoadHeroSpine(spineStr, SpinePlaceCfg.HeroDetail, self.m_role_root)
end

function Form_GuildElevatorcall:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine(true)
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
      UILuaHelper.SetSpineTimeScale(spineLoadObj.spineObj, 1)
    end)
  end
end

function Form_GuildElevatorcall:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_GuildElevatorcall:RefreshLongPressUI(iCurEnergy, haveNum)
  self.m_txt_scheduletotal_Text.text = string.format(self.m_scheduleTotalStr, iCurEnergy, self.m_summonEnergyMax)
  local energy = iCurEnergy / self.m_summonEnergyMax
  local value = string.format("%.0f", energy * 100)
  if 0 < energy and value == 0 then
    value = 1
  end
  self.m_txt_schedulenum_Text.text = string.gsubnumberreplace(self.m_scheduleNumStr, value)
  self.m_img_bg_bar02_Image.fillAmount = energy
  self.m_uifx_img_bg_bar03_Image.fillAmount = energy
  self:RefreshCostUI(haveNum)
end

function Form_GuildElevatorcall:LongPressClick()
  if self.m_costNum and self.m_curSummonEnergy < self.m_summonEnergyMax then
    local cost = self.m_costNum == 0 and 1 or self.m_costNum
    local iAddEnergy = cost * __AncientResourceOnce
    if self.m_curSummonEnergy + iAddEnergy > self.m_summonEnergyMax then
      iAddEnergy = self.m_summonEnergyMax - self.m_curSummonEnergy
    end
    AncientManager:ReqAncientAddEnergyCS(iAddEnergy)
    self.m_costNum = 0
  elseif self.m_curSummonEnergy >= self.m_summonEnergyMax then
    self:RefreshRightUI()
  end
end

function Form_GuildElevatorcall:LongPress()
  self.m_scheduleNum = self.m_scheduleNum + 1
  local cost = self.m_scheduleNum * __AncientResourceOnce
  local energy = self.m_curSummonEnergy + cost
  if cost <= self.m_haveItemNum and energy <= self.m_summonEnergyMax then
    self.m_costNum = self.m_scheduleNum
    local haveNum = self.m_haveItemNum - cost
    self:RefreshLongPressUI(energy, haveNum)
    UILuaHelper.SetActive(self.m_img_lightstar_full, true)
    GlobalManagerIns:TriggerWwiseBGMState(292)
  elseif energy < self.m_summonEnergyMax + __AncientResourceOnce and energy > self.m_summonEnergyMax - __AncientResourceOnce then
    local lastCost = (self.m_scheduleNum - 1) * __AncientResourceOnce
    local lastEnergy = self.m_curSummonEnergy + lastCost
    local iAddEnergy = self.m_summonEnergyMax - lastEnergy
    local needNum = lastCost + iAddEnergy
    if needNum <= self.m_haveItemNum then
      self.m_costNum = self.m_scheduleNum
      local haveNum = self.m_haveItemNum - needNum
      self:RefreshLongPressUI(needNum + self.m_curSummonEnergy, haveNum)
      UILuaHelper.SetActive(self.m_img_lightstar_full, true)
    else
      UILuaHelper.SetActive(self.m_uifx_injection, false)
      UILuaHelper.SetActive(self.m_uifx_injection_one, false)
    end
    GlobalManagerIns:TriggerWwiseBGMState(292)
  else
    UILuaHelper.SetActive(self.m_uifx_injection, false)
    UILuaHelper.SetActive(self.m_uifx_injection_one, false)
  end
end

function Form_GuildElevatorcall:PressEnter()
  self.m_scheduleNum = 0
  self.m_costNum = 0
  self.m_haveItemNum = ItemManager:GetItemNum(__AncientResourceItem)
  UILuaHelper.SetActive(self.m_uifx_injection, true)
  UILuaHelper.SetActive(self.m_uifx_injection_one, false)
  UILuaHelper.SetActive(self.m_uifx_injection_one, true)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "GuildElevatorcall_loop")
end

function Form_GuildElevatorcall:PressExit()
  if self.m_scheduleNum ~= 0 then
    UILuaHelper.SetActive(self.m_uifx_injection_one, false)
    UILuaHelper.SetActive(self.m_uifx_injection_one, true)
    GlobalManagerIns:TriggerWwiseBGMState(293)
  else
    GlobalManagerIns:TriggerWwiseBGMState(289)
  end
  self.m_scheduleNum = 0
  self.m_costNum = 0
  UILuaHelper.SetActive(self.m_uifx_injection, false)
  UILuaHelper.SetActive(self.m_img_lightstar_full, false)
end

function Form_GuildElevatorcall:OnBtnsymbolClicked()
  utils.popUpDirectionsUI({tipsID = 1036})
end

function Form_GuildElevatorcall:OnBtnmoreClicked()
  local heroId = AncientManager:GetCurHeroID()
  if heroId and heroId ~= 0 then
    StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {heroID = heroId})
  end
end

function Form_GuildElevatorcall:OnBtnchangeClicked()
  StackFlow:Push(UIDefines.ID_FORM_GUILDELEVATORMAIN)
end

function Form_GuildElevatorcall:OnBtnrefreshClicked()
  local costTab = utils.changeStringRewardToLuaTable(__AncientTaskRefresh)
  local times = AncientManager:GetTaskRefreshTimes()
  if times >= table.getn(costTab) then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13025)
    return
  end
  local cost = costTab[times + 1]
  if cost then
    local itemCfg = ItemManager:GetItemConfigById(cost[1])
    local name = itemCfg and tostring(itemCfg.m_mItemName) or ""
    utils.ShowCommonTipCost({
      beforeItemID = cost[1],
      beforeItemNum = cost[2],
      confirmCommonTipsID = 1037,
      formatFun = function(content)
        return string.gsubnumberreplace(content, name, tostring(cost[2]))
      end,
      funSure = function()
        AncientManager:ReqAncientRefreshQuestCS()
        UILuaHelper.PlayAnimationByName(self.m_pnl_task, "GuildElevatorcall_refresh")
      end
    })
  end
end

function Form_GuildElevatorcall:OnBtnschedulegrayClicked()
  local summonHero = AncientManager:GetAncientSummonHero()
  if summonHero and self.m_summonHeroCfg and summonHero.iSummonTimes < self.m_summonHeroCfg.m_Limit then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13026)
  end
end

function Form_GuildElevatorcall:OnBtnsummonClicked()
  if self.m_summon_sequence then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "GuildElevatorcall_call_in")
  local animationTime = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, "GuildElevatorcall_call_in")
  self.m_summon_sequence = Tweening.DOTween.Sequence()
  self.m_summon_sequence:AppendInterval(animationTime)
  self.m_summon_sequence:OnComplete(function()
    AncientManager:ReqAncientSummonHeroCS()
    self.m_summon_sequence = nil
  end)
  self.m_summon_sequence:SetAutoKill(true)
end

function Form_GuildElevatorcall:OnBtnbackClicked()
  local form = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_GUILD)
  if form == nil then
    StackFlow:Push(UIDefines.ID_FORM_GUILD)
  end
  self:CloseForm()
end

function Form_GuildElevatorcall:OnEventLeaveAlliance()
  self:OnBtnhomeClicked()
end

function Form_GuildElevatorcall:OnBtnhomeClicked()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function Form_GuildElevatorcall:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine()
end

function Form_GuildElevatorcall:IsFullScreen()
  return true
end

function Form_GuildElevatorcall:GetDownloadResourceExtra()
  local vPackage = {}
  local vResourceExtra = {}
  local list = AncientManager:GetAllAncientCharacterIdsAndCfgList()
  for i, heroId in ipairs(list) do
    vPackage[#vPackage + 1] = {
      sName = tostring(heroId),
      eType = DownloadManager.ResourcePackageType.Character
    }
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_GuildElevatorcall", Form_GuildElevatorcall)
return Form_GuildElevatorcall
