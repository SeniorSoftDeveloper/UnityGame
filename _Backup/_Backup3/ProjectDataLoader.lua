---- Copyright (c) Cragon. All rights reserved.
--
-----------------------------------------
--ProjectDataLoader = {
--	Instance = nil,
--	DataVersion = nil,
--	DataVersionKey = nil,
--	DataFileURLRoot = nil,
--	FunctionLoadDown = nil,
--	MainC = nil,
--	WWWProjectData = nil,
--	RemoteDataFileListBytes = nil,
--	TableRemoteData = {},
--	TableLocalData = {},
--	TableNeedLoadFileInfo = {},
--}
--
-----------------------------------------
--function ProjectDataLoader:new(o)
--	 o = o or {}
--    setmetatable(o,self)
--    self.__index = self
--    if(self.Instance==nil)
--	then
--		self.Instance = o
--	end
--
--    return self.Instance
--end
--
-----------------------------------------
--function ProjectDataLoader:onCreate(data_version,data_filelist_name,commonlua_root_url,local_commonlua_versionkey,function_loaddown)
--	self.DataVersion = data_version
--	self.DataFileURLRoot = commonlua_root_url
--	self.DataVersionKey = local_commonlua_versionkey
--	self.FunctionLoadDown = function_loaddown
--	self.MainC = MainC:new(nil)
--
--	local path_mgr = CS.Casinos.CasinosContext.Instance.PathMgr
--	local datafilelist_path_local = path_mgr:combinePersistentDataPath('DataFileList.txt',true)
--	local filelist_info_local = CS.Casinos.LuaHelper.readAllText(datafilelist_path_local)
--	if(filelist_info_local~=nil)
--	then
--		self:ParseDataFileList(filelist_info_local, true)
--	end
--
--	local datafilelist_remoteurl = self:CombineRemoteDataPath(data_filelist_name)
--	datafilelist_remoteurl = CS.Casinos.CasinoHelper.FormalUrlWithRandomVersion(datafilelist_remoteurl)
--	self.WWWProjectData = CS.UnityEngine.WWW(datafilelist_remoteurl)
--end
--
-----------------------------------------
--function ProjectDataLoader:onUpdate()
--	if(self.WWWProjectData == nil)
--	then
--		return
--	end
--
--	if (self.WWWProjectData.isDone == true)
--	then
--        if ((self.WWWProjectData.error == nil or (self.WWWProjectData.error ~= nil and string.len(self.WWWProjectData.error) <= 0)))
--		then
--			self.RemoteDataFileListBytes = self.WWWProjectData.bytes
--			self:ParseDataFileList(self.WWWProjectData.text,false)
--
--			self.TableNeedLoadFileInfo = self:_getNeedLoadAssetAndDeleteOldAsset()
--			local need_load_count = self.MainC.LuaHelper:GetTableCount(self.TableNeedLoadFileInfo)
--			if(need_load_count > 0)
--			then
--				self.MainC.WWWLoader:StartDownload(self.TableNeedLoadFileInfo,self.LoadPro,self.LoadOneFileDown,self.LoadDown)
--			else
--				self.LoadDown()
--			end
--            self.WWWProjectData = nil
--		else
--			CS.Casinos.UiHelperCasinos.UiShowPreLoading("WWWProjectData Error "..self.WWWProjectData.error.."  url = "..self.WWWProjectData.url,0)
--		end
--	end
--end
--
-----------------------------------------
--function ProjectDataLoader:onRelease()
--	print('UpdateData___UpdateDataRelease')
--end
--
-----------------------------------------
--function ProjectDataLoader:ParseDataFileList(data_filelist_text,is_local)
--		local split_array = self.MainC.LuaHelper:SplitStr(data_filelist_text,'\n')
--		for key,value in pairs(split_array) do
--			 if (string.len(value) > 0)
--			 then
--				 local info_array = self.MainC.LuaHelper:SplitStr(value,' ')
--				 local info_array_count = self.MainC.LuaHelper:GetTableCount(info_array)
--				 if (is_local == true)
--				 then
--					 if (info_array_count == 2)
--					 then
--						self.TableLocalData[info_array[1]] = info_array[2]
--					 end
--				 else
--					 if (info_array_count == 2)
--					 then
--						self.TableRemoteData[info_array[1]] = info_array[2]
--					 end
--				 end
--			 end
--		end
--end
--
-----------------------------------------
--function ProjectDataLoader.LoadPro(current_index,total)
--	local pro = current_index / total
--	local tips = "????????????????????????????????????"
--	if(CS.Casinos.CasinosContext.Instance.UseLan == true)
--	then
--		local lan = CS.Casinos.CasinosContext.Instance.CurrentLan
--		if(lan == "English")
--		then
--			tips = "Updating the art resources, please wait"
--		else
--			if(lan == "Chinese" or lan == "ChineseSimplified")
--			then
--				tips = "????????????????????????????????????"
--			end
--		end
--	end
--	CS.Casinos.UiHelperCasinos.UiShowPreLoading(tips,pro * 100)
--end
--
-----------------------------------------
--function ProjectDataLoader.LoadOneFileDown(key,file_bytes)
--	-- ?????????
--	local path_mgr = CS.Casinos.CasinosContext.Instance.PathMgr
--	local local_file_path =	path_mgr:combinePersistentDataPath(key,true)
--	CS.Casinos.LuaHelper.writeFile(file_bytes,local_file_path)
--end
--
-----------------------------------------
--function ProjectDataLoader.LoadDown()
--	local loader = ProjectDataLoader:new(nil)
--	local path_mgr = CS.Casinos.CasinosContext.Instance.PathMgr
--	local local_file_path =	path_mgr:combinePersistentDataPath("DataFileList.txt",true)
--	CS.Casinos.LuaHelper.writeFile(loader.RemoteDataFileListBytes,local_file_path)
--	CS.UnityEngine.PlayerPrefs.SetString(loader.DataVersionKey,loader.DataVersion)
--	if(loader.FunctionLoadDown ~= nil)
--	then
--		loader.FunctionLoadDown()
--	end
--end
--
-----------------------------------------
--function ProjectDataLoader:CombineRemoteDataPath(path)
--	return self.DataFileURLRoot..path
--end
--
-----------------------------------------
--function ProjectDataLoader:_getNeedLoadAssetAndDeleteOldAsset()
--	local needloadasset_array = {}
--	local same_asset_array = {}
--
--	for key,value in pairs(self.TableRemoteData) do
--		local datamd5_local = self.TableLocalData[key]
--		if(datamd5_local ~= nil and string.len(datamd5_local) > 0)
--		then
--			 if (datamd5_local == value)
--			 then
--				same_asset_array[key] = value
--			 else
--				local data_remoteurl = self:CombineRemoteDataPath(key)
--				needloadasset_array[key] = data_remoteurl
--			 end
--		else
--			local data_remoteurl = self:CombineRemoteDataPath(key)
--			needloadasset_array[key]= data_remoteurl
--		end
--	end
--
--	for key,value in pairs(self.TableLocalData) do
--		 local same_asset = same_asset_array[key]
--		 if(same_asset==nil)
--		 then
--			local need_del_file = CS.Casinos.CasinosContext.Instance.PathMgr:combinePersistentDataPath(key,true)
--			CS.Casinos.LuaHelper.deleteFile(need_del_file)
--		 end
--	end
--
--	return needloadasset_array
--end