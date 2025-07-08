local Form_Main = class("Form_Main", require("UI/UIFrames/Form_MainUI"))

function Form_Main:SetInitParam(param)
end

function Form_Main:AfterInit()
end

function Form_Main:OnActive()
  local rawImage = self.m_3dPlayer:GetComponent("RawImage")
  rawImage.texture = CS.ModelCtrl.Instance.m_RenderTexture
  self.m_downloadText_Text.text = ""
  local versionContext = CS.VersionContext.GetContext()
  self.m_version_Text.text = versionContext.ClientLocalVersionFull
  StackFlow:DestroyUI(UIDefines.ID_FORM_LOGINNEW)
  StackFlow:DestroyUI(UIDefines.ID_FORM_LOGINANNOUNCEMENT)
  StackFlow:DestroyUI(UIDefines.ID_FORM_LOGINANNOUNCEMENTMAINTAIN)
  StackFlow:DestroyUI(UIDefines.ID_FORM_LOGINANNOUNCEMENTUPGRADE)
  CS.AkSoundEngine.SetRTPCValue("playback_speed", 500)
  CS.WwiseMusicPlayer.Instance:PlayBGM("New_SoundBank.bnk", "Play_400101_atked02")
  log.info("MUF AUTO ENTER MAIN CITY")
end

function Form_Main:OnStartBtnClicked()
  log.info("Enter Battle Game")
  self:TestTrgpDownLoad()
end

function Form_Main:TestTrgpDownLoad()
  CS.TGRPDownloader.InitService()
  local util = require("common/XLua/util")
  CS.MonoMethodUtil.StartCoroutine(util.cs_generator(function()
    coroutine.yield(CS.TGRPDownloader.InitAddResDownloader())
    local availableSize = CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024
    local unDownloadedSize = CS.TGRPDownloader.UnDownloadedAddResSize
    log.info("TestCyd unDownloadedSize: " .. tostring(unDownloadedSize))
    if availableSize < unDownloadedSize then
      return
    end
    CS.TGRPDownloader.DownloadAddRes(function(ret)
      if ret == true then
        log.info("TestCyd DownloadAddRes complete !!!")
      end
    end, function()
      log.info("TestCyd DownloadAddRes start !!!")
    end, function(curBytes, totalBytes, speed)
      log.info(string.format("curBytes:%s,totalBytes:%s,speed:%s", tostring(curBytes), tostring(totalBytes), tostring(speed)))
    end)
  end))
end

function Form_Main:OnFriendBtnClicked()
  self.m_progress:SetActive(true)
  log.info("Start PreDownload ")
  local loginContext = CS.LoginContext.GetContext()
  
  local function CheckPreDownload(flag)
    log.info("CheckPreDownload :", tostring(flag))
    if flag == true then
      CS.MUF.Download.DownloadResource.Instance:StartPreDownload(callback.handler(self, self.OnPreDownloadCB), callback.handler(self, self.OnPreDownloadProgress))
    end
  end
  
  log.info("loginContext.ClientLoginVersion : ", loginContext.ClientLoginVersion)
  log.info("resFile version :", self.m_InputField_InputField.text)
  if self.m_InputField_InputField.text ~= "" then
    local handler = CS.MUF.Download.DownloadResource.Instance:CheckPreDownload(self.m_InputField_InputField.text, CheckPreDownload)
  end
end

function Form_Main:OnPreDownloadCB(handler)
  log.info("预下载版本:", self.m_InputField_InputField.text, " 增量预下载完成")
  self.m_downloadText_Text.text = "增量预下载完成"
end

function Form_Main:OnPreDownloadProgress(handler)
  if handler.Status ~= CS.MUF.Download.DownloadStatus.Success then
    local progress = math.floor(handler.CurrDownloadSize / handler.NeedDownloadSize)
    self.m_downloadText_Text.text = "预下载增量 下载百分比： " .. progress .. " 当前下载量:" .. handler.CurrDownloadFileCount .. " 总量 : " .. handler.NeedDownloadFileCount
  end
end

function Form_Main:OnSkinBtnClicked()
  self.m_progress:SetActive(true)
  log.info("Start PreUpgradePatch ")
  local versionContext = CS.VersionContext.GetContext()
  local loginContext = CS.LoginContext.GetContext()
  log.info("Start PreUpgradePatch versionContext.ClientLocalVersionFull ", versionContext.ClientLocalVersionFull)
  log.info("Start PreUpgradePatch loginContext.ResPatchList ", tostring(loginContext.ResPatchList))
  
  local function CheckUpgrade(version)
    log.info("version : ", version)
    log.info("upgradePatch version :", self.m_InputField_InputField.text)
    if self.m_InputField_InputField.text ~= "" and version ~= "0" then
      CS.MUF.Download.UpgradePatch.Instance:StartUpgradePatch(versionContext.ClientLocalVersion, false, callback.handler(self, self.OnPreUpgradePathCB), callback.handler(self, self.OnPreUpgradePathProgress))
    else
      log.error("CDN热更预下载 patch_list.json 不存在 或者 输入的预下载版本为空!!!")
    end
  end
  
  local function updateCallBack(result)
    log.info("sharpfix result : ", result)
    if result ~= 1 then
      CS.com.muf.sharpfix.SharpFixPatchManager.Instance:LoadAllSharpFixPatch()
    end
  end
  
  list = {}
  list[1] = "http://192.168.40.14:8080/mufgames/framework/sharpfix_patch5/"
  list[2] = "http://192.168.40.14:8080/mufgames/framework/ios_sharpfix_patch5/"
  CS.com.muf.sharpfix.SharpFixPatchManager.Instance:DownloadSharpFixPatchByServer(list, updateCallBack)
end

function Form_Main:OnPreUpgradePathCB(handler)
  log.info("预下载热更包完成 : ", handler.Name)
  self.m_downloadText_Text.text = "热更包完成"
  CS.MUF.Download.UpgradePatch.Instance:CheckVersion()
end

function Form_Main:OnPreUpgradePathProgress(handler)
  if handler.NeedDownloadSize > 0 and 0 >= handler.NeedUnZipFileSize then
    local progress = handler.CurrDownloadSize / handler.NeedDownloadSize
    log.info("download progress  : ", progress)
    self.m_downloadText_Text.text = "预下载热更新包 下载中 : " .. progress .. "%"
  end
  if 0 < handler.NeedUnZipFileSize then
    local zipProgress = handler.CurrUnZipFileSize / handler.NeedUnZipFileSize
    log.info("zip progress : ", zipProgress)
    self.m_downloadText_Text.text = "预下载热更新包 解压中 : " .. zipProgress .. "%"
  end
end

local bOpen = false
local bPause = false

function Form_Main:OnShopBtnClicked()
  self.m_progress:SetActive(true)
  if bOpen == true then
    if bPause then
      CS.MUF.Download.DownloadResource.Instance:ResumeAllDownload()
      bPause = false
    else
      CS.MUF.Download.DownloadResource.Instance:PauseAllDownload()
      bPause = true
    end
  else
    log.error("TestCyd Form_Main OnShopBtnClicked==========================")
    bOpen = true
    local handle = CS.MUF.Download.DownloadResource.Instance:StartBackgroundDownload(callback.handler(self, self.OnBackgroundCB), callback.handler(self, self.OnBackgroundProgress))
    self:OnBackgroundProgress(handle)
  end
end

function Form_Main:OnBackgroundCB(handler)
  local versionContext = CS.VersionContext.GetContext()
  log.info("当前版本:", versionContext.ClientLocalVersion, " 增量下载完成")
  log.info("增量下载状态 :" .. tostring(handler.Status))
  self.m_downloadText_Text.text = "后台增量下载完成 "
end

function Form_Main:OnBackgroundProgress(handler)
  if handler.Status ~= CS.MUF.Download.DownloadStatus.Success then
    local progress = math.floor(handler.CurrDownloadSize / handler.NeedDownloadSize)
    self.m_downloadText_Text.text = "后台增量 下载百分比： " .. progress .. "  当前下载量:" .. handler.CurrDownloadFileCount .. " 总量 : " .. handler.NeedDownloadFileCount
  end
end

function Form_Main:OnUpdate(dt)
end

ActiveLuaUI("Form_Main", Form_Main)
local fullscreen = true
return Form_Main
