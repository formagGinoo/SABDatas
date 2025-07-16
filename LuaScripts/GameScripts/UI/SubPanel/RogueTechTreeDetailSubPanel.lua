local UISubPanelBase = require("UI/Common/UISubPanelBase")
local RogueTechTreeDetailSubPanel = class("RogueTechTreeDetailSubPanel", UISubPanelBase)
local EnterAnimStr = "level_detail_in"
local OutAnimStr = "level_detail_out"

function RogueTechTreeDetailSubPanel:OnInit()
  if self.m_initData then
    self.m_bgClkBack = self.m_initData.bgBackFun
  end
  self.m_levelRogueStageHelper = RogueStageManager:GetLevelRogueStageHelper()
  UILuaHelper.SetActive(self.m_btn_detail_bg, self.m_bgClkBack ~= nil)
  UILuaHelper.SetCanvasGroupAlpha(self.m_panel_detail, 0)
  self.m_treeCfg = nil
  self:InitUI()
end

function RogueTechTreeDetailSubPanel:OnFreshData()
  self.m_treeCfg = self.m_panelData.showTreeCfg
  self:FreshBaseInfo()
  self:FreshStatusShow()
  self:CheckShowAnimIn()
  GlobalManagerIns:TriggerWwiseBGMState(255)
end

function RogueTechTreeDetailSubPanel:AddEventListeners()
  self:addEventListener("eGameEvent_RogueStage_ActiveTreeNode", handler(self, self.OnActiveTreeNodeBack))
end

function RogueTechTreeDetailSubPanel:RemoveAllEventListeners()
  self:clearEventListener()
end

function RogueTechTreeDetailSubPanel:OnActiveTreeNodeBack(param)
  if not param then
    return
  end
  if not self.m_treeCfg then
    return
  end
  local activeID = param.techID
  if self.m_treeCfg.m_TechID ~= activeID then
    return
  end
  self:FreshBaseInfo()
  self:FreshStatusShow()
end

function RogueTechTreeDetailSubPanel:OnDestroy()
  RogueTechTreeDetailSubPanel.super.OnDestroy(self)
  if self.m_detailOutTimer ~= nil then
    TimeService:KillTimer(self.m_detailOutTimer)
    self.m_detailOutTimer = nil
  end
end

function RogueTechTreeDetailSubPanel:InitUI()
  self.m_img_icon_circle = self.m_img_icon:GetComponent("CircleImage")
end

function RogueTechTreeDetailSubPanel:FreshBaseInfo()
  if not self.m_treeCfg then
    return
  end
  UILuaHelper.SetBaseImageAtlasSprite(self.m_img_icon_circle, self.m_treeCfg.m_TechPic)
  local isAct = self.m_levelRogueStageHelper:IsTechNodeActive(self.m_treeCfg.m_TechID)
  UILuaHelper.SetActive(self.m_img_bg_unactivated, isAct ~= true)
  UILuaHelper.SetActive(self.m_img_bg_activated, isAct == true)
  self.m_txt_skilldes_Text.text = self.m_treeCfg.m_mTechDesc
  self.m_txt_skillname_Text.text = self.m_treeCfg.m_mTechName
end

function RogueTechTreeDetailSubPanel:FreshStatusShow()
  if not self.m_treeCfg then
    return
  end
  local techID = self.m_treeCfg.m_TechID
  local isActive, unActAtr = self.m_levelRogueStageHelper:IsTechNodeActive(techID)
  local isMathCondition, unMathStr = self.m_levelRogueStageHelper:IsTechNodePreConditionMatch(techID)
  UILuaHelper.SetActive(self.m_pnl_btn, not isActive and isMathCondition)
  UILuaHelper.SetActive(self.m_z_txt_activated, isActive)
  UILuaHelper.SetActive(self.m_pnl_unactivated, not isActive and not isMathCondition)
  if not isActive and isMathCondition then
    local costArray = self.m_treeCfg.m_Cost
    local costTabList = utils.changeCSArrayToLuaTable(costArray)
    local costID = costTabList[1][1]
    local costNum = costTabList[1][2]
    local curHaveNum = ItemManager:GetItemNum(costID)
    local iconPath = ItemManager:GetItemIconPathByID(costID)
    UILuaHelper.SetAtlasSprite(self.m_cost_icon_Image, iconPath)
    self.m_txt_itemcost_Text.text = costNum
    UILuaHelper.SetColorByMultiIndex(self.m_txt_itemcost, costNum <= curHaveNum and 0 or 1)
    UILuaHelper.SetActive(self.m_btn_Sure, costNum <= curHaveNum)
    UILuaHelper.SetActive(self.m_btn_Not_Sure, costNum > curHaveNum)
    if costNum > curHaveNum then
      self.m_costNoHaveStr = unActAtr
    end
    self.m_costID = costID
    self.m_costNum = costNum
  end
  if not isActive and not isMathCondition then
    self.m_z_txt_unactivated_Text.text = unMathStr
  end
end

function RogueTechTreeDetailSubPanel:CheckShowAnimIn()
  if self.m_levelType == LevelManager.LevelType.Tower then
    return
  end
  UILuaHelper.PlayAnimationByName(self.m_panel_detail, EnterAnimStr)
end

function RogueTechTreeDetailSubPanel:CheckShowAnimOut(endFun)
  if self.m_detailOutTimer ~= nil then
    return
  end
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_panel_detail, EnterAnimStr)
  UILuaHelper.PlayAnimationByName(self.m_panel_detail, OutAnimStr)
  self.m_detailOutTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    if endFun then
      endFun()
    end
    self.m_detailOutTimer = nil
  end)
end

function RogueTechTreeDetailSubPanel:OnBtndetailbgClicked()
  self:CheckShowAnimOut(function()
    if self.m_bgClkBack then
      self.m_bgClkBack()
    end
  end)
end

function RogueTechTreeDetailSubPanel:OnBtnSureClicked()
  if not self.m_treeCfg then
    return
  end
  RogueStageManager:ReqRogueUnlockTech(self.m_treeCfg.m_TechID)
end

function RogueTechTreeDetailSubPanel:OnBtnNotSureClicked()
  if not self.m_treeCfg then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_COMMON_TOAST, 53001)
end

function RogueTechTreeDetailSubPanel:OnCosticonClicked()
  if self.m_costID and self.m_costNum then
    utils.openItemDetailPop({
      iID = self.m_costID,
      iNum = self.m_costNum
    })
  end
end

return RogueTechTreeDetailSubPanel
