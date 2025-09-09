local UIItemBase = require("UI/Common/UIItemBase")
local Minigame108AssembleItem = class("Minigame108AssembleItem", UIItemBase)
local perportyIconPath = {
  "Atlas_Activity108Minigame-1/activity108minigame_popup_icon_01",
  "Atlas_Activity108Minigame-1/activity108minigame_popup_icon_02",
  "Atlas_Activity108Minigame-1/activity108minigame_popup_icon_05",
  "Atlas_Activity108Minigame-1/activity108minigame_popup_icon_06"
}

function Minigame108AssembleItem:OnInit()
  if self.m_itemInitData then
    self.OnItemClkCallback = self.m_itemInitData.OnItemClk
  end
  self.btnEx = self.m_btn:GetComponent("ButtonExtensions")
  UILuaHelper.SetActive(self.m_btn_select, false)
end

function Minigame108AssembleItem:MoniClick()
  self.OnItemClkCallback(self.m_itemData, self.m_itemIndex, self.is_select)
end

function Minigame108AssembleItem:OnFreshData()
  if self.btnEx then
    function self.btnEx.Clicked()
      if self.OnItemClkCallback then
        self:MoniClick()
      end
    end
  end
  self.allProperty = {}
  if self.m_itemData.cfg.m_Property1Num ~= 0 then
    table.insert(self.allProperty, 1)
  end
  if self.m_itemData.cfg.m_Property2Num ~= 0 then
    table.insert(self.allProperty, 2)
  end
  if self.m_itemData.cfg.m_Property3Num ~= 0 then
    table.insert(self.allProperty, 3)
  end
  if self.m_itemData.cfg.m_Property4Num ~= 0 then
    table.insert(self.allProperty, 4)
  end
  self.m_txt_assemble_Text.text = self.m_itemData.cfg.m_mName
  if 2 <= table.size(self.allProperty) then
    UILuaHelper.SetActive(self.m_txt_assemblenum1.transform.parent, true)
    UILuaHelper.SetActive(self.m_txt_assemblenum2.transform.parent, true)
    UILuaHelper.SetTPAtlasSprite(self.m_img_component1_Image, perportyIconPath[self.allProperty[1]])
    UILuaHelper.SetTPAtlasSprite(self.m_img_component2_Image, perportyIconPath[self.allProperty[2]])
    self.m_txt_assemblenum1_Text.text = self.m_itemData.cfg["m_Property" .. self.allProperty[1] .. "Num"]
    self.m_txt_assemblenum2_Text.text = self.m_itemData.cfg["m_Property" .. self.allProperty[2] .. "Num"]
  else
    UILuaHelper.SetActive(self.m_txt_assemblenum2.transform.parent, false)
    UILuaHelper.SetTPAtlasSprite(self.m_img_component1_Image, perportyIconPath[self.allProperty[1]])
    self.m_txt_assemblenum1_Text.text = self.m_itemData.cfg["m_Property" .. self.allProperty[1] .. "Num"]
  end
  UILuaHelper.SetAtlasSprite(self.m_item_Image, self.m_itemData.cfg.m_IconPath)
  UILuaHelper.SetActive(self.m_btn_select, self.m_itemData.is_select)
end

function Minigame108AssembleItem:SetSelect(is_select)
  self.m_itemData.is_select = is_select
  UILuaHelper.SetActive(self.m_btn_select, is_select)
end

function Minigame108AssembleItem:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

return Minigame108AssembleItem
