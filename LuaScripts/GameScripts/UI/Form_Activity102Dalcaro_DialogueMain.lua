local Form_Activity102Dalcaro_DialogueMain = class("Form_Activity102Dalcaro_DialogueMain", require("UI/UIFrames/Form_Activity102Dalcaro_DialogueMainUI"))
local LevelDegree = LevelHeroLamiaActivityManager.LevelDegree
local UILevelItem = require("UI/Item/LamiaLevel/UIDalcaroItem")
local Dalcaro_DialogueMain_cut = "Dalcaro_DialogueMain_cut"

function Form_Activity102Dalcaro_DialogueMain:SetInitParam(param)
end

function Form_Activity102Dalcaro_DialogueMain:AfterInit()
  self.super.AfterInit(self)
  local initGridData = {
    itemClkBackFun = handler(self, self.OnItemClick)
  }
  self.m_luaextensionInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scroll_extension_InfinityGrid, "LamiaLevel/UIDalcaroItem", initGridData)
  self.itemCom = UILevelItem.new(nil, self.m_item_choose, nil, nil, 1)
end

function Form_Activity102Dalcaro_DialogueMain:OnActive()
  self.super.OnActive(self)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(123)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(115)
end

function Form_Activity102Dalcaro_DialogueMain:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity102Dalcaro_DialogueMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity102Dalcaro_DialogueMain:FreshUI()
  self.super.FreshUI(self)
  self:FreshDegreeLevelList()
  self:FreshLevelTab(self.m_curDegreeIndex)
end

function Form_Activity102Dalcaro_DialogueMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("LevelDetailDalcaroSubPanel", self.m_level_detail_root, self, {
        bgBackFun = handler(self, self.OnLevelDetailBgClick)
      }, {
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      }, function(luaPanel)
        self.m_luaDetailLevel = luaPanel
        self.m_luaDetailLevel:AddEventListeners()
      end)
    else
      self.m_luaDetailLevel:FreshData({
        activityID = self.m_activityID,
        levelID = self.m_curDetailLevelID
      })
    end
    UILuaHelper.SetActive(self.m_button_extension_choose, true)
    self:FreshChooseItemNode()
    GlobalManagerIns:TriggerWwiseBGMState(95)
  else
    TimeService:SetTimer(0.2, 1, function()
      if utils.isNull(self.m_level_detail_root) then
        return
      end
      UILuaHelper.SetActive(self.m_level_detail_root, false)
      if utils.isNull(self.m_button_extension_choose) then
        return
      end
      UILuaHelper.SetActive(self.m_button_extension_choose, false)
    end)
    GlobalManagerIns:TriggerWwiseBGMState(96)
  end
end

function Form_Activity102Dalcaro_DialogueMain:FreshChooseItemNode()
  if not self.m_curDetailLevelID then
    return
  end
  if not self.m_curDegreeIndex then
    return
  end
  local chooseItemIndex = self:GetLevelIndexByLevelID(self.m_curDegreeIndex, self.m_curDetailLevelID)
  if not chooseItemIndex then
    return
  end
  local itemData = self.DegreeCfgTab[self.m_curDegreeIndex].levelList[chooseItemIndex]
  if not itemData then
    return
  end
  self.itemCom:FreshData(itemData, chooseItemIndex)
end

function Form_Activity102Dalcaro_DialogueMain:OnBtnNormalClicked()
  if self.m_curDegreeIndex == LevelDegree.Normal then
    return
  end
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  TimeService:SetTimer(aniLen, 1, function()
    self:FreshLevelTab(LevelDegree.Normal)
  end)
end

function Form_Activity102Dalcaro_DialogueMain:OnBtnHardClicked()
  if self.m_curDegreeIndex == LevelDegree.Hard then
    return
  end
  if self.m_isHarLock then
    local clientMsgStr = ConfigManager:GetClientMessageTextById(40039)
    clientMsgStr = string.CS_Format(clientMsgStr, self:GetHardLevelUnlockStr(), self:GetHardTimeUnlockStr())
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, clientMsgStr)
    return
  end
  LevelHeroLamiaActivityManager:SetActivitySubEnter(self.DegreeCfgTab[LevelDegree.Hard].activitySubID)
  local aniLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, Dalcaro_DialogueMain_cut)
  TimeService:SetTimer(aniLen, 1, function()
    self:FreshLevelTab(LevelDegree.Hard)
  end)
  LocalDataManager:SetIntSimple("HeroActDialogueMainHardEntry" .. self.m_activityID, 1, true)
  self.m_hard_new:SetActive(false)
end

function Form_Activity102Dalcaro_DialogueMain:OnBtnbuffheroClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_BUFFHEROLIST, {
    activityID = self.m_activityID
  })
end

function Form_Activity102Dalcaro_DialogueMain:OnBtnCollectClicked()
  if not self.m_activityID then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY102DALCARO_DIALOGUECOLLECTION, {
    activityID = self.m_activityID,
    activitySubID = self.DegreeCfgTab[LevelDegree.Normal].activitySubID
  })
end

local fullscreen = true
ActiveLuaUI("Form_Activity102Dalcaro_DialogueMain", Form_Activity102Dalcaro_DialogueMain)
return Form_Activity102Dalcaro_DialogueMain
