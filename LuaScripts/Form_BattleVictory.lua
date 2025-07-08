local Form_BattleVictory = class("Form_BattleVictory", require("UI/UIFrames/Form_BattleVictoryUI"))
local PushFaceManager = _ENV.PushFaceManager
local String_Format = string.format
local AccountLevelIns = ConfigManager:GetConfigInsByName("AccountLevel")
local GlobalSettingsIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local AFK_LEVEL_CNT = tonumber(GlobalSettingsIns:GetValue_ByName("AFKLevelCnt").m_Value) or 5
local GoblinRewardIns = ConfigManager:GetConfigInsByName("GoblinReward")
local AFKEXPAnim = "ash_in"
local AFKEXPAnimDeltaTime = 0.8
local RoleExpTime = 1.5
local StartWaitTime = 0.5
local DurationTime = 0.1
local ItemInAnimStr = "BattleVictory_common_item_in"
local MaxProgressNum = LevelManager.GoblinMaxProgressNum

function Form_BattleVictory:SetInitParam(param)
end

function Form_BattleVictory:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  self.m_itemDataList = nil
  self.m_ItemWidgetList = {}
  self.m_rewardItemBase = self.m_reward_root.transform:Find("c_common_item")
  UILuaHelper.SetActive(self.m_rewardItemBase, false)
  self.m_roleExpUpTimer = nil
  self.m_isShowAnim = false
  self.m_groupRewardCfgList = nil
  self.m_HeroSpineDynamicLoader = UIDynamicObjectManager:GetCustomLoaderByType(UIDynamicObjectManager.CustomLoaderType.Spine)
  self.m_curHeroSpineObj = nil
end

function Form_BattleVictory:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  GlobalManagerIns:TriggerWwiseBGMState(9)
  ActivityManager:CheckEmergencyGift()
  self:FreshData()
  self:FreshUI()
end

function Form_BattleVictory:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:CheckRecycleSpine(true)
  self:ClearData()
end

function Form_BattleVictory:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleSpine(true)
  for i = 0, AFK_LEVEL_CNT do
    if self["AFKExpUpTimer" .. i] then
      TimeService:KillTimer(self["AFKExpUpTimer" .. i])
      self["AFKExpUpTimer" .. i] = nil
    end
  end
  if self.m_waitAnimTimer then
    TimeService:KillTimer(self.m_waitAnimTimer)
    self.m_waitAnimTimer = nil
  end
  if self.m_itemDataList ~= nil then
    local dataLen = #self.m_itemDataList
    for i = 1, dataLen do
      if self["ItemInitTimer" .. i] then
        TimeService:KillTimer(self["ItemInitTimer" .. i])
        self["ItemInitTimer" .. i] = nil
      end
    end
  end
  local roleLevelUpList = self:GetRoleLevelExpUpList()
  if roleLevelUpList and #roleLevelUpList then
    local roleLvNum = #roleLevelUpList
    for i = 1, roleLvNum do
      if self["RoleLvTimer" .. i] then
        TimeService:KillTimer(self["RoleLvTimer" .. i])
        self["RoleLvTimer" .. i] = nil
      end
    end
  end
  local afkLvUpList = self:GetAFKExpUpList()
  if afkLvUpList and next(afkLvUpList) then
    for i, v in ipairs(afkLvUpList) do
      if self["AFKLvTimer" .. i] then
        TimeService:KillTimer(self["AFKLvTimer" .. i])
        self["AFKLvTimer" .. i] = nil
      end
    end
  end
  if self.m_roleExpUpTimer then
    TimeService:KillTimer(self.m_roleExpUpTimer)
    self.m_roleExpUpTimer = nil
  end
  self:ClearData()
end

function Form_BattleVictory:AddEventListeners()
  self:addEventListener("eGameEvent_Activity_EmergencyGiftPush", handler(self, self.OnEmergencyGift))
end

function Form_BattleVictory:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_BattleVictory:OnEmergencyGift(params)
  local act = ActivityManager:GetActivityByType(MTTD.ActivityType_EmergencyGift)
  if act then
    local pushGift = act:GetPackList()
    if pushGift and 0 < #pushGift then
      self:broadcastEvent("eGameEvent_EmergencyGiftPushFace", {
        activityId = act:getID(),
        isPush = true
      })
    end
  end
end

function Form_BattleVictory:ClearData()
end

function Form_BattleVictory:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelID = tParam.levelID
  self.m_levelSubType = LevelManager:GetLevelSunType(self.m_levelType, self.m_levelID)
  self.m_csRewardList = tParam.rewardData
  self.m_isQuickFinish = tParam.isQuickFinish
  self.m_levelCfg = LevelManager:GetLevelCfgByTypeAndLevelID(self.m_levelType, self.m_levelID)
  self.m_showHeroID = tParam.showHeroID
  log.info("Form_BattleVictory tParam.showHeroID tParam.showHeroID: " .. tostring(self.m_showHeroID))
  self:FreshRewardListData()
  self.m_csui.m_param = nil
end

function Form_BattleVictory:FreshRewardListData()
  if not self.m_csRewardList then
    return
  end
  self.m_itemDataList = {}
  for key, rewardCsData in pairs(self.m_csRewardList) do
    if rewardCsData then
      local tempReward = {
        iID = rewardCsData.iID,
        iNum = rewardCsData.iNum
      }
      self.m_itemDataList[#self.m_itemDataList + 1] = tempReward
    end
  end
end

function Form_BattleVictory:GetRoleMaxExpNum(roleLV)
  if not roleLV then
    return
  end
  local accountLevelCfg = AccountLevelIns:GetValue_ByAccountLv(roleLV)
  if accountLevelCfg:GetError() then
    return
  end
  return accountLevelCfg.m_AccountlvupEXP
end

function Form_BattleVictory:GetLevelSettlementByTypeAndID()
  local levelCfg = LevelManager:GetLevelCfgByTypeAndLevelID(self.m_levelType, self.m_levelID)
  if not levelCfg then
    return
  end
  return levelCfg.m_Settlement
end

function Form_BattleVictory:GetShowSpineAndVoice()
  local heroID = self:GetLevelSettlementByTypeAndID()
  local heroCfg
  if heroID and heroID ~= 0 then
    heroCfg = HeroManager:GetHeroConfigByID(heroID)
  else
    heroID = self.m_showHeroID
    if heroID then
      heroCfg = HeroManager:GetHeroConfigByID(heroID)
    end
  end
  if not heroCfg then
    return
  end
  local voice = HeroManager:GetHeroBattleVictoryVoice(heroID)
  local spineStr = heroCfg.m_Spine
  if not spineStr then
    return
  end
  return spineStr, voice
end

function Form_BattleVictory:GetRoleLevelExpUpList()
  local oldRoleLv = RoleManager:GetOldLevel()
  local curRoleLv = RoleManager:GetLevel() or 0
  local oldRoleExp = RoleManager:GetOldRoleExp()
  local roleExp = RoleManager:GetRoleExp() or 0
  local roleLevelUpList = {}
  if curRoleLv == oldRoleLv then
    local roleLvMaxExp = self:GetRoleMaxExpNum(curRoleLv) or 0
    roleLevelUpList[#roleLevelUpList + 1] = {
      showLv = curRoleLv,
      startRoleExp = oldRoleExp,
      endRoleExp = roleExp,
      maxExp = roleLvMaxExp
    }
  else
    for i = oldRoleLv, curRoleLv do
      local roleLvMaxExp = self:GetRoleMaxExpNum(i) or 0
      roleLevelUpList[#roleLevelUpList + 1] = {
        showLv = i,
        startRoleExp = i == oldRoleLv and oldRoleExp or 0,
        endRoleExp = i == curRoleLv and roleExp or roleLvMaxExp,
        maxExp = roleLvMaxExp
      }
    end
  end
  return roleLevelUpList
end

function Form_BattleVictory:GetAFKExpUpList()
  local afkLv = HangUpManager:GetAFKLevel()
  local oldAFKLv = HangUpManager:GetOldAFKLevel()
  local afkExp = HangUpManager:GetAFKExp()
  local oldAFKExp = HangUpManager:GetOldAFKExp()
  local afkUpList = {}
  if oldAFKLv == 0 then
    oldAFKLv = 1
  end
  if afkLv == oldAFKLv then
    afkUpList[#afkUpList + 1] = {
      afkLv = afkLv,
      startAFKExp = oldAFKExp,
      endAFKExp = afkExp,
      lastLvUpExpPoint = 0
    }
  else
    for i = oldAFKLv, afkLv do
      local lastLvUpItem = afkUpList[#afkUpList]
      local lastLvUpExpPoint = lastLvUpItem and lastLvUpItem.lastLvUpExpPoint + lastLvUpItem.endAFKExp - lastLvUpItem.startAFKExp or 0
      afkUpList[#afkUpList + 1] = {
        afkLv = i,
        startAFKExp = i == oldAFKLv and oldAFKExp or 0,
        endAFKExp = i == afkLv and afkExp or AFK_LEVEL_CNT,
        lastLvUpExpPoint = lastLvUpExpPoint
      }
    end
  end
  return afkUpList
end

function Form_BattleVictory:GetShowSpineHeroIDByParam(tParam)
  if not tParam then
    return
  end
  local levelCfg = LevelManager:GetLevelCfgByTypeAndLevelID(tParam.levelType, tParam.levelID)
  if not levelCfg then
    return
  end
  local settlementSpine = levelCfg.m_Settlement
  if settlementSpine and settlementSpine ~= "" then
    local characterInfoCfg = ConfigManager:GetConfigInsByName("CharacterInfo")
    local allHeroCfg = characterInfoCfg:GetAll()
    for i, tempCfg in pairs(allHeroCfg) do
      if tempCfg.m_Spine == settlementSpine then
        return tempCfg.m_HeroID
      end
    end
  end
  return tParam.showHeroID
end

function Form_BattleVictory:FreshUI()
  if self.m_levelType == nil or self.m_levelType == 0 then
    return
  end
  self:FreshRewardItems()
  self:FreshShowSpine()
  self:FreshHangUpShow()
  self:FreshShowNextLevel()
  self:CheckShowBeforeLv()
  self:FreshShowLevelInfo()
  self:FreshShowAddExpInfo()
  self.m_isShowAnim = true
  UILuaHelper.SetActive(self.m_btn_MaskSkip, true)
  self.m_waitAnimTimer = TimeService:SetTimer(StartWaitTime, 1, function()
    self.m_waitAnimTimer = nil
    self:CheckShowEnterAnim()
  end)
  self:FreshShowRewardItemAnims()
end

function Form_BattleVictory:FreshShowAddExpInfo()
  local oldRoleLv = RoleManager:GetOldLevel()
  local curRoleLv = RoleManager:GetLevel() or 0
  local oldRoleExp = RoleManager:GetOldRoleExp()
  local roleExp = RoleManager:GetRoleExp() or 0
  local totalAddRole = 0
  if oldRoleLv == nil or oldRoleExp == nil then
    totalAddRole = 0
  elseif oldRoleLv == curRoleLv then
    totalAddRole = roleExp - oldRoleExp
  else
    for i = oldRoleLv, curRoleLv do
      if i == oldRoleLv then
        local roleMaxExp = self:GetRoleMaxExpNum(i)
        totalAddRole = totalAddRole + roleMaxExp - oldRoleExp
      elseif i == curRoleLv then
        totalAddRole = totalAddRole + roleExp
      else
        local roleMaxExp = self:GetRoleMaxExpNum(i)
        totalAddRole = totalAddRole + roleMaxExp
      end
    end
  end
  self.m_txt_exp_num_Text.text = "+" .. totalAddRole
end

function Form_BattleVictory:FreshShowLevelInfo()
  if not self.m_levelID then
    return
  end
  local isGoblin = self.m_levelType == LevelManager.LevelType.Goblin
  UILuaHelper.SetActive(self.m_node_goblin_level_info, isGoblin)
  UILuaHelper.SetActive(self.m_node_normal, not isGoblin)
  UILuaHelper.SetActive(self.m_img_win, not isGoblin)
  if isGoblin then
    local levelCfg, levelNameStr
    levelCfg = LevelManager:GetLevelCfgByTypeAndLevelID(self.m_levelType, self.m_levelID)
    if levelCfg then
      levelNameStr = levelCfg.m_LevelName or levelCfg.m_mName
    end
    self.m_txt_level_title_Text.text = levelNameStr
    local goblinHelper = LevelManager:GetLevelGoblinHelper()
    local curStageIndex, rewardStageNum, scoreNum = goblinHelper:GetGoblinRewardIndex(levelCfg)
    curStageIndex = curStageIndex or 0
    rewardStageNum = rewardStageNum or 0
    self.m_txt_damagenum_Text.text = scoreNum
    for i = 1, MaxProgressNum do
      UILuaHelper.SetActive(self["m_pnl_item" .. i], i <= rewardStageNum)
      if i <= rewardStageNum then
        UILuaHelper.SetActive(self["m_unfinish_item" .. i], i > curStageIndex)
        UILuaHelper.SetActive(self["m_finish_item" .. i], i <= curStageIndex)
        if 2 <= curStageIndex then
          local processNum = curStageIndex - 1
          local maxProcessNum = MaxProgressNum - 1
          local percentNum = processNum / maxProcessNum
          self.m_img_line_progress_Image.fillAmount = percentNum
        else
          self.m_img_line_progress_Image.fillAmount = 0
        end
      end
    end
  end
  local rewardViewRoot = isGoblin and self.m_material_reward_root or self.m_normal_reward_root
  UILuaHelper.SetParent(self.m_reward_view, rewardViewRoot, true)
end

function Form_BattleVictory:GetGoblinRewardIndex(levelCfg)
  if not levelCfg then
    return
  end
  local rewardGroupID = levelCfg.m_RewardGroupID
  if not rewardGroupID then
    return
  end
  self.m_groupRewardCfgList = {}
  local groupRewardCfgArray = GoblinRewardIns:GetValue_ByRewardGroupID(rewardGroupID)
  if not groupRewardCfgArray then
    return
  end
  for i, v in pairs(groupRewardCfgArray) do
    local tempReward = {
      rewardCfg = v,
      stageID = v.m_StageID
    }
    self.m_groupRewardCfgList[#self.m_groupRewardCfgList + 1] = tempReward
  end
  table.sort(self.m_groupRewardCfgList, function(a, b)
    return a.stageID < b.stageID
  end)
  local goblinHelper = LevelManager:GetLevelGoblinHelper()
  local stageDetail = goblinHelper:GetLevelDetailDataByLevelID(levelCfg.m_LevelID) or {}
  local scoreNum = stageDetail.iScore or 0
  local rewardStageNum = #self.m_groupRewardCfgList
  local curStageIndex
  for i, v in ipairs(self.m_groupRewardCfgList) do
    local minScoreNum = v.rewardCfg.m_CountMin
    local upScoreNum
    if i < rewardStageNum then
      upScoreNum = self.m_groupRewardCfgList[i + 1].rewardCfg.m_CountMin
    else
      upScoreNum = v.rewardCfg.m_CountMin
    end
    curStageIndex = i
    if scoreNum >= minScoreNum and scoreNum < upScoreNum then
      break
    end
  end
  return curStageIndex, rewardStageNum, scoreNum
end

function Form_BattleVictory:FreshHangUpShow()
  local isShowHangUp = true
  if self.m_levelType == LevelManager.LevelType.Tower or UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.AFK) ~= true or self.m_levelType == LevelManager.LevelType.Dungeon then
    isShowHangUp = false
  end
  if self.m_levelType == LevelManager.LevelType.MainLevel and self.m_levelSubType == LevelManager.MainLevelSubType.ExLevel then
    isShowHangUp = false
  end
  UILuaHelper.SetActive(self.m_hangup_level, isShowHangUp)
end

function Form_BattleVictory:FreshShowNextLevel()
  local isShowNextBtn = false
  local levelTowerHelper = LevelManager:GetLevelTowerHelper()
  local subType = self.m_levelSubType
  local isOpen = levelTowerHelper:IsLevelSubTypeInOpen(subType)
  local isHaveTimes, curTime, maxTimes = levelTowerHelper:IsSubTowerHaveTimes(subType)
  if self.m_levelType == LevelManager.LevelType.Tower and levelTowerHelper:IsSubTowerAllLevelPass(subType) ~= true and isHaveTimes and isOpen then
    isShowNextBtn = true
  end
  local isShowBattleTimes = self.m_levelType == LevelManager.LevelType.Tower and subType ~= LevelManager.TowerLevelSubType.Main
  UILuaHelper.SetActive(self.m_btn_level_bg, isShowNextBtn)
  UILuaHelper.SetActive(self.m_txt_battletime, isShowNextBtn and isShowBattleTimes)
  if isShowNextBtn and isShowBattleTimes then
    local leftTimes = (maxTimes or 0) - (curTime or 0)
    self.m_txt_battletime_Text.text = String_Format(ConfigManager:GetCommonTextById(20036), leftTimes, maxTimes)
  end
end

function Form_BattleVictory:CheckShowBeforeLv()
  local oldRoleLv = RoleManager:GetOldLevel()
  local curRoleLv = RoleManager:GetLevel() or 0
  local oldRoleExp = RoleManager:GetOldRoleExp()
  local roleExp = RoleManager:GetRoleExp() or 0
  if oldRoleExp == nil or oldRoleLv == nil then
    self:FreshShowRoleLvAndExp(curRoleLv, roleExp)
  else
    self:FreshShowRoleLvAndExp(oldRoleLv or 0, oldRoleExp or 0)
  end
  local afkLvUpList = self:GetAFKExpUpList()
  if next(afkLvUpList) then
    self:FreshShowAFKPoint(afkLvUpList[1].startAFKExp)
  end
end

function Form_BattleVictory:CheckShowEnterAnim()
  self:CheckShowHangUpAnim()
  self:CheckShowRoleLevelAnim(function()
    PushFaceManager:CheckShowNextPopPanel()
    self.m_isShowAnim = false
    UILuaHelper.SetActive(self.m_btn_MaskSkip, false)
  end)
end

function Form_BattleVictory:CheckShowRoleLevelAnim(endFun)
  local oldRoleLv = RoleManager:GetOldLevel()
  local curRoleLv = RoleManager:GetLevel() or 0
  local oldRoleExp = RoleManager:GetOldRoleExp()
  local roleExp = RoleManager:GetRoleExp() or 0
  local roleMaxExp = self:GetRoleMaxExpNum(curRoleLv)
  if not roleMaxExp then
    if endFun then
      endFun()
    end
    return
  end
  if oldRoleExp == nil or oldRoleLv == nil then
    self:FreshShowRoleLvAndExp(curRoleLv, roleExp)
    if endFun then
      endFun()
    end
    return
  end
  local roleLevelUpList = self:GetRoleLevelExpUpList()
  if not roleLevelUpList then
    if endFun then
      endFun()
    end
    return
  end
  for i, roleUpItem in ipairs(roleLevelUpList) do
    local showLv = roleUpItem.showLv
    local startRoleExp = roleUpItem.startRoleExp
    local startPercent = roleUpItem.startRoleExp / roleUpItem.maxExp
    local endRoleExp = roleUpItem.endRoleExp
    local endPercent = roleUpItem.endRoleExp / roleUpItem.maxExp
    if i == 1 then
      self:FreshShowRoleLvAndExp(showLv, startRoleExp)
      UILuaHelper.DoTMPNumber(self.m_txt_role_exp_Text, startRoleExp, endRoleExp, RoleExpTime)
      UILuaHelper.DoSliderValue(self.m_exp_slider_Slider, startPercent, endPercent, RoleExpTime)
    else
      if self["RoleLvTimer" .. i] then
        TimeService:KillTimer(self["RoleLvTimer" .. i])
        self["RoleLvTimer" .. i] = nil
      end
      self["RoleLvTimer" .. i] = TimeService:SetTimer(RoleExpTime * (i - 1), 1, function()
        self["RoleLvTimer" .. i] = nil
        self:FreshShowRoleLvAndExp(showLv, startRoleExp)
        UILuaHelper.DoTMPNumber(self.m_txt_role_exp_Text, startRoleExp, endRoleExp, RoleExpTime)
        UILuaHelper.DoSliderValue(self.m_exp_slider_Slider, startPercent, endPercent, RoleExpTime)
      end)
    end
    if i == #roleLevelUpList then
      if self.m_roleExpUpTimer then
        TimeService:KillTimer(self.m_roleExpUpTimer)
        self.m_roleExpUpTimer = nil
      end
      self.m_roleExpUpTimer = TimeService:SetTimer(RoleExpTime * i + 0.5, 1, function()
        self.m_roleExpUpTimer = nil
        if endFun then
          endFun()
        end
      end)
    end
  end
end

function Form_BattleVictory:FreshShowRoleLvAndExp(roleLv, roleExp)
  roleLv = roleLv or 0
  roleExp = roleExp or 0
  local roleMaxExp = self:GetRoleMaxExpNum(roleLv) or 0
  self.m_txt_role_lv_Text.text = roleLv
  self.m_txt_role_exp_Text.text = roleExp
  self.m_txt_role_exp_total_Text.text = roleMaxExp
  local percentNum = roleExp / roleMaxExp
  if 1 < percentNum then
    percentNum = 1
  end
  self.m_exp_slider_Slider.value = percentNum
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_role_exp)
end

function Form_BattleVictory:CheckShowHangUpAnim()
  local oldAFKLv = HangUpManager:GetOldAFKLevel()
  local afkExp = HangUpManager:GetAFKExp()
  local oldAFKExp = HangUpManager:GetOldAFKExp()
  if oldAFKExp == nil or oldAFKLv == nil then
    self:FreshShowAFKPoint(afkExp or 0)
    return
  end
  local afkLvUpList = self:GetAFKExpUpList()
  if not afkLvUpList then
    return
  end
  for i, afkLvUpItem in ipairs(afkLvUpList) do
    local startAnimExp = afkLvUpItem.startAFKExp
    local endAnimExp = afkLvUpItem.endAFKExp
    local lastLvUpExpPoint = afkLvUpItem.lastLvUpExpPoint
    local afkLv = afkLvUpItem.afkLv
    if i == 1 then
      self:ShowAFKAnimPoint(startAnimExp, endAnimExp)
      self:FreshAFKLv(afkLv)
    else
      if self["AFKLvTimer" .. i] then
        TimeService:KillTimer(self["AFKLvTimer" .. i])
        self["AFKLvTimer" .. i] = nil
      end
      self["AFKLvTimer" .. i] = TimeService:SetTimer(lastLvUpExpPoint * AFKEXPAnimDeltaTime, 1, function()
        self["AFKLvTimer" .. i] = nil
        self:ShowAFKAnimPoint(startAnimExp, endAnimExp)
        self:FreshAFKLv(afkLv)
      end)
    end
  end
end

function Form_BattleVictory:ShowAFKAnimPoint(startAnimExp, endAnimExp)
  if startAnimExp == 0 and endAnimExp == 0 then
    if self["AFKExpUpTimer" .. 0] then
      TimeService:KillTimer(self["AFKExpUpTimer" .. 0])
      self["AFKExpUpTimer" .. 0] = nil
    end
    self["AFKExpUpTimer" .. 0] = TimeService:SetTimer(1 * AFKEXPAnimDeltaTime, 1, function()
      self:FreshShowAFKPoint(0)
    end)
    return
  end
  self:FreshShowAFKPoint(startAnimExp)
  for m = startAnimExp, endAnimExp do
    if 0 < m then
      local waitDelta = m - startAnimExp
      local redNode = self["m_img_battle_light" .. m]
      if redNode and 0 < waitDelta then
        if self["AFKExpUpTimer" .. m] then
          TimeService:KillTimer(self["AFKExpUpTimer" .. m])
          self["AFKExpUpTimer" .. m] = nil
        end
        self["AFKExpUpTimer" .. m] = TimeService:SetTimer(waitDelta * AFKEXPAnimDeltaTime, 1, function()
          UILuaHelper.SetActive(redNode, true)
          UILuaHelper.PlayAnimationByName(redNode, AFKEXPAnim)
        end)
      end
    end
  end
end

function Form_BattleVictory:FreshAFKLv(afkLv)
  if not afkLv then
    return
  end
  self.m_txt_lv_custom_02_Text.text = afkLv
end

function Form_BattleVictory:FreshShowAFKPoint(expNum)
  if not expNum then
    return
  end
  for i = 1, AFK_LEVEL_CNT do
    if self["m_img_battle_light" .. i] then
      self["m_img_battle_light" .. i]:SetActive(i <= expNum)
    end
  end
end

function Form_BattleVictory:FreshRewardItems()
  if not self.m_itemDataList then
    return
  end
  local itemWidgets = self.m_ItemWidgetList
  local dataLen = #self.m_itemDataList
  local parentTrans = self.m_reward_root
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local processItemData = ResourceUtil:GetProcessRewardData(self.m_itemDataList[i])
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_rewardItemBase, parentTrans.transform).gameObject
      local itemWidget = self:createCommonItem(itemObj)
      local processItemData = ResourceUtil:GetProcessRewardData(self.m_itemDataList[i])
      itemWidget:SetItemInfo(processItemData)
      itemWidget:SetItemIconClickCB(function(itemID, itemNum, itemCom)
        self:OnRewardItemClick(itemID, itemNum, itemCom)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function Form_BattleVictory:FreshShowRewardItemAnims()
  if not self.m_itemDataList then
    return
  end
  local dataLen = #self.m_itemDataList
  for i = 1, dataLen do
    local itemWidget = self.m_ItemWidgetList[i]
    if itemWidget then
      local tempObj = itemWidget:GetItemRoot()
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    end
  end
  for i = 1, dataLen do
    local itemWidget = self.m_ItemWidgetList[i]
    if itemWidget then
      local tempObj = itemWidget:GetItemRoot()
      if i == 1 then
        UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
        UILuaHelper.PlayAnimationByName(tempObj, ItemInAnimStr)
      else
        self["ItemInitTimer" .. i] = TimeService:SetTimer(i * DurationTime, 1, function()
          UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
          UILuaHelper.PlayAnimationByName(tempObj, ItemInAnimStr)
        end)
      end
    end
  end
end

function Form_BattleVictory:FreshShowSpine()
  local spineStr, voice = self:GetShowSpineAndVoice()
  if not spineStr then
    return
  end
  if voice and voice ~= "" then
    UILuaHelper.StartPlaySFX(voice)
  end
  log.info("Form_BattleVictory:FreshShowSpine spineStr spineStr spineStr: " .. tostring(spineStr))
  log.info("Form_BattleVictory:FreshShowSpine spineStr voice voice: " .. tostring(voice))
  self:LoadHeroSpine(spineStr, "battlewin", self.m_hero_root)
end

function Form_BattleVictory:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent)
  if not heroSpineAssetName then
    return
  end
  if self.m_HeroSpineDynamicLoader then
    self:CheckRecycleSpine()
    self.m_HeroSpineDynamicLoader:LoadHeroSpine(heroSpineAssetName, showTypeStr, uiParent, function(spineLoadObj)
      self:CheckRecycleSpine()
      self.m_curHeroSpineObj = spineLoadObj
      local spineRootObj = self.m_curHeroSpineObj.spineObj
      UILuaHelper.SpineResetMatParam(spineRootObj)
      UILuaHelper.SetSpineTimeScale(spineRootObj, 1)
    end)
  end
end

function Form_BattleVictory:CheckRecycleSpine(isResetParam)
  if self.m_HeroSpineDynamicLoader and self.m_curHeroSpineObj then
    if isResetParam then
      UILuaHelper.SpineResetMatParam(self.m_curHeroSpineObj.spineObj)
    end
    self.m_HeroSpineDynamicLoader:RecycleHeroSpineObject(self.m_curHeroSpineObj)
    self.m_curHeroSpineObj = nil
  end
end

function Form_BattleVictory:CheckGoNextLevelOrExit()
  if self.m_isQuickFinish == true then
    return
  end
  if self.m_levelType == LevelManager.LevelType.MainLevel then
    local levelCfg = LevelManager:GetLevelCfgByTypeAndLevelID(self.m_levelType, self.m_levelID)
    if not levelCfg then
      return
    end
    if levelCfg.m_LevelWarp == 1 then
      local levelMainHelper = LevelManager:GetLevelMainHelper()
      if not levelMainHelper then
        return
      end
      local nextLevelCfg = levelMainHelper:GetNextShowLevelCfg(LevelManager.MainLevelSubType.MainStory)
      if not nextLevelCfg then
        return
      end
      local nextLevelID = nextLevelCfg.m_LevelID
      BattleFlowManager:EnterNextBattle(self.m_levelType, nextLevelID)
      return
    end
  end
  BattleFlowManager:ExitBattle()
end

function Form_BattleVictory:OnRewardItemClick(itemID, itemNum, itemCom)
  if self.m_isShowAnim then
    return
  end
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_BattleVictory:OnBtnBgCloseClicked()
  if self.m_isShowAnim then
    return
  end
  
  local function RealCloseForm()
    self:CloseForm()
    if self.m_isQuickFinish ~= true then
      self:CheckGoNextLevelOrExit()
    end
  end
  
  local iLevelType = self.m_levelType
  local iLevelID = self.m_levelID
  DownloadManager:ReserveDownloadByMainLevelID(iLevelID)
  local iNewbieMainLevelID = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("NewbieMainLevelID").m_Value)
  if iLevelType == LevelManager.LevelType.MainLevel and iLevelID == iNewbieMainLevelID then
    local vPackage = {
      {
        sName = "Pack_Hall",
        eType = DownloadManager.ResourcePackageType.Custom
      }
    }
    local vResourceABExtra
    
    local function OnDownloadComplete(ret)
      log.info(string.format("Download BattleVictory To Hall Complete: %s", tostring(ret)))
      RealCloseForm()
    end
    
    DownloadManager:DownloadResourceWithUI(vPackage, vResourceABExtra, "Newbie2Hall", nil, nil, OnDownloadComplete)
  else
    RealCloseForm()
  end
end

function Form_BattleVictory:OnBtnDataClicked()
  if self.m_isShowAnim then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

function Form_BattleVictory:OnBtnlevelbgClicked()
  if self.m_levelType ~= LevelManager.LevelType.Tower then
    return
  end
  local levelTowerHelper = LevelManager:GetLevelTowerHelper()
  if not levelTowerHelper then
    return
  end
  if levelTowerHelper:IsLevelSubTypeInOpen(self.m_levelSubType) ~= true then
    return
  end
  local nextLevelCfg = levelTowerHelper:GetNextShowLevelCfg(self.m_levelSubType)
  if not nextLevelCfg then
    return
  end
  local nextLevelID = nextLevelCfg.m_LevelID
  BattleFlowManager:EnterNextBattle(self.m_levelType, nextLevelID)
end

function Form_BattleVictory:OnBtnMaskSkipClicked()
  if not self.m_isShowAnim then
    return
  end
  for i = 0, AFK_LEVEL_CNT do
    if self["AFKExpUpTimer" .. i] then
      TimeService:KillTimer(self["AFKExpUpTimer" .. i])
      self["AFKExpUpTimer" .. i] = nil
    end
  end
  local afkLvUpList = self:GetAFKExpUpList()
  if afkLvUpList and 0 < #afkLvUpList then
    local lenNum = #afkLvUpList
    for i = 1, lenNum do
      if self["AFKLvTimer" .. i] then
        TimeService:KillTimer(self["AFKLvTimer" .. i])
        self["AFKLvTimer" .. i] = nil
      end
    end
  end
  local roleLevelUpList = self:GetRoleLevelExpUpList()
  if roleLevelUpList and 0 < #roleLevelUpList then
    local roleLvNum = #roleLevelUpList
    for i = 1, roleLvNum do
      if self["RoleLvTimer" .. i] then
        TimeService:KillTimer(self["RoleLvTimer" .. i])
        self["RoleLvTimer" .. i] = nil
      end
    end
  end
  if self.m_waitAnimTimer then
    TimeService:KillTimer(self.m_waitAnimTimer)
    self.m_waitAnimTimer = nil
  end
  if self.m_roleExpUpTimer then
    TimeService:KillTimer(self.m_roleExpUpTimer)
    self.m_roleExpUpTimer = nil
  end
  local curRoleLv = RoleManager:GetLevel() or 0
  local roleExp = RoleManager:GetRoleExp() or 0
  self:FreshShowRoleLvAndExp(curRoleLv, roleExp)
  local afkExp = HangUpManager:GetAFKExp()
  self:FreshShowAFKPoint(afkExp)
  local afkLv = HangUpManager:GetAFKLevel()
  self:FreshAFKLv(afkLv)
  self.m_isShowAnim = false
  UILuaHelper.SetActive(self.m_btn_MaskSkip, false)
  PushFaceManager:CheckShowNextPopPanel()
end

function Form_BattleVictory:GetDownloadResourceExtra(tParam)
  local vPackage = {}
  local vResourceExtra = {}
  local heroID = self:GetShowSpineHeroIDByParam(tParam)
  if heroID then
    vPackage[#vPackage + 1] = {
      sName = tostring(heroID),
      eType = DownloadManager.ResourcePackageType.Character
    }
  end
  return vPackage, vResourceExtra
end

function Form_BattleVictory:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_BattleVictory", Form_BattleVictory)
return Form_BattleVictory
