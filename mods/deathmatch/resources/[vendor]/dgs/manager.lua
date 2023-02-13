local loadstring = loadstring
-------------------------------------------------Parent/Layer Manager
--Speed Up
local tableInsert = table.insert
local tableRemove = table.remove
local tableFind = table.find
local isElement = isElement
local assert = assert
local tostring = tostring
local tonumber = tonumber
local type = type
local mathMin = math.min
local mathMax = math.max
local mathClamp = math.restrict
local getElementType = getElementType

--Parent System
BottomFatherTable = {}		--Store Bottom Father Element
CenterFatherTable = {}		--Store Center Father Element (Default)
TopFatherTable = {}			--Store Top Father Element
dgsWorld3DTable = {}
dgsScreen3DTable = {}
FatherTable = {}			--Store Father Element
ChildrenTable = {}			--Store Children Element
LayerCastTable = {center=CenterFatherTable,top=TopFatherTable,bottom=BottomFatherTable}
--
--Element Data System
dgsElementData = {[resourceRoot] = {}}		----The Global BuiltIn DGS Element Data Table
local l_dgsElementData = dgsElementData
--
--Element Type
dgsElementType = {}
local l_dgsElementType = dgsElementType
--
function dgsSetLayer(dgsEle,layer,forceDetatch)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetLayer",1,"dgs-dxelement")) end
	if dgsElementType[dgsEle] == "dgs-dxtab" then return false end
	if not(layerBuiltIn[layer]) then error(dgsGenAsrt(layer,"dgsSetLayer",2,"string","top/center/bottom")) end
	local hasParent = isElement(FatherTable[dgsEle])
	if hasParent and not forceDetatch then return false end
	if hasParent then
		local id = tableFind(ChildrenTable[FatherTable[dgsEle]],dgsEle)
		if id then
			tableRemove(ChildrenTable[FatherTable[dgsEle]],id)
		end
		FatherTable[dgsEle] = nil
	end
	local oldLayer = dgsElementData[dgsEle].alwaysOn or "center"
	if oldLayer == layer then return false end
	local id = tableFind(LayerCastTable[oldLayer],dgsEle)
	if id then
		tableRemove(LayerCastTable[oldLayer],id)
	end
	dgsSetData(dgsEle,"alwaysOn",layer == "center" and false or layer)
	tableInsert(LayerCastTable[layer],dgsEle)
	return true
end

function dgsGetLayer(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetLayer",1,"dgs-dxelement")) end
	return dgsElementData[dgsEle].alwaysOn or "center"
end

function dgsSetCurrentLayerIndex(dgsEle,index)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsSetCurrentLayerIndex",1,"dgs-dxelement")) end
	if not(type(index) == "number") then error(dgsGenAsrt(index,"dgsSetCurrentLayerIndex",2,"number")) end
	local layer = dgsElementData[dgsEle].alwaysOn or "center"
	local hasParent = isElement(FatherTable[dgsEle])
	local theTable = hasParent and ChildrenTable[FatherTable[dgsEle]] or LayerCastTable[layer]
	local index = mathClamp(index,1,#theTable+1)
	local id = tableFind(theTable,dgsEle)
	if id then
		tableRemove(theTable,id)
	end
	tableInsert(theTable,index,dgsEle)
	return true
end

function dgsGetCurrentLayerIndex(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetCurrentLayerIndex",1,"dgs-dxelement")) end
	local layer = dgsElementData[dgsEle].alwaysOn or "center"
	local hasParent = isElement(FatherTable[dgsEle])
	local theTable = hasParent and ChildrenTable[FatherTable[dgsEle]] or LayerCastTable[layer]
	return tableFind(theTable,dgsEle) or false
end

function dgsGetLayerElements(layer)
	if not(layerBuiltIn[layer]) then error(dgsGenAsrt(layer,"dgsGetLayerElements",1,"string","top/center/bottom")) end
	return #LayerCastTable[layer] or false
end

function dgsGetChild(parent,id) return ChildrenTable[parent][id] or false end
function dgsGetChildren(parent) return ChildrenTable[parent] or {} end
function dgsGetParent(child) return FatherTable[child] or false end
function dgsGetDxGUINoParent(alwaysBottom) return alwaysBottom and BottomFatherTable or CenterFatherTable end

function dgsGetDxGUIFromResource(res)
	local res = res or sourceResource
	if res then
		local serialized,cnt = {},0
		for k,v in pairs(boundResource[res] or {}) do
			cnt = cnt+1
			serialized[cnt] = k
		end
		return serialized
	end
end

function dgsSetParent(child,parent,nocheckfather,noUpdatePosSize)
	if parent == resourceRoot then parent = nil end
	if not(dgsIsType(child)) then error(dgsGenAsrt(child,"dgsSetParent",1,"dgs-dxelement")) end
	if not(not dgsElementData[child] or not dgsElementData[child].attachTo) then error(dgsGenAsrt(child,"dgsSetParent",1,_,_,_,"attached dgs element can not have a parent")) end
	local _parent = FatherTable[child]
	local parentTable = isElement(_parent) and ChildrenTable[_parent] or CenterFatherTable
	if isElement(parent) then
		if not dgsIsType(parent) then return end
		if not nocheckfather then
			local id = tableFind(parentTable,child)
			if id then
				tableRemove(parentTable,id)
			end
		end
		FatherTable[child] = parent
		ChildrenTable[parent] = ChildrenTable[parent] or {}
		tableInsert(ChildrenTable[parent],child)
		setElementParent(child,parent)
	else
		local id = tableFind(parentTable,child)
		if id then
			tableRemove(parentTable,id)
		end
		FatherTable[child] = nil
		tableInsert(CenterFatherTable,child)
		setElementParent(child,resourceRoot)
	end
	---Update Position and Size
	if not noUpdatePosSize then
		local rlt = dgsElementData[child].relative
		local pos = rlt[1] and dgsElementData[child].rltPos or dgsElementData[child].absPos
		local size = rlt[2] and dgsElementData[child].rltSize or dgsElementData[child].absSize
		calculateGuiPositionSize(child,pos[1],pos[2],rlt[1] and true or false,size[1],size[2],rlt[2] and true or false)
	end
	if dgsElementType[child] == "dgs-dxscrollpane" then
		local scrollbars = (dgsElementData[child] or {}).scrollbars
		if scrollbars then
			dgsSetParent(scrollbars[1],parent)
			dgsSetParent(scrollbars[2],parent)
			configScrollPane(child)
		end
	end
	return true
end

function blurEditMemo()
	local dgsType = dgsGetType(MouseData.focused)
	if dgsType == "dgs-dxedit" then
		guiBlur(GlobalEdit)
	elseif dgsType == "dgs-dxmemo" then
		guiBlur(GlobalMemo)
	end
end

function dgsBringToFront(dgsEle,mouse,dontMoveParent,dontChangeData)
	local eleType = dgsIsType(dgsEle)
	if not(eleType) then error(dgsGenAsrt(dgsEle,"dgsBringToFront",1,"dgs-dxelement")) end
	local parent = FatherTable[dgsEle]	--Get Parent
	local lastFront = MouseData.focused
	if not dontChangeData then
		MouseData.focused = dgsEle
		if dgsGetType(dgsEle) == "dgs-dxedit" then
			MouseData.editCursor = true
			resetTimer(MouseData.EditMemoTimer)
			guiFocus(GlobalEdit)
			dgsElementData[GlobalEdit].linkedDxEdit = dgsEle
		elseif dgsElementType[dgsEle] == "dgs-dxmemo" then
			MouseData.editCursor = true
			resetTimer(MouseData.EditMemoTimer)
			guiFocus(GlobalMemo)
			dgsElementData[GlobalMemo].linkedDxMemo = dgsEle
		elseif dgsEle ~= lastFront then
			local dgsType = dgsGetType(lastFront)
			if dgsType == "dgs-dxedit" then
				guiBlur(GlobalEdit)
			elseif dgsType == "dgs-dxmemo" then
				guiBlur(GlobalMemo)
			end
		end
		if isElement(lastFront) and dgsElementData[lastFront].clearSelection then
			dgsSetData(lastFront,"selectfrom",dgsElementData[lastFront].cursorpos)
		end
	end
	if dgsElementData[dgsEle].changeOrder then
		if not isElement(parent) then
			if dgsScreen3DType[eleType] then
				local id = tableFind(dgsScreen3DTable,dgsEle)
				if id then
					tableRemove(dgsScreen3DTable,id)
					tableInsert(dgsScreen3DTable,dgsEle)
				end
			elseif dgsWorld3DType[eleType] then
				local id = tableFind(dgsWorld3DTable,dgsEle)
				if id then
					tableRemove(dgsWorld3DTable,id)
					tableInsert(dgsWorld3DTable,dgsEle)
				end
			else
				local layer = dgsElementData[dgsEle].alwaysOn or "center"
				local layerTable = LayerCastTable[layer]
				local id = tableFind(layerTable,dgsEle)
				if id then
					tableRemove(layerTable,id)
					tableInsert(layerTable,dgsEle)
				end
			end
		else
			local parents = dgsEle
			while true do
				local uparents = FatherTable[parents]	--Get Parent
				local eleType = dgsIsType(uparents)
				if isElement(uparents) then
					local children = ChildrenTable[uparents]
					local id = tableFind(children,parents)
					if id then
						tableRemove(children,id)
						tableInsert(children,parents)
						if dgsElementType[parents] == "dgs-dxscrollpane" then
							local scrollbar = dgsElementData[parents].scrollbars
							dgsBringToFront(scrollbar[1],"left",_,true)
							dgsBringToFront(scrollbar[2],"left",_,true)
						end
					end
					parents = uparents
				else
					if dgsScreen3DType[eleType] then
						local id = tableFind(dgsScreen3DTable,parents)
						if id then
							tableRemove(dgsScreen3DTable,id)
							tableInsert(dgsScreen3DTable,parents)
						end
						break
					elseif dgsWorld3DType[eleType] then
						local id = tableFind(dgsWorld3DTable,parents)
						if id then
							tableRemove(dgsWorld3DTable,id)
							tableInsert(dgsWorld3DTable,parents)
						end
						break
					else
						local layer = dgsElementData[parents].alwaysOn or "center"
						local layerTable = LayerCastTable[layer]
						local id = tableFind(layerTable,parents)
						if id then
							tableRemove(layerTable,id)
							tableInsert(layerTable,parents)
							if dgsElementType[parents] == "dgs-dxscrollpane" then
								local scrollbar = dgsElementData[parents].scrollbars
								dgsBringToFront(scrollbar[1],"left",_,true)
								dgsBringToFront(scrollbar[2],"left",_,true)
							end
						end
						break
					end
				end
				if dontMoveParent then
					break
				end
			end
		end
	end
	dgsFocus(dgsEle)
	lastFront = dgsEle
	if mouse == "left" then
		MouseData.clickl = dgsEle
		if MouseData.hitData3D[0] and MouseData.hitData3D[5] then
			MouseData.lock3DInterface = MouseData.hitData3D[5]
		end
		MouseData.clickData = nil
	elseif mouse == "right" then
		MouseData.clickr = dgsEle
	end
	return true
end

function dgsMoveToBack(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsMoveToBack",1,"dgs-dxelement")) end
	if dgsElementData[dgsEle].changeOrder then
		local parent = FatherTable[dgsEle]	--Get Parent
		if isElement(parent) then
			local children = ChildrenTable[parent]
			local id = tableFind(children,dgsEle)
			if id then
				tableRemove(children,id)
				tableInsert(children,1,dgsEle)
				return true
			end
			return false
		else
			local layer = dgsElementData[dgsEle].alwaysOn or "center"
			local layerTable = LayerCastTable[layer]
			local id = tableFind(layerTable,dgsEle)
			if id then
				tableRemove(layerTable,id)
				tableInsert(layerTable,1,dgsEle)
				return true
			end
			return false
		end
	end
end

------------------------------------------------Type Manager
dgsType = {
	"dgs-dx3dinterface",
	"dgs-dx3dline",
	"dgs-dx3dtext",
	"dgs-dx3dimage",
	"dgs-dxbutton",
	"dgs-dxedit",
	"dgs-dxmemo",
	"dgs-dxdetectarea",
	"dgs-dxgridlist",
	"dgs-dximage",
	"dgs-dxradiobutton",
	"dgs-dxcheckbox",
	"dgs-dxlabel",
	"dgs-dxline",
	"dgs-dxlayout",
	"dgs-dxscrollbar",
	"dgs-dxscrollpane",
	"dgs-dxscalepane",
	"dgs-dxselector",
	"dgs-dxswitchbutton",
	"dgs-dxwindow",
	"dgs-dxprogressbar",
	"dgs-dxtabpanel",
	"dgs-dxtab",
	"dgs-dxcombobox",
	"dgs-dxcombobox-Box",
	"dgs-dxcustomrenderer",
	"dgs-dxbrowser",
}

dgsPluginType = {

}

dgsScreen3DType = {
	"dgs-dx3dimage",
	"dgs-dx3dtext",
}

dgsWorld3DType = {
	"dgs-dx3dinterface",
	"dgs-dx3dline",
}

for i=1,#dgsType do
	dgsType[dgsType[i]] = dgsType[i]
end

for i=1,#dgsScreen3DType do
	dgsScreen3DType[dgsScreen3DType[i]] = dgsScreen3DType[i]
end

for i=1,#dgsWorld3DType do
	dgsWorld3DType[dgsWorld3DType[i]] = dgsWorld3DType[i]
end

setElementData(resourceRoot,"DGSType",dgsType,false)

function dgsAddType(typeName,isPlugin)
	if isPlugin then
		dgsPluginType[#dgsPluginType+1] = typeName
		dgsPluginType[typeName] = typeName
	else
		dgsType[#dgsType+1] = typeName
		dgsType[typeName] = typeName
	end
	return true
end

function dgsGetType(dgsEle)
	if isElement(dgsEle) then return tostring(dgsElementType[dgsEle] or getElementType(dgsEle)) end
	local theType = type(dgsEle)
	if theType == "userdata" and dgsElementType[dgsEle] then return "destroyed element" end
	return theType
end

function dgsIsType(dgsEle,isType)
	if isType then
		if isElement(dgsEle) then
			local eleData = dgsElementData[dgsEle]
			if isType == (eleData and eleData.asPlugin) then return true end
			if isType == dgsElementType[dgsEle] then return true end
			return getElementType(dgsEle) == isType
		else
			return type(dgsEle) == isType
		end
	else
	
		if not isElement(dgsEle) then return false end
		local eleData = dgsElementData[dgsEle]
		if eleData and eleData.asPlugin then
			return dgsPluginType[eleData.asPlugin]
		end
		return dgsType[dgsElementType[dgsEle] or getElementType(dgsEle)]
	end
	return false
end

function dgsGetPluginType(dgsEle) return dgsEle and (dgsElementData[dgsEle] and dgsElementData[dgsEle].asPlugin or false) or dgsGetType(dgsEle) end

function dgsSetType(dgsEle,myType)
	if isElement(dgsEle) and type(myType) == "string" then
		dgsElementType[dgsEle] = myType
		return true
	end
	return false
end

------------------------------------------------Property Manager
local dgsDataFunctions = {
	["dgs-dxscrollbar"] = {
		length = function(dgsEle,key,value,oldValue)
			local absSize = dgsElementData[dgsEle].absSize
			local w,h = absSize[1],absSize[2]
			local isHorizontal = dgsElementData[dgsEle].isHorizontal
			if (value[2] and value[1]*(isHorizontal and w-h*2 or h-w*2) or value[1]) < dgsElementData[dgsEle].minLength then
				dgsElementData[dgsEle].length = {dgsElementData[dgsEle].minLength,false}
			end
		end,
		position = function(dgsEle,key,value,oldValue)
			if oldValue then
				if not dgsElementData[dgsEle].locked then
					local grades = dgsElementData[dgsEle].grades
					local scaler = dgsElementData[dgsEle].map
					local nValue,oValue = value,oldValue
					if grades then
						nValue,oValue = nValue/100*grades+0.5,oValue/100*grades+0.5
						nValue,oValue = nValue-nValue%1,oValue-oValue%1
						dgsSetData(dgsEle,"currentGrade",nValue)
						dgsElementData[dgsEle][key] = nValue/grades*100
					else
						dgsElementData[dgsEle][key] = nValue
					end
					triggerEvent("onDgsElementScroll",dgsEle,dgsEle,dgsElementData[dgsEle][key],oldValue,nValue,oValue)
				else
					dgsElementData[dgsEle][key] = oldValue
				end
			end
		end,
		grades = function(dgsEle,key,value,oldValue)
			if value then
				local currentGrade = dgsElementData[dgsEle].position/100*value+0.5
				dgsSetData(dgsEle,"currentGrade",currentGrade-currentGrade%1)
			else
				dgsSetData(dgsEle,"currentGrade",false)
			end
		end,
	},
	["dgs-dxgridlist"] = {
		columnHeight = function(dgsEle,key,value,oldValue)
			configGridList(dgsEle)
		end,
		mode = function(dgsEle,key,value,oldValue)
			configGridList(dgsEle)
		end,
		scrollBarThick = function(dgsEle,key,value,oldValue)
			configGridList(dgsEle)
		end,
		scrollBarState = function(dgsEle,key,value,oldValue)
			configGridList(dgsEle)
		end,
		leading = function(dgsEle,key,value,oldValue)
			configGridList(dgsEle)
		end,
		rowData = function(dgsEle,key,value,oldValue)
			if dgsElementData[dgsEle].autoSort then
				dgsElementData[dgsEle].nextRenderSort = true
			end
		end,
		rowMoveOffset = function(dgsEle,key,value,oldValue)
			dgsGridListUpdateRowMoveOffset(dgsEle)
		end,
		defaultSortFunctions = function(dgsEle,key,value,oldValue)
			local sortFunction = dgsElementData[dgsEle].sortFunction
			local oldDefSortFnc = oldValue
			local oldUpperSortFnc = sortFunctions[oldDefSortFnc[1]]
			local oldLowerSortFnc = sortFunctions[oldDefSortFnc[2]]
			local defSortFnc = dgsElementData[dgsEle].defaultSortFunctions
			local upperSortFnc = sortFunctions[defSortFnc[1]]
			local lowerSortFnc = sortFunctions[defSortFnc[2]]
			local oldSort = sortFunction == oldLowerSortFnc and lowerSortFnc or upperSortFnc
		end,
	},
	["dgs-dxscrollpane"] = {
		scrollBarThick = function(dgsEle,key,value,oldValue)
			configScrollPane(dgsEle)
		end,
		scrollBarState = function(dgsEle,key,value,oldValue)
			configScrollPane(dgsEle)
		end,
		scrollBarOffset = function(dgsEle,key,value,oldValue)
			configScrollPane(dgsEle)
		end,
		scrollBarLength = function(dgsEle,key,value,oldValue)
			configScrollPane(dgsEle)
		end,
		ignoreParentTitle = function(dgsEle,key,value,oldValue)
			configPosSize(dgsEle,false,true)
			configScrollPane(dgsEle)
		end,
		ignoreTitle = function(dgsEle,key,value,oldValue)
			local children = dgsGetChildren(dgsEle)
			for i=1,#children do
				if not dgsElementData[children[i]].ignoreParentTitle then
					configPosSize(children[i],false,true)
					configScrollPane(children[i])
				end
			end
		end,
	},
	["dgs-dxswitchbutton"] = {
		state = function(dgsEle,key,value,oldValue)
			triggerEvent("onDgsSwitchButtonStateChange",dgsEle,value,oldValue)
		end,
	},
	["dgs-dxcombobox"] = {
		scrollBarThick = function(dgsEle,key,value,oldValue)
			assert(type(value) == "number","Bad argument 'dgsSetData' at 3,expect number got"..type(value))
			local scrollbar = dgsElementData[dgsEle].scrollbar
			configComboBox(dgsEle)
		end,
		listState = function(dgsEle,key,value,oldValue)
			triggerEvent("onDgsComboBoxStateChange",dgsEle,value == 1 and true or false)
		end,
		viewCount = function(dgsEle,key,value,oldValue)
			dgsComboBoxSetViewCount(dgsEle,value)
		end,
		itemHeight = function(dgsEle,key,value,oldValue)
			if dgsElementData[dgsEle].viewCount then
				dgsComboBoxSetViewCount(dgsEle,dgsElementData[dgsEle].viewCount)
			end
		end,
		arrow = function (dgsEle,key,value,oldValue)
			if dgsElementData[oldValue] and dgsElementData[oldValue].styleResource then 
				destroyElement(oldValue)
			end
		end,
	},
	["dgs-dxtabpanel"] = {
		selected = function(dgsEle,key,value,oldValue)
			local old,new = oldValue,value
			local tabs = dgsElementData[dgsEle].tabs
			triggerEvent("onDgsTabPanelTabSelect",dgsEle,new,old,tabs[new],tabs[old])
			if isElement(tabs[new]) then
				triggerEvent("onDgsTabSelect",tabs[new],new,old,tabs[new],tabs[old])
			end
		end,
		tabPadding = function(dgsEle,key,value,oldValue)
			local width = dgsElementData[dgsEle].absSize[1]
			local change = value[2] and value[1]*width or value[1]
			local old = oldValue[2] and oldValue[1]*width or oldValue[1]
			local tabs = dgsElementData[dgsEle].tabs
			dgsSetData(dgsEle,"tabLengthAll",dgsElementData[dgsEle].tabLengthAll+(change-old)*#tabs*2)
		end,
		tabGapSize = function(dgsEle,key,value,oldValue)
			local width = dgsElementData[dgsEle].absSize[1]
			local change = value[2] and value[1]*width or value[1]
			local old = oldValue[2] and oldValue[1]*width or oldValue[1]
			local tabs = dgsElementData[dgsEle].tabs
			dgsSetData(dgsEle,"tabLengthAll",dgsElementData[dgsEle].tabLengthAll+(change-old)*mathMax((#tabs-1),1))
		end,
		tabAlignment = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].showPos = 0
		end,
		tabHeight = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].configNextFrame = true
		end,
	},
	["dgs-dxtab"] = {
		text = function(dgsEle,key,value,oldValue)
			if type(value) == "table" then
				dgsElementData[dgsEle]._translationText = value
				value = dgsTranslate(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translationText = nil
			end
			local tabpanel = dgsElementData[dgsEle].parent
			local w = dgsElementData[tabpanel].absSize[1]
			local t_minWid = dgsElementData[tabpanel].tabMinWidth
			local t_maxWid = dgsElementData[tabpanel].tabMaxWidth
			local minwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1]
			local maxwidth = t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
			dgsElementData[dgsEle].text = tostring(value)
			dgsSetData(dgsEle,"width",mathClamp(dxGetTextWidth(tostring(value),dgsElementData[dgsEle].textSize[1],dgsElementData[dgsEle].font or dgsElementData[tabpanel].font),minwidth,maxwidth))
			return triggerEvent("onDgsTextChange",dgsEle)
		end,
		textSize = function(dgsEle,key,value,oldValue)
			local tabpanel = dgsElementData[dgsEle].parent
			local w = dgsElementData[tabpanel].absSize[1]
			local t_minWid = dgsElementData[tabpanel].tabMinWidth
			local t_maxWid = dgsElementData[tabpanel].tabMaxWidth
			local minwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1]
			local maxwidth = t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
			dgsSetData(dgsEle,"width",mathClamp(dxGetTextWidth(dgsElementData[dgsEle].text,dgsElementData[dgsEle].textSize[1],dgsElementData[dgsEle].font or dgsElementData[tabpanel].font),minwidth,maxwidth))
		end,
		font = function(dgsEle,key,value,oldValue)
			--Multilingual
			if type(value) == "table" then
				dgsElementData[dgsEle]._translationFont = value
				value = dgsGetTranslationFont(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translationFont = nil
			end
			dgsElementData[dgsEle].font = value
			
			local tabpanel = dgsElementData[dgsEle].parent
			local w = dgsElementData[tabpanel].absSize[1]
			local t_minWid = dgsElementData[tabpanel].tabMinWidth
			local t_maxWid = dgsElementData[tabpanel].tabMaxWidth
			local minwidth = t_minWid[2] and t_minWid[1]*w or t_minWid[1]
			local maxwidth = t_maxWid[2] and t_maxWid[1]*w or t_maxWid[1]
			dgsSetData(dgsEle,"width",mathClamp(dxGetTextWidth(dgsElementData[dgsEle].text,dgsElementData[dgsEle].textSize[1],dgsElementData[dgsEle].font or dgsElementData[tabpanel].font),minwidth,maxwidth))
		end,
		width = function(dgsEle,key,value,oldValue)
			local tabpanel = dgsElementData[dgsEle].parent
			dgsSetData(tabpanel,"tabLengthAll",dgsElementData[tabpanel].tabLengthAll+(value-oldValue))
		end,
	},
	["dgs-dxedit"] = {
		text = function(dgsEle,key,value,oldValue)
			handleDxEditText(dgsEle,value)
		end,
		textSize = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].textFontLen = dxGetTextWidth(dgsElementData[dgsEle].text,value[1],dgsElementData[dgsEle].font)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		textColor = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		font = function(dgsEle,key,value,oldValue)
			--Multilingual
			if type(value) == "table" then
				dgsElementData[dgsEle]._translationFont = value
				value = dgsGetTranslationFont(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translationFont = nil
			end
			dgsElementData[dgsEle].font = value
			
			local eleData = dgsElementData[dgsEle]
			eleData.textFontLen = dxGetTextWidth(eleData.text,eleData.textSize[1],eleData.font)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		padding = function(dgsEle,key,value,oldValue)
			configEdit(dgsEle)
		end,
		showPos = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		masked = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end
	},
	["dgs-dxmemo"] = {
		text = function(dgsEle,key,value,oldValue)
			return handleDxMemoText(dgsEle,value)
		end,
		scrollBarThick = function(dgsEle,key,value,oldValue)
			configMemo(dgsEle)
		end,
		scrollBarState = function(dgsEle,key,value,oldValue)
			configMemo(dgsEle)
		end,
		textSize = function(dgsEle,key,value,oldValue)
			dgsMemoRebuildTextTable(dgsEle)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		textColor = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		font = function(dgsEle,key,value,oldValue)
			--Multilingual
			if type(value) == "table" then
				dgsElementData[dgsEle]._translationFont = value
				value = dgsGetTranslationFont(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translationFont = nil
			end
			dgsElementData[dgsEle].font = value
			
			dgsMemoRebuildTextTable(dgsEle)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		wordWrap = function(dgsEle,key,value,oldValue)
			if value then
				dgsMemoRebuildWordWrapMapTable(dgsEle)
			end
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
		showPos = function(dgsEle,key,value,oldValue)
			dgsElementData[dgsEle].updateTextRTNextFrame = true
		end,
	},
	["dgs-dxprogressbar"] = {
		progress = function(dgsEle,key,value,oldValue)
			triggerEvent("onDgsProgressBarChange",dgsEle,value,oldValue)
		end
	},
	["dgs-dx3dinterface"] = {
		size = function(dgsEle,key,value,oldValue)
			local temprt = dgsElementData[dgsEle].renderTarget
			if isElement(temprt) then
				destroyElement(temprt)
			end
			local renderTarget = dxCreateRenderTarget(value[1],value[2],true)
			dgsSetData(dgsEle,"renderTarget",renderTarget)
		end
	},
	["dgs-dxscalepane"] = {
		scrollBarThick = function(dgsEle,key,value,oldValue)
			configScalePane(dgsEle)
		end,
		scrollBarState = function(dgsEle,key,value,oldValue)
			configScalePane(dgsEle)
		end,
		scrollBarOffset = function(dgsEle,key,value,oldValue)
			configScalePane(dgsEle)
		end,
		scrollBarLength = function(dgsEle,key,value,oldValue)
			configScalePane(dgsEle)
		end,
		scale = function(dgsEle,key,value,oldValue)
			configScalePane(dgsEle)
		end,
	},
	["default"] = {
		text = function(dgsEle,key,value,oldValue)
			if type(value) == "table" then
				dgsElementData[dgsEle]._translationText = value
				value = dgsTranslate(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translationText = nil
			end
			dgsElementData[dgsEle].text = tostring(value)
			triggerEvent("onDgsTextChange",dgsEle)
		end,
		font = function(dgsEle,key,value,oldValue)
			--Multilingual
			if type(value) == "table" then
				dgsElementData[dgsEle]._translationFont = value
				value = dgsGetTranslationFont(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translationFont = nil
			end
			dgsElementData[dgsEle].font = value
		end,
		caption = function(dgsEle,key,value,oldValue)
			if type(value) == "table" then
				dgsElementData[dgsEle]._translationText = value
				value = dgsTranslate(dgsEle,value,sourceResource)
			else
				dgsElementData[dgsEle]._translationText = nil
			end
			dgsElementData[dgsEle].caption = tostring(value)
		end,
		ignoreParentTitle = function(dgsEle,key,value,oldValue)
			configPosSize(dgsEle,false,true)
		end,
		ignoreTitle = function(dgsEle,key,value,oldValue)
			local children = dgsGetChildren(dgsEle)
			for i=1,#children do
				if not dgsElementData[children[i]].ignoreParentTitle then
					configPosSize(children[i],false,true)
					if dgsElementType[children[i]] == "dgs-dxscrollpane" then
						configScrollPane(children[i])
					end
				end
			end
		end,
		asPlugin = function(dgsEle,key,value,oldValue)
			dgsAddType(value,true)
		end,
	},
}

function dgsGetData(dgsEle,key)
	return dgsElementData[dgsEle] and dgsElementData[dgsEle][key] or false
end

function dgsSetData(dgsEle,key,value,nocheck)
	local dgsType,key = dgsElementType[dgsEle] or "",key or ""
	if not (isElement(dgsEle) and dgsType) then return false end
	if not dgsElementData[dgsEle] then dgsElementData[dgsEle] = {} end
	local eleData = dgsElementData[dgsEle]
	local oldValue = eleData[key]
	if oldValue == value then return true end
	eleData[key] = value
	if nocheck then return true end
	local dataHandlerList = dgsDataFunctions[dgsType] or dgsDataFunctions.default
	local dataHandler = dataHandlerList[key] or dgsDataFunctions.default[key]
	if dataHandler then dataHandler(dgsEle,key,value,oldValue) end
	if eleData.propertyListener and eleData.propertyListener[key] then triggerEvent("onDgsPropertyChange",dgsEle,key,value,oldValue) end
	return true
end

function dgsAddPropertyListener(dgsEle,propertyNames)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsAddPropertyListener",1,"dgs-dxelement/table")) end
	if isTable then
		for i=1,#dgsEle do
			dgsAddPropertyListener(dgsEle[i],propertyNames)
		end
		return true
	else
		local eleData = dgsElementData[dgsEle]
		eleData.propertyListener = eleData.propertyListener or {}
		if type(propertyNames) == "table" then
			for i=1,#propertyNames do
				eleData.propertyListener[propertyNames[i]] = true
			end
		else
			eleData.propertyListener[propertyNames] = true
		end
	end
end

function dgsRemovePropertyListener(dgsEle,propertyNames)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsRemovePropertyListener",1,"dgs-dxelement/table")) end
	if isTable then
		for i=1,#dgsEle do
			dgsRemovePropertyListener(dgsEle[i],propertyNames)
		end
		return true
	else
		local eleData = dgsElementData[dgsEle]
		eleData.propertyListener = eleData.propertyListener or {}
		if type(propertyNames) == "table" then
			for i=1,#propertyNames do
				eleData.propertyListener[propertyNames[i]] = false
			end
		else
			eleData.propertyListener[propertyNames] = false
		end
	end
end

function dgsGetListeningProperties(dgsEle)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetListeningProperties",1,"dgs-dxelement")) end
	local eleData = dgsElementData[dgsEle]
	eleData.propertyListener = eleData.propertyListener or {}
	local listening = {}
	for k,v in pairs(eleData.propertyListener) do
		listening[#listening+1] = k
	end
	return listening
end

local compatibility = {
	1,
	["dgs-dxprogressbar"] = {
		isReverse = "isClockWise",
	}
}
function checkCompatibility(dgsEle,key)
	local eleTyp = dgsGetType(dgsEle)
	if compatibility[eleTyp] and compatibility[eleTyp][key] then
		if not getElementData(localPlayer,"DGS-DEBUG-C") then
			outputDebugString("Deprecated property '"..key.."' @dgsSetProperty with "..eleTyp..". To fix (Replace with "..compatibility[eleTyp][key]..")",2)
			outputDebugString("To find it, run it again with command /debugdgs c",2)
			return true
		else
			outputDebugString("Found deprecated property '"..key.."' @dgsSetProperty with "..eleTyp..", replace with "..compatibility[eleTyp][key],2)
			return false
		end
	end
	return true
end

local _dgsSetData = dgsSetData
function dgsSetProperty(dgsEle,key,value,...)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsSetProperty",1,"dgs-dxelement/table")) end
	if isTable then
		for i=1,#dgsEle do
			dgsSetProperty(dgsEle[i],key,value,...)
		end
		return true
	else
		if #compatibility == 0 or checkCompatibility(dgsEle,key) then
			if key == "functions" then
				if value then
					local fnc,err
					if type(value) == "function" then
						fnc = value
					else
						fnc,err = loadstring(value)
						dgsElementData[dgsEle].functions_string = {value,{...}}
					end
					if not fnc then error("Bad argument @dgsSetProperty at argument 2, failed to load function ("..err..")") end
					value = {fnc,{...}}
				end
			elseif key == "absPos" then
				dgsSetPosition(dgsEle,value[1],value[2],false)
			elseif key == "rltPos" then
				dgsSetPosition(dgsEle,value[1],value[2],true)
			elseif key == "absSize" then
				dgsSetSize(dgsEle,value[1],value[2],false)
			elseif key == "rltSize" then
				dgsSetSize(dgsEle,value[1],value[2],true)
			end
			return _dgsSetData(dgsEle,key,value)
		else
			error("DGS Compatibility Check")
		end
	end
end

function dgsGetProperty(dgsEle,key)
	if not(dgsIsType(dgsEle)) then error(dgsGenAsrt(dgsEle,"dgsGetProperty",1,"dgs-dxelement")) end
	return (dgsElementData[dgsEle] or {})[key] or false
end

function dgsSetProperties(dgsEle,theTable)
	local isTable = type(dgsEle) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsSetProperties",1,"dgs-dxelement/table")) end
	if not(type(theTable) == "table") then error(dgsGenAsrt(theTable,"dgsSetProperties",2,"table")) end
	local dxElements = isTable and dgsEle or {dgsEle}
	for i=1,#dxElements do
		local dgsEle = dxElements[i]
		for key,value in pairs(theTable) do
			dgsSetProperty(dgsEle,key,value)
		end
	end
	return success
end

function dgsGetProperties(dgsEle,properties)
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsGetProperties",1,"dgs-dxelement/table")) end
	if not(not properties or type(properties) == "table") then error(dgsGenAsrt(properties,"dgsGetProperties",2,"table/none")) end
	if not dgsElementData[dgsEle] then return false end
	if not properties then return dgsElementData[dgsEle] end
	local data = {}
	for k,key in ipairs(properties) do
		data[key] = dgsElementData[dgsEle][key]
	end
	return data
end

function dgsSetPropertyInherit(dxgui,key,value,...)
	local isTable = type(dxgui) == "table"
	if not(dgsIsType(dgsEle) or isTable) then error(dgsGenAsrt(dgsEle,"dgsSetPropertyInherit",1,"dgs-dxelement/table")) end
	local dxElements = isTable and dxgui or {dxgui}
	for i=1,#dxElements do
		local dgsEle = dxElements[i]
		dgsSetProperty(dgsEle,key,value)
		for index,child in ipairs(dgsGetChildren(dgsEle)) do
			dgsSetPropertyInherit(child,key,value,...)
		end
	end
	return true
end
------------------------Custom Easing Function
resourceTranslation = {}
LanguageTranslation = {}
LanguageTranslationAttach = {}
boundResource = {}
dgsEasingFunction = {}
dgsEasingFunctionOrg = {}
SEInterface = [[
local args = {...};
local progress,setting,self = args[1],args[2],args[3];
local propertyTable = dgsElementData[self];
]]
function dgsAddEasingFunction(name,str,isOverWrite)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsAddEasingFunction",1,"string")) end
	if not(type(str) == "string") then error(dgsGenAsrt(str,"dgsAddEasingFunction",2,"string")) end
	if easingBuiltIn[name] then error(dgsGenAsrt(name,"dgsAddEasingFunction",1,_,_,"duplicated name with built-in easing function ("..name..")")) end
	if not isOverWrite and dgsEasingFunction[name] then error(dgsGenAsrt(name,"dgsAddEasingFunction",1,_,_,"this name has been used ("..name..")")) end
	local str = SEInterface..str
	local fnc,err = loadstring(str)
	if not fnc then error(dgsGenAsrt(fnc,"dgsAddEasingFunction",2,_,_,_,"Failed to load function:"..err)) end
	dgsEasingFunction[name] = fnc
	dgsEasingFunctionOrg[name] = str
	return true
end

function dgsRemoveEasingFunction(name)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsRemoveEasingFunction",1,"string")) end
	if dgsEasingFunction[name] then
		dgsEasingFunction[name] = nil
		dgsEasingFunctionOrg[name] = nil
		return true
	end
	return false
end

function dgsEasingFunctionExists(name)
	if not(type(name) == "string") then error(dgsGenAsrt(name,"dgsEasingFunctionExists",1,"string")) end
	return easingBuiltIn[name] or (dgsEasingFunction[name] and true)
end

------------------------Animations Define
animGUIList,moveGUIList,sizeGUIList,alphaGUIList = {},{},{},{}

------------------------DGS Property Saver
dgsElementKeeper = {}
function dgsSetElementKeeperEnabled(state)
	if sourceResource then
		dgsElementKeeper[sourceResource] = state and true or nil
		return true
	end
	return false
end

function dgsGetElementKeeperEnabled()
	if sourceResource then
		return dgsElementKeeper[sourceResource]
	end
	return false
end

function DGSI_SaveData()
	--Properties
	setElementData(root,"DGSI_Properties",dgsElementData,false)
	--Types
	setElementData(root,"DGSI_ElementType",dgsElementType,false)
	--Bound Resource
	setElementData(root,"DGSI_BoundResource",boundResource,false)
	--Translations
	setElementData(root,"DGSI_TranslationResRegister",resourceTranslation,false)
	setElementData(root,"DGSI_TranslationLanguage",LanguageTranslation,false)
	setElementData(root,"DGSI_TranslationLanguageAttach",LanguageTranslationAttach,false)
	--Easing Functions
	setElementData(root,"DGSI_EasingFunctions",dgsEasingFunctionOrg,false)
	--Element Keeper
	setElementData(root,"DGSI_ElementKeeper",dgsElementKeeper,false)
	--Layer Data
	setElementData(root,"DGSI_LayerData",{
		bottom=BottomFatherTable,
		center=CenterFatherTable,
		top=TopFatherTable,
		world3d=dgsWorld3DTable,
		screen3d=dgsScreen3DTable,
	},false)
	setElementData(root,"DGSI_ParentChildData",{
		parent=FatherTable,
		child=ChildrenTable,
	},false)
	--Animations
	setElementData(root,"DGSI_Animations",{
		anim=animGUIList,
		move=moveGUIList,
		size=sizeGUIList,
		alpha=alphaGUIList,
	},false)
	--Others
	setElementData(root,"DGSI_SaveData",true,false)
end

--[[
Logger type:
1.Texutre
2.Shader
3.Font
]]
function DGSI_AllocateDxElement(e,oldDgsElementLogger)
	if oldDgsElementLogger[e] then
		if isElement(oldDgsElementLogger[e][3]) then
			return oldDgsElementLogger[e][3]
		else
			local dxElement
			if oldDgsElementLogger[e][1] == 1 then
				dxElement = __dxCreateTexture(oldDgsElementLogger[e][2])
			elseif oldDgsElementLogger[e][1] == 2 then 
				dxElement = __dxCreateShader(oldDgsElementLogger[e][2])
			elseif oldDgsElementLogger[e][1] == 3 then 
				dxElement = __dxCreateFont(unpack(oldDgsElementLogger[e][2]))
			end
			if dxElement then
				oldDgsElementLogger[e][3] = dxElement
				dgsElementLogger[dxElement] = oldDgsElementLogger[e]
				return dxElement
			end
		end
	end
	return nil
end

function DGSI_ReadData()
	local SaveData = getElementData(root,"DGSI_SaveData")
	if SaveData == true then
		--Element Logger
		local oldDgsElementLogger = getElementData(root,"DGSI_ElementLogger") or {}
		--Properties
		local _dgsElementData = getElementData(root,"DGSI_Properties") or {}
		for dgsElement,data in pairs(_dgsElementData) do
			if not isElement(dgsElement) then
				_dgsElementData[dgsElement] = nil
			else
				if data.functions_string then
					local fnc = loadstring(data.functions_string[1])
					data.functions = {fnc,data.functions_string[2]}
				end
				if data.eventHandlers then
					local eventHandlers = data.eventHandlers
					for eventName,fncs in pairs(eventHandlers) do
						for fncName,datas in pairs(fncs) do
							if not addEventHandler(eventName,dgsElement,_G[fncName],datas[2],datas[3]) then
								fncs[fncName] = nil
							end
						end
					end
				end
				for key,value in pairs(data) do
					local dataType = type(value)
					if dataType == "table" then
						for i,e in pairs(value) do
							local eType = type(e)
							if eType == "userdata" and not isElement(e) then
								value[i] = DGSI_AllocateDxElement(e,oldDgsElementLogger)
							end
						end
					elseif dataType == "userdata" and not isElement(value) then
						data[key] = DGSI_AllocateDxElement(value,oldDgsElementLogger)
					end
				end
			end
		end
		removeElementData(root,"DGSI_Properties")
		dgsElementData = table.merger(dgsElementData,_dgsElementData)
		--Types
		local _dgsElementType = getElementData(root,"DGSI_ElementType") or {}
		for dgsElement,data in pairs(_dgsElementType) do
			if not isElement(dgsElement) then _dgsElementType[dgsElement] = nil end
		end
		dgsElementType = table.merger(dgsElementType,_dgsElementType)
		removeElementData(root,"DGSI_ElementType")
		--Bound Resource
		local _boundResource = getElementData(root,"DGSI_BoundResource") or {}
		for res,t in pairs(_boundResource) do
			local resType = type(res)
			if resType ~= "userdata" then
				_boundResource[res] = nil
			elseif getUserdataType(res) ~= "resource-data" then
				_boundResource[res] = nil
			end
		end
		boundResource = table.merger(boundResource,_boundResource)
		removeElementData(root,"DGSI_BoundResource")
		--Translations
		resourceTranslation = getElementData(root,"DGSI_TranslationResRegister") or {}
		removeElementData(root,"DGSI_TranslationResRegister")
		
		LanguageTranslation = getElementData(root,"DGSI_TranslationLanguage") or {}
		removeElementData(root,"DGSI_TranslationLanguage")
		
		LanguageTranslationAttach = getElementData(root,"DGSI_TranslationLanguageAttach") or {}
		removeElementData(root,"DGSI_TranslationLanguageAttach")
		--Easing Functions
		local easingOrg = getElementData(root,"DGSI_EasingFunctions") or {}
		for name,data in pairs(easingOrg) do
			local fnc = loadstring(data)
			dgsEasingFunction[name] = fnc
		end
		removeElementData(root,"DGSI_EasingFunctions")
		--Element Keeper
		dgsElementKeeper = getElementData(root,"DGSI_ElementKeeper") or {}
		for res,t in pairs(dgsElementKeeper) do
			local resType = type(res)
			if resType ~= "userdata" then
				dgsElementKeeper[res] = nil
			elseif getUserdataType(res) ~= "resource-data" then
				dgsElementKeeper[res] = nil
			end
		end
		removeElementData(root,"DGSI_ElementKeeper")
		--Layer Data
		local layerData = getElementData(root,"DGSI_LayerData") or {}
		local _BottomFatherTable = layerData.bottom
		local _CenterFatherTable = layerData.center
		local _TopFatherTable = layerData.top
		for index,dgsElement in pairs(_BottomFatherTable) do
			if not isElement(dgsElement) then _BottomFatherTable[index] = nil end
		end
		for index,dgsElement in pairs(_CenterFatherTable) do
			if not isElement(dgsElement) then _CenterFatherTable[index] = nil end
		end
		for index,dgsElement in pairs(_TopFatherTable) do
			if not isElement(dgsElement) then _TopFatherTable[index] = nil end
		end
		BottomFatherTable = table.merger(BottomFatherTable,_BottomFatherTable)
		CenterFatherTable = table.merger(CenterFatherTable,_CenterFatherTable)
		TopFatherTable = table.merger(TopFatherTable,_TopFatherTable)
		LayerCastTable = {bottom=BottomFatherTable,center=CenterFatherTable,top=TopFatherTable}
		local _dgsWorld3DTable = layerData.world3d
		for index,dgsElement in pairs(_dgsWorld3DTable) do
			if not isElement(dgsElement) then _dgsWorld3DTable[index] = nil end
		end
		local _dgsScreen3DTable = layerData.screen3d
		for index,dgsElement in pairs(_dgsScreen3DTable) do
			if not isElement(dgsElement) then _dgsScreen3DTable[index] = nil end
		end
		dgsWorld3DTable = table.merger(dgsWorld3DTable,_dgsWorld3DTable)
		dgsScreen3DTable = table.merger(dgsScreen3DTable,_dgsScreen3DTable)
		removeElementData(root,"DGSI_LayerData")
		
		local pcData = getElementData(root,"DGSI_ParentChildData") or {}
		FatherTable = pcData.parent
		ChildrenTable = pcData.child
		for dgsElement,data in pairs(FatherTable) do
			if not isElement(dgsElement) then FatherTable[dgsElement] = nil end
		end
		for dgsElement,data in pairs(ChildrenTable) do
			if not isElement(dgsElement) then ChildrenTable[dgsElement] = nil end
		end
		removeElementData(root,"DGSI_ParentChildData")
		
		--Animations
		local animData = getElementData(root,"DGSI_Animations") or {}
		animGUIList = animData.anim
		moveGUIList = animData.move
		sizeGUIList = animData.size
		alphaGUIList = animData.alpha
		removeElementData(root,"DGSI_Animations")
	end
	--Others

	setElementData(root,"DGSI_SaveData",false,false)
end

addEventHandler("onClientResourceStop",resourceRoot,function()
	--Element Logger
	setElementData(root,"DGSI_ElementLogger",dgsElementLogger,false)
	destroyElement(GlobalEdit)
	destroyElement(GlobalMemo)
	local terminator = createElement("dgs-dxterminator")
	addEventHandler("onClientElementDestroy",terminator,function()
		DGSI_SaveData()
	end,false)
end,false)

addEventHandler("onClientResourceStart",resourceRoot,function()
	DGSI_ReadData()
end,false)

addEventHandler("onClientResourceStop",root,function(res)
	if boundResource[res] then
		dgsClear(nil,res)
		resourceTranslation[res] = nil
	end
	externalElementPool[res] = nil	--Clear external element pool
	if dgsElementKeeper[res] then dgsElementKeeper[res] = nil end
	if res == getThisResource() then	--Recover Cursor Alpha
		setCursorAlpha(255)
	end
	if G2DHookerEvents[res] then -- G2D Hooker
		G2DHookerEvents[res] = nil 
		if table.count(G2DHookerEvents) == 0 then 
			removeEventHandler("onDgsEditAccepted",root,handleHookerEvents)
			removeEventHandler("onDgsTextChange",root,handleHookerEvents)
			removeEventHandler("onDgsComboBoxSelect",root,handleHookerEvents)
			removeEventHandler("onDgsTabSelect",root,handleHookerEvents)
		end
	end
end)