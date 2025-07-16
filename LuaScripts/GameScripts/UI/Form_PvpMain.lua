local Form_PvpMain = class("Form_PvpMain", require("UI/UIFrames/Form_PvpMainUI"))
local PvPNewCoinID = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewCoin"))
local PVPNewShopJumpID = ConfigManager:GetGlobalSettingsByKey("PVPNewShopJumpID")
local PVPNewRankPagecnt = ConfigManager:GetGlobalSettingsByKey("PVPNewRankPagecnt")
local FormPlotMaxNum = HeroManager.FormPlotMaxNum
local PVPNewChallengeCostIns = ConfigManager:GetConfigInsByName("PVPNewChallengeCost")
local pairs = _ENV.pairs
local PVPNewRefreshCD = tonumber(ConfigManager:GetGlobalSettingsByKey("PVPNewRefreshCD"))
local UpdateDeltaNum = 3
local EnemyInAnimStr = "m_base_enemy_in"
local DurationTime = 0.15

function Form_PvpMain:SetInitParam(param)
end

function Form_PvpMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1105)
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_playerHeadCom = self:createPlayerHead(self.m_mine_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
  self.m_waitEnemyIndex = nil
  self.m_mineFormData = nil
  self.m_heroFormDataList = {}
  self.m_formPower = nil
  self.m_heroWidgetList = {}
  self:CreateFormHeroWidgetList()
  self.m_reqEnemyIndex = nil
  self.m_enemyDataList = {}
  self.m_enemy_item_list = {
    [1] = self:InitEnemyItem(self.m_base_enemy, 1)
  }
  self.m_challengeCostCfgList = {}
  self:FreshCreateChallengeCostCfgList()
  self.m_isCanUpdateCDTime = false
  self.m_curDeltaTimeNum = 0
  self.m_mineFormationPower = 0
  self:PlayVoiceOnFirstEnter()
end

function Form_PvpMain:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self.m_waitEnemyIndex = nil
  BattleFlowManager:CheckSetEnterTimer(BattleFlowManager.ArenaType.Arena)
  self.m_isCanUpdateCDTime = false
  self:CheckInSeasonEndFresh()
end

function Form_PvpMain:OnInactive()
  self.super.OnInactive(self)
  self:ClearData()
  self:RemoveAllEventListeners()
  if self.m_playingId then
    CS.UI.UILuaHelper.StopPlaySFX(self.m_playingId)
  end
end

function Form_PvpMain:OnUpdate(dt)
  self:CheckUpdateCDTime()
end

function Form_PvpMain:OnDestroy()
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

function Form_PvpMain:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_csui.m_param = nil
  end
end

function Form_PvpMain:ClearData()
  self.m_reqEnemyIndex = nil
end

function Form_PvpMain:FreshFormData()
  if not self.m_mineFormData then
    return
  end
  self.m_heroFormDataList = {}
  local heroList = self.m_mineFormData.vHero
  local mutePower = 0
  for _, v in ipairs(heroList) do
    local heroID = v.iHeroId
    local heroData = HeroManager:GetHeroDataByID(heroID)
    if heroData then
      local serverData = ArenaManager:GeneratePvpHeroModifyData(heroData.serverData)
      local newHeroData = {
        serverData = serverData,
        characterCfg = heroData.characterCfg
      }
      self.m_heroFormDataList[#self.m_heroFormDataList + 1] = newHeroData
      if ArenaManager:GetPvpHeroModifyCfg() then
        local power = HeroManager:GetHeroAttr():GetHeroPowerByParam(heroID, {}, serverData)
        if power then
          mutePower = mutePower + power
        end
      end
    end
  end
  self.m_mineFormationPower = mutePower == 0 and self.m_mineFormData.iPower or mutePower
end

function Form_PvpMain:IsTicketFree()
  local ticketFreeCount = ArenaManager:GetSeasonTicketFreeCount() or 0
  local isFree = 0 < ticketFreeCount
  return isFree
end

function Form_PvpMain:FreshCreateChallengeCostCfgList()
  local allCostCfg = PVPNewChallengeCostIns:GetAll()
  for _, tempCfg in pairs(allCostCfg) do
    self.m_challengeCostCfgList[tempCfg.m_Times] = tempCfg
  end
end

function Form_PvpMain:GetMinePlayerInfoTab()
  local stRoleId = {
    iZoneId = UserDataManager:GetZoneID(),
    iUid = RoleManager:GetUID()
  }
  local iHeadId = RoleManager:GetHeadID()
  local iHeadFrameId = RoleManager:GetHeadFrameID()
  local iHeadFrameExpireTime = RoleManager:GetHeadFrameExpireTime()
  local iLevel = RoleManager:GetLevel()
  return {
    iHeadId = iHeadId,
    iHeadFrameId = iHeadFrameId,
    iHeadFrameExpireTime = iHeadFrameExpireTime,
    iLevel = iLevel,
    stRoleId = stRoleId
  }
end

function Form_PvpMain:AddEventListeners()
  self:addEventListener("eGameEvent_Hero_GetForm", handler(self, self.OnHeroGetForm))
  self:addEventListener("eGameEvent_Level_ArenaRefreshEnemy", handler(self, self.OnArenaFreshEnemy))
  self:addEventListener("eGameEvent_Level_ArenaGetArenaReport", handler(self, self.OnArenaReportBack))
  self:addEventListener("eGameEvent_UpDataRankList", handler(self, self.OnUpDataArenaRankBack))
  self:addEventListener("eGameEvent_Level_ArenaBuyTicket", handler(self, self.OnArenaBuyTicketBack))
  self:addEventListener("eGameEvent_Level_ArenaUnknown", handler(self, self.OnEnemyUnknown))
  self:addEventListener("eGameEvent_Level_ArenaGetEnemyDetail", handler(self, self.OnArenaGetEnemyDetail))
  self:addEventListener("eGameEvent_Arena_SeasonInit", handler(self, self.OnArenaSeasonInit))
end

function Form_PvpMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpMain:OnHeroGetForm(param)
  if not param then
    return
  end
  self.m_mineFormData = param.stForm
  self:FreshFormData()
  self:FreshShowForm()
end

function Form_PvpMain:OnArenaFreshEnemy()
  self:ShowFreshEnemyFx()
  TimeService:SetTimer(0.16, 1, function()
    self:CheckShowFreshCD()
    self:FreshEnemy()
  end)
end

function Form_PvpMain:OnArenaReportBack(stData)
  StackPopup:Push(UIDefines.ID_FORM_PVPRECORDLIST, stData)
end

function Form_PvpMain:OnUpDataArenaRankBack()
  StackPopup:Push(UIDefines.ID_FORM_PVPRANKLIST)
end

function Form_PvpMain:OnArenaBuyTicketBack()
  if self.m_waitEnemyIndex then
    self:OnEnemyItemClk(self.m_waitEnemyIndex)
    self.m_waitEnemyIndex = nil
  end
  self:FreshPVPMoney()
end

function Form_PvpMain:OnEnemyUnknown()
  ArenaManager:ReqOriginalArenaRefreshEnemy(true)
end

function Form_PvpMain:OnArenaGetEnemyDetail(param)
  if not param then
    return
  end
  if self.m_reqEnemyIndex then
    StackPopup:Push(UIDefines.ID_FORM_PVPMAINPOPUP, {
      enemyIndex = self.m_reqEnemyIndex,
      param = param
    })
    self.m_reqEnemyIndex = nil
  end
end

function Form_PvpMain:OnArenaSeasonInit()
  self:CheckInSeasonEndFresh()
end

function Form_PvpMain:CreateFormHeroWidgetList()
  for i = 1, FormPlotMaxNum do
    local tempHeroRoot = self.m_form_root.transform:Find("c_common_hero_small" .. i)
    local heroWid
    if tempHeroRoot then
      heroWid = self:createHeroIcon(tempHeroRoot)
      self.m_heroWidgetList[#self.m_heroWidgetList + 1] = heroWid
    end
  end
end

function Form_PvpMain:FreshUI()
  self:FreshMineInfo()
  self:FreshEnemy()
  self:CheckShowFreshCD()
  self:CheckReqOrFreshForm()
  self:InitFreshEnemyFxStatus()
  self:ShowEnemyItemListAnim()
end

function Form_PvpMain:FreshMineInfo()
  self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
  local roleName = RoleManager:GetName()
  self.m_txt_name_Text.text = roleName
  local rank = ArenaManager:GetSeasonRank()
  self.m_txt_rank_num_Text.text = rank
  local pointNum = ArenaManager:GetSeasonPoint()
  self.m_txt_achievement_Text.text = pointNum
  self:FreshPVPMoney()
end

function Form_PvpMain:FreshPVPMoney()
  local curBuyTicketNum = ArenaManager:GetSeasonTicketBuyCount() + 1
  local maxBuyTicketNum = #self.m_challengeCostCfgList
  local leftTimes = maxBuyTicketNum - ArenaManager:GetSeasonTicketBuyCount()
  UILuaHelper.SetActive(self.m_btn_PvPMoney, curBuyTicketNum <= maxBuyTicketNum)
  local itemNum = ItemManager:GetItemNum(PvPNewCoinID) or 0
  local iconPath = ItemManager:GetItemIconPathByID(PvPNewCoinID)
  if iconPath then
    UILuaHelper.SetAtlasSprite(self.m_icon_pvpmoney_Image, iconPath)
  end
  self.m_txt_pvpmoney_Text.text = BigNumFormat(itemNum)
  self.m_txt_left_buy_ticket_Text.text = leftTimes .. "/" .. maxBuyTicketNum
end

function Form_PvpMain:CheckShowFreshCD()
  local lastFreshTime = ArenaManager:GetSeasonLastEnemyFreshTime()
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTime = curServerTime - lastFreshTime
  if deltaTime < PVPNewRefreshCD then
    self.m_isCanUpdateCDTime = true
  else
    self.m_isCanUpdateCDTime = false
  end
  UILuaHelper.SetActive(self.m_txt_refresh_cd, self.m_isCanUpdateCDTime)
  UILuaHelper.SetActive(self.m_z_txt_refresh, not self.m_isCanUpdateCDTime)
end

function Form_PvpMain:FreshEnemy()
  local arenaEnemyDic = ArenaManager:GetEnemyDic()
  self.m_enemyDataList = {}
  for enemyIndex, v in pairs(arenaEnemyDic) do
    self.m_enemyDataList[#self.m_enemyDataList + 1] = {enemyData = v, enemyIndex = enemyIndex}
  end
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

function Form_PvpMain:InitEnemyItem(itemObj, index)
  if not itemObj then
    return
  end
  local itemTrans = itemObj.transform
  local txt_power = itemTrans:Find("img_rival_power_bg/m_txt_rival_power"):GetComponent(T_TextMeshProUGUI)
  local node_img_free = itemTrans:Find("m_img_free")
  local node_PvP_money = itemTrans:Find("m_rival_pvpmoney")
  local img_PvP_money_icon = itemTrans:Find("m_rival_pvpmoney/m_icon_rival_pvpmoney"):GetComponent(T_Image)
  local txt_name = itemTrans:Find("m_txt_rival_name"):GetComponent(T_TextMeshProUGUI)
  local txt_achievement = itemTrans:Find("icon_rival_achievement/m_txt_rival_achievement"):GetComponent(T_TextMeshProUGUI)
  local fx_fresh = itemTrans:Find("m_enemy_refresh_fx")
  local playerHeadObj = itemTrans:Find("c_circle_head2").gameObject
  local playerHeadCom = self:createPlayerHead(playerHeadObj)
  playerHeadCom:SetStopClkStatus(true)
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
    txt_achievement = txt_achievement,
    fx_fresh = fx_fresh,
    playerHeadCom = playerHeadCom
  }
  return item
end

function Form_PvpMain:FreshEnemyItemData(item, itemData)
  if not item then
    return
  end
  if not itemData then
    return
  end
  item.itemData = itemData
  local enemyData = itemData.enemyData
  item.txt_power.text = enemyData.stRoleSimpleInfo.mSimpleData[MTTDProto.CmdSimpleDataType_OriginalPvpDefend] or 0
  item.playerHeadCom:SetPlayerHeadInfo(enemyData.stRoleSimpleInfo)
  local isFree = self:IsTicketFree()
  UILuaHelper.SetActive(item.node_img_free, isFree)
  UILuaHelper.SetActive(item.node_PvP_money, not isFree)
  if not isFree then
    local itemID = PvPNewCoinID
    local iconPath = ItemManager:GetItemIconPathByID(itemID)
    if iconPath then
      UILuaHelper.SetAtlasSprite(item.img_PvP_money_icon, iconPath)
    end
  end
  item.txt_name.text = enemyData.stRoleSimpleInfo.sName or ""
  item.txt_achievement.text = enemyData.iScore
end

function Form_PvpMain:CheckReqOrFreshForm()
  self.m_mineFormData = HeroManager:GetFormDataByLevelTypeAndSubType(BattleFlowManager.ArenaType.Arena, BattleFlowManager.ArenaSubType.ArenaDefense)
  if self.m_mineFormData then
    self:FreshFormData()
    self:FreshShowForm()
  else
    HeroManager:ReqGetForm(BattleFlowManager.ArenaType.Arena, BattleFlowManager.ArenaSubType.ArenaDefense)
  end
end

function Form_PvpMain:FreshShowForm()
  if not self.m_mineFormData then
    return
  end
  self.m_txt_power_Text.text = self.m_mineFormationPower or 0
  self:FreshShowFormList()
end

function Form_PvpMain:FreshShowFormList()
  if not self.m_heroWidgetList then
    return
  end
  if not next(self.m_heroWidgetList) then
    return
  end
  for i = 1, FormPlotMaxNum do
    local formHeroData = self.m_heroFormDataList[i]
    local heroIcon = self.m_heroWidgetList[i]
    if heroIcon then
      if formHeroData then
        heroIcon:SetActive(true)
        heroIcon:SetHeroData(formHeroData.serverData, nil, nil, true)
      else
        heroIcon:SetActive(false)
      end
    end
  end
end

function Form_PvpMain:CheckBuyTicket(waitEnemyIndex)
  local curBuyTicketNum = ArenaManager:GetSeasonTicketBuyCount() + 1
  if curBuyTicketNum > #self.m_challengeCostCfgList then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40015)
    return
  end
  local curCostCfg = self.m_challengeCostCfgList[curBuyTicketNum]
  if not curCostCfg then
    return
  end
  local needCostItemID = curCostCfg.m_Cost[0][0]
  local needCostNum = curCostCfg.m_Cost[0][1]
  local curHaveNum = ItemManager:GetItemNum(needCostItemID, true)
  if needCostNum > curHaveNum then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40016)
    return
  end
  utils.ShowCommonTipCost({
    beforeItemID = needCostItemID,
    beforeItemNum = needCostNum,
    afterItemID = PvPNewCoinID,
    afterItemNum = 1,
    funSure = function()
      if waitEnemyIndex then
        self.m_waitEnemyIndex = waitEnemyIndex
      end
      ArenaManager:ReqOriginalArenaBuyTicket()
    end
  })
end

function Form_PvpMain:CheckUpdateCDTime()
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

function Form_PvpMain:ShowCDTimeStr()
  local nextFreshTime = ArenaManager:GetSeasonLastEnemyFreshTime() + PVPNewRefreshCD
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTime = nextFreshTime - curServerTime
  if deltaTime < 0 then
    deltaTime = 0
    self:CheckShowFreshCD()
  end
  self.m_txt_refresh_cd_Text.text = deltaTime .. "s"
end

function Form_PvpMain:ShowEnemyItemListAnim()
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

function Form_PvpMain:InitFreshEnemyFxStatus()
  if not self.m_enemy_item_list then
    return
  end
  for _, tempEnemyItem in ipairs(self.m_enemy_item_list) do
    local nodeFxFresh = tempEnemyItem.fx_fresh
    UILuaHelper.SetActive(nodeFxFresh, false)
  end
end

function Form_PvpMain:ShowFreshEnemyFx()
  if not self.m_enemy_item_list then
    return
  end
  for _, tempEnemyItem in ipairs(self.m_enemy_item_list) do
    local nodeFxFresh = tempEnemyItem.fx_fresh
    UILuaHelper.SetActive(nodeFxFresh, false)
    UILuaHelper.SetActive(nodeFxFresh, true)
  end
end

function Form_PvpMain:CheckInSeasonEndFresh()
  local curSeasonEndTime = ArenaManager:GetCurSeasonEndTime() or 0
  local nextSeasonStartTime = ArenaManager:GetNextSeasonStartTime() or 0
  local curServerTime = TimeUtil:GetServerTimeS()
  if curSeasonEndTime <= curServerTime and nextSeasonStartTime > curServerTime then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40025)
    self:CloseForm()
    StackPopup:PopAll()
  else
    self:FreshUI()
  end
end

function Form_PvpMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYPVP, {})
  self.m_mineFormData = nil
  self:CloseForm()
end

function Form_PvpMain:OnBackHome()
  ArenaManager:ClearCacheMineSeasonInfo()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_PvpMain:OnBtnDefenseClicked()
  BattleFlowManager:StartEnterBattle(BattleFlowManager.ArenaType.Arena, BattleFlowManager.ArenaSubType.ArenaDefense)
end

function Form_PvpMain:OnEnemyItemClk(index)
  if not index then
    return
  end
  local enemyData = self.m_enemyDataList[index]
  if not enemyData then
    return
  end
  local isFree = self:IsTicketFree()
  local coinNum = ItemManager:GetItemNum(PvPNewCoinID)
  if not isFree and coinNum < 1 then
    self:CheckBuyTicket(index)
    return
  end
  self.m_reqEnemyIndex = enemyData.enemyIndex
  ArenaManager:ReqOriginalArenaGetEnemyDetail(self.m_reqEnemyIndex)
end

function Form_PvpMain:OnBtnrecordClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  ArenaManager:ReqOriginalArenaGetArenaReport()
end

function Form_PvpMain:OnBtnstoreClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  QuickOpenFuncUtil:OpenFunc(PVPNewShopJumpID)
end

function Form_PvpMain:OnBtnrewardClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackPopup:Push(UIDefines.ID_FORM_PVPREWARDPOP)
end

function Form_PvpMain:OnBtnrankingClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  RankManager:ReqArenaRankListCS(RankManager.RankType.Arena, 1, PVPNewRankPagecnt)
end

function Form_PvpMain:OnBtnrefreshClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(247)
  local lastFreshTime = ArenaManager:GetSeasonLastEnemyFreshTime()
  local curServerTime = TimeUtil:GetServerTimeS()
  local deltaTime = curServerTime - lastFreshTime
  if deltaTime > PVPNewRefreshCD then
    ArenaManager:ReqOriginalArenaRefreshEnemy(false)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40017)
  end
end

function Form_PvpMain:OnBtnPvPMoneyClicked()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  self:CheckBuyTicket()
end

function Form_PvpMain:PlayVoiceOnFirstEnter()
  local closeVoice = ConfigManager:GetGlobalSettingsByKey("PVPVoice")
  CS.UI.UILuaHelper.StartPlaySFX(closeVoice, nil, function(playingId)
    self.m_playingId = playingId
  end, function()
    self.m_playingId = nil
  end)
end

local fullscreen = true
ActiveLuaUI("Form_PvpMain", Form_PvpMain)
return Form_PvpMain
