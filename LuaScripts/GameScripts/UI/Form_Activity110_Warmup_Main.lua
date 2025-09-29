local Form_Activity110_Warmup_Main = class("Form_Activity110_Warmup_Main", require("UI/UIFrames/Form_Activity110_Warmup_MainUI"))
local levelTb = ConfigManager:GetConfigInsByName("MiniGameFlopLevelInfo")
local cardInfoTb = ConfigManager:GetConfigInsByName("MiniGameFlopCardInfo")
local clueInfoTb = ConfigManager:GetConfigInsByName("MiniGameFlopClueInfo")

function Form_Activity110_Warmup_Main:SetInitParam(param)
end

function Form_Activity110_Warmup_Main:AfterInit()
  self.super.AfterInit(self)
end

function Form_Activity110_Warmup_Main:updateStep(param)
  self.step = self.step + 1
  if self.step > self.levelCfg.m_Steps then
    self.m_txt_step_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100903), self.step, self.levelCfg.m_Steps)
  else
    self.m_txt_step_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100902), self.step, self.levelCfg.m_Steps)
  end
end

function Form_Activity110_Warmup_Main:JudgeWin()
  local itemcs = self.itemObjs
  self.gameWin = true
  for i = 1, #itemcs do
    if not itemcs[i].isOpen then
      self.gameWin = false
    end
  end
  if self.gameWin then
    log.info("游戏结束:", tostring(self.gameWin))
    self.gameTimeEnd = true
    TimeService:KillTimer(self.timer)
    TimeService:SetTimer(0.8, 1, function()
      self.m_stActivity:RequestPassLevelCS(self.levelCfg.m_LevelID, self.step, self.is_select_iClueTime)
    end)
  elseif self.gameTimeEnd then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110_WARMUP_VICTORY, {
      gameWin = self.gameWin,
      LevelId = self.Param.LevelId,
      step = self.step
    })
  end
end

function Form_Activity110_Warmup_Main:OnActive()
  self.super.OnActive(self)
  GlobalManagerIns:TriggerWwiseBGMState(380)
  self.Param = self.m_csui.m_param
  self.levelCfg = levelTb:GetValue_ByLevelID(self.Param.LevelId)
  self.activityId = self.Param.activityId
  self.is_select_iClueTime = self.Param.is_select_iClueTime
  self.m_stActivity = ActivityManager:GetActivityByID(self.activityId)
  self.gameStart = false
  self.isJudging = false
  self.firstClickedCard = nil
  self.firstClickedCard_data = nil
  self.firstClickedCard_index = nil
  self.remainTime = self.levelCfg.m_Times
  self.step = 0
  self.gameTimeEnd = false
  self.gameWin = false
  self.m_txt_time_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100901), self.levelCfg.m_Times)
  self.m_txt_step_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100902), self.step, self.levelCfg.m_Steps)
  local time = self.levelCfg.m_Times
  self:CreateCards()
  self:ShowCardsFont()
  self:StartGame()
end

function Form_Activity110_Warmup_Main:StartTimer()
  self.timer = TimeService:SetTimer(1, self.levelCfg.m_Times, function()
    self.remainTime = self.remainTime - 1
    if not utils.isNull(self.m_txt_time_Text) then
      self.m_txt_time_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100901), self.remainTime)
    end
    if self.remainTime == 0 then
      TimeService:KillTimer(self.timer)
      self.gameTimeEnd = true
      self:JudgeWin()
    end
  end)
end

function Form_Activity110_Warmup_Main:CreateCards()
  local cardGroup = utils.changeCSArrayToLuaTable(self.levelCfg.m_CardGroup)
  local card_ids = self:getRandomUniqueElements(cardGroup, self.levelCfg.m_CardNum)
  local max_card = utils.changeCSArrayToLuaTable(self.levelCfg.m_MaxCardNum)
  local scale = self.levelCfg.m_Scale
  self.data_list = {}
  local data_list_index = {}
  for i = 1, max_card[1] * max_card[2] do
    self.data_list[i] = 0
    data_list_index[i] = i
  end
  while 0 < #data_list_index do
    for i = 1, #card_ids do
      local pos = self:getRandomUniqueElements(data_list_index, 2)
      for j = 1, #pos do
        local data = {
          cfg = cardInfoTb:GetValue_ByCardID(card_ids[i]),
          activityId = self.activityId
        }
        self.data_list[pos[j]] = data
        table.removebyvalue(data_list_index, pos[j])
      end
    end
  end
  UILuaHelper.SetLocalScale(self.m_pnl_card, scale, scale, scale)
  self.m_pnl_card:GetComponent("GridLayoutGroup").constraintCount = max_card[1]
  self.itemObjs = {}
  for i = self.m_pnl_card.transform.childCount - 1, 1, -1 do
    local child = self.m_pnl_card.transform:GetChild(i).gameObject
    GameObject.Destroy(child)
  end
  for i = 1, table.size(self.data_list) do
    local ui = GameObject.Instantiate(self.m_item_flopcard, self.m_pnl_card.transform)
    UILuaHelper.SetActive(ui, true)
    local script = self:GetItemScript(ui, self.data_list[i])
    table.insert(self.itemObjs, script)
  end
  for i = 1, #self.itemObjs do
    UILuaHelper.BindButtonClickManual(self, self.itemObjs[i].ui.transform:Find("m_btn_flop"):GetComponent("Button"), function()
      self:OnItemClk(i)
    end)
    self.itemObjs[i]:FreshUI()
  end
end

function Form_Activity110_Warmup_Main:GetItemScript(ui, data)
  local itemSc = {}
  itemSc.ui = ui
  itemSc.itemData = data
  itemSc.isOpen = false
  itemSc.isPair = false
  
  function itemSc:ShowCardFont()
    local mask = self.ui.transform:Find("m_btn_flop/m_pnl_mask")
    UILuaHelper.PlayAnimationByName(self.ui.transform, "m_110main_flopcard_front")
    UILuaHelper.SetActive(mask, false)
    self.isOpen = true
  end
  
  function itemSc:PlaySuccessAni()
    TimeService:SetTimer(0.34, 1, function()
      local ani = self.ui.transform:Find("m_btn_flop/m_fx_card_tips")
      UILuaHelper.SetActive(ani, true)
    end)
  end
  
  function itemSc:ShowCardBack()
    local mask = self.ui.transform:Find("m_btn_flop/m_pnl_mask")
    UILuaHelper.PlayAnimationByName(self.ui.transform, "m_110main_flopcard_back")
    UILuaHelper.SetActive(mask, true)
    self.isOpen = false
  end
  
  function itemSc:FreshUI()
    local card_id = self.itemData.cfg.m_CardID
    local m_img_card_Image = self.ui.transform:Find("m_btn_flop/c_pnl_card/m_img_card"):GetComponent("Image")
    UILuaHelper.SetAtlasSprite(m_img_card_Image, self.itemData.cfg.m_Pic)
  end
  
  return itemSc
end

function Form_Activity110_Warmup_Main:OnItemClk(index)
  if self.gameStart then
    local itemSc = self.itemObjs[index]
    if itemSc.isPair then
      return
    end
    GlobalManagerIns:TriggerWwiseBGMState(381)
    if self.firstClickedCard == nil then
      self.firstClickedCard = self.itemObjs[index]
      self.firstClickedCard:ShowCardFont()
    else
      if self.isJudging then
        return
      end
      if self.firstClickedCard == itemSc then
        return
      end
      self:updateStep()
      if self.firstClickedCard.itemData.cfg.m_CardID == itemSc.itemData.cfg.m_CardID then
        itemSc.isPair = true
        itemSc:ShowCardFont()
        itemSc:PlaySuccessAni()
        GlobalManagerIns:TriggerWwiseBGMState(382)
        self.firstClickedCard:PlaySuccessAni()
        self.firstClickedCard.isPair = true
        self.firstClickedCard = nil
        self:JudgeWin()
      else
        itemSc:ShowCardFont()
        self.isJudging = true
        GlobalManagerIns:TriggerWwiseBGMState(384)
        TimeService:SetTimer(1, 1, function()
          itemSc:ShowCardBack()
          self.isJudging = false
          self.firstClickedCard:ShowCardBack()
          self.firstClickedCard = nil
          self.firstClickedCard_data = nil
        end)
      end
    end
  end
end

function Form_Activity110_Warmup_Main:ShowCardsFont()
  for i = 1, #self.itemObjs do
    self.itemObjs[i]:ShowCardFont()
  end
end

function Form_Activity110_Warmup_Main:StartGame()
  local waitTime = self.levelCfg.m_CardShowTime
  self.startGameTimer = TimeService:SetTimer(waitTime, 1, function()
    for i = 1, #self.itemObjs do
      self.itemObjs[i]:ShowCardBack()
    end
    self.gameStart = true
    self:StartTimer()
  end)
end

function Form_Activity110_Warmup_Main:getRandomUniqueElements(array, count)
  if count > #array then
    count = #array
  end
  local result = {}
  local selectedIndices = {}
  while count > #result do
    local randomIndex = math.random(#array)
    if not selectedIndices[randomIndex] then
      table.insert(result, array[randomIndex])
      selectedIndices[randomIndex] = true
    end
  end
  return result
end

function Form_Activity110_Warmup_Main:OnInactive()
  self.super.OnInactive(self)
  TimeService:KillTimer(self.timer)
  TimeService:KillTimer(self.startGameTimer)
end

function Form_Activity110_Warmup_Main:OnDestroy()
  self:clearEventListener()
  self.super.OnDestroy(self)
end

function Form_Activity110_Warmup_Main:OnBtncloseClicked()
  if not self.gameTimeEnd then
    utils.CheckAndPushCommonTips({
      tipsID = 1260,
      func1 = function()
        self:CloseForm()
      end
    })
  else
    self:CloseForm()
  end
end

function Form_Activity110_Warmup_Main:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity110_Warmup_Main", Form_Activity110_Warmup_Main)
return Form_Activity110_Warmup_Main
