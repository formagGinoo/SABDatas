local Form_Activity105Minigame_Puzzle = class("Form_Activity105Minigame_Puzzle", require("UI/UIFrames/Form_Activity105Minigame_PuzzleUI"))
local iMaxLevelNum = 5

function Form_Activity105Minigame_Puzzle:SetInitParam(param)
end

function Form_Activity105Minigame_Puzzle:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk), nil)
  self.m_prefabHelper = self.m_reward:GetComponent("PrefabHelper")
  self.m_minigameHelper = HeroActivityManager:GetMinigameHelper()
end

function Form_Activity105Minigame_Puzzle:OnActive()
  self.super.OnActive(self)
  self:InitData()
  self:RefreshUI()
end

function Form_Activity105Minigame_Puzzle:OnInactive()
  self.super.OnInactive(self)
end

function Form_Activity105Minigame_Puzzle:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_Activity105Minigame_Puzzle:InitData()
  local params = self.m_csui.m_param
  if params then
    self.iActId = params.main_id
    self.iSubActId = params.sub_id
    params = nil
  end
end

function Form_Activity105Minigame_Puzzle:RefreshUI()
  local vAllLegacyStageCfg = self.m_minigameHelper:GetSubActMiniGameAllLegacyStageCfg(self.iSubActId)
  self.iFinishCoun = 0
  for i = 1, iMaxLevelNum do
    local cfg = vAllLegacyStageCfg[i]
    if cfg then
      self:RefreshLevelItem(cfg)
    end
  end
  if not utils.isNull(self.m_txt_progress_Text) then
    self.m_txt_progress_Text.text = self.iFinishCoun .. "/" .. iMaxLevelNum
  end
  local subConfig = HeroActivityManager:GetSubInfoByID(self.iSubActId)
  if subConfig then
    local reward = utils.changeCSArrayToLuaTable(subConfig.m_Rewards)
    if not utils.isNull(self.m_prefabHelper) then
      utils.ShowPrefabHelper(self.m_prefabHelper, function(go, index, data)
        go.transform.localScale = Vector3.one * 0.52
        local processData = ResourceUtil:GetProcessRewardData({
          iID = data[1],
          iNum = data[2]
        })
        local itemWidgetIcon = self:createCommonItem(go)
        itemWidgetIcon:SetItemInfo(processData)
        itemWidgetIcon:SetItemHaveGetActive(HeroActivityManager:IsSubActAwarded(self.iActId, self.iSubActId))
        itemWidgetIcon:SetItemIconClickCB(function(itemID, itemNum, itemCom)
          self:OnRewardCommonItemClk(itemID, itemNum, itemCom)
        end)
      end, reward)
    end
  end
end

function Form_Activity105Minigame_Puzzle:OnRewardCommonItemClk(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  local act_data = HeroActivityManager:GetHeroActData(self.iActId)
  if not act_data then
    return
  end
  if not HeroActivityManager:IsSubActAwarded(self.iActId, self.iSubActId) and self.iFinishCoun >= iMaxLevelNum then
    HeroActivityManager:ReqLamiaGetSubActAwardCS(self.iActId, self.iSubActId, function()
      self:RefreshUI()
    end)
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

function Form_Activity105Minigame_Puzzle:RefreshLevelItem(cfg)
  if not cfg then
    log.error("Form_Activity105Minigame_Puzzle RefreshLevelItem error! ")
    return
  end
  local act_data = HeroActivityManager:GetHeroActData(self.iActId)
  if not act_data then
    return
  end
  local stMiniGame = act_data.server_data.stMiniGame
  local bIsPass = stMiniGame.mGameStat[cfg.m_LevelID] == 1
  bIsPass = bIsPass and LegacyLevelManager:IsLevelHavePass(cfg.m_LevelID)
  if bIsPass then
    self.iFinishCoun = self.iFinishCoun + 1
  end
  self["m_img_mask0" .. cfg.m_PiecesID]:SetActive(true)
  if bIsPass then
    local bHaveMark = LocalDataManager:GetIntSimple("HeroActMiniGamePuzzlebUnlockMark_" .. cfg.m_LevelID, 0) == 1
    if not bHaveMark then
      UILuaHelper.PlayAnimationByName(self["m_img_mask0" .. cfg.m_PiecesID], "m_pnl_minigame_puzzle_lock", 1, 0)
      local fAniLength = UILuaHelper.GetAnimationLengthByName(self["m_img_mask0" .. cfg.m_PiecesID], "m_pnl_minigame_puzzle_lock")
      TimeService:SetTimer(fAniLength, 1, function()
        LocalDataManager:SetIntSimple("HeroActMiniGamePuzzlebUnlockMark_" .. cfg.m_LevelID, 1, true)
        if utils.isNull(self["m_img_mask0" .. cfg.m_PiecesID]) then
          return
        end
        self["m_img_mask0" .. cfg.m_PiecesID]:SetActive(false)
      end)
    else
      self["m_img_mask0" .. cfg.m_PiecesID]:SetActive(false)
    end
  end
  self["m_txt_unlocktips0" .. cfg.m_PiecesID .. "_Text"].text = string.gsubNumberReplace(ConfigManager:GetCommonTextById(100816), cfg.m_mLevelNum)
end

function Form_Activity105Minigame_Puzzle:OnBtngetrewardClicked()
  local act_data = HeroActivityManager:GetHeroActData(self.iActId)
  if not act_data then
    return
  end
  if not HeroActivityManager:IsSubActAwarded(self.iActId, self.iSubActId) and self.iFinishCoun >= iMaxLevelNum then
    HeroActivityManager:ReqLamiaGetSubActAwardCS(self.iActId, self.iSubActId, function()
      self:RefreshUI()
    end)
    return
  end
end

function Form_Activity105Minigame_Puzzle:OnBackClk()
  self:CloseForm()
end

function Form_Activity105Minigame_Puzzle:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_Activity105Minigame_Puzzle", Form_Activity105Minigame_Puzzle)
return Form_Activity105Minigame_Puzzle
