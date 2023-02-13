local Settings = {
	var = {}
}


local scx, scy = guiGetScreenSize()
local envTex_1 = dxCreateTexture("txd/vehicleenvmap128.png")
local envTex_2 = dxCreateTexture("txd/xvehicleenv128.png")

----------------------------------------------------------------------------------------------------------------------------------------
-- an additional list of textures the effect is applied to
	
-- carpaint
	
	local texturegrun = {
			"predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
			"hotknifebody128b", "hotknifebody128a", "rcgoblin92texpage128", "rcraider92texpage128", 
			"rctiger92body128","rhino92texpage256", "combinetexpage128","hotdog92body256",
			"raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
			"polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , 
			"dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256", 
			"shamalbody256", "skimmer92body128", "maverick92body128", "leviathnbody8bit256" }

-- windshields
			
	local texturegene = {}

-- Use shader tex names resource to pick the names
----------------------------------------------------------------------------------------------------------------------------------------

---------------------------------
-- Settings for effect
---------------------------------
function setEffectv()
    local v = Settings.var
	
	v.renderDistance = 60 -- shader will be applied to textures nearer than this
	v.brightnessFactorPaint = 0.08
	v.brightnessFactorWShield = 0.08
	
	v.bumpSize = 0.5 -- for car paint
	v.bumpSizeWnd = 0 -- for windshields
	v.normal = 1 -- deformation strength
	v.bumpIntensity = {0.25, 0.25} -- intensity of the bump effect
	
	v.minZviewAngleFade = -0.5 -- the camera z direction where the fading starts
	
	v.brightnessAdd = 0.5 -- before bright pass
	v.brightnessMul = 1.5 -- multiply after brightpass
	v.brightpassCutoff = 0.16 -- 0-1
	v.brightpassPower = 2 -- 1-5
	
	v.uvMul = {1.5,1.5} -- uv multiply
	v.uvMov = {0,0} -- uv move
	
 --Sky gradient color coating
	v.skyLightIntensity = 0
 --Pearlescent
	v.filmDepth =0
	v.filmIntensity = 0

end

function startCarPaintReflectLite()
		if cprlEffectEnabled then return end
		local v = Settings.var
		setEffectv()
		-- Create stuff
		grunShader = dxCreateShader ( "fx/car_refgrun.fx",1,v.renderDistance,true)
		geneShader = dxCreateShader ( "fx/car_refgene.fx",1,v.renderDistance,true)
		shatShader = dxCreateShader ( "fx/car_refgene.fx",1,v.renderDistance,true)

		myScreenSource = dxCreateScreenSource( scx, scy)
		
		if grunShader and geneShader and shatShader and myScreenSource then

			outputConsole( "Started: Shader Car paint reflect.")
			
			addEventHandler ( "onClientHUDRender", getRootElement (), updateScreen )
	
			--Set variables
			dxSetShaderValue ( grunShader, "minZviewAngleFade",v.minZviewAngleFade)
			dxSetShaderValue ( grunShader, "sCutoff",v.brightpassCutoff)
			dxSetShaderValue ( grunShader, "sPower", v.brightpassPower)			
			dxSetShaderValue ( grunShader, "sAdd", v.brightnessAdd)
			dxSetShaderValue ( grunShader, "sMul", v.brightnessMul)
			dxSetShaderValue ( grunShader, "sNorFac", v.normal)
			dxSetShaderValue ( grunShader, "bumpIntensity", v.bumpIntensity[1])
			
		    dxSetShaderValue ( grunShader, "brightnessFactor", v.brightnessFactorPaint)  
			dxSetShaderValue ( grunShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( grunShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( grunShader, "skyLightIntensity", v.skyLightIntensity)
			dxSetShaderValue ( grunShader, "filmDepth", v.filmDepth)
			dxSetShaderValue ( grunShader, "gFilmIntensity", v.filmIntensity)

			dxSetShaderValue ( geneShader, "minZviewAngleFade",v.minZviewAngleFade)			
			dxSetShaderValue ( geneShader, "sCutoff",v.brightpassCutoff)
			dxSetShaderValue ( geneShader, "sPower", v.brightpassPower)	
			dxSetShaderValue ( geneShader, "sAdd", v.brightnessAdd)
			dxSetShaderValue ( geneShader, "sMul", v.brightnessMul)
			dxSetShaderValue ( geneShader, "sNorFac", v.normal)
			dxSetShaderValue ( geneShader, "bumpIntensity", v.bumpIntensity[2])
			
            dxSetShaderValue ( geneShader, "brightnessFactor", v.brightnessFactorWShield) 
			dxSetShaderValue ( geneShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( geneShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( geneShader, "skyLightIntensity", v.skyLightIntensity)

			dxSetShaderValue ( shatShader, "minZviewAngleFade",v.minZviewAngleFade)			
		    dxSetShaderValue ( shatShader, "sCutoff",v.brightpassCutoff)
			dxSetShaderValue ( shatShader, "sPower", v.brightpassPower)	
			dxSetShaderValue ( shatShader, "sAdd", v.brightnessAdd)
			dxSetShaderValue ( shatShader, "sMul", v.brightnessMul)
			dxSetShaderValue ( shatShader, "sNorFac", v.normal)
			dxSetShaderValue ( shatShader, "bumpIntensity", v.bumpIntensity[2])
			
			dxSetShaderValue ( shatShader, "brightnessFactor", v.brightnessFactorWShield) 		
			dxSetShaderValue ( shatShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( shatShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( shatShader, "skyLightIntensity", v.skyLightIntensity)
			
		    dxSetShaderValue ( grunShader, "bumpSize",v.bumpSize)
			dxSetShaderValue ( geneShader, "bumpSize",v.bumpSizeWnd)
		
			-- Set textures
			textureVol = dxCreateTexture ( "txd/smallnoise3d.dds" )
			textureFringe = dxCreateTexture ( "txd/ColorRamp01.png" )
			
			dxSetShaderValue ( grunShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( grunShader, "sFringeTexture", textureFringe )
			dxSetShaderValue ( grunShader, "sReflectionTexture", envTex_2 )
            
			dxSetShaderValue ( geneShader, "gShatt", false )
			dxSetShaderValue ( geneShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( geneShader, "sReflectionTexture", envTex_2 )
			
			dxSetShaderValue ( shatShader, "gShatt", true )
            dxSetShaderValue ( shatShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( shatShader, "sReflectionTexture", envTex_2 )			

			-- Apply to world texture
			engineApplyShaderToWorldTexture ( grunShader, "vehiclegrunge256" )
			engineApplyShaderToWorldTexture ( grunShader, "?emap*" )
			engineApplyShaderToWorldTexture ( geneShader, "vehiclegeneric256" )
			engineApplyShaderToWorldTexture ( shatShader, "vehicleshatter128" )
	
	        engineApplyShaderToWorldTexture ( geneShader, "hotdog92glass128" )
								
			for _,addList in ipairs(texturegrun) do
				engineApplyShaderToWorldTexture (grunShader, addList )
		    end
			
			for _,addList in ipairs(texturegene) do
				engineApplyShaderToWorldTexture (geneShader, addList )
		    end
			
			cprlEffectEnabled = true
			
			if v.skyLightIntensity==0 then return end
			local pntBright=v.skyLightIntensity
			vehTimer = setTimer(function()
							if cprlEffectEnabled then
								local rSkyTop,gSkyTop,bSkyTop,rSkyBott,gSkyBott,bSkyBott= getSkyGradient ()
								local cx,cy,cz = getCameraMatrix()
								if (isLineOfSightClear(cx,cy,cz,cx,cy,cz+30,true,false,false,true,false,true,false,localPlayer)) then 
									pntBright=pntBright+0.015 else pntBright=pntBright-0.015 end
								if pntBright>v.skyLightIntensity then pntBright=v.skyLightIntensity end
								if pntBright<0 then pntBright=0 end 
								dxSetShaderValue ( grunShader, "sSkyColorTop", rSkyTop/255, gSkyTop/255, bSkyTop/255)
								dxSetShaderValue ( grunShader, "sSkyColorBott", rSkyBott/255, gSkyBott/255, bSkyBott/255)
								dxSetShaderValue ( grunShader, "sSkyLightIntensity", pntBright)
								dxSetShaderValue ( geneShader, "sSkyColorTop", rSkyTop/255, gSkyTop/255, bSkyTop/255)
								dxSetShaderValue ( geneShader, "sSkyColorBott", rSkyBott/255, gSkyBott/255, bSkyBott/255)
								dxSetShaderValue ( geneShader, "sSkyLightIntensity", pntBright)
								dxSetShaderValue ( shatShader, "sSkyColorTop", rSkyTop/255, gSkyTop/255, bSkyTop/255)
								dxSetShaderValue ( shatShader, "sSkyColorBott", rSkyBott/255, gSkyBott/255, bSkyBott/255)
								dxSetShaderValue ( shatShader, "sSkyLightIntensity", pntBright)
								
							end
						end
						,50,0 )				

		else
			outputChatBox( "Could not create CPRef shader. Please use debugscript 3",255,0,0 )
		end
end

function stopCarPaintReflectLite()
	if not cprlEffectEnabled then return end
	removeEventHandler ( "onClientHUDRender", getRootElement (), updateScreen )
	engineRemoveShaderFromWorldTexture(grunShader,"*")
	engineRemoveShaderFromWorldTexture(geneShader,"*")
	engineRemoveShaderFromWorldTexture(shatShader,"*")
	destroyElement(grunShader)
	destroyElement(geneShader)
	destroyElement(shatShader)
	grunShader = nil
	geneShader = nil
	shatShader = nil
	destroyElement(myScreenSource)
	destroyElement(textureVol)
	destroyElement(textureFringe)
	myScreenSource = nil
	textureVol = nil
	textureFringe = nil
	if isTimer(vehTimer) then
		killTimer(vehTimer)
	end
	vehTimer = nil
	cprlEffectEnabled = false
end

function updateScreen()
	if myScreenSource then
		dxUpdateScreenSource( myScreenSource)
	end
end

function enableVehiclePipe()
	print("PS2 Vehicle Reflect Enabled")

    startCarPaintReflectLite()
end
function disableVehiclePipe()
    stopCarPaintReflectLite()
    print("PS2 Vehicle Reflect Disabled")
end