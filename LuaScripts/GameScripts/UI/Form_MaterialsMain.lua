local Form_MaterialsMain = class("Form_MaterialsMain", require("UI/UIFrames/Form_MaterialsMainUI"))
local UpdateDeltaNum = 3
local MaxDotNum = 5
local TopEndRateNum = 0.15
local MidPerRateNum = 0.175
local PopMaterialLockTimeNum = 0.06

function Form_MaterialsMain:SetInitParam(param)
end

function Form_MaterialsMain:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1106)
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  self.m_isCanUpdateLeftTime = false
  self.m_curDeltaTimeNum = 0
  self.GoblinDailyLimitNum = tonumber(ConfigManager:GetGlobalSettingsByKey("GoblinDailyLimit"))
  self.m_levelGoblinHelper = LevelManager:GetLevelGoblinHelper()
  self.m_levelCfgList = nil
  self.m_levelMaterialItems = {}
  self.m_pnl_item_obj = self.m_pnl_item.gameObject
  self.m_pnl_item_name = self.m_pnl_item_obj.name
  local levelMaterialItem = self:createLevelMaterialItem(self.m_pnl_item.gameObject)
  self.m_pnl_item_obj.name = self.m_pnl_item_name .. 1
  levelMaterialItem:SetItemClkBack(function(levelID)
    self:OnLevelMaterialItemClk(levelID)
  end)
  self.m_levelMaterialItems[#self.m_levelMaterialItems + 1] = levelMaterialItem
end

function Form_MaterialsMain:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(13)
end

function Form_MaterialsMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_MaterialsMain:OnUpdate(dt)
  self:CheckUpdateLeftTime()
end

function Form_MaterialsMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_MaterialsMain:AddEventListeners()
  self:addEventListener("eGameEvent_Level_MopUp", handler(self, self.OnLevelMopUp))
  self:addEventListener("eGameEvent_Level_PushStageTimes", handler(self, self.OnEventPushDailyTimes))
end

function Form_MaterialsMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_MaterialsMain:OnLevelMopUp(param)
  if not param then
    return
  end
  local levelType = param.levelType
  if levelType == LevelManager.LevelType.Goblin then
    self:FreshLeftTimes()
  end
end

function Form_MaterialsMain:OnEventPushDailyTimes(params)
  if not params then
    return
  end
  local levelType = params.levelType
  if levelType == LevelManager.LevelType.Goblin then
    self:FreshLeftTimes()
  end
end

function Form_MaterialsMain:ClearData()
end

function Form_MaterialsMain:FreshData()
end

function Form_MaterialsMain:FreshLevelCfgList()
  self.m_levelCfgList = self.m_levelGoblinHelper:GetGoblinLevelList(LevelManager.GoblinSubType.Skill)
end

function Form_MaterialsMain:FreshUI()
  self:FreshLeftTimes()
  self.m_isCanUpdateLeftTime = true
  self:FreshLevelCfgList()
  self:FreshLevelItems()
  self:FreshLevelProgress()
  self:CheckPopMaterials()
end

function Form_MaterialsMain:CheckUpdateLeftTime()
  if not self.m_isCanUpdateLeftTime then
    return
  end
  if self.m_curDeltaTimeNum <= UpdateDeltaNum then
    self.m_curDeltaTimeNum = self.m_curDeltaTimeNum + 1
  else
    self.m_curDeltaTimeNum = 0
    self:ShowLeftTimeStr()
  end
end

function Form_MaterialsMain:ShowLeftTimeStr()
  local nextResetTimer = TimeUtil:GetServerNextCommonResetTime()
  local curTimer = TimeUtil:GetServerTimeS()
  if nextResetTimer < curTimer then
    return
  end
  local leftTimeSec = nextResetTimer - curTimer
  self.m_txt_time_num_Text.text = TimeUtil:SecondsToFormatStrDHOrHMS(leftTimeSec)
end

function Form_MaterialsMain:FreshLeftTimes()
  local curTimes = self.m_levelGoblinHelper:GetDailyTimesBySubLevelType(LevelManager.GoblinSubType.Skill) or 0
  local leftTimes = self.GoblinDailyLimitNum - curTimes
  self.m_txt_remain_num_Text.text = leftTimes .. "/" .. self.GoblinDailyLimitNum
end

function Form_MaterialsMain:FreshLevelItems()
  if not self.m_levelCfgList then
    return
  end
  local levelCfgList = self.m_levelCfgList
  local itemWidgets = self.m_levelMaterialItems
  local dataLen = #levelCfgList
  local childCount = #itemWidgets
  local totalFreshNum = dataLen < childCount and childCount or dataLen
  for i = 1, totalFreshNum do
    if i <= childCount and i <= dataLen then
      local itemWidget = itemWidgets[i]
      local itemData = levelCfgList[i]
      itemWidget:FreshMaterialLevel(itemData)
      itemWidget:SetActive(true)
    elseif i > childCount and i <= dataLen then
      local parentTrans = self["m_level_item" .. i].transform
      local itemObj = GameObject.Instantiate(self.m_pnl_item_obj, parentTrans).gameObject
      itemObj.name = self.m_pnl_item_name .. i
      local itemWidget = self:createLevelMaterialItem(itemObj)
      local itemData = levelCfgList[i]
      itemWidget:FreshMaterialLevel(itemData)
      itemWidget:SetItemClkBack(function(levelID)
        self:OnLevelMaterialItemClk(levelID)
      end)
      itemWidgets[#itemWidgets + 1] = itemWidget
      itemWidget:SetActive(true)
      UILuaHelper.SetLocalPosition(itemObj, 0, 0, 0)
    elseif i <= childCount and i > dataLen then
      itemWidgets[i]:SetActive(false)
    end
  end
end

function Form_MaterialsMain:FreshLevelProgress()
  if not self.m_levelCfgList then
    return
  end
  local unlockLevelNum = 0
  for i = 1, MaxDotNum do
    local levelCfg = self.m_levelCfgList[i]
    UILuaHelper.SetActive(self["m_pnl_dot" .. i], levelCfg ~= nil)
    if levelCfg then
      local isUnlock = self.m_levelGoblinHelper:IsLevelUnLock(levelCfg.m_LevelID)
      UILuaHelper.SetActive(self["m_select_dot" .. i], isUnlock)
      UILuaHelper.SetActive(self["m_lock_dot" .. i], not isUnlock)
      if isUnlock == true then
        unlockLevelNum = unlockLevelNum + 1
      end
    end
  end
  local levelListLen = #self.m_levelCfgList
  if levelListLen <= 0 then
    return
  end
  local progress = 0
  for i = 1, unlockLevelNum do
    if i == 1 then
      progress = progress + TopEndRateNum
    else
      progress = progress + MidPerRateNum
    end
  end
  self.m_img_slider_Image.fillAmount = progress
end

function Form_MaterialsMain:CheckPopMaterials()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  local levelID = tParam.levelID
  if levelID then
    self.m_popMatItemLock = UILockIns:Lock(PopMaterialLockTimeNum)
    TimeService:SetTimer(PopMaterialLockTimeNum, 1, function()
      self:OnLevelMaterialItemClk(levelID)
    end)
  end
end

function Form_MaterialsMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
  self:CloseForm()
end

function Form_MaterialsMain:OnLevelMaterialItemClk(levelID)
  if not levelID then
    return
  end
  local isUnlock, tips_id = self.m_levelGoblinHelper:IsLevelUnLock(levelID)
  if isUnlock ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
    return
  end
  StackPopup:Push(UIDefines.ID_FORM_MATERIALSPOP, {levelID = levelID})
end

local fullscreen = true
ActiveLuaUI("Form_MaterialsMain", Form_MaterialsMain)
return Form_MaterialsMain
