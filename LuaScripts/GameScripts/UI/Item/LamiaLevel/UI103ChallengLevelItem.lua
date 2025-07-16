local UIItemBase = require("UI/Common/UIItemBase")
local UI103ChallengLevelItem = class("UI103ChallengLevelItem", UIItemBase)

function UI103ChallengLevelItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_levelCfg = nil
  self.m_isChoose = false
  self.m_isUnlock = false
  self.m_unlockStr = nil
  self.m_isPass = nil
  self.m_levelHelper = LevelHeroLamiaActivityManager:GetLevelHelper()
  local transform = self.m_itemRootObj.transform:Find("ui_activitiy103Luoleilai_exdialogue_item/levelNode")
  if not utils.isNull(transform) then
    local btn_Challenge = transform:Find("btn_Challenge")
    if not utils.isNull(btn_Challenge) then
      self.btn_Challenge = btn_Challenge:GetComponent("ButtonExtensions")
      self.btn_Challenge.Clicked = handler(self, self.OnBtnChallengeClicked)
    end
    local node_normal = transform:Find("node_normal")
    if not utils.isNull(node_normal) then
      self.node_normal = node_normal.gameObject
    end
    local txt_normal = transform:Find("node_normal/txt_normal")
    if not utils.isNull(txt_normal) then
      self.txt_normal = txt_normal:GetComponent("TMPPro")
    end
    local img_lock = transform:Find("img_lock")
    if not utils.isNull(img_lock) then
      self.node_lock = img_lock.gameObject
    end
    local txt_lock_name = transform:Find("img_lock/txt_lock_name")
    if not utils.isNull(txt_lock_name) then
      self.txt_lock_name = txt_lock_name:GetComponent("TMPPro")
    end
    local frame_select = transform:Find("frame_select")
    if not utils.isNull(frame_select) then
      self.node_select = frame_select.gameObject
    end
    local txt_select = transform:Find("frame_select/txt_select")
    if not utils.isNull(txt_select) then
      self.txt_select = txt_select:GetComponent("TMPPro")
    end
    local img_clear = transform:Find("img_clear")
    if not utils.isNull(img_clear) then
      self.node_pass = img_clear.gameObject
    end
    local txt_name = transform:Find("img_clear/txt_name")
    if not utils.isNull(txt_name) then
      self.txt_name = txt_name:GetComponent("TMPPro")
    end
    local item_group = transform:Find("item_group")
    if not utils.isNull(item_group) then
      self.item_group = item_group.gameObject
    end
    local item_normal = transform:Find("item_group/item_normal")
    if not utils.isNull(item_normal) then
      self.item_normal = item_normal:GetComponent("Image")
    end
    local item_clear = transform:Find("item_group/item_clear")
    if not utils.isNull(item_clear) then
      self.item_clear = item_clear:GetComponent("Image")
    end
    local txt_rewardnum = transform:Find("txt_rewardnum")
    if not utils.isNull(txt_rewardnum) then
      self.txt_rewardnum = txt_rewardnum:GetComponent("TMPPro")
      self.txt_reward_mulColor = txt_rewardnum:GetComponent("MultiColorChange")
    end
    local vx_fx = transform:Find("vx_fx")
    if not utils.isNull(vx_fx) then
      self.m_vx_fx = vx_fx.gameObject
    end
  end
end

function UI103ChallengLevelItem:OnFreshData()
  self.m_levelCfg = self.m_itemData.levelCfg
  local levelID = self.m_levelCfg.m_LevelID
  self.m_isChoose = self.m_itemData.isChoose
  self.m_isUnlock, _, self.m_unlockStr = self.m_levelHelper:IsLevelUnLock(levelID)
  self.m_isPass = self.m_levelHelper:IsLevelHavePass(levelID)
  self:FreshItemUI()
  self:ChangeChoose(self.m_isChoose)
end

function UI103ChallengLevelItem:ResetNodeState()
  if not utils.isNull(self.node_pass) then
    UILuaHelper.SetActive(self.node_pass, false)
  end
  if not utils.isNull(self.node_select) then
    UILuaHelper.SetActive(self.node_select, false)
  end
  if not utils.isNull(self.node_normal) then
    UILuaHelper.SetActive(self.node_normal, false)
  end
  if not utils.isNull(self.node_lock) then
    UILuaHelper.SetActive(self.node_lock, false)
  end
  if not utils.isNull(self.item_clear) then
    self.item_clear.gameObject:SetActive(false)
  end
  if not utils.isNull(self.m_vx_fx) then
    self.m_vx_fx:SetActive(true)
  end
end

function UI103ChallengLevelItem:SetNodeState()
  if self.m_isPass then
    if not utils.isNull(self.node_pass) then
      UILuaHelper.SetActive(self.node_pass, true)
    end
    if not utils.isNull(self.item_clear) then
      self.item_clear.gameObject:SetActive(true)
    end
  elseif self.m_isChoose then
    if not utils.isNull(self.node_select) then
      UILuaHelper.SetActive(self.node_select, true)
    end
    if not utils.isNull(self.m_vx_fx) then
      self.m_vx_fx:SetActive(false)
    end
    if not utils.isNull(self.item_clear) then
      self.item_clear.gameObject:SetActive(false)
    end
  elseif self.m_isUnlock then
    if not utils.isNull(self.node_normal) then
      UILuaHelper.SetActive(self.node_normal, true)
    end
    if not utils.isNull(self.item_normal) then
      self.item_normal.gameObject:SetActive(true)
    end
    if not utils.isNull(self.item_clear) then
      self.item_clear.gameObject:SetActive(false)
    end
  elseif not self.m_isUnlock then
    if not utils.isNull(self.node_lock) then
      UILuaHelper.SetActive(self.node_lock, true)
    end
    if not utils.isNull(self.item_normal) then
      self.item_normal.gameObject:SetActive(true)
    end
    if not utils.isNull(self.item_clear) then
      self.item_clear.gameObject:SetActive(false)
    end
  end
end

function UI103ChallengLevelItem:FreshItemUI()
  if not self.m_levelCfg then
    return
  end
  local levelCfg = self.m_levelCfg
  self.txt_normal.text = levelCfg.m_LevelRef
  self.txt_lock_name.text = levelCfg.m_LevelRef
  self.txt_select.text = levelCfg.m_LevelRef
  self.txt_name.text = levelCfg.m_LevelRef
  self:ResetNodeState()
  self:SetNodeState()
  local idx = self.m_isPass and 1 or 0
  if not utils.isNull(self.txt_reward_mulColor) then
    self.txt_reward_mulColor:SetColorByIndex(idx)
  end
  local keyWardItemData = levelCfg.m_KeyReward
  if keyWardItemData.Length == 0 then
    if not utils.isNull(self.item_group) then
      UILuaHelper.SetActive(self.item_group, false)
    end
  else
    if not utils.isNull(self.item_group) then
      UILuaHelper.SetActive(self.item_group, true)
    end
    local itemID = tonumber(keyWardItemData[0])
    local itemNum = tonumber(keyWardItemData[1])
    if not utils.isNull(self.item_normal) then
      UILuaHelper.SetAtlasSprite(self.item_normal, ItemManager:GetItemIconPathByID(itemID))
    end
    if not utils.isNull(self.item_clear) then
      UILuaHelper.SetAtlasSprite(self.item_clear, ItemManager:GetItemIconPathByID(itemID))
    end
    if not utils.isNull(self.txt_rewardnum) then
      self.txt_rewardnum.text = itemNum
    end
  end
end

function UI103ChallengLevelItem:ChangeChoose(isChoose)
  self.m_isChoose = isChoose
  self.m_itemData.isChoose = isChoose
  if isChoose then
    self:ResetNodeState()
  else
    self:SetNodeState()
  end
  if not utils.isNull(self.node_select) then
    UILuaHelper.SetActive(self.node_select, isChoose)
  end
  if not utils.isNull(self.m_vx_fx) then
    self.m_vx_fx:SetActive(not isChoose)
  end
end

function UI103ChallengLevelItem:OnBtnChallengeClicked()
  if not self.m_itemData then
    return
  end
  if not self.m_isUnlock then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, self.m_unlockStr)
    return
  end
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
  if self.m_isChoose ~= true then
    self:ChangeChoose(true)
  end
end

function UI103ChallengLevelItem:OnRewardItemClick(itemID, itemNum, itemCom)
  if not itemID then
    return
  end
  utils.openItemDetailPop({iID = itemID, iNum = itemNum})
end

return UI103ChallengLevelItem
