

AlphaTxds = {"*shadow*","white64"}

addEventHandler( "onClientResourceStart", root,function() 
    night_shader = dxCreateShader( "alpha.fx" ) 
    if not night_shader then outputChatBox("[Night Blend Fix] Fail to create shader") end
    for i, v in ipairs(AlphaTxds) do
        --print(i, v)
		engineApplyShaderToWorldTexture(night_shader,v)
		outputChatBox(v)
    end

end)