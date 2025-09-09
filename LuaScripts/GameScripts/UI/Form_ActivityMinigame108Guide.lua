local Form_ActivityMinigame108Guide = class("Form_ActivityMinigame108Guide", require("UI/UIFrames/Form_ActivityMinigame108GuideUI"))

function Form_ActivityMinigame108Guide:SetInitParam(param)
end

function Form_ActivityMinigame108Guide:AfterInit()
  self.super.AfterInit(self)
  self.m_rootTrans = self.m_csui.m_uiGameObject.transform
  local goBackBtnRoot = self.m_rootTrans:Find("content_node/ui_common_top_back").gameObject
  if goBackBtnRoot then
    self.m_widgetBtnBack = self:createBackButton(goBackBtnRoot, handler(self, self.OnBackClk))
  end
  self.configTb = ConfigManager:GetConfigInsByName("MiniGame108Guide")
  local cdata = self.configTb:GetAll()
  self.data_list = {}
  for k, v in pairs(cdata) do
    self.data_list[k] = v
  end
  self.curIndex = 0
  self.page_items_root = self.m_rootTrans:Find("page_items")
  self.itemObjs = {}
  for i = 1, table.size(self.data_list) do
    local itemObj = GameObject.Instantiate(self.m_page_item, self.page_items_root)
    UILuaHelper.SetActive(itemObj, true)
    table.insert(self.itemObjs, itemObj)
  end
end

function Form_ActivityMinigame108Guide:ShowItemObjOn(index)
  for i = 1, table.size(self.itemObjs) do
    UILuaHelper.SetActive(self.itemObjs[i].transform:Find("c_img_selected"), false)
    UILuaHelper.SetActive(self.itemObjs[i].transform:Find("c_img_normal"), true)
  end
  UILuaHelper.SetActive(self.itemObjs[index].transform:Find("c_img_selected"), true)
  UILuaHelper.SetActive(self.itemObjs[index].transform:Find("c_img_normal"), false)
end

function Form_ActivityMinigame108Guide:OnActive()
  self.super.OnActive(self)
  self:Show(1)
  self:ShowItemObjOn(1)
end

function Form_ActivityMinigame108Guide:Show(index)
  local data = self.data_list[index]
  self.m_txt_title_Text.text = data.m_mTitle
  self.m_txt_desc_Text.text = data.m_mDesc
  UILuaHelper.SetAtlasSprite(self.m_img_content_Image, data.m_GudiePic)
  self.curIndex = index
  if self.curIndex == 1 then
    UILuaHelper.SetActive(self.m_bttn_left, false)
    UILuaHelper.SetActive(self.m_bttn_right, true)
  elseif self.curIndex == table.size(self.data_list) then
    UILuaHelper.SetActive(self.m_bttn_right, false)
    UILuaHelper.SetActive(self.m_bttn_left, true)
  else
    UILuaHelper.SetActive(self.m_bttn_left, true)
    UILuaHelper.SetActive(self.m_bttn_right, true)
  end
end

function Form_ActivityMinigame108Guide:OnInactive()
  self.super.OnInactive(self)
end

function Form_ActivityMinigame108Guide:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_ActivityMinigame108Guide:OnBackClk()
  self:CloseForm()
end

function Form_ActivityMinigame108Guide:OnBttnleftClicked()
  self.curIndex = self.curIndex - 1
  self:Show(self.curIndex)
  self:ShowItemObjOn(self.curIndex)
end

function Form_ActivityMinigame108Guide:OnBttnrightClicked()
  self.curIndex = self.curIndex + 1
  self:Show(self.curIndex)
  self:ShowItemObjOn(self.curIndex)
end

function Form_ActivityMinigame108Guide:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_ActivityMinigame108Guide", Form_ActivityMinigame108Guide)
return Form_ActivityMinigame108Guide
