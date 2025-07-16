local ItemIcon = class("ItemIcon")

function ItemIcon:ctor(goRoot)
  self.m_goRoot = goRoot
  self.m_btnClick = self.m_goRoot.transform:Find("c_btnClick"):GetComponent("Button")
  self.m_btnClick:GetComponent("Empty4Raycast").raycastTarget = false
  self.m_btnClick:GetComponent("Empty4Raycast").SwallowTouch = false
  UILuaHelper.BindButtonClickManual(self, self.m_btnClick, handler(self, self.OnItemIconClicked))
  self.m_fItemIconClickCB = nil
  self.m_imageBG = self.m_goRoot.transform:Find("c_bg").gameObject
  local tranSelected = self.m_goRoot.transform:Find("c_bg_selected")
  if tranSelected ~= nil then
    self.m_imageSelected = tranSelected.gameObject
  else
    self.m_imageSelected = nil
  end
  self.m_imageItem = self.m_goRoot.transform:Find("c_item"):GetComponent("Image")
  self.m_imageNumBG = self.m_goRoot.transform:Find("c_num_bg").gameObject
  self.m_textNum = self.m_imageNumBG.transform:Find("c_txt_num"):GetComponent(T_TextMeshProUGUI)
  self.m_imageLvBG = self.m_goRoot.transform:Find("c_lv_bg").gameObject
  self.m_textLv = self.m_imageLvBG.transform:Find("common_item_txt_lv"):GetComponent(T_TextMeshProUGUI)
  self.m_textLvNum = self.m_textLv.transform:Find("c_txt_lv_num"):GetComponent(T_TextMeshProUGUI)
  self.m_imageTimeBG = self.m_goRoot.transform:Find("c_time_bg").gameObject
  self.m_textTime = self.m_imageTimeBG.transform:Find("c_txt_time"):GetComponent(T_TextMeshProUGUI)
  local tranBarBG = self.m_goRoot.transform:Find("c_bar_bg")
  if tranBarBG ~= nil then
    self.m_imageBarBG = tranBarBG.gameObject
    self.m_imageBar = self.m_imageBarBG.transform:Find("c_bar"):GetComponent("Image")
    self.m_textBar = self.m_imageBarBG.transform:Find("c_bar_txt"):GetComponent(T_TextMeshProUGUI)
  else
    self.m_imageBarBG = nil
    self.m_imageBar = nil
    self.m_textBar = nil
  end
  self.m_vGoImageRarity = {}
  local panelRarity = self.m_goRoot.transform:Find("c_bar_grade")
  if panelRarity ~= nil then
    self.m_vGoImageRarity[1] = panelRarity:Find("c_icon_item_n").gameObject
    self.m_vGoImageRarity[2] = panelRarity:Find("c_icon_item_r").gameObject
    self.m_vGoImageRarity[3] = panelRarity:Find("c_icon_item_sr").gameObject
    self.m_vGoImageRarity[4] = panelRarity:Find("c_icon_item_ssr").gameObject
  end
  self.m_obj_need_rootTrans = self.m_goRoot.transform:Find("c_num_need")
  if self.m_obj_need_rootTrans then
    self.m_obj_need_root = self.m_obj_need_rootTrans.gameObject
    self.m_txt_num_have = self.m_goRoot.transform:Find("c_num_need/img_black_bg/c_txt_num_have"):GetComponent(T_TextMeshProUGUI)
    self.m_txt_num_need = self.m_goRoot.transform:Find("c_num_need/img_black_bg/c_txt_num_need"):GetComponent(T_TextMeshProUGUI)
    self.m_txt_need_split = self.m_goRoot.transform:Find("c_num_need/img_black_bg/c_txt_split"):GetComponent(T_TextMeshProUGUI)
  end
  self.m_item_have_get = self.m_goRoot.transform:Find("c_item_have_get")
end

function ItemIcon:OnUpdate(dt)
end

function ItemIcon:RefreshNum(iNum)
  if iNum == nil or iNum <= 0 then
    return
  end
  self.m_imageNumBG:SetActive(true)
  self.m_textNum.text = BigNumFormat(iNum)
end

function ItemIcon:SetItemInfo(iID, iNum, bBag)
  self.m_iItemID = iID
  self.m_iItemNum = iNum
  if iID == nil then
    return
  end
  local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(iID)
  if stItemData == nil then
    return
  end
  if not stItemData.m_IconPath then
    return
  end
  self.m_stItemData = stItemData
  CS.UI.UILuaHelper.SetAtlasSprite(self.m_imageItem, "Atlas_Item/" .. stItemData.m_IconPath)
  for iRarity, goImageRarity in pairs(self.m_vGoImageRarity) do
    if iRarity == self.m_stItemData.m_ItemRarity then
      goImageRarity:SetActive(true)
    else
      goImageRarity:SetActive(false)
    end
  end
  self.m_imageNumBG:SetActive(false)
  self.m_imageLvBG:SetActive(false)
  self.m_imageTimeBG:SetActive(false)
  if self.m_imageBarBG then
    self.m_imageBarBG:SetActive(false)
  end
  if stItemData.m_ItemType == ItemManager.ItemType.Item then
    self:RefreshNum(iNum)
  elseif stItemData.m_ItemType == ItemManager.ItemType.Chest then
    self:RefreshNum(iNum)
  elseif stItemData.m_ItemType == ItemManager.ItemType.IdleCapsule then
    self:RefreshNum(iNum)
    self.m_imageTimeBG:SetActive(true)
    local iTime = tonumber(string.split(stItemData.m_ItemUse, ",")[2])
    self.m_textTime.text = math.floor(iTime / 3600) .. ConfigManager:GetCommonTextById(20012)
  elseif stItemData.m_ItemType == ItemManager.ItemType.Fragment then
    if bBag then
      if self.m_imageBarBG then
        self.m_imageBarBG:SetActive(true)
        local iOneCount = tonumber(string.split(stItemData.m_ItemUse, ":")[2])
        local fPercent = math.min(iNum / iOneCount, 1)
        self.m_imageBar.fillAmount = fPercent
        self.m_textBar.text = iNum .. "/" .. iOneCount
        if iNum >= iOneCount then
          self.m_textBar.color = CS.UnityEngine.Color.red
        else
          self.m_textBar.color = CS.UnityEngine.Color.black
        end
      end
    else
      self:RefreshNum(iNum)
    end
  end
end

function ItemIcon:SetNeedNum(needNum, haveNum)
  if not self.m_iItemID then
    return
  end
  self.m_imageNumBG:SetActive(false)
  if self.m_obj_need_root then
    self.m_obj_need_root:SetActive(true)
    haveNum = haveNum or ItemManager:GetItemNum(self.m_iItemID)
    self.m_txt_num_have.text = BigNumFormat(haveNum)
    self.m_txt_num_need.text = BigNumFormat(needNum)
    if needNum <= haveNum then
      UILuaHelper.SetColor(self.m_txt_num_have, 153, 255, 71)
      UILuaHelper.SetColor(self.m_txt_need_split, 153, 255, 71)
    else
      UILuaHelper.SetColor(self.m_txt_num_have, 246, 85, 85)
      UILuaHelper.SetColor(self.m_txt_need_split, 246, 85, 85)
    end
    UILuaHelper.ForceRebuildLayoutImmediate(self.m_goRoot)
  end
end

function ItemIcon:SetSwallowTouch(bSwallowTouch)
  self.m_btnClick:GetComponent("Empty4Raycast").SwallowTouch = bSwallowTouch
end

function ItemIcon:SetSelected(bSelected)
  if self.m_imageSelected then
    self.m_imageSelected:SetActive(bSelected)
  end
end

function ItemIcon:SetItemHaveGetActive(isActive)
  if self.m_item_have_get then
    UILuaHelper.SetActive(self.m_item_have_get, isActive)
  end
end

function ItemIcon:SetActive(isActive)
  if self.m_goRoot then
    self.m_goRoot.gameObject:SetActive(isActive)
  end
end

function ItemIcon:SetParent(parentTrans)
  if not parentTrans then
    return
  end
  if not self.m_goRoot then
    return
  end
  UILuaHelper.SetParent(self.m_goRoot, parentTrans)
end

function ItemIcon:GetItemRoot()
  return self.m_goRoot
end

function ItemIcon:SetItemIconClickCB(fClickCB)
  self.m_btnClick:GetComponent("Empty4Raycast").raycastTarget = fClickCB ~= nil
  self.m_fItemIconClickCB = fClickCB
end

function ItemIcon:OnItemIconClicked()
  if self.m_fItemIconClickCB then
    self.m_fItemIconClickCB(self.m_iItemID, self.m_iItemNum, self)
  end
end

return ItemIcon
