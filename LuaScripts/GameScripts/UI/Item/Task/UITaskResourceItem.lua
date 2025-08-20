local UIItemBase = require("UI/Common/UIItemBase")
local UITaskResourceItem = class("UITaskResourceItem", UIItemBase)

function UITaskResourceItem:OnInit()
  self.m_itemIconReward = self:createCommonItem(self.m_itemTemplateCache:GameObject("c_common_item"))
  self.m_itemIconReward:SetItemIconClickCB(handler(self, self.ShowItemTips))
end

function UITaskResourceItem:OnFreshData()
  local iState = self.m_itemData.iState
  local bDownloading = self.m_itemData.bDownloading
  local lCurBytes = 0
  local lTotalBytes = 0
  for _, stProgressInfo in pairs(self.m_itemData.mProgress) do
    lCurBytes = lCurBytes + stProgressInfo.lCurBytes
    lTotalBytes = lTotalBytes + stProgressInfo.lTotalBytes
  end
  local itemRootObj = self.m_itemIconReward:GetItemRoot().gameObject
  local c_bg_tips = itemRootObj.transform:Find("c_bg_tips")
  if iState == MTTDProto.QuestState_Over then
    itemRootObj:SetActive(false)
    if c_bg_tips then
      c_bg_tips.gameObject:SetActive(false)
    end
  else
    itemRootObj:SetActive(true)
    if c_bg_tips then
      c_bg_tips.gameObject:SetActive(true)
    end
  end
  if bDownloading then
    self.m_bg_item_finish:SetActive(false)
    self.m_icon_download:SetActive(true)
    self.m_icon_wait:SetActive(false)
    self.m_btn_receive:SetActive(false)
    self.m_icon_finish:SetActive(false)
    self.m_btn_continue:SetActive(false)
  elseif 0 < lTotalBytes and lCurBytes < lTotalBytes then
    if DownloadManager:IsAutoDownloadAddResAllSingle(self.m_itemData.iID) then
      self.m_bg_item_finish:SetActive(false)
      self.m_icon_download:SetActive(false)
      self.m_icon_wait:SetActive(true)
      self.m_btn_receive:SetActive(false)
      self.m_icon_finish:SetActive(false)
      self.m_btn_continue:SetActive(false)
    else
      self.m_bg_item_finish:SetActive(false)
      self.m_icon_download:SetActive(false)
      self.m_icon_wait:SetActive(false)
      self.m_btn_receive:SetActive(false)
      self.m_icon_finish:SetActive(false)
      self.m_btn_continue:SetActive(true)
    end
  elseif iState == MTTDProto.QuestState_Finish then
    self.m_bg_item_finish:SetActive(false)
    self.m_icon_download:SetActive(false)
    self.m_icon_wait:SetActive(false)
    self.m_btn_receive:SetActive(true)
    self.m_icon_finish:SetActive(false)
    self.m_btn_continue:SetActive(false)
  else
    self.m_bg_item_finish:SetActive(true)
    self.m_icon_download:SetActive(false)
    self.m_icon_wait:SetActive(false)
    self.m_btn_receive:SetActive(false)
    self.m_icon_finish:SetActive(true)
    self.m_btn_continue:SetActive(false)
  end
  local tConfigTaskResourceDownload = self.m_itemData.tConfig
  local vRewardInfo = tConfigTaskResourceDownload.m_Reward
  if 0 < vRewardInfo.Length then
    local stRewardInfo = vRewardInfo[0]
    local processData = ResourceUtil:GetProcessRewardData({
      iID = tonumber(stRewardInfo[0]),
      iNum = tonumber(stRewardInfo[1])
    })
    self.m_itemIconReward:SetItemInfo(processData)
  end
  self.m_txt_name_Text.text = tConfigTaskResourceDownload.m_mTaskName
  if self.m_txt_download_Text then
    if tConfigTaskResourceDownload.m_TaskTag ~= 5 then
      self.m_txt_download_Text.text = ConfigManager:GetCommonTextById(2032)
    else
      self.m_txt_download_Text.text = ConfigManager:GetCommonTextById(2033)
    end
  end
  self:RefreshDownloadProgress()
end

function UITaskResourceItem:RefreshDownloadProgress()
  local iState = self.m_itemData.iState
  local bDownloading = self.m_itemData.bDownloading
  local lCurBytes = 0
  local lTotalBytes = 0
  for _, stProgressInfo in pairs(self.m_itemData.mProgress) do
    lCurBytes = lCurBytes + stProgressInfo.lCurBytes
    lTotalBytes = lTotalBytes + stProgressInfo.lTotalBytes
  end
  if bDownloading then
    self.m_num_percentage:SetActive(true)
    self.m_z_txt_wait:SetActive(false)
    self.m_z_txt_done:SetActive(false)
    self.m_bar_Image.fillAmount = lCurBytes / lTotalBytes
    self.m_num_percentage_Text.text = DownloadManager:GetDownloadProgressStr(lCurBytes, lTotalBytes)
  elseif 0 < lTotalBytes and lCurBytes < lTotalBytes then
    self.m_num_percentage:SetActive(false)
    self.m_z_txt_wait:SetActive(true)
    self.m_z_txt_done:SetActive(false)
    self.m_bar_Image.fillAmount = 0
  elseif iState == MTTDProto.QuestState_Finish then
    self.m_num_percentage:SetActive(false)
    self.m_z_txt_wait:SetActive(false)
    self.m_z_txt_done:SetActive(true)
    self.m_bar_Image.fillAmount = 1
  else
    self.m_num_percentage:SetActive(false)
    self.m_z_txt_wait:SetActive(false)
    self.m_z_txt_done:SetActive(true)
    self.m_bar_Image.fillAmount = 1
  end
end

function UITaskResourceItem:OnBtnreceiveClicked()
  DownloadManager:RequestQuestTakeReward(self.m_itemData.iID)
end

function UITaskResourceItem:OnBtncontinueClicked()
  DownloadManager:ReserveDownloadByManual(self.m_itemData.iID)
end

function UITaskResourceItem:ShowItemTips(iID, iNum)
  CS.GlobalManager.Instance:TriggerWwiseBGMState(2)
  utils.openItemDetailPop({iID = iID, iNum = iNum})
end

function UITaskResourceItem:OnUpdate(dt)
  self:RefreshDownloadProgress()
end

return UITaskResourceItem
