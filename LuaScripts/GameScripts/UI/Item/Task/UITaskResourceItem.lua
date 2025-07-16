local UIItemBase = require("UI/Common/UIItemBase")
local UITaskResourceItem = class("UITaskResourceItem", UIItemBase)

function UITaskResourceItem:OnInit()
  self.m_itemIconReward = self:createCommonItem(self.m_itemTemplateCache:GameObject("c_common_item"))
  self.m_itemIconReward:SetItemIconClickCB(handler(self, self.ShowItemTips))
end

function UITaskResourceItem:OnFreshData()
  local iState = self.m_itemData.iState
  local bDownloading = self.m_itemData.bDownloading
  if iState == MTTDProto.QuestState_Doing and bDownloading then
    self.m_bg_item_finish:SetActive(false)
    self.m_icon_download:SetActive(true)
    self.m_icon_wait:SetActive(false)
    self.m_btn_receive:SetActive(false)
    self.m_icon_finish:SetActive(false)
    self.m_btn_continue:SetActive(false)
  elseif iState == MTTDProto.QuestState_Finish then
    self.m_bg_item_finish:SetActive(false)
    self.m_icon_download:SetActive(false)
    self.m_icon_wait:SetActive(false)
    self.m_btn_receive:SetActive(true)
    self.m_icon_finish:SetActive(false)
    self.m_btn_continue:SetActive(false)
  elseif iState == MTTDProto.QuestState_Doing and not bDownloading then
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
  if vRewardInfo.Length > 0 then
    local stRewardInfo = vRewardInfo[0]
    local processData = ResourceUtil:GetProcessRewardData({
      iID = tonumber(stRewardInfo[0]),
      iNum = tonumber(stRewardInfo[1])
    })
    self.m_itemIconReward:SetItemInfo(processData)
  end
  self.m_txt_name_Text.text = tConfigTaskResourceDownload.m_mTaskName
  self:RefreshDownloadProgress()
end

function UITaskResourceItem:RefreshDownloadProgress()
  local iState = self.m_itemData.iState
  local bDownloading = self.m_itemData.bDownloading
  if iState == MTTDProto.QuestState_Doing and bDownloading then
    self.m_num_percentage:SetActive(true)
    self.m_z_txt_wait:SetActive(false)
    self.m_z_txt_done:SetActive(false)
    local mProgress = self.m_itemData.mProgress
    local lTotalBytes = 0
    local lCurBytes = 0
    for _, stProgressInfo in pairs(mProgress) do
      lTotalBytes = lTotalBytes + stProgressInfo.lTotalBytes
      lCurBytes = lCurBytes + stProgressInfo.lCurBytes
    end
    self.m_bar_Image.fillAmount = lCurBytes / lTotalBytes
    self.m_num_percentage_Text.text = DownloadManager:GetDownloadProgressStr(lCurBytes, lTotalBytes)
  elseif iState == MTTDProto.QuestState_Finish then
    self.m_num_percentage:SetActive(false)
    self.m_z_txt_wait:SetActive(false)
    self.m_z_txt_done:SetActive(true)
    self.m_bar_Image.fillAmount = 1
  elseif iState == MTTDProto.QuestState_Doing and not bDownloading then
    self.m_num_percentage:SetActive(false)
    self.m_z_txt_wait:SetActive(true)
    self.m_z_txt_done:SetActive(false)
    self.m_bar_Image.fillAmount = 0
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
