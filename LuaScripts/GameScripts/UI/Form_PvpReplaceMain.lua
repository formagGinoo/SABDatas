local Form_PvpReplaceMain = class("Form_PvpReplaceMain", require("UI/UIFrames/Form_PvpReplaceMainUI"))
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local ReplaceArenaToken = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaToken"))
local ReplaceArenaShopJumpID = ConfigManager:GetGlobalSettingsByKey("ReplaceArenaShopJumpID")
local ReplaceArenaPtRanklist = ConfigManager:GetGlobalSettingsByKey("ReplaceArenaPtRanklist")
local pairs = _ENV.pairs
local ReplaceArenaAutoRefreshCD = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAutoRefreshCD"))
local UpdateDeltaNum = 3
local UpdateRewardDeltaNum = 60
local DefaultTeamIndex = 1
local EnemyInAnimStr = "m_base_enemy_in"
local DurationTime = 0.15
local BattleTeamNum = PvpReplaceManager.BattleTeamNum

function Form_PvpReplaceMain:SetInitParam(param)
end

function Form_PvpReplaceMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1127)
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_playerHeadCom = self:createPlayerHead(self.m_mine_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
  self.m_waitEnemyIndex = nil
  self.m_curTeamIndex = nil
  self.m_mineFormDataDic = {
    [PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Defence_1] = {},
    [PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Defence_2] = {},
    [PvpReplaceManager.LevelSubType.ReplaceArenaSubType_Defence_3] = {}
  }
  self.m_heroFormDataList = {}
  self.m_formPower = nil
  self.m_heroWidgetList = {}
  self:CreateFormHeroWidgetList()
  self.m_formPageIndex = nil
  self.m_reqEnemyIndex = nil
  self.m_enemyDataList = {}
  self.m_enemy_item_list = {
    [1] = self:InitEnemyItem(self.m_base_enemy, 1)
  }
  self.m_isCanUpdateCDTime = false
  self.m_curDeltaTimeNum = 0
  self.m_reqRankCache = {
    [RankManager.RankType.ReplacePVPGrade] = false,
    [RankManager.RankType.ReplacePVPScore] = false
  }
  self.m_isEnterReqFreshEnemy = false
  self.m_isCanUpdateReward = false
  self.m_curDeltaRewardTime = 0
  self.m_formReqCache = {}
  self:RegisterRedDot()
  self.m_isShowPopPanel = nil
  self.m_isEnemyRankChangeWait = nil
  self.m_isShowWaitEnemy = false
end

function Form_PvpReplaceMain:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_isReqSeeAfk = nil
  self:FreshData()
  self.m_isShowPopPanel = nil
  self.m_isEnemyRankChangeWait = nil
  self.m_waitEnemyIndex = nil
  self.m_barPosX = tonumber(self.m_bar.transform:GetComponent("RectTransform").anchoredPosition.x)
  self.m_barPosY = tonumber(self.m_bar.transform:GetComponent("RectTransform").anchoredPosition.y)
  self.m_barWidth = tonumber(self.m_bar.transform:GetComponent("RectTransform").rect.width)
  BattleFlowManager:CheckSetEnterTimer(BattleFlowManager.ArenaType.Arena)
  self.m_isCanUpdateCDTime = false
  self:CheckInSeasonEndFresh()
  GlobalManagerIns:TriggerWwiseBGMState(13)
  self:EnterReqFreshEnemy()
end

function Form_PvpReplaceMain:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpReplaceMain:OnUpdate(dt)
  self:CheckUpdateCDTime()
  self:CheckUpdateReward()
end

function Form_PvpReplaceMain:OnDestroy()
  self.super.OnDestroy(self)
  if self.m_enemy_item_list then
    for i = 1, #self.m_enemy_item_list do
      if self["ItemInitTimer" .. i] then
        TimeService:KillTimer(self["ItemInitTimer" .. i])
        self["ItemInitTimer" .. i] = nil
      end
    end
  end
end

function Form_PvpReplaceMain:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_csui.m_param = nil
  end
end

function Form_PvpReplaceMain:ClearCacheData()
end

function Form_PvpReplaceMain:FreshFormData()
  if not self.m_mineFormDataDic then
    return
  end
  self.m_heroFormDataListDic = {}
  for levelSubType, tempFormData in pairs(self.m_mineFormDataDic) do
    local heroList = tempFormData.vHero
    local tempHeroList = {}
    for _, v in ipairs(heroList) do
      local heroID = v.iHeroId
      local heroData = HeroManager:GetHeroDataByID(heroID)
      if heroData then
        tempHeroList[#tempHeroList + 1] = heroData
      end
    end
    self.m_heroFormDataListDic[levelSubType] = tempHeroList
  end
end

function Form_PvpReplaceMain:IsTicketFree()
  local ticketFreeCount = PvpReplaceManager:GetSeasonTicketFreeCount() or 0
  local totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaDailyFreeTime") or 2)
  local leftTimes = totalFreeNum - ticketFreeCount
  local isFree = 0 < leftTimes
  return isFree
end

function Form_PvpReplaceMain:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_GetForm", handler(self, self.OnHeroGetForm))
  self:addEventListener("eGameEvent_Level_ArenaReplaceRefreshEnemy", handler(self, self.OnArenaFreshEnemy))
  self:addEventListener("eGameEvent_Level_ArenaReplaceGetArenaReport", handler(self, self.OnArenaReportBack))
  self:addEventListener("eGameEvent_UpDataRankList", handler(self, self.OnUpDataArenaRankBack))
  self:addEventListener("eGameEvent_Level_ArenaReplaceBuyTicket", handler(self, self.OnArenaBuyTicketBack))
  self:addEventListener("eGameEvent_Level_ArenaReplaceGetEnemyDetail", handler(self, self.OnArenaGetEnemyDetail))
  self:addEventListener("eGameEvent_ReplaceArena_SeasonInit", handler(self, self.OnArenaSeasonInit))
  self:addEventListener("eGameEvent_ReplaceArena_RankChange", handler(self, self.OnEventReplaceRankChange))
  self:addEventListener("eGameEvent_Level_ArenaReplaceSeeAfk", handler(self, self.OnArenaReplaceSeeAfk))
  self:addEventListener("eGameEvent_Level_ArenaReplaceAFKFresh", handler(self, self.OnEventReplaceAFKFresh))
end

function Form_PvpReplaceMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceMain:OnHeroGetForm(param)
  if not param then
    return
  end
  local levelSubType = param.levelSubType
  if self.m_formReqCache[levelSubType] == true then
    self.m_formReqCache[levelSubType] = false
    self.m_mineFormDataDic[levelSubType] = param.stForm
  end
  local isAllBack = true
  for _, isReq in pairs(self.m_formReqCache) do
    if isReq == true then
      isAllBack = false
    end
  end
  if isAllBack == true then
    self:FreshFormData()
    self:FreshTotalPower()
    self:ChangeFreshFormTeam(DefaultTeamIndex)
  end
end

function Form_PvpReplaceMain:OnArenaFreshEnemy()
  if self.m_isEnterReqFreshEnemy then
    self:CheckShowFreshCD()
    self:FreshEnemy()
  else
    self:CheckShowFreshCD()
    self:FreshEnemy()
    self:ShowEnemyItemListAnim()
  end
  self.m_isEnterReqFreshEnemy = false
end

function Form_PvpReplaceMain:OnArenaReportBack(stData)
  StackPopup:Push(UIDefines.ID_FORM_PVPREPLACERECORDLIST, {
    battleRecordList = stData,
    backFun = function()
      self:OnTopPanelBack()
    end
  })
  self.m_isShowPopPanel = true
end

function Form_PvpReplaceMain:OnUpDataArenaRankBack(rankType)
  self.m_reqRankCache[rankType] = true
  local isAllBack = true
  for _, v in pairs(self.m_reqRankCache) do
    if v == false then
      isAllBack = false
    end
  end
  if isAllBack == true then
    StackPopup:Push(UIDefines.ID_FORM_PVPREPLACERANKLIST, {
      backFun = function()
        self:OnTopPanelBack()
      end
    })
    self.m_isShowPopPanel = true
  end
end

function Form_PvpReplaceMain:OnArenaBuyTicketBack()
  if self.m_waitEnemyIndex then
    self:OnEnemyItemClk(self.m_waitEnemyIndex)
    self.m_waitEnemyIndex = nil
  end
  self:FreshPVPMoney()
end

function Form_PvpReplaceMain:OnArenaGetEnemyDetail(param)
  if not param then
    return
  end
  if self.m_reqEnemyIndex then
    BattleFlowManager:SavePvpReplaceDetailData(self.m_reqEnemyIndex, param)
    local enemyTempData = self.m_enemyDataList[self.m_reqEnemyIndex]
    StackPopup:Push(UIDefines.ID_FORM_PVPREPLACEDETAILS, {
      enemyIndex = self.m_reqEnemyIndex,
      enemyData = enemyTempData,
      param = param,
      backFun = function()
        self:OnTopPanelBack()
      end
    })
    self.m_isShowPopPanel = true
    self.m_reqEnemyIndex = nil
  end
end

function Form_PvpReplaceMain:OnArenaSeasonInit()
  self:CheckInSeasonEndFresh()
end

function Form_PvpReplaceMain:OnEventReplaceRankChange()
  self:FreshRankInfo()
  self:FreshMineInfo()
  if self.m_isShowPopPanel then
    self.m_isEnemyRankChangeWait = true
  else
    PvpReplaceManager:ReqReplaceArenaRefreshEnemy()
  end
end

function Form_PvpReplaceMain:OnArenaReplaceSeeAfk(replaceArenaAfkInfo)
  if not self.m_isReqSeeAfk then
    return
  end
  if not replaceArenaAfkInfo then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_PVPREPLACEINFORPOP, {
    backFun = function()
      self:OnTopPanelBack()
    end
  })
  self.m_isReqSeeAfk = false
  self.m_isShowPopPanel = true
end

function Form_PvpReplaceMain:OnEventReplaceAFKFresh()
  self:FreshRewardStatus()
end

function Form_PvpReplaceMain:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_PVP_replace_reward_red_dot, RedDotDefine.ModuleType.PvpReplaceHangUpReward)
end

function Form_PvpReplaceMain:CreateFormHeroWidgetList()
  for i = 1, FormPlotMaxNum do
    local tempHeroRoot = self.m_form_root.transform:Find("c_common_hero_small" .. i)
    local heroWid
    if tempHeroRoot then
      heroWid = self:createHeroIcon(tempHeroRoot)
      self.m_heroWidgetList[#self.m_heroWidgetList + 1] = heroWid
    end
  end
end

function Form_PvpReplaceMain:CheckInSeasonEndFresh()
  local curSeasonEndTime, nextSeasonStartTime = PvpReplaceManager:GetSeasonTimeByCfg()
  local curServerTime = TimeUtil:GetServerTimeS()
  if curSeasonEndTime <= curServerTime and nextSeasonStartTime > curServerTime then
    utils.CheckAndPushCommonTips({
      tipsID = 1225,
      bLockBack = true,
      func1 = function()
        self:CloseForm()
        StackPopup:PopAll()
      end
    })
  else
    self:FreshUI()
  end
end

function Form_PvpReplaceMain:EnterReqFreshEnemy()
  local curSeasonEndTime, nextSeasonStartTime = PvpReplaceManager:GetSeasonTimeByCfg()
  local curServerTime = TimeUtil:GetServerTimeS()
  if curSeasonEndTime <= curServerTime and nextSeasonStartTime > curServerTime then
    return
  end
  self.m_isEnterReqFreshEnemy = true
  PvpReplaceManager:ReqReplaceArenaRefreshEnemy()
end

function Form_PvpReplaceMain:FreshUI()
  self:FreshMineInfo()
  self:FreshEnemy()
  self:CheckShowFreshCD()
  self:CheckReqOrFreshForm()
  self:ShowEnemyItemListAnim()
  self:FreshRewardStatus()
  self:FreshRankInfo()
end

function Form_PvpReplaceMain:FreshRankInfo()
  local rankNum = PvpReplaceManager:GetSeasonRank() or 0
  local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum, PvpReplaceManager:GetSeasonArenPlay() or 0)
  if not rankCfg then
    return
  end
  self.m_txt_enemyrankname_mine_Text.text = rankCfg.m_mName
  UILuaHelper.SetAtlasSprite(self.m_img_rank_big_Image, rankCfg.m_RankIcon)
end

function Form_PvpReplaceMain:FreshRewardStatus()
  local afkData = PvpReplaceManager:GetReplaceArenaAfkInfo()
  if not afkData then
    UILuaHelper.SetActive(self.m_get_100, false)
    return
  end
  local isRankHaveReward = PvpReplaceManager:IsAfkRankCanReward()
  if isRankHaveReward then
    UILuaHelper.SetActive(self.m_node_bar, true)
    local limitTimeSecNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaAFKLimit"))
    local lastTakeTime = afkData.iTakeRewardTime
    local fullTime = lastTakeTime + limitTimeSecNum
    local curServerTime = TimeUtil:GetServerTimeS()
    local isFull = fullTime <= curServerTime
    if not isFull then
      if self.m_canShowAnim then
        self.m_canShowAnim = false
        UILuaHelper.StopAnimation(self.m_img_icon)
        UILuaHelper.ResetAnimationByName(self.m_img_icon, "box_loop2", -1)
      end
      local percentNum = (curServerTime - lastTakeTime) / limitTimeSecNum
      if percentNum < 0 then
        percentNum = 0
      end
      self.percentNum = percentNum
      self.m_txt_reward_Text.text = math.floor(percentNum * 100) .. "%"
      self.m_bar_Image.fillAmount = percentNum
      UILuaHelper.SetActive(self.m_get_100, false)
      UILuaHelper.SetActive(self.m_glow_30, 0.3 < percentNum)
      UILuaHelper.SetActive(self.m_glow_50, 0.5 < percentNum)
      self.m_isCanUpdateReward = not isFull
    else
      self.m_txt_reward_Text.text = "100%"
      self.percentNum = 1
      self.m_bar_Image.fillAmount = 1
      if not self.m_canShowAnim then
        self.m_canShowAnim = true
        self.m_img_icon.transform:GetComponent("Animation").enabled = true
        UILuaHelper.PlayAnimationByName(self.m_img_icon, "box_loop2")
        UILuaHelper.SetActive(self.m_get_100, true)
        UILuaHelper.SetActive(self.m_glow_30, true)
        UILuaHelper.SetActive(self.m_glow_50, true)
      end
    end
    if self.m_barWidth and self.m_barPosX and self.m_bar_glow and self.m_barPosY and self.percentNum then
      local x = self.percentNum * self.m_barWidth + self.m_barPosX
      self.m_bar_glow:SetActive(true)
      UILuaHelper.SetAnchoredPosition(self.m_bar_glow, x, self.m_barPosY, 0)
    else
      self.m_bar_glow:SetActive(false)
    end
  else
    UILuaHelper.SetActive(self.m_get_100, false)
    UILuaHelper.SetActive(self.m_node_bar, true)
    if self.m_barWidth and self.m_barPosX and self.m_bar_glow and self.m_barPosY then
      local x = self.m_barPosX
      self.m_bar_glow:SetActive(true)
      UILuaHelper.SetAnchoredPosition(self.m_bar_glow, x, self.m_barPosY, 0)
    else
      self.m_bar_glow:SetActive(false)
    end
    self.m_txt_reward_Text.text = "0%"
    self.m_bar_Image.fillAmount = 0
    self.m_isCanUpdateReward = false
  end
end

function Form_PvpReplaceMain:CheckUpdateReward()
  if not self.m_isCanUpdateReward then
    return
  end
  if self.m_curDeltaRewardTime <= UpdateRewardDeltaNum then
    self.m_curDeltaRewardTime = self.m_curDeltaRewardTime + 1
  else
    self.m_curDeltaRewardTime = 0
    self:FreshRewardStatus()
  end
end

function Form_PvpReplaceMain:FreshMineInfo()
  self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
  local roleName = RoleManager:GetName()
  self.m_txt_name_Text.text = roleName
  self.m_txt_guild_name_Text.text = RoleManager:GetAllianceName() or ""
  local rank = PvpReplaceManager:GetSeasonRank()
  self.m_txt_rank_num_Text.text = rank
  self:FreshPVPMoney()
  self:FreshFreeNum()
end

function Form_PvpReplaceMain:FreshPVPMoney()
  local itemNum = ItemManager:GetItemNum(ReplaceArenaToken) or 0
  local iconPath = ItemManager:GetItemIconPathByID(ReplaceArenaToken)
  if iconPath then
    UILuaHelper.SetAtlasSprite(self.m_icon_pvpmoney_Image, iconPath)
  end
  self.m_txt_pvpmoney_Text.text = BigNumFormat(itemNum)
end

function Form_PvpReplaceMain:FreshFreeNum()
  local userFreeNum = PvpReplaceManager:GetSeasonTicketFreeCount() or 0
  local totalFreeNum = tonumber(ConfigManager:GetGlobalSettingsByKey("ReplaceArenaDailyFreeTime") or 2)
  local leftTimes = totalFreeNum - userFreeNum
  self.m_txt_left_num_Text.text = leftTimes .. "/" .. totalFreeNum
end

function Form_PvpReplaceMain:CheckShowFreshCD()
  local lastFreshTime = PvpReplaceManager:GetSeasonLastEnemyFreshTime()
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTime = curServerTime - lastFreshTime
  if deltaTime < ReplaceArenaAutoRefreshCD then
    self.m_isCanUpdateCDTime = true
  else
    self.m_isCanUpdateCDTime = false
  end
  UILuaHelper.SetActive(self.m_txt_refresh_cd, self.m_isCanUpdateCDTime)
  UILuaHelper.SetActive(self.m_z_txt_refresh, not self.m_isCanUpdateCDTime)
end

function Form_PvpReplaceMain:FreshEnemy()
  local arenaEnemyDic = PvpReplaceManager:GetEnemyDic()
  self.m_enemyDataList = {}
  for enemyIndex, v in pairs(arenaEnemyDic) do
    self.m_enemyDataList[#self.m_enemyDataList + 1] = {enemyData = v, enemyIndex = enemyIndex}
  end
  while #self.m_enemyDataList < 3 do
    local data = {isEmpty = true}
    self.m_isShowWaitEnemy = true
    self.m_enemyDataList[#self.m_enemyDataList + 1] = {
      enemyData = data,
      enemyIndex = #self.m_enemyDataList + 1
    }
  end
  UILuaHelper.SetActive(self.m_pnl_lefttimes, self.m_isShowWaitEnemy)
  local itemList = self.m_enemy_item_list
  local dataLen = #self.m_enemyDataList
  local parentTrans = self.m_enemy_root
  local childCount = #itemList
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local item = itemList[i]
      local itemData = self.m_enemyDataList[i]
      self:FreshEnemyItemData(item, itemData)
      UILuaHelper.SetActive(item.root, true)
    elseif i > childCount and i <= dataLen then
      local itemObj = GameObject.Instantiate(self.m_base_enemy, parentTrans.transform).gameObject
      local item = self:InitEnemyItem(itemObj, i)
      local itemData = self.m_enemyDataList[i]
      self:FreshEnemyItemData(item, itemData)
      itemList[#itemList + 1] = item
      UILuaHelper.SetActive(item.root, true)
    elseif i <= childCount and i > dataLen then
      local item = itemList[i]
      item.itemData = nil
      UILuaHelper.SetActive(item.root, false)
    end
  end
end

function Form_PvpReplaceMain:InitEnemyItem(itemObj, index)
  if not itemObj then
    return
  end
  local itemTrans = itemObj.transform
  local txt_power = itemTrans:Find("m_txt_rival_power"):GetComponent(T_TextMeshProUGUI)
  local node_img_free = itemTrans:Find("m_img_free")
  local node_PvP_money = itemTrans:Find("m_rival_pvpmoney")
  local img_PvP_money_icon = itemTrans:Find("m_rival_pvpmoney/m_icon_rival_pvpmoney"):GetComponent(T_Image)
  local txt_name = itemTrans:Find("m_txt_rival_name"):GetComponent(T_Text)
  local txt_guild_name = itemTrans:Find("m_txt_rival_guild_name"):GetComponent(T_Text)
  local rankImg = itemTrans:Find("bg_rank/m_img_rank"):GetComponent(T_Image)
  local txt_rankName = itemTrans:Find("m_pnl_enemyrankname/m_txt_enemyrankname"):GetComponent(T_TextMeshProUGUI)
  local playerHeadObj = itemTrans:Find("c_circle_head").gameObject
  local playerHeadCom = self:createPlayerHead(playerHeadObj)
  local emptyState = itemTrans:Find("m_pnl_empty").gameObject
  playerHeadCom:SetStopClkStatus(true)
  local txt_rank = itemTrans:Find("m_txt_noun_num"):GetComponent(T_TextMeshProUGUI)
  local itemButton = itemTrans:GetComponent(T_Button)
  UILuaHelper.BindButtonClickManual(self, itemButton, function()
    CS.GlobalManager.Instance:TriggerWwiseBGMState(35)
    self:OnEnemyItemClk(index)
  end)
  local item = {
    itemData = nil,
    root = itemTrans,
    txt_power = txt_power,
    node_img_free = node_img_free,
    itemButton = itemButton,
    node_PvP_money = node_PvP_money,
    img_PvP_money_icon = img_PvP_money_icon,
    txt_name = txt_name,
    txt_guild_name = txt_guild_name,
    txt_rank = txt_rank,
    rankImg = rankImg,
    txt_rankName = txt_rankName,
    playerHeadCom = playerHeadCom,
    emptyState = emptyState
  }
  return item
end

function Form_PvpReplaceMain:FreshEnemyItemData(item, itemData)
  if not item then
    return
  end
  if not itemData then
    return
  end
  item.itemData = itemData
  local enemyData = itemData.enemyData
  if enemyData.isEmpty then
    UILuaHelper.SetActive(item.emptyState, true)
  else
    UILuaHelper.SetActive(item.emptyState, false)
    item.txt_power.text = enemyData.stRoleSimple.mSimpleData[MTTDProto.CmdSimpleDataType_ReplaceArenaDefence] or 0
    local isFree = self:IsTicketFree()
    UILuaHelper.SetActive(item.node_img_free, isFree)
    UILuaHelper.SetActive(item.node_PvP_money, not isFree)
    if not isFree then
      local itemID = ReplaceArenaToken
      local iconPath = ItemManager:GetItemIconPathByID(itemID)
      if iconPath then
        UILuaHelper.SetAtlasSprite(item.img_PvP_money_icon, iconPath)
      end
    end
    item.playerHeadCom:SetPlayerHeadInfo(enemyData.stRoleSimple)
    item.txt_name.text = enemyData.stRoleSimple.sName or ""
    item.txt_rank.text = enemyData.iRank
    local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(enemyData.iRank, enemyData.stRoleSimple.iReplaceArenaPlaySeason or 0)
    if rankCfg then
      UILuaHelper.SetAtlasSprite(item.rankImg, rankCfg.m_RankIcon)
      item.txt_rankName.text = rankCfg.m_mName
    end
    item.txt_guild_name.text = enemyData.stRoleSimple.sAlliance ~= "" and enemyData.stRoleSimple.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
  end
end

function Form_PvpReplaceMain:CheckReqOrFreshForm()
  local isAllHave = true
  for i = 1, BattleTeamNum do
    local levelSubType = PvpReplaceManager.LevelSubType["ReplaceArenaSubType_Defence_" .. i]
    local tempFormData = HeroManager:GetFormDataByLevelTypeAndSubType(PvpReplaceManager.LevelType.ReplacePVP, levelSubType)
    if tempFormData then
      self.m_mineFormDataDic[levelSubType] = tempFormData
    else
      self.m_formReqCache[levelSubType] = true
      HeroManager:ReqGetForm(PvpReplaceManager.LevelType.ReplacePVP, levelSubType)
      isAllHave = false
    end
  end
  if isAllHave == true then
    self:FreshFormData()
    self:FreshTotalPower()
    self:ChangeFreshFormTeam(DefaultTeamIndex)
  end
end

function Form_PvpReplaceMain:FreshTotalPower()
  local totalPowerNum = 0
  for _, tempFormData in pairs(self.m_mineFormDataDic) do
    totalPowerNum = totalPowerNum + tempFormData.iPower or 0
  end
  self.m_txt_achievement_Text.text = totalPowerNum
end

function Form_PvpReplaceMain:ChangeFreshFormTeam(teamIndex)
  if not teamIndex then
    return
  end
  if teamIndex > BattleTeamNum then
    return
  end
  local lastTeamIndex = self.m_curTeamIndex
  if lastTeamIndex then
    UILuaHelper.SetActive(self["m_img_red_line" .. lastTeamIndex], false)
    UILuaHelper.SetActive(self["m_txt_day_unselect" .. lastTeamIndex], true)
  end
  self.m_curTeamIndex = teamIndex
  UILuaHelper.SetActive(self["m_img_red_line" .. teamIndex], true)
  UILuaHelper.SetActive(self["m_txt_day_unselect" .. teamIndex], false)
  self:FreshShowForm()
end

function Form_PvpReplaceMain:FreshShowForm()
  if not self.m_mineFormDataDic then
    return
  end
  if not self.m_curTeamIndex then
    return
  end
  local defenceType = PvpReplaceManager.LevelSubType["ReplaceArenaSubType_Defence_" .. self.m_curTeamIndex]
  if not defenceType then
    return
  end
  local curShowFormData = self.m_mineFormDataDic[defenceType] or {}
  self.m_txt_power_Text.text = curShowFormData.iPower or 0
  self:FreshShowFormList()
end

function Form_PvpReplaceMain:FreshShowFormList()
  if not self.m_heroWidgetList then
    return
  end
  if not next(self.m_heroWidgetList) then
    return
  end
  if not self.m_curTeamIndex then
    return
  end
  local defenceType = PvpReplaceManager.LevelSubType["ReplaceArenaSubType_Defence_" .. self.m_curTeamIndex]
  if not defenceType then
    return
  end
  local formHeroDataList = self.m_heroFormDataListDic[defenceType] or {}
  for i = 1, FormPlotMaxNum do
    local formHeroData = formHeroDataList[i]
    local heroIcon = self.m_heroWidgetList[i]
    if heroIcon then
      if formHeroData then
        heroIcon:SetActive(true)
        heroIcon:SetHeroData(formHeroData.serverData)
      else
        heroIcon:SetActive(false)
      end
    end
  end
end

function Form_PvpReplaceMain:CheckBuyTicket(waitEnemyIndex)
  local tokenCostCfg = ConfigManager:GetGlobalSettingsByKey("ReplaceArenaTokenCost")
  local itemDataTab = string.split(tokenCostCfg, "/")
  local needCostItemID = tonumber(itemDataTab[1])
  local needCostNum = tonumber(itemDataTab[2])
  local curHaveNum = ItemManager:GetItemNum(needCostItemID, true)
  if needCostNum > curHaveNum then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40016)
    return
  end
  utils.ShowCommonTipCost({
    beforeItemID = needCostItemID,
    beforeItemNum = needCostNum,
    afterItemID = ReplaceArenaToken,
    commonTextID = 100065,
    formatFun = function(formatStr)
      if not formatStr then
        return
      end
      local beforeItemName = ItemManager:GetItemName(needCostItemID)
      return string.CS_Format(formatStr, beforeItemName, needCostNum)
    end,
    afterItemNum = 1,
    funSure = function()
      if waitEnemyIndex then
        self.m_waitEnemyIndex = waitEnemyIndex
      end
      PvpReplaceManager:ReqReplaceArenaBuyTicket()
    end
  })
end

function Form_PvpReplaceMain:CheckUpdateCDTime()
  if not self.m_isCanUpdateCDTime then
    return
  end
  if self.m_curDeltaTimeNum <= UpdateDeltaNum then
    self.m_curDeltaTimeNum = self.m_curDeltaTimeNum + 1
  else
    self.m_curDeltaTimeNum = 0
    self:ShowCDTimeStr()
  end
end

function Form_PvpReplaceMain:ShowCDTimeStr()
  local nextFreshTime = PvpReplaceManager:GetSeasonLastEnemyFreshTime() + ReplaceArenaAutoRefreshCD
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTime = nextFreshTime - curServerTime
  if deltaTime < 0 then
    deltaTime = 0
    self:CheckShowFreshCD()
  end
  self.m_txt_refresh_cd_Text.text = deltaTime .. "s"
end

function Form_PvpReplaceMain:ShowEnemyItemListAnim()
  if not self.m_enemy_item_list then
    return
  end
  for i, tempEnemyItem in ipairs(self.m_enemy_item_list) do
    local tempObj = tempEnemyItem.root
    UILuaHelper.SetCanvasGroupAlpha(tempObj, 0)
    local leftIndex = i - 1
    if leftIndex == 0 then
      UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
      UILuaHelper.PlayAnimationByName(tempObj, EnemyInAnimStr)
    else
      self["ItemInitTimer" .. i] = TimeService:SetTimer(leftIndex * DurationTime, 1, function()
        UILuaHelper.SetCanvasGroupAlpha(tempObj, 1)
        UILuaHelper.PlayAnimationByName(tempObj, EnemyInAnimStr)
      end)
    end
  end
end

function Form_PvpReplaceMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYPVP, {})
  for tempKey, v in pairs(self.m_mineFormDataDic) do
    self.m_mineFormDataDic[tempKey] = {}
  end
  self:CloseForm()
end

function Form_PvpReplaceMain:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_PvpReplaceMain:OnBtnDefenseClicked()
  BattleFlowManager:StartEnterBattle(PvpReplaceManager.LevelType.ReplacePVP, PvpReplaceManager.BattleEnterSubType.Defense)
end

function Form_PvpReplaceMain:OnEnemyItemClk(index)
  if not index then
    return
  end
  local enemyData = self.m_enemyDataList[index]
  if not enemyData or enemyData.enemyData.isEmpty then
    return
  end
  local isFree = self:IsTicketFree()
  local coinNum = ItemManager:GetItemNum(ReplaceArenaToken)
  if not isFree and coinNum < 1 then
    self:CheckBuyTicket(index)
    return
  end
  self.m_reqEnemyIndex = enemyData.enemyIndex
  PvpReplaceManager:ReqReplaceArenaGetEnemyDetail(self.m_reqEnemyIndex)
end

function Form_PvpReplaceMain:OnBtnrecordClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  PvpReplaceManager:ReqReplaceArenaGetBattleRecord()
end

function Form_PvpReplaceMain:OnBtnstoreClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  QuickOpenFuncUtil:OpenFunc(ReplaceArenaShopJumpID)
end

function Form_PvpReplaceMain:OnBtnrewardClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:Push(UIDefines.ID_FORM_PVPREPLACEREWARD, {
    backFun = function()
      self:OnTopPanelBack()
    end
  })
end

function Form_PvpReplaceMain:OnBtnrankingClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  RankManager:ReqArenaRankListCS(RankManager.RankType.ReplacePVPScore, 1, ReplaceArenaPtRanklist)
  RankManager:ReqArenaRankListCS(RankManager.RankType.ReplacePVPGrade, 1, ReplaceArenaPtRanklist)
  for i, _ in pairs(self.m_reqRankCache) do
    self.m_reqRankCache[i] = false
  end
end

function Form_PvpReplaceMain:OnBtnrefreshClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(250)
  local lastFreshTime = PvpReplaceManager:GetSeasonLastEnemyFreshTime()
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTime = curServerTime - lastFreshTime
  if deltaTime > ReplaceArenaAutoRefreshCD then
    PvpReplaceManager:ReqReplaceArenaRefreshEnemy()
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40017)
  end
end

function Form_PvpReplaceMain:OnBtnPvPMoneyClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CheckBuyTicket()
end

function Form_PvpReplaceMain:OnBtntab1Clicked()
  self:OnFormTabClick(1)
end

function Form_PvpReplaceMain:OnBtntab2Clicked()
  self:OnFormTabClick(2)
end

function Form_PvpReplaceMain:OnBtntab3Clicked()
  self:OnFormTabClick(3)
end

function Form_PvpReplaceMain:OnFormTabClick(teamIndex)
  if not teamIndex then
    return
  end
  if teamIndex == self.m_curTeamIndex then
    return
  end
  self:ChangeFreshFormTeam(teamIndex)
end

function Form_PvpReplaceMain:OnBtnRewardClicked()
  if PvpReplaceManager:IsAfkRankCanReward() ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10246)
    return
  end
  self.m_isReqSeeAfk = true
  PvpReplaceManager:ReqReplaceArenaSeeAfk()
end

function Form_PvpReplaceMain:OnTopPanelBack()
  if self.m_isEnemyRankChangeWait then
    PvpReplaceManager:ReqReplaceArenaRefreshEnemy()
    self.m_isEnemyRankChangeWait = false
  end
  self.m_isShowPopPanel = false
end

function Form_PvpReplaceMain:IsFullScreen()
  return false
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceMain", Form_PvpReplaceMain)
return Form_PvpReplaceMain
