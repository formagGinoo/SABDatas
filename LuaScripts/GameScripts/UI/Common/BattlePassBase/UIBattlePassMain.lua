local UIBattlePassMain = class("UIBattlePassMain", require("UI/Common/UIBase"))
local CharacterInfoIns = ConfigManager:GetConfigInsByName("CharacterInfo")
local BattlePassBuyStatus = ActivityManager.BattlePassBuyStatus
local TopTabType = {RewardPanel = 1, TaskPanel = 2}

function UIBattlePassMain:SetInitParam(param)
end

function UIBattlePassMain:AfterInit()
  UIBattlePassMain.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local size = utils.getScreenSafeAreaRealSize()
  if size.width / size.height > 1.7777777777777777 then
    self.m_pnl_fit:GetComponent("RectTransform").offsetMax.x = 660
  end
  self.m_rewardPanel = self:CreateSubPanel("BattlePassRewardSubPanel", self.m_pnl_reward, self, nil, nil, nil)
  self.m_battlePassPanel = self:CreateSubPanel("BattlePassTaskSubPanel", self.m_pnl_task, self, nil, nil, nil)
  self.m_topTabConfig = {
    [TopTabType.RewardPanel] = {
      panelRoot = self.m_pnl_reward,
      selImg = self.m_img_reward,
      subPanel = self.m_rewardPanel
    },
    [TopTabType.TaskPanel] = {
      panelRoot = self.m_pnl_task,
      selImg = self.m_img_task,
      subPanel = self.m_battlePassPanel
    }
  }
  self.m_stopUpdate = false
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
  self.m_stActivity = nil
  self.m_isInitTopBtn = false
  self.m_titleType = 1
  self.m_lastBuState = 0
  self.m_curSelectTab = TopTabType.RewardPanel
  self.m_firstEnterPlay = true
  self.m_isFirstEnterFreshPanel = true
  self.m_animTime = UILuaHelper.GetAnimationLengthByName(self.m_vx_barglow, "BattlePass_Up_bar")
end

function UIBattlePassMain:OnGetFirstEnterType()
  if not self.m_stActivity then
    return
  end
  if not self.m_stActivity.ReachMaxLevel or not self.m_stActivity.HasUnclaimedTask then
    return
  end
  local isTaskHave = not self.m_stActivity:ReachMaxLevel() and self.m_stActivity:HasUnclaimedTask()
  self.m_curSelectTab = isTaskHave and TopTabType.TaskPanel or TopTabType.RewardPanel
  self:FreshTopTabAndPanel()
end

function UIBattlePassMain:FreshTopTabAndPanel()
  if not utils.isNull(self.m_img_star) then
    self.m_img_star:SetActive(self.m_curSelectTab == TopTabType.TaskPanel)
  end
  for k, v in pairs(self.m_topTabConfig) do
    local panelObj = v.panelRoot
    local panelObjSelect = v.selImg
    local panelLua = v.subPanel
    UILuaHelper.SetActive(panelObj, k == self.m_curSelectTab)
    UILuaHelper.SetActive(panelObjSelect, k == self.m_curSelectTab)
    if panelLua then
      if k == self.m_curSelectTab then
        if panelLua.OnActive and self.m_stActivity then
          panelLua:OnActive(self.m_stActivity:getID())
        end
      elseif panelLua and panelLua.OnInActive then
        panelLua:OnInActive()
      end
    end
  end
end

function UIBattlePassMain:OnActiveTransitionDone()
  if self.m_isFirstEnterFreshPanel then
    self:OnGetFirstEnterType()
    self.m_isFirstEnterFreshPanel = false
  end
end

function UIBattlePassMain:OnActive()
  UIBattlePassMain.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  if not self.m_isFirstEnterFreshPanel then
    self:OnGetFirstEnterType()
  end
  self:FreshUI()
  self.m_firstEnterPlay = false
  self.m_dt = 1
end

function UIBattlePassMain:OnOpen()
  UIBattlePassMain.super.OnOpen(self)
end

function UIBattlePassMain:OnUncoverd()
  if self.m_stActivity == nil then
    self:CloseForm()
    return
  end
  self:CheckShowLevelUp10()
  self:FreshShowActSpineInfo()
  if self.m_lastBuState ~= self.m_stActivity:GetBuyStatus() then
    self.m_lastBuState = self.m_stActivity:GetBuyStatus()
    local animaStr = self.m_stActivity:GetMainPanelAnimaStr()
    UILuaHelper.PlayAnimationByName(self.m_icon_advanced_light, animaStr)
    GlobalManagerIns:TriggerWwiseBGMState(321)
  end
end

function UIBattlePassMain:OnInactive()
  UIBattlePassMain.super.OnInactive(self)
  for k, v in pairs(self.m_topTabConfig) do
    local panelLua = v.subPanel
    if panelLua and panelLua and panelLua.OnInActive then
      panelLua:OnInActive()
    end
  end
  self:ClearAnimTimer()
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
end

function UIBattlePassMain:OnUpdate(dt)
  if self.m_stopUpdate then
    return
  end
  if self.m_dt then
    self.m_dt = self.m_dt - dt
    if self.m_dt <= 0 then
      self.m_dt = 1
      self:RefreshRemainTime()
    end
  end
end

function UIBattlePassMain:OnDestroy()
  UIBattlePassMain.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
end

function UIBattlePassMain:FreshData()
  self.m_stActivity = nil
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_stActivity = tParam.stActivity
    self.m_curBuyStatus = self.m_stActivity:GetBuyStatus()
    self.m_lastBuState = self.m_curBuyStatus
    self.m_titleType = self.m_stActivity:GetTitleType()
    self.m_iActivityId = self.m_stActivity:getID()
    self.m_csui.m_param = nil
    self.m_lastLevel = self.m_stActivity:GetCurLevel()
  end
end

function UIBattlePassMain:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_BattlePass_BuyExp", handler(self, self.OnBuyExp))
  self:addEventListener("eGameEvent_Activity_BattlePass_DailyTaskRefresh", handler(self, self.OnTaskReFresh))
  self:addEventListener("eGameEvent_Activity_BattlePass_TaskUpdate", handler(self, self.OnTaskUpdate))
  self:addEventListener("eGameEvent_Activity_AnywayReload", handler(self, self.OnFreshActivity))
  self:addEventListener("eGameEvent_Activity_BattlePass_CloseMain", handler(self, self.OnBackClk))
  self:addEventListener("eGameEvent_Activity_BattlePass_AdvancedPassBought", handler(self, self.FreshRewardRedShow))
  self:addEventListener("eGameEvent_Activity_BattlePass_RewardGet", handler(self, self.FreshRewardRedShow))
end

function UIBattlePassMain:OnFreshActivity()
  if self.m_iActivityId then
    self.m_stActivity = ActivityManager:GetActivityByID(self.m_iActivityId)
    if not self.m_stActivity then
      self:CloseForm()
    end
  end
end

function UIBattlePassMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function UIBattlePassMain:OnBuyExp(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshRewardRedShow()
    self:FreshTaskRedShow()
    self:FreshTaskLevelInfoShow()
  end
end

function UIBattlePassMain:OnTaskReFresh(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshTaskRedShow()
  end
end

function UIBattlePassMain:OnTaskUpdate(data)
  if data.iActivityID == self.m_stActivity:getID() then
    self:FreshTaskLevelInfoShow()
    self:FreshTaskRedShow()
    self:FreshRewardRedShow()
  end
end

function UIBattlePassMain:FreshUI()
  if self.m_stActivity == nil then
    self:CloseForm()
    return
  end
  self:FreshTitlePanel()
  self:FreshTopTipsAndClose()
  self:FreshTaskLevelInfoShow()
  self:RefreshRemainTime()
  self:FreshShowActSpineInfo()
  self:FreshBgPic()
  self:FreshTaskRedShow()
  self:FreshRewardRedShow()
end

function UIBattlePassMain:FreshTitlePanel()
  if not self.m_stActivity then
    return
  end
  self.m_pnl_title1:SetActive(false)
  self.m_pnl_title2:SetActive(false)
  if self.m_titleType == 2 then
    self.m_pnl_title1:SetActive(false)
    self.m_pnl_title2:SetActive(true)
    local roleName = self.m_stActivity:GetRoleName()
    local isShowRoleName = roleName and roleName ~= ""
    self.m_txt_role2:SetActive(isShowRoleName)
    if isShowRoleName then
      self.m_txt_role2_Text.text = roleName
    end
    local skinName = self.m_stActivity:GetSkinName()
    local isShowSkinName = skinName and skinName ~= ""
    self.m_txt_bp_titlle2:SetActive(isShowSkinName)
    if isShowSkinName then
      self.m_txt_bp_titlle2_Text.text = skinName
    end
  else
    self.m_pnl_title1:SetActive(true)
    self.m_pnl_title2:SetActive(false)
    local titleName = self.m_stActivity:GetTitleAndEnterName()
    if titleName and titleName ~= "" then
      self.m_pnl_name1:SetActive(false)
      self.m_pnl_name2:SetActive(true)
      self.m_txt_bp_titlle_Text.text = titleName
    else
      self.m_pnl_name1:SetActive(true)
      self.m_pnl_name2:SetActive(false)
    end
  end
end

function UIBattlePassMain:FreshTopTipsAndClose()
  local tipsId
  if self.m_stActivity then
    tipsId = self.m_stActivity:GetTipsID()
  end
  if not self.m_isInitTopBtn then
    local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
    self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), tipsId)
    self.m_isInitTopBtn = true
  end
end

function UIBattlePassMain:FreshTaskLevelInfoShow()
  if not self.m_stActivity then
    return
  end
  UILuaHelper.SetActive(self.m_vx_rank, false)
  local curLevel = self.m_stActivity:GetCurLevel()
  if curLevel ~= self.m_lastLevel then
    self.m_lastLevel = curLevel
    UILuaHelper.SetActive(self.m_vx_rank, true)
  end
  self.m_txt_rank_Text.text = self.m_stActivity:GetCurLevel()
  self:FreshProgress()
end

function UIBattlePassMain:FreshProgress()
  local lastFillAmount = self.m_img_bar_Image.fillAmount
  UILuaHelper.SetActive(self.m_vx_barglow, false)
  local curLevel = self.m_stActivity:GetCurLevel()
  local levelCfg = self.m_stActivity:GetLevelCfg(curLevel)
  if levelCfg then
    local needExp = self.m_stActivity:GetUpLevelExp()
    if curLevel == self.m_stActivity:GetMaxLevel() then
      self.m_img_bar_Image.fillAmount = 1
      self.m_icon_txt_Text.text = needExp .. "/" .. needExp
      UILuaHelper.SetActive(self.m_btn_add, false)
      UILuaHelper.SetActive(self.m_btn_full, true)
    else
      local curExp = self.m_stActivity:GetCurExp()
      if needExp <= curExp then
        self.m_img_bar_Image.fillAmount = 1
      else
        self.m_img_bar_Image.fillAmount = curExp / needExp
      end
      self.m_icon_txt_Text.text = curExp .. "/" .. needExp
      UILuaHelper.SetActive(self.m_btn_add, true)
      UILuaHelper.SetActive(self.m_btn_full, false)
    end
  end
  if not self.m_firstEnterPlay and lastFillAmount ~= self.m_img_bar_Image.fillAmount then
    UILuaHelper.SetActive(self.m_vx_barglow, true)
    if self.m_animTime then
      self:ClearAnimTimer()
      self.m_animaTimer = TimeService:SetTimer(self.m_animTime, 1, function()
        UILuaHelper.SetActive(self.m_vx_barglow, false)
        self.m_animaTimer = nil
      end)
    end
  end
end

function UIBattlePassMain:FreshRewardRedShow()
  if not self.m_stActivity then
    return
  end
  if not self.m_stActivity.HasRewardRed then
    return
  end
  local isRewardHaveRed = self.m_stActivity:HasRewardRed()
  UILuaHelper.SetActive(self.m_reddot_reward, isRewardHaveRed)
end

function UIBattlePassMain:FreshTaskRedShow()
  if not self.m_stActivity then
    return
  end
  if not self.m_stActivity.ReachMaxLevel or not self.m_stActivity.HasUnclaimedTask then
    return
  end
  local isTaskHaveRed = not self.m_stActivity:ReachMaxLevel() and self.m_stActivity:HasUnclaimedTask()
  UILuaHelper.SetActive(self.m_reddot_task, isTaskHaveRed)
end

function UIBattlePassMain:FreshBgPic()
  if self.m_stActivity then
    local bg, bg1 = self.m_stActivity:GetBpBgPic()
    if bg and bg ~= "" then
      UILuaHelper.SetUITexture(self.m_img_bg_Image, bg, function()
        self.m_img_bg:SetActive(true)
      end)
    end
    if bg1 and bg1 ~= "" then
      UILuaHelper.SetUITexture(self.m_img_bg1_Image, bg1, function()
        self.m_img_bg1:SetActive(true)
      end)
    end
  end
end

function UIBattlePassMain:FreshShowActSpineInfo()
  if self.m_stActivity then
    local spineStr = self.m_stActivity:GetAvatarSpineName()
    if spineStr and spineStr ~= "" then
      self:ShowHeroSpine(self.m_stActivity:GetAvatarSpineName())
    end
  end
end

function UIBattlePassMain:RefreshRemainTime()
  if not self.m_stActivity then
    return
  end
  local remainTime = self.m_stActivity:getActivityRemainTime()
  if 0 < remainTime then
    local showTimeStr = TimeUtil:SecondsToFormatCNStr4(remainTime)
    showTimeStr = string.CS_Format(ConfigManager:GetCommonTextById(220018), showTimeStr)
    self.m_txt_time_Text.text = showTimeStr
  else
    self.m_stopUpdate = true
    utils.CheckAndPushCommonTips({
      tipsID = 1751,
      func1 = function()
        self:CloseForm()
      end
    })
  end
end

function UIBattlePassMain:ShowHeroSpine(heroSpinePathStr)
  if self.m_curHeroSpineObj and self.m_curHeroSpineObj.spineStr == heroSpinePathStr then
    return
  end
  self:CheckRecycleSpine()
  if self.m_HeroSpineDynamicLoader then
    local typeStr = SpinePlaceCfg.HeroBpMain
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpinePathStr, typeStr, self.m_root_hero, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      UILuaHelper.SetActive(self.m_curHeroSpineObj.spinePlaceObj, true)
    end)
  end
end

function UIBattlePassMain:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function UIBattlePassMain:CheckShowLevelUp10()
  if not self.m_stActivity then
    return
  end
  local curBuyStatus = self.m_stActivity:GetBuyStatus()
  if self.m_stActivity:GetBattlePassHasAdvance() and curBuyStatus == BattlePassBuyStatus.Advanced then
    return
  end
  if curBuyStatus == BattlePassBuyStatus.Paid then
    return
  end
  local isMax = self.m_stActivity:ReachMaxLevel()
  local actID = self.m_stActivity:getID()
  local levelPrefabId = self.m_stActivity:GetBuyPanel2Prefab()
  if isMax then
    local isShow = LocalDataManager:GetIntSimple("BattlePassMaxShowPanel" .. actID, 0) == 1
    if isShow then
      return
    end
    if curBuyStatus ~= BattlePassBuyStatus.Free then
      return
    end
    StackFlow:Push(levelPrefabId, {
      stActivity = self.m_stActivity
    })
    LocalDataManager:SetIntSimple("BattlePassMaxShowPanel" .. actID, 1)
  else
    local curLv = self.m_stActivity:GetCurLevel()
    local advanceAddLvNum = self.m_stActivity:GetAdvancedAddLv()
    local maxLv = self.m_stActivity:GetMaxLevel()
    if curLv == maxLv - advanceAddLvNum then
      local isShow = LocalDataManager:GetIntSimple("BattlePassInAdvanceAddLvShowPanel" .. actID, 0) == 1
      if isShow then
        return
      end
      StackFlow:Push(levelPrefabId, {
        stActivity = self.m_stActivity
      })
      LocalDataManager:SetIntSimple("BattlePassInAdvanceAddLvShowPanel" .. actID, 1)
    end
  end
end

function UIBattlePassMain:OnBackClk()
  self:CloseForm()
end

function UIBattlePassMain:OnBackHome()
  if BattleFlowManager:IsInBattle() == true then
    BattleFlowManager:FromBattleToHall()
  else
    StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  end
end

function UIBattlePassMain:OnBtntaskClicked()
  if self.m_curSelectTab == TopTabType.TaskPanel then
    return
  end
  GlobalManagerIns:TriggerWwiseBGMState(32)
  self.m_curSelectTab = TopTabType.TaskPanel
  self:FreshTopTabAndPanel()
end

function UIBattlePassMain:OnBtnrewardClicked()
  if self.m_curSelectTab == TopTabType.RewardPanel then
    return
  end
  GlobalManagerIns:TriggerWwiseBGMState(32)
  self.m_curSelectTab = TopTabType.RewardPanel
  self:FreshTopTabAndPanel()
end

function UIBattlePassMain:OnBtnaddClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLEPASSLEVELUPPOP, {
    stActivity = self.m_stActivity
  })
end

function UIBattlePassMain:OnBtncheck3Clicked()
  local heroId = self.m_stActivity:GetHeroId()
  local skinId = self.m_stActivity:GetSkinId()
  if heroId and skinId then
    StackFlow:Push(UIDefines.ID_FORM_FASHION, {heroID = heroId, fashionID = skinId})
  end
end

function UIBattlePassMain:ClearAnimTimer()
  if self.m_animaTimer then
    TimeService:KillTimer(self.m_animaTimer)
    self.m_animaTimer = nil
  end
end

function UIBattlePassMain:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local spineName = tParam.stActivity:GetAvatarSpineName()
  if spineName then
    vResourceExtra[#vResourceExtra + 1] = {
      sName = spineName,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

function UIBattlePassMain:IsFullScreen()
  return true
end

return UIBattlePassMain
