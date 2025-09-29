local Form_Activity110MiniGameMain = class("Form_Activity110MiniGameMain", require("UI/UIFrames/Form_Activity110MiniGameMainUI"))
local levelTb = ConfigManager:GetConfigInsByName("MiniGameA10LevelInfo")
local LevelName = {
  CHUJI = 1,
  ZHONGJI = 2,
  GAOJI = 3,
  TEJI = 4
}
local spineName = "fanu_base_lounge"
local defaultSpineAnim = "idle_01"

function Form_Activity110MiniGameMain:SetInitParam(param)
end

function Form_Activity110MiniGameMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  if goBackBtnRoot then
    self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1267)
  end
  self:addEventListener("Form_Activity110MiniGameBattleMain_close", handler(self, self.OnMiniGameFinish))
  for i = 1, 4 do
    self:LockBtn(i, true)
  end
  self.m_spineClick = self.m_root_hero:GetComponent("SpineClick")
  if self.m_spineClick then
    self.m_spineClick.raycaster = self.m_rootTrans:GetComponent("GraphicRaycasterBugFixed")
  end
  self.m_curHeroSpineObj = nil
  self.m_spineObjTab = nil
end

function Form_Activity110MiniGameMain:OnMiniGameFinish()
  self:FreshLock(nil)
end

function Form_Activity110MiniGameMain:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(386)
  self.main_id = tParam.main_id
  self.sub_id = tParam.sub_id
  self.lvId = tParam.lvId
  if utils.isNull(self.lvId) then
    self.lvId = 1001
  end
  UILuaHelper.SetActive(self.m_pnl_unlock_tips, false)
  local act_data = HeroActivityManager:GetHeroActData(self.main_id)
  if act_data then
    self.server_gameStat = act_data.server_data.stMiniGame.mGameStat
    self.server_gameScore = act_data.server_data.stMiniGame.mGameScore
  end
  self.NowClickedLevelId = self.lvId
  for i = 1, 4 do
    self["m_txt_task" .. i .. "_Text"].text = levelTb:GetValue_BySubActIDAndLevelID(self.sub_id, 100 .. i).m_mLevelName
  end
  self:RegisterOrUpdateRedDotItem(self.m_minigame_redpoint, RedDotDefine.ModuleType.MiniGame110Reward, self.main_id)
  self:RegisterOrUpdateRedDotItem(self.m_start_redpoint, RedDotDefine.ModuleType.MiniGame110StartBtn, self.main_id)
  self:FreshLock(self.NowClickedLevelId)
  local hero_id = tonumber(ConfigManager:GetGlobalSettingsByKey("MiniGameA10CharID"))
  local unlock, isLoungeHero, tips = LoungeManager:CheckHeroLoungeUnlockById(hero_id)
  UILuaHelper.SetActive(self.m_img_bg_loungelcok, not unlock)
  self:ShowHeroSpine(spineName)
end

function Form_Activity110MiniGameMain:OnInactive()
  self.super.OnInactive(self)
  TimeService:KillTimer(self.timer)
  ResourceUtil:DestroyAndUnloadUIPrefab(self.m_spineObjTab, spineName)
end

function Form_Activity110MiniGameMain:ShowHeroSpine(showSpineStr)
  if not utils.isNull(self.m_spineObjTab) then
    if not utils.isNull(self.m_curHeroSpineObj) then
      UILuaHelper.SetActive(self.m_curHeroSpineObj, false)
    end
    self.m_curHeroSpineObj = self.m_spineObjTab
    UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
    return
  end
  
  local function callBack(spineLoadObj)
    if not utils.isNull(self.m_curHeroSpineObj) then
      UILuaHelper.SetActive(self.m_curHeroSpineObj, false)
    end
    self.m_spineObjTab = spineLoadObj
    self.m_curHeroSpineObj = spineLoadObj
    self:OnLoadSpineBack(showSpineStr)
  end
  
  ResourceUtil:CreateUIPrefab(showSpineStr, self.m_root_hero, callBack)
end

function Form_Activity110MiniGameMain:OnLoadSpineBack(showSpineStr)
  if not self.m_curHeroSpineObj then
    return
  end
  UILuaHelper.SetActive(self.m_curHeroSpineObj, true)
  UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj)
  UILuaHelper.SetSpineTimeScale(self.m_curHeroSpineObj, 1)
  self:PlaySpineAnimWithStr(defaultSpineAnim, true)
end

function Form_Activity110MiniGameMain:PlaySpineAnimWithStr(animStr, isLoop, endFun, speed)
  if animStr and UILuaHelper.CheckIsHaveSpineAnim(self.m_curHeroSpineObj, animStr) then
    speed = speed or 1
    UILuaHelper.SpinePlayAnimWithBack(self.m_curHeroSpineObj, 0, animStr, isLoop, false, endFun, speed)
  end
end

function Form_Activity110MiniGameMain:FreshLock(lvid)
  for i = 1, 4 do
    if not self:IsSelect(i) then
      self:LockBtn(i, true)
    end
    local levelid = 100 .. i
    local unlock = self:CheckLock(levelid)
    if unlock then
      local isUnlock = LocalDataManager:GetIntSimple("Form_Activity110MiniGameMain_lv" .. levelid, 0)
      if isUnlock == 0 then
        LocalDataManager:SetIntSimple("Form_Activity110MiniGameMain_lv" .. levelid, 1)
        self.timer = TimeService:SetTimer(0.5, 1, function()
          UILuaHelper.SetActive(self.m_pnl_unlock_tips, true)
          UILuaHelper.PlayAnimationByName(self.m_pnl_unlock_tips, "m_pnl_unlock_tips_in")
        end)
        UILuaHelper.PlayAnimationByName(self["m_btn_task" .. i], "m_btn_task_unlock")
      else
        local isOrgSelct = false
        if self:IsSelect(i) then
          isOrgSelct = true
        end
        self:LockBtn(i, false)
        if isOrgSelct then
          UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_select"), true)
        end
      end
    end
  end
  if not utils.isNull(lvid) then
    local index = tonumber(tostring(lvid):sub(-1))
    self:SelectBtn(index)
  end
end

function Form_Activity110MiniGameMain:CheckLock(levelId)
  local cfg = levelTb:GetValue_BySubActIDAndLevelID(self.sub_id, levelId)
  local unlockc1 = self:IsTimeUnlock(cfg)
  local unlockc2 = false
  if cfg.m_OrderLevel == 0 then
    unlockc2 = true
  elseif self.server_gameStat[cfg.m_OrderLevel] ~= nil and 0 < self.server_gameStat[cfg.m_OrderLevel] then
    unlockc2 = true
  end
  return unlockc1 and unlockc2
end

function Form_Activity110MiniGameMain:IsTimeUnlock(cfg)
  local open_time = 0
  if cfg.m_OpenTime and cfg.m_OpenTime ~= "" then
    open_time = TimeUtil:TimeStringToTimeSec2(cfg.m_OpenTime) or 0
  end
  local is_corved, t1 = HeroActivityManager:CheckIsCorveTimeByType(HeroActivityManager.CorveTimeType.minigame, {
    id = self.main_id,
    m_MemoryID = cfg.m_LevelID
  })
  if is_corved then
    open_time = t1
  end
  local cur_time = TimeUtil:GetServerTimeS()
  local unlock = open_time <= cur_time
  return unlock, open_time
end

function Form_Activity110MiniGameMain:LockBtn(index, flag)
  local ncolor = self["m_btn_task" .. index].transform:Find("m_img_bg_lcok"):GetComponent("Image").color
  ncolor.a = 1
  self["m_btn_task" .. index].transform:Find("m_img_bg_lcok"):GetComponent("Image").color = ncolor
  local lockimg = self["m_btn_task" .. index].transform:Find("m_img_bg_lcok")
  UILuaHelper.SetActive(lockimg, flag)
  UILuaHelper.SetActive(self["m_btn_task" .. index].transform:Find("m_img_bg_select"), false)
  UILuaHelper.SetActive(self["m_btn_task" .. index].transform:Find("m_img_bg_finish"), false)
  UILuaHelper.SetActive(self["m_btn_task" .. index].transform:Find("m_img_bg_normal"), true)
end

function Form_Activity110MiniGameMain:Islocked(index)
  return self["m_btn_task" .. index].transform:Find("m_img_bg_lcok").gameObject.activeInHierarchy
end

function Form_Activity110MiniGameMain:IsSelect(index)
  return self["m_btn_task" .. index].transform:Find("m_img_bg_select").gameObject.activeInHierarchy
end

function Form_Activity110MiniGameMain:SelectBtn(index, flag)
  local isUnlock = LocalDataManager:GetIntSimple("Form_Activity110MiniGameMain_lv" .. 100 .. index, 0)
  if isUnlock == 0 then
    return
  end
  for i = 1, 4 do
    if index == i then
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_normal"), true)
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_lcok"), false)
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_finish"), false)
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_select"), true)
    else
      local isUnlock = LocalDataManager:GetIntSimple("Form_Activity110MiniGameMain_lv" .. 100 .. i, 0)
      if isUnlock == 0 then
        return
      end
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_normal"), true)
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_lcok"), false)
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_finish"), false)
      UILuaHelper.SetActive(self["m_btn_task" .. i].transform:Find("m_img_bg_select"), false)
    end
  end
end

function Form_Activity110MiniGameMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity110MiniGameMain:OnBackClk()
  self:CloseForm()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(415)
end

function Form_Activity110MiniGameMain:OnBtnClick(levelid, index)
  local cfg = levelTb:GetValue_BySubActIDAndLevelID(self.sub_id, levelid)
  local _, opentime = self:IsTimeUnlock(cfg)
  if self:Islocked(index) then
    local before_cfg = levelTb:GetValue_BySubActIDAndLevelID(self.sub_id, cfg.m_OrderLevel)
    local tstr = TimeUtil:TimerToString3(opentime)
    local str = string.gsubNumberReplace(ConfigManager:GetClientMessageTextById(40054), before_cfg.m_mLevelName, tstr)
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, str)
    return
  end
  self.NowClickedLevelId = levelid
  self:SelectBtn(index)
end

function Form_Activity110MiniGameMain:OnBtntask1Clicked()
  self:OnBtnClick(1001, LevelName.CHUJI)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
end

function Form_Activity110MiniGameMain:OnBtntask2Clicked()
  self:OnBtnClick(1002, LevelName.ZHONGJI)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
end

function Form_Activity110MiniGameMain:OnBtntask3Clicked()
  self:OnBtnClick(1003, LevelName.GAOJI)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
end

function Form_Activity110MiniGameMain:OnBtntask4Clicked()
  self:OnBtnClick(1004, LevelName.TEJI)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(21)
end

function Form_Activity110MiniGameMain:OnBtnloungeClicked()
  local hero_id = tonumber(ConfigManager:GetGlobalSettingsByKey("MiniGameA10CharID"))
  local unlock, isLoungeHero, tips = LoungeManager:CheckHeroLoungeUnlockById(hero_id)
  if (not unlock or not isLoungeHero) and tips then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips)
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_LOUNGE, {heroId = hero_id})
end

function Form_Activity110MiniGameMain:OnBtnrewardClicked()
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110MINIGAMEREWARD, {
    main_id = self.main_id,
    sub_id = self.sub_id
  })
end

function Form_Activity110MiniGameMain:OnBtnstartClicked()
  log.info("当前选择难度：", self.NowClickedLevelId)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(391)
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110MINIGAMEBATTLEMAIN, {
    lvId = self.NowClickedLevelId,
    main_id = self.main_id,
    sub_id = self.sub_id
  })
  local curServerDate = TimeUtil:GetServerDate(TimeUtil:GetServerTimeS())
  local timeStr = curServerDate.year .. curServerDate.month .. curServerDate.day
  LocalDataManager:SetStringSimple("Minigame_Aiyuefa_DayilyRedpointDt", timeStr)
  self:broadcastEvent("eGameEvent_ActMinigame_StartGame")
  self:broadcastEvent("eGameEvent_Today_Play")
  self:CloseForm()
end

function Form_Activity110MiniGameMain:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  if spineName then
    vResourceExtra[#vResourceExtra + 1] = {
      sName = spineName,
      eType = DownloadManager.ResourceType.UI
    }
  end
  return vPackage, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_Activity110MiniGameMain", Form_Activity110MiniGameMain)
return Form_Activity110MiniGameMain
