local Form_AttractLetter = class("Form_AttractLetter", require("UI/UIFrames/Form_AttractLetterUI"))

function Form_AttractLetter:SetInitParam(param)
end

function Form_AttractLetter:AfterInit()
  self.super.AfterInit(self)
  self.DialogueNodeType = {
    HeroTalk = 0,
    NoahTalk = 1,
    Choose = 2,
    Start = 3,
    EndTips = 4,
    Entrust = 5,
    Invite = 6,
    Gift = 7,
    Narration = 8
  }
  self.DialogueNodeType2String = {
    [self.DialogueNodeType.HeroTalk] = "m_pnl_talk_hero",
    [self.DialogueNodeType.NoahTalk] = "m_pnl_talk_noah",
    [self.DialogueNodeType.Choose] = "m_pnl_talk_choose",
    [self.DialogueNodeType.Start] = "m_pnl_talk_Start",
    [self.DialogueNodeType.EndTips] = "m_pnl_endtips",
    [self.DialogueNodeType.Entrust] = "m_pnl_entrust",
    [self.DialogueNodeType.Invite] = "m_pnl_invite",
    [self.DialogueNodeType.Gift] = "m_pnl_talk_Gift",
    [self.DialogueNodeType.Narration] = "m_pnl_Narration"
  }
  self.mDialogueItemCache = {}
  local initGridData = {
    itemClkBackFun = handler(self, self.OnHeroItemClick)
  }
  self.m_luaHeroListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_HeroTabList_InfinityGrid, "Attract/LetterHeroListItem", initGridData)
  local initGridData2 = {
    itemClkBackFun = handler(self, self.OnHeroItemClick2)
  }
  self.m_luaLetterListInfinityGrid = require("UI/Common/UIInfinityGrid").new(self.m_LetterTabList_InfinityGrid, "Attract/LetterListItem", initGridData2)
  self.mLetterScroll = self.m_letterScroll:GetComponent("ScrollRect")
  local btnNext = self.m_Content:GetComponent("ButtonExtensions")
  btnNext.Clicked = handler(self, self.OnBtnnextClicked)
end

function Form_AttractLetter:OnActive()
  self.super.OnActive(self)
  self:FreshUI()
end

function Form_AttractLetter:OnInactive()
  self.super.OnInactive(self)
  self:ResetLetterNode()
  if self.m_csui.m_param and self.m_csui.m_param.callback then
    self.m_csui.m_param.callback()
    self.m_csui.m_param.callback = nil
  end
  self:ReqSetLetter()
  if self.m_UILockID and UILockIns:IsValidLocker(self.m_UILockID) then
    UILockIns:Unlock(self.m_UILockID)
  end
end

function Form_AttractLetter:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_AttractLetter:ResetLetterNode()
  for obj, value in pairs(self.mDialogueItemCache) do
    obj.transform:SetParent(self.m_recircleNode.transform)
    obj.transform.localPosition = Vector3.zero
  end
end

function Form_AttractLetter:FreshUI()
  local tempParams = self.m_csui.m_param
  local bIsReading = tempParams and tempParams.isReading or false
  self.iCurHeroId = tempParams and tempParams.hero_id or 0
  self.iCurLetterId = tempParams and tempParams.iLetterId or 0
  self.bIsReading = bIsReading
  if bIsReading then
    self:FreshReadingUI()
  else
    self:FreshHistoryUI()
  end
end

function Form_AttractLetter:FreshReadingUI()
  self.m_HeroTabList:SetActive(true)
  self.m_LetterTabList:SetActive(false)
  self:FreshHeroList()
  self:FreshLetterInfo()
end

function Form_AttractLetter:FreshHistoryUI()
  self.m_HeroTabList:SetActive(false)
  self.m_LetterTabList:SetActive(true)
  self:FreshLetterList()
  self:FreshLetterInfo()
end

function Form_AttractLetter:FreshHeroList()
  local letterHeroList = AttractManager:GetLetterHeroList()
  if not self.iCurHeroId or self.iCurHeroId == 0 then
    self.iCurSelectIdx = 1
    self.iCurHeroId = letterHeroList[1].heroData.serverData.iHeroId
  end
  for i, v in ipairs(letterHeroList) do
    v.bIsLetterSelected = false
  end
  for i, v in ipairs(letterHeroList) do
    if v.heroData.serverData.iHeroId == self.iCurHeroId then
      self.iCurSelectIdx = i
      v.bIsLetterSelected = true
      break
    end
  end
  if not letterHeroList or #letterHeroList == 0 then
    log.error("Form_AttractLetter:FreshHeroList() 数据异常，没有英雄信件配置")
    return
  end
  self.letterHeroList = letterHeroList
  self.m_luaHeroListInfinityGrid:ShowItemList(letterHeroList)
  self.m_luaHeroListInfinityGrid:LocateTo(self.iCurSelectIdx - 1)
  self.letterData = self.letterHeroList[self.iCurSelectIdx].letterData
end

function Form_AttractLetter:FreshLetterList()
  self.mCurHeroAttract = AttractManager:GetHeroAttractById(self.iCurHeroId)
  self.letterList = {}
  for letterID, letter in pairs(self.mCurHeroAttract.mLetter) do
    if AttractManager:IsArchiveRewardRecived(self.iCurHeroId, letter.iArchiveId) then
      table.insert(self.letterList, {
        bIsLetterSelected = false,
        letter = letter,
        heroId = self.iCurHeroId
      })
    end
  end
  table.sort(self.letterList, function(a, b)
    return a.letter.iArchiveId < b.letter.iArchiveId
  end)
  for i, v in ipairs(self.letterList) do
    if v.letter.iLetterId == self.iCurLetterId then
      self.iCurSelectLetterIdx = i
      v.bIsLetterSelected = true
      break
    end
  end
  if not self.iCurSelectLetterIdx then
    self.iCurSelectLetterIdx = 1
    self.letterList[1].bIsLetterSelected = true
  end
  self.m_luaLetterListInfinityGrid:ShowItemList(self.letterList)
  self.m_luaLetterListInfinityGrid:LocateTo(self.iCurSelectLetterIdx - 1)
  self.letterData = self.letterList[self.iCurSelectLetterIdx].letter
end

function Form_AttractLetter:OnHeroItemClick(index, itemRootObj)
  local itemIndex = index + 1
  if itemIndex == self.iCurSelectIdx then
    return
  end
  self:ReqSetLetter()
  self.letterHeroList[self.iCurSelectIdx].bIsLetterSelected = false
  self.m_luaHeroListInfinityGrid:ReBind(self.iCurSelectIdx)
  self.iCurSelectIdx = itemIndex
  self.letterHeroList[itemIndex].bIsLetterSelected = true
  self.letterData = self.letterHeroList[self.iCurSelectIdx].letterData
  self.iCurHeroId = self.letterHeroList[self.iCurSelectIdx].heroData.serverData.iHeroId
  self:FreshLetterInfo()
  self.m_luaHeroListInfinityGrid:ReBind(itemIndex)
end

function Form_AttractLetter:OnHeroItemClick2(index, itemRootObj)
  local itemIndex = index + 1
  if itemIndex == self.iCurSelectLetterIdx then
    return
  end
  self.letterList[self.iCurSelectLetterIdx].bIsLetterSelected = false
  self.m_luaLetterListInfinityGrid:ReBind(self.iCurSelectLetterIdx)
  self.iCurSelectLetterIdx = itemIndex
  self.letterList[itemIndex].bIsLetterSelected = true
  self.letterData = self.letterList[self.iCurSelectLetterIdx].letter
  self:FreshLetterInfo()
  self.m_luaLetterListInfinityGrid:ReBind(itemIndex)
end

function Form_AttractLetter:GetLetterNodeItem(type)
  local letterData = self.letterData
  local letterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(letterData.iLetterId, self.iCurCreateStep)
  if not letterCfg then
    log.error("Form_AttractLetter:GetLetterNodeItem() 检查配置表AttractLetter ID：" .. letterData.iLetterId .. " 步骤：" .. self.iCurCreateStep)
    return
  end
  local DialogueType = type or letterCfg.m_DialogueType
  local nodeName = self.DialogueNodeType2String[DialogueType]
  if not nodeName then
    log.error("Form_AttractLetter:GetLetterNodeItem() 配置类型没有找到对应节点名， 检查配置表AttractLetter ID：" .. letterData.iLetterId)
    return
  end
  local letterNode
  local temp = self.m_recircleNode.transform:Find(nodeName)
  if temp then
    letterNode = temp.gameObject
  end
  if not letterNode then
    letterNode = GameObject.Instantiate(self[nodeName], self.m_Content.transform).gameObject
    letterNode.name = nodeName
  end
  letterNode.transform:SetParent(self.m_Content.transform)
  letterNode.transform.localScale = Vector3.one
  letterNode:SetActive(true)
  local item = self.mDialogueItemCache[letterNode]
  if not item then
    item = {}
    item.root = letterNode
    if DialogueType == self.DialogueNodeType.HeroTalk then
      item.imgObj = letterNode.transform:Find("img_headmask").gameObject
      item.roleNameText = letterNode.transform:Find("heroname"):GetComponent("TMPPro")
      item.iconImg = letterNode.transform:Find("img_headmask/icon_hero"):GetComponent("CircleImage")
      item.descText = letterNode.transform:Find("txt/img_tips_plot/desc"):GetComponent("TMPPro")
      item.giftObj = letterNode.transform:Find("pnl_gift").gameObject
      item.giftObj:SetActive(false)
      item.aniName = "pnl_talk_in"
      item.canvasGroup = letterNode:GetComponent("CanvasGroup")
    elseif DialogueType == self.DialogueNodeType.NoahTalk then
      item.imgObj = letterNode.transform:Find("img_headmask").gameObject
      item.roleNameText = letterNode.transform:Find("heroname"):GetComponent("TMPPro")
      item.iconImg = letterNode.transform:Find("img_headmask/icon_hero"):GetComponent("CircleImage")
      item.descText = letterNode.transform:Find("txt/img_tips_plot/desc"):GetComponent("TMPPro")
      item.aniName = "pnl_talk_in"
      item.canvasGroup = letterNode:GetComponent("CanvasGroup")
    elseif DialogueType == self.DialogueNodeType.Choose then
      item.prefabHelper = letterNode.transform:Find("m_choose"):GetComponent("PrefabHelper")
      item.aniName = "pnl_talk_choose_in"
      item.canvasGroup = letterNode:GetComponent("CanvasGroup")
    elseif DialogueType == self.DialogueNodeType.Start then
      item.descText = letterNode.transform:Find("m_txt_start"):GetComponent("TMPPro")
      item.aniName = "pnl_talk_start_in"
    elseif DialogueType == self.DialogueNodeType.EndTips then
      item.descText = letterNode.transform:Find("m_txt_end_tips"):GetComponent("TMPPro")
      item.aniName = "pnl_talk_in"
      item.canvasGroup = letterNode:GetComponent("CanvasGroup")
    elseif DialogueType == self.DialogueNodeType.Entrust then
    elseif DialogueType == self.DialogueNodeType.Invite then
      item.titleText = letterNode.transform:Find("m_txt_invite_title"):GetComponent("TMPPro")
      item.descText = letterNode.transform:Find("m_txt_invite_desc"):GetComponent("TMPPro")
      item.finishNode = letterNode.transform:Find("m_img_finishall_invite").gameObject
      item.btnAccept = letterNode.transform:Find("m_btn_accept"):GetComponent("ButtonExtensions")
      item.aniName = "pnl_invite_in"
      item.canvasGroup = letterNode:GetComponent("CanvasGroup")
    elseif DialogueType == self.DialogueNodeType.Gift then
      item.imgObj = letterNode.transform:Find("img_headmask").gameObject
      item.iconImg = letterNode.transform:Find("img_headmask/icon_hero"):GetComponent("CircleImage")
      item.giftObj = letterNode.transform:Find("pnl_gift").gameObject
      item.btn = item.giftObj:GetComponent("ButtonExtensions")
      item.giftGetObj = letterNode.transform:Find("pnl_gift/gift_get").gameObject
      item.giftGaryObj = letterNode.transform:Find("pnl_gift/gift_gary").gameObject
      item.aniName = "pnl_talk_in"
      item.canvasGroup = letterNode:GetComponent("CanvasGroup")
    elseif DialogueType == self.DialogueNodeType.Narration then
      item.descText = letterNode.transform:Find("m_txt_Narration"):GetComponent("TMPPro")
      item.aniName = "pnl_talk_choose_in"
      item.canvasGroup = letterNode:GetComponent("CanvasGroup")
    end
    self.mDialogueItemCache[letterNode] = item
  end
  return item
end

function Form_AttractLetter:FreshLetterInfo()
  self.iCurCreateStep = 1
  self.bIsWaitting = false
  self.vNewReply = {}
  local archiveCfg = AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID(self.iCurHeroId, self.letterData.iArchiveId)
  if archiveCfg then
    self.m_txt_title_Text.text = archiveCfg.m_mTitle
  else
    self.m_txt_title_Text.text = ""
  end
  self:ResetLetterNode()
  self:FreshHistoryNode()
  if not self.bIsReading then
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_Content)
    self.mLetterScroll.verticalNormalizedPosition = 1
  end
end

function Form_AttractLetter:FreshHistoryNode()
  self.bIsInitHostory = true
  local letterData = self.letterData
  if letterData.iCurStep ~= 0 then
    local historySteps = {}
    local tempStep = 1
    local count = 0
    while tempStep <= letterData.iCurStep and tempStep ~= 0 do
      count = count + 1
      if 50 < count then
        log.error("Form_AttractLetter:FreshHistoryNode() 历史信件节点循环次数过多，检查配置表AttractLetter ID：" .. letterData.iLetterId .. " 步骤：" .. self.iCurCreateStep)
        break
      end
      table.insert(historySteps, tempStep)
      local letterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(letterData.iLetterId, tempStep)
      local stepList = utils.changeCSArrayToLuaTable(letterCfg.m_NextStep)
      if #stepList <= 1 then
        tempStep = stepList[1] or 0
      else
        local vReply = letterData.vReply
        local isSet = false
        for _, step in ipairs(vReply) do
          for _, v in ipairs(stepList) do
            if step == v then
              tempStep = step
              isSet = true
              break
            end
          end
          if isSet then
            break
          end
        end
        if not isSet then
          break
        end
      end
    end
    for i, v in ipairs(historySteps) do
      self.iCurCreateStep = v
      self:AddLetterNode()
    end
    self.bIsInitHostory = false
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_Content)
    if self.iCurCreateStep == 1 then
      self.mLetterScroll.verticalNormalizedPosition = 1
    else
      self.mLetterScroll.verticalNormalizedPosition = 0
    end
  else
    self.bIsInitHostory = false
    self.iCurCreateStep = 1
    self:AddLetterNode()
  end
end

function Form_AttractLetter:AddLetterNode()
  if self.bIsWaitting and not self.bIsInitHostory then
    return
  end
  if self.curAniItem and self.curAniItem.canvasGroup then
    self.curAniItem.canvasGroup.alpha = 1
  end
  self.bIsWaitting = false
  local item = self:GetLetterNodeItem()
  local letterData = self.letterData
  local letterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(letterData.iLetterId, self.iCurCreateStep)
  if not letterCfg then
    log.error("Form_AttractLetter:AddLetterNode() 检查配置表AttractLetter ID：" .. letterData.iLetterId .. " 步骤：" .. self.iCurCreateStep)
    return
  end
  local DialogueType = letterCfg.m_DialogueType
  if DialogueType == self.DialogueNodeType.HeroTalk then
    item.roleNameText.text = letterCfg.m_mRoleName
    item.descText.text = letterCfg.m_mPlotText
    if letterCfg.m_RoleHead ~= "" then
      item.imgObj:SetActive(true)
      UILuaHelper.SetBaseImageAtlasSprite(item.iconImg, letterCfg.m_RoleHead)
    else
      item.imgObj:SetActive(false)
    end
  elseif DialogueType == self.DialogueNodeType.NoahTalk then
    item.descText.text = letterCfg.m_mPlotText
    item.roleNameText.text = letterCfg.m_mRoleName
    if letterCfg.m_RoleHead ~= "" then
      item.imgObj:SetActive(true)
      UILuaHelper.SetBaseImageAtlasSprite(item.iconImg, letterCfg.m_RoleHead)
    else
      item.imgObj:SetActive(false)
    end
  elseif DialogueType == self.DialogueNodeType.Choose then
    self.bIsWaitting = true
    if self.bIsInitHostory then
      item.root.transform:SetParent(self.m_recircleNode.transform)
      item.root.transform.localPosition = Vector3.zero
      local temp = self:GetLetterNodeItem(self.DialogueNodeType.NoahTalk)
      temp.descText.text = letterCfg.m_mPlotText
      temp.roleNameText.text = letterCfg.m_mRoleName
      if letterCfg.m_RoleHead ~= "" then
        temp.imgObj:SetActive(true)
        UILuaHelper.SetBaseImageAtlasSprite(temp.iconImg, letterCfg.m_RoleHead)
      else
        temp.imgObj:SetActive(false)
      end
      self.bIsWaitting = false
      return
    end
    local preStep = self.iCurCreateStep - 1
    
    local function GetChooseListNext()
      local list = {}
      local step = self.iCurCreateStep
      local count = 0
      while step do
        count = count + 1
        if 10 < count then
          log.error("Form_AttractLetter:GetChooseListNext() 选项列表循环次数过多，检查配置表AttractLetter ID：" .. letterData.iLetterId .. " 步骤：" .. self.iCurCreateStep)
          break
        end
        local cfg = AttractManager:GetAttractLetterCfgByIDAndStep(letterData.iLetterId, step)
        if cfg then
          if cfg.m_DialogueType == self.DialogueNodeType.Choose then
            table.insert(list, step)
          else
            step = false
            break
          end
        else
          step = false
          break
        end
        step = step + 1
      end
      return list
    end
    
    local function GetChooseList()
      if preStep <= 0 then
        return GetChooseListNext()
      end
      local preLetterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(letterData.iLetterId, preStep)
      if not preLetterCfg then
        return GetChooseListNext()
      end
      if preLetterCfg.m_DialogueType == self.DialogueNodeType.Choose then
        preStep = preStep - 1
        return GetChooseList()
      end
      return utils.changeCSArrayToLuaTable(preLetterCfg.m_NextStep)
    end
    
    local stepList = GetChooseList()
    utils.ShowPrefabHelper(item.prefabHelper, function(go, index, step)
      local transform = go.transform
      local cfg = AttractManager:GetAttractLetterCfgByIDAndStep(letterData.iLetterId, step)
      transform:Find("m_txt_choose"):GetComponent("TMPPro").text = cfg.m_mPlotText
      local btn = go:GetComponent("ButtonExtensions")
      btn.Clicked = handler1(self, self.OnClickChoose, {
        step = step,
        stepList = stepList,
        root = item.root
      })
    end, stepList)
  elseif DialogueType == self.DialogueNodeType.Start then
    item.descText.text = letterCfg.m_mPlotText
  elseif DialogueType == self.DialogueNodeType.EndTips then
    item.descText.text = letterCfg.m_mPlotText
  elseif DialogueType == self.DialogueNodeType.Entrust then
  elseif DialogueType == self.DialogueNodeType.Invite then
    self.bIsWaitting = true
    local cfg = AttractManager:GetAttractArchiveCfgByHeroIDAndArchiveID(self.iCurHeroId, letterData.iArchiveId)
    item.titleText.text = cfg.m_mTitle
    item.descText.text = letterCfg.m_mPlotText
    if AttractManager:IsMailSaw(self.iCurHeroId, letterData.iArchiveId) then
      item.finishNode:SetActive(true)
      item.btnAccept.gameObject:SetActive(false)
    else
      item.finishNode:SetActive(false)
      item.btnAccept.gameObject:SetActive(true)
      item.btnAccept.Clicked = handler1(self, self.OnClickAcceptInvite, {
        timelineId = letterCfg.m_TimelineID,
        timelineType = letterCfg.m_TimelineType,
        item = item
      })
    end
  elseif DialogueType == self.DialogueNodeType.Gift then
    self.bIsWaitting = true
    if letterCfg.m_RoleHead ~= "" then
      item.imgObj:SetActive(true)
      UILuaHelper.SetBaseImageAtlasSprite(item.iconImg, letterCfg.m_RoleHead)
    else
      item.imgObj:SetActive(false)
    end
    if self.iCurCreateStep < letterData.iCurrentStep then
      item.giftGetObj:SetActive(true)
      item.giftGaryObj:SetActive(false)
    else
      item.giftGetObj:SetActive(false)
      item.giftGaryObj:SetActive(true)
    end
    item.btn.Clicked = handler(self, self.OnClickGift)
  elseif DialogueType == self.DialogueNodeType.Narration then
    item.descText.text = letterCfg.m_mPlotText
  end
  if self.bIsInitHostory then
    return
  end
  UILuaHelper.ForceRebuildLayoutImmediate(self.m_Content)
  if self.iCurCreateStep == 1 then
    self.mLetterScroll.verticalNormalizedPosition = 1
  else
    self.mLetterScroll.verticalNormalizedPosition = 0
  end
  UILuaHelper.PlayAnimationByName(item.root, item.aniName)
  self.curAniItem = item
end

function Form_AttractLetter:OnClickChoose(params)
  self.bIsWaitting = true
  self.vNewReply = {}
  self.vNewReply[#self.vNewReply + 1] = params.step
  self.iCurCreateStep = params.step
  AttractManager:ReqSetLetter(self.iCurHeroId, self.letterData.iLetterId, params.step, self.vNewReply, function()
    self.bIsWaitting = false
    self.vNewReply = {}
    local letterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(self.letterData.iLetterId, params.step)
    params.root.transform:SetParent(self.m_recircleNode.transform)
    params.root.transform.localPosition = Vector3.zero
    local item = self:GetLetterNodeItem(self.DialogueNodeType.NoahTalk)
    item.descText.text = letterCfg.m_mPlotText
    item.roleNameText.text = letterCfg.m_mRoleName
    if letterCfg.m_RoleHead ~= "" then
      item.imgObj:SetActive(true)
      UILuaHelper.SetBaseImageAtlasSprite(item.iconImg, letterCfg.m_RoleHead)
    else
      item.imgObj:SetActive(false)
    end
  end)
end

function Form_AttractLetter:OnClickAcceptInvite(params)
  self.bIsWaitting = false
  self.m_UILockID = UILockIns:Lock(1)
  local externRes = {}
  local depen = CS.VisualFavorability.GetDepenResource(params.timelineType, params.timelineId)
  for k, v in pairs(depen) do
    table.insert(externRes, {sName = k, eType = v})
  end
  DownloadManager:DownloadResourceWithUI(nil, externRes, "Form_AttractLetter:OnClickAcceptInviteCallback", nil, nil, function()
    self:OnClickAcceptInviteCallback(params)
  end, nil, nil, nil, nil, function()
    if self.m_UILockID then
      UILockIns:Unlock(self.m_UILockID)
      self.m_UILockID = nil
    end
  end)
end

function Form_AttractLetter:OnClickAcceptInviteCallback(params)
  if self.m_UILockID then
    UILockIns:Unlock(self.m_UILockID)
    self.m_UILockID = nil
  end
  self.m_UILockID = UILockIns:Lock(10)
  CS.VisualFavorability.LoadFavorability(params.timelineType, params.timelineId, function()
    CS.UI.UILuaHelper.HideMainUI()
    if self.m_UILockID then
      UILockIns:Unlock(self.m_UILockID)
      self.m_UILockID = nil
    end
  end, function()
    CS.UI.UILuaHelper.ShowMainUI()
    AttractManager:ResetCamera()
    AttractManager:ReqSetLetter(self.iCurHeroId, self.letterData.iLetterId, self.iCurCreateStep, self.vNewReply, function()
      self.vNewReply = {}
      params.item.finishNode:SetActive(true)
      params.item.btnAccept.gameObject:SetActive(false)
    end)
  end)
end

function Form_AttractLetter:OnClickGift()
  self.bIsWaitting = false
  AttractManager:ReqSetLetter(self.iCurHeroId, self.letterData.iLetterId, self.iCurCreateStep, self.vNewReply, function()
    self.vNewReply = {}
    local letterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(self.letterData.iLetterId, self.iCurCreateStep)
    local stepList = utils.changeCSArrayToLuaTable(letterCfg.m_NextStep)
    if stepList[1] and stepList[1] ~= 0 then
      self.iCurCreateStep = stepList[1]
      self:AddLetterNode()
    end
  end)
end

function Form_AttractLetter:OnBtnnextClicked()
  if self.bIsWaitting then
    return
  end
  local letterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(self.letterData.iLetterId, self.iCurCreateStep)
  local stepList = utils.changeCSArrayToLuaTable(letterCfg.m_NextStep)
  if stepList[1] and stepList[1] ~= 0 then
    local cfg = AttractManager:GetAttractLetterCfgByIDAndStep(self.letterData.iLetterId, stepList[1])
    if cfg.m_DialogueType == self.DialogueNodeType.Choose then
      self.iCurCreateStep = stepList[1]
      self:AddLetterNode()
      self.bIsWaitting = true
      return
    end
  end
  if self.iCurCreateStep <= self.letterData.iCurStep and stepList[1] and stepList[1] ~= 0 then
    self.iCurCreateStep = stepList[#stepList]
    self:AddLetterNode()
    return
  end
  if not stepList[1] or stepList[1] == 0 then
    return
  end
  self.iCurCreateStep = stepList[1]
  self:AddLetterNode()
end

function Form_AttractLetter:ReqSetLetter(bIsClose)
  if self.iCurCreateStep <= self.letterData.iCurStep then
    return
  end
  local letterCfg = AttractManager:GetAttractLetterCfgByIDAndStep(self.letterData.iLetterId, self.iCurCreateStep)
  if letterCfg.m_DialogueType == self.DialogueNodeType.Choose then
    local bIsChoosen = false
    for _, v in ipairs(self.vNewReply) do
      if v == self.iCurCreateStep then
        bIsChoosen = true
        break
      end
    end
    if not bIsChoosen then
      self.iCurCreateStep = self.iCurCreateStep - 1
      if self.iCurCreateStep <= self.letterData.iCurStep then
        if bIsClose then
          self.iCurCreateStep = self.iCurCreateStep + 1
          self:CloseForm()
        end
        return
      end
    end
  elseif letterCfg.m_DialogueType == self.DialogueNodeType.Invite then
    self.iCurCreateStep = self.iCurCreateStep - 1
    if self.iCurCreateStep <= self.letterData.iCurStep then
      if bIsClose then
        self.iCurCreateStep = self.iCurCreateStep + 1
        self:CloseForm()
      end
      return
    end
  end
  AttractManager:ReqSetLetter(self.iCurHeroId, self.letterData.iLetterId, self.iCurCreateStep, self.vNewReply, function()
    if bIsClose then
      self:CloseForm()
    end
  end)
end

function Form_AttractLetter:OnBtncloseClicked()
  if self.iCurCreateStep <= self.letterData.iCurStep then
    self:CloseForm()
    return
  end
  self:ReqSetLetter(true)
end

function Form_AttractLetter:IsOpenGuassianBlur()
  return true
end

function Form_AttractLetter:GetDownloadResourceExtra(params)
  local CfgIns = ConfigManager:GetConfigInsByName("AttractArchive")
  local cfgs = CfgIns:GetAll()
  local vResourceExtra = {}
  vResourceExtra[#vResourceExtra + 1] = {
    sName = "TimelineDependency",
    eType = DownloadManager.ResourceType.Bytes
  }
  for k, v in pairs(cfgs) do
    if v.m_HeroID and v.m_HeroID > 0 then
      for _, cfg in ipairs(v) do
        if cfg.m_TimelineType and cfg.m_TimelineType == 1 then
          vResourceExtra[#vResourceExtra + 1] = {
            sName = cfg.m_TimelineId,
            eType = DownloadManager.ResourceType.MaterialReplace
          }
        end
      end
    end
  end
  return nil, vResourceExtra
end

local fullscreen = true
ActiveLuaUI("Form_AttractLetter", Form_AttractLetter)
return Form_AttractLetter
