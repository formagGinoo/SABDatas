local Form_LoginDownloadTips = class("Form_LoginDownloadTips", require("UI/UIFrames/Form_LoginDownloadTipsUI"))

function Form_LoginDownloadTips:SetInitParam(param)
end

function Form_LoginDownloadTips:AfterInit()
  self.super.AfterInit(self)
  self.m_sForceTitle = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsForce")
  self.m_btn_upgrade_force.transform:Find("txt02"):GetComponent("Text").text = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsDownload")
  self.m_sNormalNecessaryTitle = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsNecessaryNormal")
  self.m_btn_necessary_normal.transform:Find("txt_black_necessary_normal"):GetComponent("Text").text = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsDownloadNecessary")
  self.m_sNormalAllTitle = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsAllNormal")
  self.m_btn_later_normal.transform:Find("txt_black_later_normal"):GetComponent("Text").text = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsLater")
  self.m_btn_upgrade_right_normal.transform:Find("txt"):GetComponent("Text").text = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsDownload")
  self.m_sAutoConfirmText = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsCountDown")
  self.m_sTipsCommon03 = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsSpaceDesc")
  self.m_z_txt_tips_common04_Text.text = CS.ConfFact.LangFormat4DataInit("LoginDownloadNecessaryResourceTipsMobilePrompt")
  self.m_fAutoConfirmTimeMax = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("FullDownloadCountdown").m_Value)
end

function Form_LoginDownloadTips:OnActive()
  self.super.OnActive(self)
  local tParam = self.m_csui.m_param
  self.m_isNewbie = tParam.isNewbie
  self.m_isNecessary = tParam.isNecessary
  self.m_isForceDownload = tParam.isForceDownload
  self.m_callback = tParam.callback
  self.m_Btn_Return:SetActive(true)
  self:RefreshDownloadAllInfo()
  if self.m_isForceDownload then
    self.m_pnl_download_force:SetActive(true)
    self.m_pnl_download_normal:SetActive(false)
    self.m_z_textTitle_force_Text.text = string.gsub(self.m_sForceTitle, "{size}", DownloadManager:GetDownloadSizeStr(self.m_lDownloadAllSizeTotal - self.m_lDownloadAllSizeDownloaded))
    self.m_countDownTxt = self.m_z_txt_countdown_force_Text
  else
    self.m_pnl_download_force:SetActive(false)
    self.m_pnl_download_normal:SetActive(true)
    if self.m_isNecessary then
      self.m_z_textTitle_necessary_normal:SetActive(true)
      self.m_z_textTitle_all_normal:SetActive(false)
      self:RefreshDownloadNecessaryInfo()
      self.m_z_textTitle_necessary_normal_Text.text = string.customizereplace(self.m_sNormalNecessaryTitle, {"{size1}", "{size2}"}, DownloadManager:GetDownloadSizeStr(self.m_lDownloadNecessarySizeTotal - self.m_lDownloadNecessarySizeDownloaded), DownloadManager:GetDownloadSizeStr(self.m_lDownloadAllSizeTotal - self.m_lDownloadAllSizeDownloaded - (self.m_lDownloadNecessarySizeTotal - self.m_lDownloadNecessarySizeDownloaded)))
      self.m_btn_necessary_normal:SetActive(true)
      self.m_btn_later_normal:SetActive(false)
    else
      self.m_z_textTitle_necessary_normal:SetActive(false)
      self.m_z_textTitle_all_normal:SetActive(true)
      self.m_z_textTitle_all_normal_Text.text = string.gsub(self.m_sNormalAllTitle, "{size}", DownloadManager:GetDownloadSizeStr(self.m_lDownloadAllSizeTotal - self.m_lDownloadAllSizeDownloaded))
      self.m_btn_necessary_normal:SetActive(false)
      self.m_btn_later_normal:SetActive(true)
    end
    self.m_countDownTxt = self.m_z_txt_countdown_normal_Text
  end
  self.m_pnl_download_common:SetActive(true)
  local availableSize = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
  self.m_z_txt_tips_common03_Text.text = string.gsub(self.m_sTipsCommon03, "{device_size}", DownloadManager:GetDownloadSizeStr(availableSize))
  self.m_fAutoConfirmTime = 0
  self:RefreshConnectStatus()
  self:RefreshAutoConfirm(0)
end

function Form_LoginDownloadTips:RefreshDownloadAllInfo()
  local sCoreResourcePackName, sExpansionResourcePackName = DownloadManager:GetLoginResourcePackName()
  local vPackage = {}
  local vExtraResource = {}
  local sPackages = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName(sCoreResourcePackName).m_Value
  local vCorePackages = string.split(sPackages, "/")
  for k, v in ipairs(vCorePackages) do
    vPackage[#vPackage + 1] = {
      sName = v,
      eType = DownloadManager.ResourcePackageType.Custom
    }
  end
  local levelMainHelper = LevelManager:GetLevelMainHelper()
  local chapterCfg = levelMainHelper:GetCurrentLevelCfg(LevelManager.MainLevelSubType.MainStory)
  if chapterCfg and chapterCfg.m_ChapterID <= 6 then
    for i = chapterCfg.m_ChapterID, 6 do
      if i == 1 then
        vPackage[#vPackage + 1] = {
          sName = "Pack_0-3",
          eType = DownloadManager.ResourcePackageType.Custom
        }
      else
        local sChapterName = string.format("Pack_MainLevel_%d", i - 1)
        vPackage[#vPackage + 1] = {
          sName = sChapterName,
          eType = DownloadManager.ResourcePackageType.Custom
        }
      end
    end
  end
  sPackages = ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName(sExpansionResourcePackName).m_Value
  local vExpansionPackages = string.split(sPackages, "/")
  for k, v in ipairs(vExpansionPackages) do
    vPackage[#vPackage + 1] = {
      sName = v,
      eType = DownloadManager.ResourcePackageType.Custom
    }
  end
  if self.m_isNewbie then
    vPackage[#vPackage + 1] = {
      sName = "Pack_Prologue",
      eType = DownloadManager.ResourcePackageType.Custom
    }
  end
  local stLanguageElment = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
  vExtraResource[#vExtraResource + 1] = {
    sName = "AllLanguage" .. stLanguageElment.m_LanguageObject,
    eType = DownloadManager.ResourceType.Language
  }
  vExtraResource[#vExtraResource + 1] = {
    sName = "AddLanguage" .. stLanguageElment.m_LanguageObject,
    eType = DownloadManager.ResourceType.Language
  }
  vExtraResource[#vExtraResource + 1] = {
    sName = "LanResObj_" .. stLanguageElment.m_Translation .. "_add",
    eType = DownloadManager.ResourceType.LanResObj
  }
  self.m_vDownloadAllResourceAB = DownloadManager:GetResourceABList(vPackage, vExtraResource)
  self.m_lDownloadAllSizeTotal = DownloadManager:GetResourceABListTotalBytes(self.m_vDownloadAllResourceAB)
  self.m_lDownloadAllSizeDownloaded = DownloadManager:GetResourceABListDownloadedBytes(self.m_vDownloadAllResourceAB)
end

function Form_LoginDownloadTips:RefreshDownloadNecessaryInfo()
  local vPackage = {}
  local vExtraResource = {}
  if self.m_isNewbie then
    vPackage[#vPackage + 1] = {
      sName = "Pack_Prologue",
      eType = DownloadManager.ResourcePackageType.Custom
    }
  else
    vPackage[#vPackage + 1] = {
      sName = "Pack_Hall",
      eType = DownloadManager.ResourcePackageType.Custom
    }
  end
  local stLanguageElment = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
  vExtraResource[#vExtraResource + 1] = {
    sName = "AllLanguage" .. stLanguageElment.m_LanguageObject,
    eType = DownloadManager.ResourceType.Language
  }
  vExtraResource[#vExtraResource + 1] = {
    sName = "AddLanguage" .. stLanguageElment.m_LanguageObject,
    eType = DownloadManager.ResourceType.Language
  }
  vExtraResource[#vExtraResource + 1] = {
    sName = "LanResObj_" .. stLanguageElment.m_Translation .. "_add",
    eType = DownloadManager.ResourceType.LanResObj
  }
  self.m_vDownloadNecessaryResourceAB = DownloadManager:GetResourceABList(vPackage, vExtraResource)
  self.m_lDownloadNecessarySizeTotal = DownloadManager:GetResourceABListTotalBytes(self.m_vDownloadNecessaryResourceAB)
  self.m_lDownloadNecessarySizeDownloaded = DownloadManager:GetResourceABListDownloadedBytes(self.m_vDownloadNecessaryResourceAB)
end

function Form_LoginDownloadTips:RefreshConnectStatus()
  local bAutoConfirm = CS.DeviceUtil.IsWIFIConnected()
  if self.m_bAutoConfirm ~= bAutoConfirm then
    self.m_bAutoConfirm = bAutoConfirm
    self.m_fAutoConfirmTime = 0
  end
  if self.m_bAutoConfirm then
    if not utils.isNull(self.m_countDownTxt) then
      self.m_countDownTxt.gameObject:SetActive(true)
    end
    self.m_z_txt_tips_common04:SetActive(false)
  else
    if not utils.isNull(self.m_countDownTxt) then
      self.m_countDownTxt.gameObject:SetActive(false)
    end
    self.m_z_txt_tips_common04:SetActive(true)
  end
end

function Form_LoginDownloadTips:RefreshAutoConfirm(dt)
  if self.m_bAutoConfirm then
    self.m_fAutoConfirmTime = self.m_fAutoConfirmTime + dt
    local fRemainTime = self.m_fAutoConfirmTimeMax - self.m_fAutoConfirmTime
    self.m_countDownTxt.text = string.gsub(self.m_sAutoConfirmText, "{count}", math.ceil(fRemainTime))
    if fRemainTime <= 0 then
      self.m_fAutoConfirmTime = 0
      if self.m_isForceDownload then
        self:OnBtnupgradeforceClicked(true)
      else
        self:OnBtnupgraderightnormalClicked(true)
      end
    end
  end
end

function Form_LoginDownloadTips:OnBtnupgradeforceClicked(isAutoConfirm)
  LocalDataManager:SetIntSimple("LoginDownloadTipsSelect", 2)
  if self.m_callback then
    self.m_callback(true, isAutoConfirm, {
      vResourceAB = self.m_vDownloadAllResourceAB,
      lSizeTotal = self.m_lDownloadAllSizeTotal,
      lSizeDownloaded = self.m_lDownloadAllSizeDownloaded
    }, 1)
  end
  self:CloseForm()
end

function Form_LoginDownloadTips:OnBtnnecessarynormalClicked()
  LocalDataManager:SetIntSimple("LoginDownloadTipsSelect", 1)
  if self.m_callback then
    self.m_callback(true, false, {
      vResourceAB = self.m_vDownloadNecessaryResourceAB,
      lSizeTotal = self.m_lDownloadNecessarySizeTotal,
      lSizeDownloaded = self.m_lDownloadNecessarySizeDownloaded
    }, 1)
  end
  self:CloseForm()
end

function Form_LoginDownloadTips:OnBtnlaternormalClicked()
  LocalDataManager:SetIntSimple("LoginDownloadTipsSelect", 0)
  if self.m_callback then
    self.m_callback(false, false)
  end
  self:CloseForm()
end

function Form_LoginDownloadTips:OnBtnupgraderightnormalClicked(isAutoConfirm)
  LocalDataManager:SetIntSimple("LoginDownloadTipsSelect", 2)
  if self.m_callback then
    self.m_callback(true, isAutoConfirm, {
      vResourceAB = self.m_vDownloadAllResourceAB,
      lSizeTotal = self.m_lDownloadAllSizeTotal,
      lSizeDownloaded = self.m_lDownloadAllSizeDownloaded
    }, 2)
  end
  self:CloseForm()
end

function Form_LoginDownloadTips:OnBtnReturnClicked()
  if self.m_callback then
    if self.m_isForceDownload then
      CS.ApplicationManager.Instance:RestartGame()
    elseif self.m_isNecessary then
      CS.ApplicationManager.Instance:RestartGame()
    else
      self:OnBtnlaternormalClicked()
    end
  end
end

function Form_LoginDownloadTips:OnBtnCloseClicked()
end

function Form_LoginDownloadTips:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoginDownloadTips:OnUpdate(dt)
  self:RefreshConnectStatus()
  self:RefreshAutoConfirm(dt)
end

function Form_LoginDownloadTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LoginDownloadTips:IsOpenGuassianBlur()
  return true
end

ActiveLuaUI("Form_LoginDownloadTips", Form_LoginDownloadTips)
return Form_LoginDownloadTips
