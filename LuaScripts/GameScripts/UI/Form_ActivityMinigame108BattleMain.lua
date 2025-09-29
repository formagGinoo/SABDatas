local Form_ActivityMinigame108BattleMain = class("Form_ActivityMinigame108BattleMain", require("UI/UIFrames/Form_ActivityMinigame108BattleMainUI"))
local EventType = {
  Normal = 1,
  Judgement = 2,
  Select = 3,
  Result = 4
}
local MapBgDic = {
  [1] = {
    "activity108minigame_bg_grassland01",
    "activity108minigame_bg_grassland02"
  },
  [2] = {
    "activity108minigame_bg_wilderness01",
    "activity108minigame_bg_wilderness02"
  },
  [3] = {
    "activity108minigame_bg_snowfield01",
    "activity108minigame_bg_snowfield02"
  }
}
local OverAutoIndex = 2
local MiniGame108EventIns = ConfigManager:GetConfigInsByName("MiniGame108Event")

function Form_ActivityMinigame108BattleMain:SetInitParam(param)
end

function Form_ActivityMinigame108BattleMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk, nil, handler(self, self.OnBackHome)))
  self.m_SpiderSpine = self.m_img_spider.transform:Find("activity108_spider"):GetComponent(typeof(CS.Spine.Unity.SkeletonGraphic))
  self.isNextEnabled = true
  local initGridData = {
    itemClkBackFun = handler(self, self.OnEventItemClick)
  }
  self.m_grid = self:CreateInfinityGrid(self.m_eventScroll_InfinityGrid, "ActivityMinigame108/Minigame108EventItem", initGridData)
end

function Form_ActivityMinigame108BattleMain:OnActive()
  self.super.OnActive(self)
  self.main_id = self.m_csui.m_param.main_id
  self.sub_id = self.m_csui.m_param.sub_id
  self.lvconfig = self.m_csui.m_param.data
  self.spindata = self.m_csui.m_param.spindata
  self.myProperty = self.m_csui.m_param.myProperty
  self.recProperty = self.m_csui.m_param.recProperty
  self.m_eventPool = utils.changeCSArrayToLuaTable(self.lvconfig.m_EventPool)
  self.m_SpecialEvent = utils.changeCSArrayToLuaTable(self.lvconfig.m_SpecialEvent)
  table.insert(self.m_SpecialEvent, {
    self.lvconfig.m_LevelDistance,
    1001
  })
  self.zz_maxhp = self.lvconfig.m_InitialHP
  self.zz_hp = self.zz_maxhp
  self.time = 0
  self.step = 0
  self.gameover = false
  StackFlow:DestroyUI(UIDefines.ID_FORM_ACTIVITYMINIGAME108_POP)
  StackFlow:DestroyUI(UIDefines.ID_FORM_ACTIVITYMINIGAME108ASSEMBLE)
  self:ChangeSpineSkin(self.spindata)
  self.m_SpiderSpine.AnimationState:SetAnimation(0, "Move", true)
  self.m_txt_life01_Text.text = self.zz_hp
  self.m_txt_life02_Text.text = "/" .. self.zz_maxhp
  self.m_img_bg_blood_Image.fillAmount = self.zz_hp / self.zz_maxhp
  self.m_img_bg_slider_Image.fillAmount = self.step / self.lvconfig.m_LevelDistance
  self.m_txt_score_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(20376), self.time)
  self.m_txt_progress_end_Text.text = self.lvconfig.m_LevelDistance
  for i = 1, 5 do
    UILuaHelper.SetActive(self["m_img_event" .. i], false)
  end
  for i = 1, #self.m_SpecialEvent - 1 do
    UILuaHelper.SetActive(self["m_img_event" .. i], true)
    local percent = self.m_SpecialEvent[i][1] / self.lvconfig.m_LevelDistance
    UILuaHelper.SetAnchoredPosition(self["m_img_event" .. i], 708 * percent)
    self["m_txt_progress" .. i .. "_Text"].text = self.m_SpecialEvent[i][1]
  end
  self:FreshProperty()
  self.m_nextSpecialStep = 0
  self.m_nextSpecialEventId = 0
  self.m_curEventList = {}
  self:AddStep()
  UILuaHelper.SetUITexture(self.m_img_bg1_Image, MapBgDic[self.lvconfig.m_MapType][2])
  UILuaHelper.SetUITexture(self.m_img_bg2_Image, MapBgDic[self.lvconfig.m_MapType][1])
  UILuaHelper.SetUITexture(self.m_img_bg3_Image, MapBgDic[self.lvconfig.m_MapType][2])
  UILuaHelper.SetUITexture(self.m_img_bg4_Image, MapBgDic[self.lvconfig.m_MapType][1])
end

function Form_ActivityMinigame108BattleMain:FreshProperty()
  for i = 1, 4 do
    local pnl_recommend = self["m_pnl_progress" .. i].transform:Find("pnl_recommend")
    local pnl_self = self["m_pnl_progress" .. i].transform:Find("pnl_self")
    for j = 0, pnl_recommend.transform.childCount - 1 do
      local t = pnl_recommend.transform:GetChild(j)
      t.gameObject:SetActive(false)
    end
    if 0 >= table.size(self.myProperty) then
      return
    end
    for j = 0, pnl_self.transform.childCount - 1 do
      local t = pnl_self.transform:GetChild(j)
      if j < self.myProperty[i] then
        t.gameObject:SetActive(true)
        local color = t.gameObject:GetComponent("MultiColorChange")
        color:SetColorByIndex(1)
      else
        t.gameObject:SetActive(false)
      end
    end
  end
end

function Form_ActivityMinigame108BattleMain:OnEventItemClick(m_itemData)
  print("OnEventItemClick")
end

function Form_ActivityMinigame108BattleMain:AddStep()
  self.lastStep = self.step
  self.step = self.step + 1
  self:AddEvent()
  self.m_img_bg_slider_Image.fillAmount = self.step / self.lvconfig.m_LevelDistance
end

function Form_ActivityMinigame108BattleMain:FreshNextSpecialEvent()
  if table.getn(self.m_SpecialEvent) > 0 then
    for _, v in ipairs(self.m_SpecialEvent) do
      if self.lastStep < v[1] then
        self.m_nextSpecialStep = v[1]
        self.m_nextSpecialEventId = v[2]
        break
      end
    end
  end
end

function Form_ActivityMinigame108BattleMain:SpeedStep()
  self.lastStep = self.step
  self:FreshNextSpecialEvent()
  local num = self.m_nextSpecialStep - self.step
  for i = 1, num - 1 do
    self.step = self.step + 1
    local result = self:AddEvent()
    if result then
      self.m_img_bg_slider_Image.fillAmount = self.step / self.lvconfig.m_LevelDistance
      return
    end
  end
  if self.m_nextSpecialStep ~= self.lvconfig.m_LevelDistance then
    self.step = self.step + 1
    self:AddSpecialEvent(self.m_nextSpecialEventId)
  else
    self.step = self.step + 1
    self:AddEvent()
  end
  self.m_img_bg_slider_Image.fillAmount = self.step / self.lvconfig.m_LevelDistance
end

function Form_ActivityMinigame108BattleMain:Hurt(value)
  if value < 0 then
    UILuaHelper.PlayAnimationByName(self.m_pnl_blood, "BattleMain_blood")
  end
  self.zz_hp = self.zz_hp + value
  if self.zz_hp > 100 then
    self.zz_hp = 100
  end
  if 0 >= self.zz_hp then
    self.zz_hp = 0
    self.gameover = true
  end
  self.m_img_bg_blood_Image.fillAmount = self.zz_hp / self.zz_maxhp
  self.m_txt_life01_Text.text = self.zz_hp
  self.m_txt_life02_Text.text = "/" .. self.zz_maxhp
end

function Form_ActivityMinigame108BattleMain:OnBackClk()
  self:DestroyForm()
end

function Form_ActivityMinigame108BattleMain:OnBackHome()
  self:DestroyForm()
end

function Form_ActivityMinigame108BattleMain:OnInactive()
  self.super.OnInactive(self)
  self.m_curEventList = {}
end

function Form_ActivityMinigame108BattleMain:OnDestroy()
  self.super.OnDestroy(self)
  UILuaHelper.CheckClearSkeletonAssetData(self.m_SpiderSpine)
end

function Form_ActivityMinigame108BattleMain:ChangeSpineSkin(skinNames)
  local skeleton = self.m_SpiderSpine.Skeleton
  local combinedSkin = CS.Spine.Skin("combinedSpine")
  for i = 1, #skinNames do
    local skin = skeleton.Data:FindSkin(skinNames[i])
    if skin ~= nil then
      combinedSkin:AddSkin(skin)
    end
  end
  skeleton:SetSkin(combinedSkin)
  skeleton:SetSlotsToSetupPose()
  self.m_SpiderSpine:UpdateMesh()
end

function Form_ActivityMinigame108BattleMain:RandomEventFormPool()
  local length = table.getn(self.m_eventPool)
  local index = math.random(1, length)
  if self.m_eventPool[index] then
    return self.m_eventPool[index]
  end
end

function Form_ActivityMinigame108BattleMain:FreshGrid()
  if self.m_grid then
    self.m_grid:ShowItemList(self.m_curEventList, true)
    GlobalManagerIns:TriggerWwiseBGMState(378)
    local length = #self.m_curEventList
    if length > OverAutoIndex then
      self.m_grid:LocateTo(length - 1)
    end
  end
end

function Form_ActivityMinigame108BattleMain:FreshEventPanel(itemData)
  self:FreshGrid()
  if itemData.cfg.m_EventType == EventType.Judgement or itemData.cfg.m_EventType == EventType.Normal then
    self.m_pnl_choose:SetActive(false)
    self.m_pnl_next:SetActive(true)
    self.m_btn_confirm:SetActive(false)
  end
  self.m_btn_confirm:SetActive(false)
  if self.m_curEventCfg then
    local type = self.m_curEventCfg.m_EventType
    if type == EventType.Select then
      self.m_pnl_choose:SetActive(type == EventType.Select)
      self.m_txt_choose1_Text.text = self.m_curEventCfg.m_mSelect1Text
      self.m_txt_choose2_Text.text = self.m_curEventCfg.m_mSelect2Text
    end
    self.m_pnl_next:SetActive(type ~= EventType.Select)
  end
end

function Form_ActivityMinigame108BattleMain:GetEventCfgById(eventId)
  local eventCfg = MiniGame108EventIns:GetValue_ByEventID(eventId)
  if not eventCfg:GetError() then
    return eventCfg
  end
end

function Form_ActivityMinigame108BattleMain:AddEventData()
  local randomId = self:RandomEventFormPool()
  self:FreshNextSpecialEvent()
  if self.step == self.m_nextSpecialStep and self.m_nextSpecialStep ~= self.lvconfig.m_LevelDistance then
    randomId = self.m_nextSpecialEventId
  end
  local randomCfg = self:GetEventCfgById(randomId)
  if randomCfg then
    local itemData = {cfg = randomCfg, JudgementResult = 0}
    if itemData.cfg.m_EventType == EventType.Judgement then
      local tale = utils.changeCSArrayToLuaTable(randomCfg.m_PropertyLimit)
      if self.myProperty[tale[1]] >= tale[2] then
        itemData.JudgementResult = 1
      else
        itemData.JudgementResult = 0
      end
    end
    self.m_curEventList[#self.m_curEventList + 1] = itemData
    self.m_curEventCfg = randomCfg
    return itemData
  end
end

function Form_ActivityMinigame108BattleMain:FreshHpbarAndCost(hp, cost)
  self:Hurt(hp)
  self.time = self.time + cost
  UILuaHelper.PlayAnimationByName(self.m_UIEff_Time, "BattleMain_TimeRefresh_in")
  self.m_txt_score_Text.text = string.gsubnumberreplace("<size=52>{0}</size>s", self.time)
end

function Form_ActivityMinigame108BattleMain:FreshEventUI(itemData)
  if itemData.cfg.m_EventType == EventType.Normal then
    self:FreshHpbarAndCost(itemData.cfg.m_Result1HP, itemData.cfg.m_Result1Cost)
  elseif itemData.cfg.m_EventType == EventType.Judgement then
    if itemData.JudgementResult == 1 then
      self:FreshHpbarAndCost(itemData.cfg.m_Result1HP, itemData.cfg.m_Result1Cost)
    else
      self:FreshHpbarAndCost(itemData.cfg.m_Result2HP, itemData.cfg.m_Result2Cost)
    end
  end
end

function Form_ActivityMinigame108BattleMain:AddEvent()
  local itemData = self:AddEventData()
  self:FreshEventPanel(itemData)
  self:FreshEventUI(itemData)
  if self.gameover then
    local itemData = {
      cfg = nil,
      JudgementResult = 0,
      ResultEvent = true,
      Result = 0,
      Cost = self.time
    }
    self.m_curEventList[#self.m_curEventList + 1] = itemData
    self:FreshGrid()
    self.m_pnl_choose:SetActive(false)
    self.m_pnl_next:SetActive(false)
    self.m_btn_confirm:SetActive(true)
    log.info("游戏结束失败")
    self.m_bg_all:GetComponent(T_Animation):Stop()
    self.m_SpiderSpine.AnimationState:SetAnimation(0, "Down", true)
    return true
  end
  if self.step == self.lvconfig.m_LevelDistance then
    self.m_pnl_choose:SetActive(false)
    self.m_pnl_next:SetActive(false)
    self.m_btn_confirm:SetActive(true)
    local itemData = {
      cfg = nil,
      JudgementResult = 0,
      ResultEvent = true,
      Result = 1,
      Cost = self.time
    }
    self.m_curEventList[#self.m_curEventList + 1] = itemData
    self:FreshGrid()
    self.m_SpiderSpine.AnimationState:SetAnimation(0, "Jump", true)
    self.m_bg_all:GetComponent(T_Animation):Stop()
    log.info("游戏结束,成功")
    HeroActivityManager:ReqHeroActMiniGameFinishCS(self.main_id, self.sub_id, self.lvconfig.m_LevelID, self.time)
    return true
  end
  return false
end

function Form_ActivityMinigame108BattleMain:AddSpecialEvent(eventId)
  local eventCfg = MiniGame108EventIns:GetValue_ByEventID(eventId)
  if eventCfg then
    local itemData = {cfg = eventCfg, JudgementResult = 0}
    if itemData.cfg.m_EventType == EventType.Judgement then
      local tale = utils.changeCSArrayToLuaTable(eventCfg.m_PropertyLimit)
      if self.myProperty[tale[1]] >= tale[2] then
        itemData.JudgementResult = 1
      else
        itemData.JudgementResult = 0
      end
    end
    self.m_curEventList[#self.m_curEventList + 1] = itemData
    self.m_curEventCfg = eventCfg
    self:FreshEventPanel(itemData)
    self:FreshEventUI(itemData)
  end
end

function Form_ActivityMinigame108BattleMain:OnBtnskipClicked()
  if self.isNextEnabled then
    self:SpeedStep()
    self.isNextEnabled = false
  end
  TimeService:KillTimer(self.timer)
  self.timer = TimeService:SetTimer(0.5, 1, function()
    self.isNextEnabled = true
  end)
end

function Form_ActivityMinigame108BattleMain:OnBtnconfirmClicked()
  self:DestroyForm()
end

function Form_ActivityMinigame108BattleMain:OnBtnnextClicked()
  if self.isNextEnabled then
    self:AddStep()
    self.isNextEnabled = false
  end
  TimeService:KillTimer(self.timer)
  self.timer = TimeService:SetTimer(0.5, 1, function()
    self.isNextEnabled = true
  end)
end

function Form_ActivityMinigame108BattleMain:OnBtnchoose1Clicked()
  local eventId = self.m_curEventCfg.m_Select1Event
  self:AddSpecialEvent(eventId)
end

function Form_ActivityMinigame108BattleMain:OnBtnchoose2Clicked()
  local eventId = self.m_curEventCfg.m_Select2Event
  self:AddSpecialEvent(eventId)
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMinigame108BattleMain", Form_ActivityMinigame108BattleMain)
return Form_ActivityMinigame108BattleMain
