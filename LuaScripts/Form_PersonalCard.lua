local Form_PersonalCard = class("Form_PersonalCard", require("UI/UIFrames/Form_PersonalCardUI"))

function Form_PersonalCard:SetInitParam(param)
end

function Form_PersonalCard:AfterInit()
  self.super.AfterInit(self)
  self.m_leftHeadFrameTrans = self.m_icon_left_head_frame.transform
  self.m_zoneID = nil
  self.m_otherRoleID = nil
  self.m_otherRoleInfo = nil
  self.m_itemTemplate = self.m_hero_item
  UILuaHelper.SetActive(self.m_itemTemplate, false)
  self.m_vItem = {}
  self.m_heroShowDataList = nil
end

function Form_PersonalCard:OnActive()
  self:FreshData()
  self:AddEventListeners()
  self:CheckReqOrFreshMineInfo()
end

function Form_PersonalCard:OnInactive()
  self.super.OnInactive(self)
  self:CheckRecycleHeadFrameNode()
end

function Form_PersonalCard:OnDestroy()
  self.super.OnDestroy(self)
  self:CheckRecycleHeadFrameNode()
end

function Form_PersonalCard:RegisterRedDot()
  if self.m_otherRoleInfo then
    UILuaHelper.SetActive(self.m_role_head_red_dot, false)
  else
    self:RegisterOrUpdateRedDotItem(self.m_role_head_red_dot, RedDotDefine.ModuleType.PersonalCardEntry)
  end
end

function Form_PersonalCard:AddEventListeners()
  self:addEventListener("eGameEvent_Rename_SetName", handler(self, self.SetRoleName))
  self:addEventListener("eGameEvent_RoleBusinessCard", handler(self, self.OnSeeOtherInfo))
  self:addEventListener("eGameEvent_RoleSetCard", handler(self, self.OnRoleSetCard))
end

function Form_PersonalCard:OnSeeOtherInfo(paramTab)
  if not paramTab then
    return
  end
  self.m_otherRoleInfo = paramTab.roleBusinessCard
  self:FreshUI()
end

function Form_PersonalCard:SetRoleName()
  self.m_txt_name_Text.text = tostring(RoleManager:GetName())
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_name)
end

function Form_PersonalCard:OnRoleSetCard(paramTab)
  if not paramTab then
    return
  end
  self:FreshLeftHeadShow()
  self:FreshLeftHeadFrameShow()
end

function Form_PersonalCard:FreshData()
  local tParam = self.m_csui.m_param
  self.m_zoneID = nil
  self.m_otherRoleID = nil
  if tParam then
    self.m_zoneID = tParam.zoneID
    self.m_otherRoleID = tParam.otherRoleID
    self.m_csui.m_param = nil
  end
  self.m_otherRoleInfo = nil
end

function Form_PersonalCard:CheckReqOrFreshMineInfo()
  if self.m_otherRoleID ~= nil and self.m_zoneID ~= nil then
    RoleManager:ReqRoleSeeBusinessCard(self.m_otherRoleID, self.m_zoneID)
  else
    self:FreshUI()
  end
end

function Form_PersonalCard:GetName()
  if self.m_otherRoleInfo then
    return self.m_otherRoleInfo.sName or ""
  else
    return RoleManager:GetName() or ""
  end
end

function Form_PersonalCard:GetUID()
  if self.m_otherRoleInfo then
    return self.m_otherRoleInfo.stRoleId.iUid or ""
  else
    return RoleManager:GetUID() or ""
  end
end

function Form_PersonalCard:GetServerZone()
  if self.m_otherRoleInfo then
    return self.m_otherRoleInfo.stRoleId.iZoneId or ""
  else
    return UserDataManager:GetZoneID() or ""
  end
end

function Form_PersonalCard:GetLevel()
  if self.m_otherRoleInfo then
    return self.m_otherRoleInfo.iLevel or 0
  else
    return RoleManager:GetLevel() or 0
  end
end

function Form_PersonalCard:GetRoleExp()
  if self.m_otherRoleInfo then
    return self.m_otherRoleInfo.iExp or 0
  else
    return RoleManager:GetRoleExp() or 0
  end
end

function Form_PersonalCard:GetMainLevelProgressID()
  if self.m_otherRoleInfo then
    local mainLevelTab = self.m_otherRoleInfo.mmProgress[LevelManager.LevelType.MainLevel] or {}
    local mainLevelID = mainLevelTab[LevelManager.MainLevelSubType.MainStory]
    return mainLevelID
  else
    local manager = LevelManager:GetLevelHelperByType(LevelManager.LevelType.MainLevel)
    local levelId = manager:GetLastPassLevelIDBySubType(LevelManager.MainLevelSubType.MainStory)
    return levelId
  end
end

function Form_PersonalCard:GetMainHardProgressID()
  if self.m_otherRoleInfo then
    local mainLevelTab = self.m_otherRoleInfo.mmProgress[LevelManager.LevelType.MainLevel] or {}
    local mainHardLevelID = mainLevelTab[LevelManager.MainLevelSubType.HardLevel]
    return mainHardLevelID
  else
    local manager = LevelManager:GetLevelHelperByType(LevelManager.LevelType.MainLevel)
    local levelId = manager:GetLastPassLevelIDBySubType(LevelManager.MainLevelSubType.HardLevel)
    return levelId
  end
end

function Form_PersonalCard:GetGuildStr()
  if self.m_otherRoleInfo then
    return self.m_otherRoleInfo.sAllianceName ~= "" and self.m_otherRoleInfo.sAllianceName or ConfigManager:GetCommonTextById(20111) or ""
  else
    return RoleManager:GetAllianceName()
  end
end

function Form_PersonalCard:GetTowerLevelCfg()
  local mainHardLevelID
  if self.m_otherRoleInfo then
    local towerLevelTab = self.m_otherRoleInfo.mmProgress[LevelManager.LevelType.Tower] or {}
    mainHardLevelID = towerLevelTab[LevelManager.TowerLevelSubType.Main]
  else
    local levelTowerHelper = LevelManager:GetLevelHelperByType(LevelManager.LevelType.Tower)
    mainHardLevelID = levelTowerHelper:GetLastPassLevelIDBySubType(LevelManager.TowerLevelSubType.Main)
  end
  if mainHardLevelID == nil or mainHardLevelID == 0 then
    local levelTowerHelper = LevelManager:GetLevelHelperByType(LevelManager.LevelType.Tower)
    local curShowLevelList = levelTowerHelper:GetTowerLevelList(LevelManager.TowerLevelSubType.Main)
    return curShowLevelList[1]
  else
    return LevelManager:GetLevelCfgByTypeAndLevelID(LevelManager.LevelType.Tower, mainHardLevelID)
  end
end

function Form_PersonalCard:GetHeroHaveNum()
  if self.m_otherRoleInfo then
    local heroNum = 0
    for _, num in pairs(self.m_otherRoleInfo.mCampHeroNum) do
      heroNum = heroNum + num
    end
    return heroNum
  else
    local heroList = HeroManager:GetHeroServerList()
    return #heroList
  end
end

function Form_PersonalCard:GetHeroTopFiveDataList()
  if self.m_otherRoleInfo then
    local heroServerDataList = self.m_otherRoleInfo.vTopHero or {}
    local showHeroList = {}
    for _, v in ipairs(heroServerDataList) do
      local tempServerData = {serverData = v}
      showHeroList[#showHeroList + 1] = tempServerData
    end
    return showHeroList
  else
    return HeroManager:GetTopFiveHeroByCombat()
  end
end

function Form_PersonalCard:GetHeroCampHeroListNumAndHaveNum(campType)
  local cfgList = HeroManager:GetHeroCfgListByCamp(campType)
  local allCampNum = cfgList ~= nil and #cfgList or 0
  local curCampNum = 0
  if self.m_otherRoleInfo then
    curCampNum = self.m_otherRoleInfo.mCampHeroNum[campType] or 0
  else
    local dataList = HeroManager:GetHeroServerDataListByCamp(campType)
    curCampNum = dataList ~= nil and #dataList or 0
  end
  return curCampNum, allCampNum
end

function Form_PersonalCard:GetHeadID()
  if self.m_otherRoleInfo then
    local tempHeadID = self.m_otherRoleInfo.iHeadId
    if tempHeadID == nil or tempHeadID == 0 then
      tempHeadID = RoleManager:GetDefaultHeadID()
    end
    return tempHeadID
  else
    return RoleManager:GetHeadID()
  end
end

function Form_PersonalCard:GetHeadFrameID()
  if self.m_otherRoleInfo then
    return RoleManager:GetHeadFrameIDByIDAndExpireTime(self.m_otherRoleInfo.iHeadFrameId, self.m_otherRoleInfo.iHeadFrameExpireTime)
  else
    return RoleManager:GetHeadFrameID()
  end
end

function Form_PersonalCard:FreshUI()
  self:RegisterRedDot()
  self:FreshRoleBaseInfo()
  self:FreshZoneAndUIDInfo()
  self:FreshMainLevelInfoShow()
  self:ShowTowerInfo()
  self:FreshHeroHaveNumShow()
  self:ShowCampProgress()
  self:RefreshTopFiveHero()
  self:FreshEditorShow()
  self:FreshFriendShow()
end

function Form_PersonalCard:FreshRoleBaseInfo()
  self.m_txt_name_Text.text = tostring(self:GetName())
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_pnl_name)
  self.m_txt_level_Text.text = tostring(self:GetLevel())
  local roleExp = self:GetRoleExp() or 0
  local maxExp = RoleManager:GetRoleMaxExpNum(self:GetLevel())
  if maxExp then
    self.m_num_empirical_Text.text = roleExp .. "/" .. maxExp
    self.m_line_progress_Image.fillAmount = math.min(roleExp / maxExp, 1)
  else
    self.m_num_empirical_Text.text = "-/-"
    self.m_line_progress_Image.fillAmount = 1
  end
  self.m_txt_guild_tips_Text.text = self:GetGuildStr()
  self:FreshLeftHeadShow()
  self:FreshLeftHeadFrameShow()
end

function Form_PersonalCard:FreshLeftHeadShow()
  local headID = self:GetHeadID()
  local roleHeadCfg = RoleManager:GetPlayerHeadCfg(headID)
  if not roleHeadCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_head_Image, roleHeadCfg.m_HeadPic)
end

function Form_PersonalCard:CheckRecycleHeadFrameNode()
  if self.m_headFrameEftStr and self.m_headFrameEftObj then
    utils.RecycleInParentUIPrefab(self.m_headFrameEftStr, self.m_headFrameEftObj)
  end
  self.m_headFrameEftStr = nil
  self.m_headFrameEftObj = nil
end

function Form_PersonalCard:FreshLeftHeadFrameShow()
  local headFrameID = self:GetHeadFrameID()
  local roleHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not roleHeadFrameCfg then
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_icon_left_head_frame_Image, roleHeadFrameCfg.m_HeadFramePic, function()
    if not UILuaHelper.IsNull(self.m_icon_left_head_frame) then
      UILuaHelper.SetNativeSize(self.m_icon_left_head_frame)
    end
  end)
  if roleHeadFrameCfg.m_HeadFrameEft and roleHeadFrameCfg.m_HeadFrameEft ~= "" then
    utils.TryLoadUIPrefabInParent(self.m_leftHeadFrameTrans, roleHeadFrameCfg.m_HeadFrameEft, function(nameStr, gameObject)
      self.m_headFrameEftStr = nameStr
      self.m_headFrameEftObj = gameObject
      self:FreshShowLeftHeadFrameChild()
    end)
  else
    UILuaHelper.SetActiveChildren(self.m_leftHeadFrameTrans, false)
  end
end

function Form_PersonalCard:FreshShowLeftHeadFrameChild()
  local headFrameID = self:GetHeadFrameID()
  local playerHeadFrameCfg = RoleManager:GetPlayerHeadFrameCfg(headFrameID)
  if not playerHeadFrameCfg then
    return
  end
  UILuaHelper.SetActiveChildren(self.m_leftHeadFrameTrans, false)
  if playerHeadFrameCfg.m_HeadFrameEft then
    local subNode = self.m_leftHeadFrameTrans:Find(playerHeadFrameCfg.m_HeadFrameEft)
    if subNode then
      UILuaHelper.SetActive(subNode, true)
    end
  end
end

function Form_PersonalCard:FreshZoneAndUIDInfo()
  self.m_num_Text.text = tostring(self:GetUID())
  self.m_servenum_Text.text = tostring(self:GetServerZone())
end

function Form_PersonalCard:FreshMainLevelInfoShow()
  local levelId = self:GetMainLevelProgressID()
  if levelId then
    local levelCfg = LevelManager:GetMainLevelCfgById(levelId)
    if levelCfg then
      self.m_normal_stage_num_Text.text = levelCfg.m_ChapterIndex .. "-" .. levelCfg.m_LevelIndex
    else
      self.m_hard_stage_num_Text.text = ConfigManager:GetCommonTextById(20028)
      log.error("can not GetMainLevelCfgById MainStory id === " .. tostring(levelId))
    end
  else
    self.m_normal_stage_num_Text.text = ConfigManager:GetCommonTextById(20028)
  end
  local levelId2 = self:GetMainHardProgressID()
  if levelId2 then
    local levelCfg2 = LevelManager:GetMainLevelCfgById(levelId2)
    if levelCfg2 then
      self.m_hard_stage_num_Text.text = levelCfg2.m_ChapterIndex .. "-" .. levelCfg2.m_LevelIndex
    else
      self.m_hard_stage_num_Text.text = ConfigManager:GetCommonTextById(20028)
      log.error("can not GetMainLevelCfgById HardLevel id === " .. tostring(levelId2))
    end
  else
    self.m_hard_stage_num_Text.text = ConfigManager:GetCommonTextById(20028)
  end
end

function Form_PersonalCard:RefreshTopFiveHero()
  local heroItemParentTrans = self.m_hero_list.transform
  local topFive = self:GetHeroTopFiveDataList()
  for j = 1, #topFive do
    local serverData = topFive[j].serverData
    local panelItem = self.m_vItem[j]
    if panelItem == nil then
      panelItem = {}
      panelItem.go = GameObject.Instantiate(self.m_itemTemplate, heroItemParentTrans)
      panelItem.widgetItemIcon = self:createHeroIcon(panelItem.go)
      self.m_vItem[j] = panelItem
    end
    UILuaHelper.SetActive(panelItem.go, true)
    panelItem.widgetItemIcon:SetHeroData(serverData, nil, nil, true)
    panelItem.widgetItemIcon:SetHeroIconClickCB(function()
      self:OnHeroIconClk(j)
    end)
  end
  self.m_heroShowDataList = topFive
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_hero_list)
  for i = #topFive + 1, #self.m_vItem do
    UILuaHelper.SetActive(self.m_vItem[i].go, false)
  end
  local combat = 0
  for i, v in ipairs(topFive) do
    if v.serverData and v.serverData.iPower then
      combat = combat + v.serverData.iPower
    end
  end
  self.m_txt_power_num_Text.text = combat
end

function Form_PersonalCard:ShowCampProgress()
  for i = 1, 4 do
    local curCampNum, allCampNum = self:GetHeroCampHeroListNumAndHaveNum(i)
    self["m_progress_camp" .. i .. "_Image"].fillAmount = curCampNum / allCampNum
  end
end

function Form_PersonalCard:ShowTowerInfo()
  local levelCfg = self:GetTowerLevelCfg()
  if levelCfg then
    self.m_tower_num_Text.text = levelCfg.m_LevelName
  else
    self.m_tower_num_Text.text = "--"
  end
end

function Form_PersonalCard:FreshHeroHaveNumShow()
  local haveNum = self:GetHeroHaveNum()
  self.m_txt_depend_num_Text.text = tostring(haveNum)
end

function Form_PersonalCard:FreshEditorShow()
  local isCanEditor = self.m_otherRoleInfo == nil
  UILuaHelper.SetActive(self.m_btn_cardcreat, isCanEditor)
  UILuaHelper.SetActive(self.m_btn_icon_rename, isCanEditor)
end

function Form_PersonalCard:FreshFriendShow()
  local isOtherRole = self.m_otherRoleInfo ~= nil
  local isShowAddFriend = false
  if isOtherRole then
    local stRoleId = self.m_otherRoleInfo.stRoleId
    local isBlack = FriendManager:PlayerIsShield(stRoleId)
    isShowAddFriend = isOtherRole and not isBlack
  end
  UILuaHelper.SetActive(self.m_pnl_other, isShowAddFriend)
  if isShowAddFriend then
    local stRoleId = self.m_otherRoleInfo.stRoleId
    local isFriend = FriendManager:PlayerIsFriend(stRoleId)
    local isAdded = FriendManager:IsFriendInAddedList(stRoleId)
    UILuaHelper.SetActive(self.m_btn_WaitPass, not isFriend and isAdded)
    UILuaHelper.SetActive(self.m_btn_CanAdd, not isFriend and not isAdded)
    UILuaHelper.SetActive(self.m_btn_HaveFriend, isFriend)
  end
end

function Form_PersonalCard:OnHeroIconClk(heroIndex)
  if self.m_otherRoleInfo then
    return
  end
  if not heroIndex then
    return
  end
  local heroData = self.m_heroShowDataList[heroIndex]
  if not heroData then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
    heroID = heroData.serverData.iHeroId,
    heroServerData = heroData.serverData
  })
end

function Form_PersonalCard:OnBtncloseClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CloseForm()
end

function Form_PersonalCard:OnBtniconrenameClicked()
  StackPopup:Push(UIDefines.ID_FORM_PERSONALRENAME)
end

function Form_PersonalCard:OnBtniconcopybgClicked()
  UILuaHelper.CopyTextToClipboard(tostring(self:GetUID()))
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20025)
end

function Form_PersonalCard:OnBtnCanAddClicked()
  if not self.m_otherRoleInfo then
    return
  end
  FriendManager:RqsAddFriend(self.m_otherRoleInfo.stRoleId, function()
    self:FreshFriendShow()
  end)
end

function Form_PersonalCard:OnBtnWaitPassClicked()
  if not self.m_otherRoleInfo then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10322))
end

function Form_PersonalCard:OnBtnHaveFriendClicked()
  if not self.m_otherRoleInfo then
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(10321))
end

function Form_PersonalCard:OnBtncardcreatClicked()
  StackPopup:Push(UIDefines.ID_FORM_PERSONALCHANGE)
end

function Form_PersonalCard:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PersonalCard", Form_PersonalCard)
return Form_PersonalCard
