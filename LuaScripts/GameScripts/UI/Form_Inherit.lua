local Form_Inherit = class("Form_Inherit", require("UI/UIFrames/Form_InheritUI"))
local GlobalCfgIns = ConfigManager:GetConfigInsByName("GlobalSettings")
local INHERIT_SYNC_GRIDS = tonumber(GlobalCfgIns:GetValue_ByName("InheritGrids").m_Value) or 100
local INHERIT_SYNC_UNLOCK_COST = GlobalCfgIns:GetValue_ByName("InheritUnlockCost").m_Value or ""
local INHERIT_SYNC_RESET_COST = GlobalCfgIns:GetValue_ByName("InheritResetCost").m_Value or ""
local INHERIT_SYNC_CD = tonumber(GlobalCfgIns:GetValue_ByName("InheritCD").m_Value) or 0

function Form_Inherit:SetInitParam(param)
end

function Form_Inherit:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local resourceBarRoot = self.m_rootTrans:Find("content_node/ui_common_top_resource").gameObject
  self.m_widgetResourceBar = self:createResourceBar(resourceBarRoot)
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil, nil, 1107)
  self.m_InheritListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_scrollView_InfinityGrid, "Inherit/UIInheritItem")
  self.m_InheritListInfinityGrid:RegisterButtonCallback("c_btn_empty", handler(self, self.OnEmptyItemClk))
  self.m_InheritListInfinityGrid:RegisterButtonCallback("c_btn_lock", handler(self, self.OnLockBtnClk))
  self.m_InheritListInfinityGrid:RegisterButtonCallback("c_btnClick", handler(self, self.OnHeroItemClk))
  self.m_inherit_lv = 0
  self.m_unlockPosNum = 5
  self.m_maxSlotNum = tonumber(INHERIT_SYNC_GRIDS)
  self.m_topFiveList = {}
  self.m_inheritList = {}
  self.m_otherHeroList = {}
  self.m_inheritCellList = {}
end

function Form_Inherit:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:RefreshUI()
  if self.m_InheritListInfinityGrid then
    self.m_InheritListInfinityGrid:LocateTo(0)
  end
end

function Form_Inherit:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self.m_evoTimer = nil
end

function Form_Inherit:OnUpdate(dt)
  self.m_InheritListInfinityGrid:OnUpdate(dt)
end

function Form_Inherit:AddEventListeners()
  self:addEventListener("eGameEvent_Inherit_Change", handler(self, self.RefreshUI))
  self:addEventListener("eGameEvent_Inherit_Evolve", handler(self, self.OnEvolveSuccess))
  self:addEventListener("eGameEvent_Inherit_EvolveClose", handler(self, self.OnEvolveSuccessClose))
end

function Form_Inherit:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_Inherit:RefreshUI()
  self.m_topFiveList = InheritManager:GetTopFiveHero()
  self.m_inherit_lv = InheritManager:GetInheritLevel()
  self.m_inheritList = InheritManager:GetInheritList()
  self.m_otherHeroList = InheritManager:GetListOfInheritableHeroes()
  local isEvo = InheritManager:GetInheritIsEvo()
  for i = 1, 5 do
    if self.m_topFiveList[i] then
      local characterCfg = self.m_topFiveList[i].characterCfg
      local serverData = self.m_topFiveList[i].serverData
      ResourceUtil:CreateHeroHeadIcon(self["m_img_head" .. i .. "_Image"], characterCfg.m_HeroID, serverData.iStar)
      self["m_txt_lv" .. i .. "_Text"].text = tostring(serverData.iLevel)
      self["m_img_bghero_done" .. i]:SetActive(isEvo)
      self["m_bg_lv_done" .. i]:SetActive(isEvo)
    end
  end
  self.m_txt_lv_maxnum_Text.text = tostring(self.m_inherit_lv)
  self.m_txt_num_Text.text = string.format(ConfigManager:GetCommonTextById(20015), InheritManager:GetIsHaveHeroGridsNum(), InheritManager:GetIsOpenGridsNum())
  local btnStr = InheritManager:GetInheritIsEvo() == true and ConfigManager:GetCommonTextById(1302) or ConfigManager:GetCommonTextById(1301)
  self.m_txt_m_btn_uplv_Text.text = btnStr
  self:refreshInheritLoopScroll()
  self:RefreshEvoUI()
end

function Form_Inherit:RefreshEvoUI()
  local isEvo = InheritManager:GetInheritIsEvo()
  local beginEvoLv = InheritManager:GetInheritEvoBeginLevel()
  self.m_inheritMaxLv = InheritManager:GetInheritMaxLv()
  self.m_btn_uplv_undo:SetActive(beginEvoLv > self.m_inherit_lv or self.m_inherit_lv == self.m_inheritMaxLv and isEvo)
  self.m_btn_uplv:SetActive(beginEvoLv <= self.m_inherit_lv and self.m_inherit_lv < self.m_inheritMaxLv and isEvo or self.m_inherit_lv == beginEvoLv and not isEvo)
  self.m_pnl_lv_limit:SetActive(beginEvoLv <= self.m_inherit_lv and isEvo)
  self.m_img_blood5:SetActive(not isEvo)
  self.m_pnl_tree_undo:SetActive(not isEvo)
  self.m_pnl_tree_done:SetActive(isEvo)
  self.m_pnl_ball_undo:SetActive(not isEvo and beginEvoLv > self.m_inherit_lv)
  self.m_pnl_ball_already:SetActive(not isEvo and self.m_inherit_lv == beginEvoLv)
  self.m_pnl_ball_done:SetActive(isEvo)
  self.m_txt_lv_limit_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(3001), self.m_inheritMaxLv)
  local str = not isEvo and ConfigManager:GetCommonTextById(1301) or ConfigManager:GetCommonTextById(1302)
  self.m_txt_m_btn_uplv_undo_Text.text = str
end

function Form_Inherit:refreshInheritLoopScroll()
  self.m_inheritCellList = self:GetInheritCellList()
  self.m_InheritListInfinityGrid:ShowItemList(self.m_inheritCellList)
end

function Form_Inherit:GotoLevelUp(index)
  local heroData = self.m_topFiveList[index]
  StackFlow:Push(UIDefines.ID_FORM_HEROUPGRADE, {
    heroDataList = {heroData},
    heroID = heroData.serverData.iHeroId,
    closeBackFun = function(backHeroID)
      self:RefreshUI()
    end
  })
end

function Form_Inherit:GetInheritCellList()
  local starEffectMap = StargazingManager:GetCastleStarTechEffectByType(StargazingManager.CastleStarEffectType.Inherit)
  local extNum = starEffectMap[StargazingManager.CastleStarEffectType.Inherit] or 0
  local next = InheritManager:GetIsOpenGridsNum() + 1
  local num = #self.m_inheritList + 2
  if 0 < num % 8 then
    num = num + (8 - num % 8)
  end
  num = math.min(num, self.m_maxSlotNum + extNum)
  num = math.max(num, 40)
  local inheritList = {}
  for i = 1, num do
    local info = self.m_inheritList[i]
    if info then
      inheritList[i] = info
    elseif next == i then
      inheritList[i] = {
        iHeroId = 0,
        iCdTime = 0,
        isLock = true,
        showNext = true
      }
    else
      inheritList[i] = {
        iHeroId = 0,
        iCdTime = 0,
        isLock = true
      }
    end
  end
  return inheritList
end

function Form_Inherit:OnHeroItemClk(index, go)
  log.error("OnHeroItemClk ---" .. index)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
end

function Form_Inherit:OnEmptyItemClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex or not self.m_inheritList[fjItemIndex] then
    return
  end
  local iCdTime = self.m_inheritList[fjItemIndex].iCdTime
  local cdTime = tonumber(INHERIT_SYNC_CD) - (TimeUtil:GetServerTimeS() - iCdTime)
  if self.m_inheritList and cdTime <= 0 then
    StackFlow:Push(UIDefines.ID_FORM_INHERITHEROLIST, {pos = fjItemIndex})
  else
    local vInfo = string.split(INHERIT_SYNC_RESET_COST, ",")
    local processData = ResourceUtil:GetProcessRewardData({
      tonumber(vInfo[1]),
      1
    })
    utils.ShowCommonTipCost({
      beforeItemID = tonumber(vInfo[1]),
      beforeItemNum = tonumber(vInfo[2]),
      formatFun = function(sContent)
        return string.format(sContent, tostring(processData.name), vInfo[2])
      end,
      confirmCommonTipsID = 1215,
      funSure = function()
        local time = tonumber(INHERIT_SYNC_CD) - (TimeUtil:GetServerTimeS() - iCdTime)
        if time <= 0 then
          StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 13020)
        else
          InheritManager:ReqInheritResetGrid(fjItemIndex)
        end
      end
    })
  end
end

function Form_Inherit:OnLockBtnClk(index, go)
  local fjItemIndex = index + 1
  if not fjItemIndex then
    return
  end
  local vInfo = string.split(INHERIT_SYNC_UNLOCK_COST, ",")
  utils.ShowCommonTipCost({
    beforeItemID = tonumber(vInfo[1]),
    beforeItemNum = tonumber(vInfo[2]),
    confirmCommonTipsID = 1218,
    funSure = function()
      InheritManager:ReqInheritUnlockGrid()
    end
  })
end

function Form_Inherit:OnEvolveSuccess()
  StackFlow:Push(UIDefines.ID_FORM_INHERITLEVELUP)
end

function Form_Inherit:OnEvolveSuccessClose()
  GlobalManagerIns:TriggerWwiseBGMState(240)
  UILuaHelper.PlayAnimationByName(self.m_csui.m_uiGameObject, "Inherit_switch")
  local detailAnimLen = UILuaHelper.GetAnimationLengthByName(self.m_csui.m_uiGameObject, "Inherit_switch")
  self.m_evoTimer = TimeService:SetTimer(detailAnimLen, 1, function()
    if self and self.RefreshUI then
      self:RefreshUI()
    end
    self.m_evoTimer = nil
  end)
end

function Form_Inherit:OnBtnherobg1Clicked()
  self:GotoLevelUp(1)
end

function Form_Inherit:OnBtnherobg2Clicked()
  self:GotoLevelUp(2)
end

function Form_Inherit:OnBtnherobg3Clicked()
  self:GotoLevelUp(3)
end

function Form_Inherit:OnBtnherobg4Clicked()
  self:GotoLevelUp(4)
end

function Form_Inherit:OnBtnherobg5Clicked()
  self:GotoLevelUp(5)
end

function Form_Inherit:OnBtnuplvClicked()
  if InheritManager:GetInheritIsEvo() then
    local curLv = InheritManager:GetInheritLevel()
    local maxLevel = InheritManager:GetInheritMaxLv()
    if curLv >= maxLevel then
      StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10421)
      return
    end
    StackFlow:Push(UIDefines.ID_FORM_INHERITLEVELUPPOP)
  else
    local function callBack()
      InheritManager:ReqInheritEvolve()
    end
    
    StackFlow:Push(UIDefines.ID_FORM_INHERITUPTIPS, {callBack = callBack})
  end
end

function Form_Inherit:OnBtnuplvundoClicked()
  local curLv = InheritManager:GetInheritLevel()
  local maxLevel = InheritManager:GetInheritMaxLv()
  if curLv >= maxLevel then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10421)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 10420)
  end
end

function Form_Inherit:OnBtniconruleClicked()
  utils.CheckAndPushCommonTips({tipsID = 1228})
end

function Form_Inherit:IsFullScreen()
  return true
end

function Form_Inherit:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Inherit:OnBackClk()
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  StackFlow:RemoveUIFromStack(UIDefines.ID_FORM_INHERIT)
end

local fullscreen = true
ActiveLuaUI("Form_Inherit", Form_Inherit)
return Form_Inherit
