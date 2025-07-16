local Form_Activity101Lamia_ShardSelect = class("Form_Activity101Lamia_ShardSelect", require("UI/UIFrames/Form_Activity101Lamia_ShardSelectUI"))
local StepEnum = {
  StartStep = 0,
  ShowTimeTextStep = 1,
  WaitChooseTimeStep = 2,
  ShowPlaceStep = 3,
  WaitChoosePlaceStep = 4,
  ShowFinishUI = 5,
  EndStep = 6
}
local MaxDragDeltaNum = 800

local function __ShowCurText(self, config)
  local item = self.text_item_cache[self.cur_text_index]
  if not item then
    local obj = GameObject.Instantiate(self.m_pnl_txt, self.m_pnl_txt.transform.parent).gameObject
    local trans = obj.transform
    item = {
      obj = obj,
      m_bg_title_name_Image = trans:Find("m_bg_title_name"):GetComponent("Image"),
      m_txt_name_Text = trans:Find("m_bg_title_name/m_txt_name"):GetComponent("TMPPro"),
      m_CommonTMPTypewriter = trans:Find("m_txt_content"):GetComponent("CommonTMPTypewriter"),
      m_txt_content_Text = trans:Find("m_txt_content"):GetComponent("TMPPro")
    }
    self.text_item_cache[self.cur_text_index] = item
  end
  item.obj:SetActive(true)
  local color_rgb = string.split(config.m_NameColor, ",")
  color_rgb[4] = color_rgb[4] or 255
  item.m_bg_title_name_Image.color = Color(color_rgb[1] / 255, color_rgb[2] / 255, color_rgb[3] / 255, color_rgb[4] / 255)
  item.m_txt_name_Text.text = config.m_mName
  self.cur_TMPtween = item.m_CommonTMPTypewriter
  self.is_typing = true
  self.m_btn_continue:SetActive(false)
  self.m_btn_touch:SetActive(true)
  self.cur_TMPtween:StartTypeweiteByFixedSpeed(config.m_mText, function()
    self.is_typing = false
    self.m_btn_continue:SetActive(true)
    self.m_btn_touch:SetActive(false)
  end)
end

local StepFunc = {}
StepFunc[StepEnum.StartStep] = function(self)
  local config = self.config
  UILuaHelper.SetAtlasSprite(self.m_icon_item_Image, ItemManager:GetItemIconPathByID(config.m_Item))
  self.m_pnl_time:SetActive(false)
  self.m_pnl_place:SetActive(false)
  self.cur_text_index = 1
  self:DoStepOrNextStep()
  self.m_img_none:SetActive(true)
end
StepFunc[StepEnum.ShowTimeTextStep] = function(self)
  local text_config = HeroActivityManager:GetFormatActMemoryTextCfgByID(self.m_MemoryID)
  local text_list = text_config[HeroActivityManager.ActMemoryTextType.TimeSelect]
  local config = text_list[self.cur_text_index]
  if config then
    __ShowCurText(self, config)
  else
    self:DoStepOrNextStep()
  end
end
StepFunc[StepEnum.WaitChooseTimeStep] = function(self)
  if self.is_selected then
    self.is_selected = false
    self.error_times = nil
    self.m_btn_touch:SetActive(true)
    self.m_pnl_time:SetActive(false)
    self:DoStepOrNextStep()
    self.m_img_none:SetActive(true)
  else
    self.m_img_none:SetActive(false)
    self.m_pnl_time:SetActive(true)
    self.m_btn_time_yes:SetActive(false)
    self.m_btn_time_gray:SetActive(true)
  end
end
StepFunc[StepEnum.ShowPlaceStep] = function(self)
  local text_config = HeroActivityManager:GetFormatActMemoryTextCfgByID(self.m_MemoryID)
  local text_list = text_config[HeroActivityManager.ActMemoryTextType.PlaceSelect]
  local config = text_list[self.cur_text_index]
  if config then
    __ShowCurText(self, config)
  else
    self.m_btn_touch:SetActive(false)
    self.cur_select_idx = 1
    self:DoStepOrNextStep()
  end
end
StepFunc[StepEnum.WaitChoosePlaceStep] = function(self)
  if self.is_selected then
    self.is_selected = false
    self.error_times = nil
    self.m_btn_touch:SetActive(true)
    self:DoStepOrNextStep()
  else
    self.m_img_none:SetActive(false)
    self.m_pnl_place:SetActive(true)
    local cfg = HeroActivityManager:GetActMemoryChoiceByTypeAndChoiceID(self.m_ChoiceTime[1], self.m_ChoiceTime[2])
    UILuaHelper.SetAtlasSprite(self.m_icon_time_Image, cfg.m_Pic1)
    self.m_txt_time_Text.text = cfg.m_mText
    self:FreshPlace()
  end
end
StepFunc[StepEnum.ShowFinishUI] = function(self)
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDMEMORY, {
    cur_text_index = self.cur_text_index,
    config = self.config,
    call_back = function()
      self:DoStepOrNextStep()
    end
  })
end
StepFunc[StepEnum.EndStep] = function(self)
  local config = self.config
  if config.m_UIType == 1 then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDPERSONALITYCOMPLETE, {
      call_back = function()
        self:CloseForm()
      end
    })
  else
    self:CloseForm()
  end
end

function Form_Activity101Lamia_ShardSelect:SetInitParam(param)
end

function Form_Activity101Lamia_ShardSelect:AfterInit()
  self.super.AfterInit(self)
  local goRoot = self.m_csui.m_uiGameObject
  self.m_rootTrans = goRoot.transform
  self.m_groupCam = self:OwnerStack().Group:GetCamera()
  self.m_btn_symbol:SetActive(false)
  self.m_img_place_oriLpos = self.m_img_place.transform.localPosition
  local goBackBtnRoot = goRoot.transform:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  self.text_item_cache = {}
  self.m_pnl_txt:SetActive(false)
  local trans = self.m_pnl_time.transform
  for i = 1, 4 do
    local btn = trans:Find("btn_moon" .. i):GetComponent(T_Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function()
      self:OnSelectTimeClicked(i)
    end)
  end
  self.m_img_place_BtnEx = self.m_img_place:GetComponent("ButtonExtensions")
  if self.m_img_place_BtnEx then
    self.m_img_place_BtnEx.BeginDrag = handler(self, self.OnImgBeginDrag)
    self.m_img_place_BtnEx.Drag = handler(self, self.OnImgDrag)
    self.m_img_place_BtnEx.EndDrag = handler(self, self.OnImgEndDrag)
  end
end

function Form_Activity101Lamia_ShardSelect:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(145)
  self.act_id = self.m_csui.m_param.act_id
  self.config = self.m_csui.m_param.config
  self.m_MemoryID = self.config.m_MemoryID
  self.cur_select_idx = nil
  self.m_ChoiceTime = utils.changeCSArrayToLuaTable(self.config.m_ChoiceTime)
  self.m_ChoicePlace = utils.changeCSArrayToLuaTable(self.config.m_ChoicePlace)
  local trans = self.m_pnl_time.transform
  for i = 1, 4 do
    local cfg = HeroActivityManager:GetActMemoryChoiceByTypeAndChoiceID(self.m_ChoiceTime[1], i)
    local m_txt_name_Text = self["m_line_nml" .. i].transform:Find("txt_name" .. i):GetComponent("TMPPro")
    local m_txt_select_Text = self["m_selected" .. i].transform:Find("txt_select_name" .. i):GetComponent("TMPPro")
    local m_btn_moon_Image = trans:Find("btn_moon" .. i .. "/icon_moon" .. i):GetComponent("Image")
    m_txt_name_Text.text = cfg.m_mText
    m_txt_select_Text.text = cfg.m_mText
    UILuaHelper.SetAtlasSprite(m_btn_moon_Image, cfg.m_Pic1)
    self["m_selected" .. i]:SetActive(false)
  end
  self.m_iTouchClickLastTime = 0
  self.cur_step = StepEnum.StartStep
  self:DoStepOrNextStep(self.cur_step)
end

function Form_Activity101Lamia_ShardSelect:OnInactive()
  self.super.OnInactive(self)
  if self.text_item_cache then
    for k, v in pairs(self.text_item_cache) do
      v.obj:SetActive(false)
    end
  end
  for i = 1, 4 do
    self["m_selected" .. i]:SetActive(false)
  end
end

function Form_Activity101Lamia_ShardSelect:DoStepOrNextStep(step)
  if not step then
    self.cur_step = self.cur_step + 1
  end
  local f = StepFunc[self.cur_step]
  if f then
    f(self)
  end
end

function Form_Activity101Lamia_ShardSelect:FreshPlace(cb)
  local all_config = HeroActivityManager:GetActMemoryChoiceByType(self.m_ChoicePlace[1])
  local config = all_config[self.cur_select_idx]
  if not config then
    if cb then
      cb()
    end
    return
  end
  UILuaHelper.SetAtlasSprite(self.m_img_place_Image, config.m_Pic1)
  self.m_txt_name_place_Text.text = config.m_mText
  self.m_img_previous_gray:SetActive(not all_config[self.cur_select_idx - 1])
  self.m_img_next_gray:SetActive(not all_config[self.cur_select_idx + 1])
end

function Form_Activity101Lamia_ShardSelect:OnImgBeginDrag(pointerEventData)
  self.m_draging = true
  if not pointerEventData then
    return
  end
  local startPos = pointerEventData.position
  self.m_startDragPos = startPos
  self.m_startDragUIPosX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, startPos.x, startPos.y, self.m_groupCam)
end

function Form_Activity101Lamia_ShardSelect:OnImgDrag(pointerEventData)
  if not pointerEventData then
    return
  end
  if not self.m_startDragUIPosX then
    return
  end
  local cur_dragPos = pointerEventData.position
  local startDragUIPosX = self.m_startDragUIPosX
  local localX, _ = UILuaHelper.ScreenPointToLocalPointInRectangle(self.m_rootTrans, cur_dragPos.x, cur_dragPos.y, self.m_groupCam)
  local deltaX = localX - startDragUIPosX
  local deltaAbsNum = math.abs(deltaX)
  if deltaAbsNum > MaxDragDeltaNum then
    return
  end
  local lerpRate = deltaAbsNum / MaxDragDeltaNum
  local paiRateNum = lerpRate * 3.1415 / 2
  local sinRateNum = math.sin(paiRateNum)
  local inputDeltaNum = sinRateNum * MaxDragDeltaNum
  if deltaX < 0 then
    inputDeltaNum = -inputDeltaNum
  end
  UILuaHelper.SetLocalPosition(self.m_img_place, self.m_img_place_oriLpos.x + inputDeltaNum, self.m_img_place_oriLpos.y, 0)
end

function Form_Activity101Lamia_ShardSelect:OnImgEndDrag(pointerEventData)
  self.m_draging = false
  if not pointerEventData then
    return
  end
  if not self.m_startDragPos then
    return
  end
  local endPos = pointerEventData.position
  local deltaNum = endPos.x - self.m_startDragPos.x
  local absDeltaNum = math.abs(deltaNum)
  UILuaHelper.SetLocalPosition(self.m_img_place, self.m_img_place_oriLpos.x, self.m_img_place_oriLpos.y, 0)
  if absDeltaNum < 100 then
    return
  end
  if deltaNum < 0 then
    self:OnBtnnextClicked()
  else
    self:OnBtnpreviousClicked()
  end
end

function Form_Activity101Lamia_ShardSelect:OnBtntouchClicked()
  local iDiff = CS.Util.GetTime() - self.m_iTouchClickLastTime
  self.m_iTouchClickLastTime = CS.Util.GetTime()
  if iDiff <= 300 and self.cur_TMPtween and self.is_typing then
    self.cur_TMPtween:StopTypewrite()
    return
  end
end

function Form_Activity101Lamia_ShardSelect:OnBtncontinueClicked()
  self.m_btn_continue:SetActive(false)
  self.m_btn_touch:SetActive(true)
  self.cur_text_index = self.cur_text_index + 1
  self:DoStepOrNextStep(self.cur_step)
end

function Form_Activity101Lamia_ShardSelect:OnSelectTimeClicked(index)
  self.m_btn_time_yes:SetActive(true)
  self.m_btn_time_gray:SetActive(false)
  for i = 1, 4 do
    self["m_selected" .. i]:SetActive(i == index)
  end
  self.cur_select_idx = index
end

function Form_Activity101Lamia_ShardSelect:OnBtntimeyesClicked()
  if self.cur_select_idx == self.m_ChoiceTime[2] then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITIPS, {
      tip_str = self.config.m_mCorrectTime,
      is_error = false,
      is_time = true,
      call_back = function()
        self.is_selected = true
        self:DoStepOrNextStep(self.cur_step)
      end
    })
  else
    self.error_times = self.error_times and self.error_times + 1 or 1
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITIPS, {
      tip_str = 2 < self.error_times and self.config.m_mWrongTimeTip2 or self.config.m_mWrongTimeTip1,
      is_error = true,
      is_time = true
    })
  end
end

function Form_Activity101Lamia_ShardSelect:OnBtnnextClicked()
  local all_config = HeroActivityManager:GetActMemoryChoiceByType(self.m_ChoicePlace[1])
  if not all_config[self.cur_select_idx + 1] then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40049)
    return
  end
  self.cur_select_idx = self.cur_select_idx + 1
  self:FreshPlace(function()
    self.cur_select_idx = self.cur_select_idx - 1
  end)
end

function Form_Activity101Lamia_ShardSelect:OnBtnpreviousClicked()
  local all_config = HeroActivityManager:GetActMemoryChoiceByType(self.m_ChoicePlace[1])
  if not all_config[self.cur_select_idx - 1] then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40049)
    return
  end
  self.cur_select_idx = self.cur_select_idx - 1
  self:FreshPlace(function()
    self.cur_select_idx = self.cur_select_idx + 1
  end)
end

function Form_Activity101Lamia_ShardSelect:OnBtnplaceyesClicked()
  if self.cur_select_idx == self.m_ChoicePlace[2] then
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITIPS, {
      tip_str = self.config.m_mCorrectPlace,
      is_error = false,
      call_back = function()
        self.is_selected = true
        self:DoStepOrNextStep(self.cur_step)
      end
    })
    local sub_id = HeroActivityManager:GetSubFuncID(self.act_id, HeroActivityManager.SubActTypeEnum.MiniGame)
    HeroActivityManager:ReqHeroActMiniGameFinishCS(self.act_id, sub_id, self.m_MemoryID)
  else
    self.error_times = self.error_times and self.error_times + 1 or 1
    StackFlow:Push(UIDefines.ID_FORM_ACTIVITY101LAMIA_SHARDITIPS, {
      tip_str = 2 < self.error_times and self.config.m_mWrongPlaceTip2 or self.config.m_mWrongPlaceTip1,
      is_error = true
    })
  end
end

function Form_Activity101Lamia_ShardSelect:OnBtntimegrayClicked()
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40034)
end

function Form_Activity101Lamia_ShardSelect:OnBackClk()
  self:CloseForm()
end

function Form_Activity101Lamia_ShardSelect:OnDestroy()
  self.super.OnDestroy(self)
  if self.text_item_cache then
    for k, v in pairs(self.text_item_cache) do
      v.obj:SetActive(false)
    end
  end
  self.text_item_cache = nil
end

function Form_Activity101Lamia_ShardSelect:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity101Lamia_ShardSelect", Form_Activity101Lamia_ShardSelect)
return Form_Activity101Lamia_ShardSelect
