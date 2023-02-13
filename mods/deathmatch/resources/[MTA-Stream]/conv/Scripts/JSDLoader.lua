-- NOTE in order to deal with case sensitve issue (Some bad formated IPLs, IDEs may associate with 
-- inconsistent filename), we pre-process all filenames to lower case by default.

print("Writing Client Object Data")
ObjectDataC = {}

function AdditionalFlag(InPut)
	return InPut
end

Culled = {}

function CulledA(InPut)
	if InPut == 2097152 then
		return 'true'
	else
		return 'nil'
	end
end
--The LOD models have the same name as the original model, except the first three letters of the LOD model are replaced by the letters "LOD." Create an LOD version of the collision model of the original model. The LOD collision should be the same size as the original model's but with nothing in it.
for i,v in pairs(IDEList) do
	if v[7]~= nil then
		local model = removeSpace(v[1])
		local texture = removeSpace(v[2])
		local drawdistance = removeSpace(v[3])
		local Flag = AdditionalFlag(removeSpace(v[6]))
		--local Culled = CulledA(removeSpace(v[6]))
		local Culled = "true"
		local LOD = v[7] == -1 and "nil" or v[7]
		
		if v[4] and v[5] then
			table.insert(ObjectDataC,string.lower(model)..','..string.lower(model)..','..string.lower(texture)..','..string.lower(model)..','..drawdistance..','..Flag..','..Culled..','..string.lower(LOD)..','..removeSpace(v[4])..','..removeSpace(v[5]))
		else
			table.insert(ObjectDataC,string.lower(model)..','..string.lower(model)..','..string.lower(texture)..','..string.lower(model)..','..drawdistance..','..Flag..','..Culled..','..string.lower(LOD))
		end
	end

end


local file = fileCreate (MapName..'/gta3.JSD' )
for i,v in pairs(ObjectDataC) do
	fileWrite(file,v.."\n")
end

fileClose(file) -- done