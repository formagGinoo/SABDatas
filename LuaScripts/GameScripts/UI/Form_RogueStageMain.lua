local Form_RogueStageMain = class("Form_RogueStageMain", require("UI/UIFrames/Form_RogueStageMainUI"))
local CliveActivityTipsItem = require("UI/Item/HeroActivity/CliveActivityTipsItem")
local __MaxTower = 5
local __Roguestagemain_up = "Roguestagemain_up"
local __Roguestagemain_down = "Roguestagemain_down"
local __Roguestagemain_ui_out = "Roguestagemain_ui_out"
local __Roguestagemain_ui_in = "Roguestagemain_ui_in"
local __CliveActivityTip_ui_out = "clive_tips_out"
local __CliveActivityTip_ui_in = "clive_tips_in"
local __Roguestagemain_leftTab = {
  "Roguestagemain_left1",
  "Roguestagemain_left2",
  "Roguestagemain_left3"
}
local __Roguestagemain_leftOutTab = {
  "Roguestagemaout_left1",
  "Roguestagemaout_left2",
  "Roguestagemaout_left3"
}

function Form_RogueStageMain:SetInitParam(param)
end

function Form_RogueStageMain:AfterInit()
  self.super.AfterInit(self)
  self.m_widgetBtnBack = self:createBackButton(self.m_common_top_back, handler(self, self.OnBackClk), nil, handler(self, self.OnBackHome), 1201)
  self.m_towerItemList = {}
  for i = 1, 3 do
    local pnl_content = self["m_pnl_toweritem" .. i].transform:Find("pnl_content")
    local icon_unlock_tran = pnl_content:Find("c_img_icon_unlock")
    local icon_unlock = pnl_content:Find("c_img_icon_unlock"):GetComponent(T_Image)
    local icon_normal_tran = pnl_content:Find("c_img_icon_normal")
    local icon_normal = pnl_content:Find("c_img_icon_normal"):GetComponent(T_Image)
    local icon_normal_add_tran = pnl_content:Find("c_img_icon_normal/c_img_icon_normal_add")
    local icon_normal_add = pnl_content:Find("c_img_icon_normal/c_img_icon_normal_add"):GetComponent(T_Image)
    local fight_obj = pnl_content:Find("c_img_figtht").gameObject
    local new_obj = pnl_content:Find("c_icon_new").gameObject
    local new_fx_obj = pnl_content:Find("c_new").gameObject
    local chose_obj = pnl_content:Find("c_btn_chosse").gameObject
    local tower_key_num_Text = pnl_content:Find("pnl_bottom_box/c_tower_key_num"):GetComponent(T_TextMeshProUGUI)
    local point_root_obj = pnl_content:Find("pnl_bottom_box/pnl_stage_point").gameObject
    local red_point = pnl_content:Find("pnl_bottom_box/txt_tower_key_num/c_lv_redpoint").gameObject
    local pointNode = {}
    for m = 1, 5 do
      pointNode[m] = {}
      pointNode[m]["point" .. m] = pnl_content:Find("pnl_bottom_box/pnl_stage_point/c_pnl_point" .. m).gameObject
      pointNode[m]["point_slider" .. m] = pnl_content:Find("pnl_bottom_box/pnl_stage_point/c_pnl_point" .. m .. "/" .. "c_point_slider" .. m):GetComponent(T_Image)
      pointNode[m]["point_finish" .. m] = pnl_content:Find("pnl_bottom_box/pnl_stage_point/c_pnl_point" .. m .. "/" .. "c_point_finish" .. m).gameObject
    end
    self.m_towerItemList[i] = {}
    self.m_towerItemList[i].root = self["m_pnl_toweritem" .. i]
    self.m_towerItemList[i].icon_unlock_obj = icon_unlock_tran.gameObject
    self.m_towerItemList[i].icon_unlock = icon_unlock
    self.m_towerItemList[i].icon_normal_obj = icon_normal_tran.gameObject
    self.m_towerItemList[i].icon_normal = icon_normal
    self.m_towerItemList[i].icon_normal_add_obj = icon_normal_add_tran.gameObject
    self.m_towerItemList[i].icon_normal_add = icon_normal_add
    self.m_towerItemList[i].fight_obj = fight_obj
    self.m_towerItemList[i].new_obj = new_obj
    self.m_towerItemList[i].chose_obj = chose_obj
    self.m_towerItemList[i].tower_key_num_Text = tower_key_num_Text
    self.m_towerItemList[i].point_root_obj = point_root_obj
    self.m_towerItemList[i].pointNode = pointNode
    self.m_towerItemList[i].new_fx_obj = new_fx_obj
    self.m_towerItemList[i].red_point = red_point
  end
  self:RegisterRedDot()
  self.m_rogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  self.cliveActivityTip = CliveActivityTipsItem:CreateCliveActivityTipsItem(self.m_panel_tips, {tipType = 2, cliveType = 1})
end

function Form_RogueStageMain:OnActive()
  self.super.OnActive(self)
  self.m_curChapterIndex = self.m_rogueStageHelper:GetCurChapterId() or 1
  self.m_stageChapterCfgTab = self.m_rogueStageHelper:GetRogueStageChapterCfg()
  self.m_maxChapter = table.getn(self.m_stageChapterCfgTab)
  self.m_curStageIndex = self:GetCurStageIndex()
  if table.getn(self.m_stageChapterCfgTab) == 0 then
    log.error("RogueStage ChapterCfg is nil !!!")
    return
  end
  self:StopTimer()
  self:RefreshUI()
  RogueStageManager:ResetRogueBagData()
  self:AddEventListeners()
  self.cliveActivityTip:OnFreshData()
end

function Form_RogueStageMain:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:StopTimer()
end

function Form_RogueStageMain:StopTimer()
  if self.m_detailOutTimer then
    TimeService:KillTimer(self.m_detailOutTimer)
    self.m_detailOutTimer = nil
  end
  if self.m_chapterClickTimer then
    TimeService:KillTimer(self.m_chapterClickTimer)
    self.m_chapterClickTimer = nil
  end
end

function Form_RogueStageMain:AddEventListeners()
  self:addEventListener("eGameEvent_RogueStage_TakeReward", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Activity_FullBurstDayUpdate", handler(self, self.OnFullBurstDayUpdate))
end

function Form_RogueStageMain:OnFullBurstDayUpdate()
  self.m_doublereward:SetActive(ActivityManager:IsFullBurstDayOpen())
end

function Form_RogueStageMain:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_RogueStageMain:RegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_book_redpoint, RedDotDefine.ModuleType.RogueHandBookEntry)
  self:RegisterOrUpdateRedDotItem(self.m_achievement_redpoint, RedDotDefine.ModuleType.RogueAchievementEntry)
  self:RegisterOrUpdateRedDotItem(self.m_img_key_bk, RedDotDefine.ModuleType.RogueRewardEntry)
  self:RegisterOrUpdateRedDotItem(self.m_develop_redpoint, RedDotDefine.ModuleType.RogueTechEntry)
end

function Form_RogueStageMain:RefreshUI()
  UILuaHelper.SetActive(self.m_level_detail_root, false)
  local curLevel = self.m_rogueStageHelper:GetDailyRewardLevel()
  self.m_key_num_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100074), curLevel)
  self:RefreshSmallTowerState()
  self:RefreshWindowUI()
  self:OnFullBurstDayUpdate()
  UILuaHelper.SetActive(self.m_img_key_bk_gary, not self.m_rogueStageHelper:IsHaveRewards())
end

function Form_RogueStageMain:GetCurStageIndex()
  local curStage = self.m_rogueStageHelper:GetCurStageId()
  for i = 1, 3 do
    if self.m_stageChapterCfgTab[self.m_curChapterIndex] and self.m_stageChapterCfgTab[self.m_curChapterIndex][i] then
      local cfg = self.m_stageChapterCfgTab[self.m_curChapterIndex][i]
      if cfg.m_StageId == curStage then
        return i
      end
    end
  end
  return 1
end

function Form_RogueStageMain:RefreshWindowUI()
  local curStage = self.m_rogueStageHelper:GetFightingStageID()
  local chapterId = self.m_curChapterIndex
  local curChapterId = self.m_rogueStageHelper:GetCurChapterId()
  for i = 1, 3 do
    local cfg = self.m_stageChapterCfgTab[chapterId][i]
    if cfg and self.m_rogueStageHelper:IsLevelUnLock(cfg.m_StageId) then
      UILuaHelper.SetActive(self.m_towerItemList[i].icon_unlock_obj, false)
      UILuaHelper.SetActive(self.m_towerItemList[i].icon_normal_obj, true)
      UILuaHelper.SetAtlasSprite(self.m_towerItemList[i].icon_normal, cfg.m_StagePic)
      UILuaHelper.SetAtlasSprite(self.m_towerItemList[i].icon_normal_add, cfg.m_StagePic)
      UILuaHelper.SetActive(self.m_towerItemList[i].fight_obj, curStage == cfg.m_StageId)
      UILuaHelper.SetActive(self.m_towerItemList[i].point_root_obj, curStage == cfg.m_StageId)
      local isPass = self.m_rogueStageHelper:IsLevelHavePass(cfg.m_StageId)
      UILuaHelper.SetActive(self.m_towerItemList[i].new_obj, not isPass)
      UILuaHelper.SetActive(self.m_towerItemList[i].new_fx_obj, not isPass)
      UILuaHelper.SetActive(self.m_towerItemList[i].icon_normal_add_obj, not isPass)
      if curStage == cfg.m_StageId then
        self:RefreshPointUI(i, cfg.m_StageId)
      end
      if not isPass then
        self:ChangeChooseImgColor(self.m_towerItemList[i].new_fx_obj)
        RogueStageManager:SetNewStageRedPointFlag(cfg.m_StageId)
      end
      if chapterId == curChapterId and self.m_curStageIndex == i and RogueStageManager:CheckDailyRedPoint() > 0 then
        UILuaHelper.SetActive(self.m_towerItemList[i].red_point, true)
      else
        UILuaHelper.SetActive(self.m_towerItemList[i].red_point, false)
      end
    else
      UILuaHelper.SetActive(self.m_towerItemList[i].icon_unlock_obj, true)
      UILuaHelper.SetActive(self.m_towerItemList[i].icon_normal_obj, false)
      UILuaHelper.SetActive(self.m_towerItemList[i].icon_normal_add_obj, false)
      UILuaHelper.SetAtlasSprite(self.m_towerItemList[i].icon_unlock, cfg.m_StagePic)
      UILuaHelper.SetActive(self.m_towerItemList[i].fight_obj, false)
      UILuaHelper.SetActive(self.m_towerItemList[i].new_obj, false)
      UILuaHelper.SetActive(self.m_towerItemList[i].point_root_obj, false)
      UILuaHelper.SetActive(self.m_towerItemList[i].new_fx_obj, false)
      UILuaHelper.SetActive(self.m_towerItemList[i].red_point, false)
    end
    UILuaHelper.SetActive(self.m_towerItemList[i].chose_obj, false)
    local _, min, max = self.m_rogueStageHelper:GetRogueStageRewardMaxGearByRewardId(cfg.m_Reward)
    if max and min then
      self.m_towerItemList[i].tower_key_num_Text.text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100710), min, max)
    end
  end
  local cfg = self.m_stageChapterCfgTab[chapterId][1]
  if cfg then
    local ornamentPic = utils.changeCSArrayToLuaTable(cfg.m_OrnamentPic)
    if ornamentPic and ornamentPic[1] then
      UILuaHelper.SetAtlasSprite(self.m_img_icon_l_Image, ornamentPic[1])
      UILuaHelper.SetAtlasSprite(self.m_img_icon_r_Image, ornamentPic[2])
    end
  end
end

function Form_RogueStageMain:ChangeChooseImgColor(rootObj)
  local img_chosse = rootObj.transform:Find("c_img_chosse")
  if not utils.isNull(img_chosse) then
    local multiColorChange = img_chosse:GetComponent("MultiColorChange")
    multiColorChange:SetColorByIndex(self.m_curChapterIndex - 1)
  end
  for i = 1, 5 do
    local img_choose = rootObj.transform:Find("c_img_chosse" .. i)
    if not utils.isNull(img_choose) then
      local multiColorChange = img_choose:GetComponent("MultiColorChange")
      multiColorChange:SetColorByIndex(self.m_curChapterIndex - 1)
    end
  end
end

function Form_RogueStageMain:ChangeSelectObjState()
  for i = 1, 3 do
    if self.m_towerItemList[i] then
      UILuaHelper.SetActive(self.m_towerItemList[i].chose_obj, i == self.m_curStageIndex)
    end
  end
end

function Form_RogueStageMain:RefreshPointUI(stageIndex, stageId)
  local gear = self.m_rogueStageHelper:GetStageGearShowDataByStageId(stageId)
  local maxGear = self.m_rogueStageHelper:GetStageRewardMaxGear(stageId)
  if self.m_towerItemList[stageIndex] and self.m_towerItemList[stageIndex].pointNode then
    local pointNode = self.m_towerItemList[stageIndex].pointNode
    for i = 1, 5 do
      if pointNode[i] then
        pointNode[i]["point" .. i]:SetActive(i <= maxGear)
        pointNode[i]["point_finish" .. i]:SetActive(i <= gear)
        pointNode[i]["point_slider" .. i].fillAmount = i < gear and 1 or 0
        if i == gear then
          UILuaHelper.PlayAnimationByName(pointNode[i]["point_finish" .. i], "Roguemain_point_loop")
        end
      end
    end
  end
end

function Form_RogueStageMain:RefreshSmallTowerState()
  for i = 1, __MaxTower do
    if self.m_stageChapterCfgTab[i] then
      local cfg = self.m_stageChapterCfgTab[i][1]
      if cfg and self.m_rogueStageHelper:IsLevelUnLock(cfg.m_StageId) then
        self["m_img_tower_unlock" .. i]:SetActive(true)
      else
        self["m_img_tower_unlock" .. i]:SetActive(false)
      end
    else
      self["m_img_tower_unlock" .. i]:SetActive(false)
    end
  end
  self:RefreshTowerPoint()
end

function Form_RogueStageMain:RefreshTowerPoint()
  UILuaHelper.SetParent(self.m_btn_tower_arrow, self["m_img_tower_touch" .. self.m_curChapterIndex], true)
  UILuaHelper.SetActive(self.m_btn_Last, self.m_curChapterIndex ~= 1)
  UILuaHelper.SetActive(self.m_btn_next, self.m_curChapterIndex ~= 5)
end

function Form_RogueStageMain:FreshLevelDetailShow()
  if self.m_curDetailLevelID then
    UILuaHelper.SetActive(self.m_level_detail_root, true)
    if self.m_luaDetailLevel == nil then
      self:CreateSubPanel("RogueStageDetailSubPanel", self.m_level_detail_root, self, {
        bgBackFun = handler(self, self.OnLevelDetailBgClick)
      }, {
        levelType = RogueStageManager.BattleType,
        levelID = self.m_curDetailLevelID
      }, function(luaPanel)
        self.m_luaDetailLevel = luaPanel
        self.m_luaDetailLevel:AddEventListeners()
      end)
    else
      self.m_luaDetailLevel:FreshData({
        levelType = RogueStageManager.BattleType,
        levelID = self.m_curDetailLevelID
      })
    end
  else
    UILuaHelper.SetActive(self.m_level_detail_root, false)
  end
end

function Form_RogueStageMain:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_RogueStageMain:IsFullScreen()
  return false
end

function Form_RogueStageMain:OnBtndevelopClicked()
  StackFlow:Push(UIDefines.ID_FORM_ROGUETALENTTREE)
end

function Form_RogueStageMain:OnBtnachievementClicked()
  StackFlow:Push(UIDefines.ID_FORM_ROGUEACHIEVEMENT)
end

function Form_RogueStageMain:OnBtnbookClicked()
  StackFlow:Push(UIDefines.ID_FORM_ROGUEHANDBOOK)
end

function Form_RogueStageMain:OnBtnboxClicked()
  StackFlow:Push(UIDefines.ID_FORM_ROGUEREWARD)
end

function Form_RogueStageMain:OnPnltoweritem1Clicked()
  self.m_curStageIndex = 1
  self:OnClickedStage()
end

function Form_RogueStageMain:OnPnltoweritem2Clicked()
  self.m_curStageIndex = 2
  self:OnClickedStage()
end

function Form_RogueStageMain:OnPnltoweritem3Clicked()
  self.m_curStageIndex = 3
  self:OnClickedStage()
end

function Form_RogueStageMain:OnRogueStagePanelOut()
  if __Roguestagemain_leftOutTab[self.m_curStageIndex] then
    UILuaHelper.PlayAnimationByName(self.m_pnl_bk, __Roguestagemain_leftOutTab[self.m_curStageIndex])
  end
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, __Roguestagemain_ui_in)
  if self.cliveActivityTip then
    UILuaHelper.PlayAnimationByName(self.m_panel_tips, __CliveActivityTip_ui_in)
  end
end

function Form_RogueStageMain:OnChangeStageRefreshUI()
  if not self.m_MoveFlag then
    local sequence = Tweening.DOTween.Sequence()
    sequence:AppendInterval(0.3)
    sequence:OnComplete(function()
      if self and self.RefreshTowerPoint then
        self:RefreshTowerPoint()
        self:RefreshWindowUI()
        self.m_MoveFlag = false
      end
    end)
    sequence:SetAutoKill(true)
  end
  self.m_MoveFlag = true
end

function Form_RogueStageMain:OnBtnLastClicked()
  if self.m_chapterClickTimer then
    return
  end
  self:OnChangeChapterClickTimer()
  if self.m_curChapterIndex == 1 then
    return
  end
  self.m_curChapterIndex = self.m_curChapterIndex - 1
  UILuaHelper.PlayAnimationByName(self.m_pnl_bk, __Roguestagemain_up)
  self:OnChangeStageRefreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(261)
end

function Form_RogueStageMain:OnBtnnextClicked()
  if self.m_chapterClickTimer then
    return
  end
  self:OnChangeChapterClickTimer()
  if self.m_maxChapter == self.m_curChapterIndex then
    if __MaxTower > self.m_maxChapter then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(53002))
    end
    return
  end
  self.m_curChapterIndex = self.m_curChapterIndex + 1
  UILuaHelper.PlayAnimationByName(self.m_pnl_bk, __Roguestagemain_down)
  self:OnChangeStageRefreshUI()
  GlobalManagerIns:TriggerWwiseBGMState(261)
end

function Form_RogueStageMain:OnClickedStage()
  if __Roguestagemain_leftTab[self.m_curStageIndex] then
    UILuaHelper.PlayAnimationByName(self.m_pnl_bk, __Roguestagemain_leftTab[self.m_curStageIndex])
  end
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, __Roguestagemain_ui_out)
  if self.m_stageChapterCfgTab[self.m_curChapterIndex] and self.m_stageChapterCfgTab[self.m_curChapterIndex][self.m_curStageIndex] then
    self.m_curDetailLevelID = self.m_stageChapterCfgTab[self.m_curChapterIndex][self.m_curStageIndex].m_StageId
  end
  self:ChangeSelectObjState()
  if self.m_curDetailLevelID then
    self:FreshLevelDetailShow()
  end
  if self.cliveActivityTip then
    UILuaHelper.PlayAnimationByName(self.m_panel_tips, __CliveActivityTip_ui_out)
  end
end

function Form_RogueStageMain:OnChangeChapterClickTimer()
  if self.m_chapterClickTimer then
    TimeService:KillTimer(self.m_chapterClickTimer)
    self.m_chapterClickTimer = nil
  end
  self.m_chapterClickTimer = TimeService:SetTimer(1, 1, function()
    self.m_chapterClickTimer = nil
  end)
end

function Form_RogueStageMain:OnLevelDetailBgClick()
  if self.m_curDetailLevelID then
    self.m_curDetailLevelID = nil
    self:OnRogueStagePanelOut()
    self:StopTimer()
    self.m_detailOutTimer = TimeService:SetTimer(0.2, 1, function()
      self:FreshLevelDetailShow()
      self.m_detailOutTimer = nil
    end)
    GlobalManagerIns:TriggerWwiseBGMState(31)
  end
end

function Form_RogueStageMain:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:Push(UIDefines.ID_FORM_HALLACTIVITYMAIN)
  self:CloseForm()
end

function Form_RogueStageMain:OnBackHome()
  StackFlow:PopAllAndReplace(UIDefines.ID_FORM_HALL)
  GameSceneManager:CheckChangeSceneToMainCity(nil, true)
end

function Form_RogueStageMain:OnPnlClivebigClicked()
  self.cliveActivityTip:OnClick()
end

function Form_RogueStageMain:GetDownloadResourceExtra(tParam)
  local vSubPanelName = {
    "RogueStageDetailSubPanel"
  }
  local vPackage = {}
  local vResourceExtra = {}
  for _, sSubPanelName in pairs(vSubPanelName) do
    local vPackageSub, vResourceExtraSub = SubPanelManager:GetSubPanelDownloadResourceExtra(sSubPanelName)
    if vPackageSub ~= nil then
      for i = 1, #vPackageSub do
        vPackage[#vPackage + 1] = vPackageSub[i]
      end
    end
    if vResourceExtraSub ~= nil then
      for i = 1, #vResourceExtraSub do
        vResourceExtra[#vResourceExtra + 1] = vResourceExtraSub[i]
      end
    end
  end
  return vPackage, vResourceExtra
end

function Form_RogueStageMain:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_RogueStageMain", Form_RogueStageMain)
return Form_RogueStageMain
