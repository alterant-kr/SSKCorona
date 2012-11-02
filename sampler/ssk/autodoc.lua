-- =============================================================
-- Copyright Roaming Gamer, LLC. 2009-2012 
-- =============================================================
-- SSKCorona Automatic documentation tool
-- =============================================================
-- Short and Sweet License: 
-- 1. You may use anything you find in the SSKCorona library and sampler to make apps and games for free or $$.
-- 2. You may not sell or distribute SSKCorona or the sampler as your own work.
-- 3. If you intend to use the art or external code assets, you must read and follow the licenses found in the
--    various associated readMe.txt files near those assets.
--
-- Credit?:  Mentioning SSKCorona and/or Roaming Gamer, LLC. in your credits is not required, but it would be nice.  Thanks!
--
-- =============================================================
--
-- =============================================================
--module(..., package.seeall);

-- str = str:gsub("^%l", string.upper) -- first letter to upper
--\n\n[[SSKCorona#Libraries| Back]]

local _require = _G.require

-- local status variables and file handles
local inFileName
local outFile = nil
local inDescription = false
local inSyntax = false
local inReturns = false
local inExample = false
local inExample2 = false
local inSeeAlso = false

-- Parsing functions
local newOutfile
local newBlock
local headerLine
local descriptionLine
local descriptionLine2
local syntaxLine
local returnsLine
local exampleLine
local exampleLine2
local seeAlsoLine
local endBlock

-- ======================================================================
-- split - Splits token (tok) separated string into integer indexed table
-- http://lua-users.org/wiki/SplitJoin (modified)
-- ======================================================================
function string:split(tok)
	local str = self
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local ftok = "(.-)" .. tok
	local last_end = 1
	local s, e, cap = str:find(ftok, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(ftok, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

-- ======================================================================
-- getWord - Gets indexed word from string, where words are separated by a single space (' ').
-- Derived from same named Torque Script function
-- ======================================================================
function string:getWord( index )
	local index = index or 1
	local aTable = self:split(" ")
	return aTable[index]
end
-- ======================================================================
-- getWords - Gets indexed words from string, starting at 'index' and ending at 'endindex' or end of line if not
-- specified.  Words are separated by a single space (' ').
-- Derived from same named Torque Script function
-- ======================================================================
function string:getWords( index, endindex )
	local index = index or 1
	local offset = index - 1
	local aTable = self:split(" ")
	local endindex = endindex or #aTable

	if(endindex > #aTable) then
		endindex = #aTable
	end

	local tmpTable = {}

	for i = index, endindex do
		tmpTable[i-offset] = aTable[i]
	end

	local tmpString = table.concat(tmpTable, " ")

	return tmpString
end


_G.require = function( ... )

	newOutfile( arg[1] )

	--print("Auto documenting: ", arg[1] )
	local path = arg[1]
	path = path:gsub( "%.", "\\") .. ".lua"
	path = system.pathForFile( path , system.ResourceDirectory )
	
	-- io.open opens a file at path. returns nil if no file found
	if path then
		local inFile, errStr = io.open( path, "r" )

		if inFile then
			--print("Succesfully opened: " .. path)
			
			-- Parse the file line by line
			local lines = inFile:read( "*l" )

			while( lines ) do

				local firstWord = lines:getWord(1)

				if( firstWord == "--[[" ) then
					newBlock( lines:getWords(2) )

				elseif( firstWord == "h" ) then
					headerLine( lines:getWords(2) )

				elseif( firstWord == "d" ) then
					descriptionLine( lines:getWords(2) )

				elseif( firstWord == "d2" ) then
					descriptionLine2( lines:getWords(2) )

				elseif( firstWord == "s" ) then
					syntaxLine( lines:getWords(2) )

				elseif( firstWord == "r" ) then
					returnsLine( lines:getWords(2) )

				elseif( firstWord == "e" ) then
					exampleLine( lines:getWords(2) )

				elseif( firstWord == "e2" ) then
					exampleLine2( lines:getWords(2) )


				elseif( firstWord == "a" ) then
					seeAlsoLine( lines:getWords(2) )

				elseif( firstWord == "--]]" ) then
					endBlock()
				end
				lines = inFile:read( "*l" )
			end

			if( outFile ) then
				io.close( outFile )
				outFile = nil
			end

			io.close(inFile)
		end
	end
	return _require( unpack(arg) )
end


local function isOutFileOpen( )
	if( outFile ) then
		return
	end
	print("Need to open outfile for first time: " .. inFileName )

	local fileName = inFileName -- .. ".txt"
	fileName = fileName:gsub( "%.", "_") .. ".txt"
	
	-- io.open opens a file at path. returns nil if no file found
	local path = system.pathForFile( fileName, system.DocumentsDirectory )
	outFile   = io.open( path, "w" )

	if outFile then
		print( "Created file" )
	else
		print( "Create file failed!" )
	end
end


newOutfile = function ( fileName ) 
	print("New In File: " .. fileName )
	inFileName = fileName

	outFile = nil
	inDescription = false
	inSyntax = false
	inReturns = false
	inExample = false
	inExample2 = false
	inSeeAlso = false

end

newBlock = function ( inFile ) 
	print(" *****************  New Block")
	--isOutFileOpen()
	--outFile:write( "Feed me data!\n", numbers[1], numbers[2], "\n" )
	inDescription = false
	inSyntax = false
	inReturns = false
	inExample = false
	inExample2 = false
	inSeeAlso = false

end

headerLine = function ( line ) 
	print("Header Line")
	isOutFileOpen()
	local name = line:gsub("^%l", string.upper)
	if(not line) then line = "" end
	
	outFile:write( "PAGENAME: " .. name .."\n" )
	outFile:write( "INDEX: " .. "[[" .. name .."| " .. name .."]]" .."\n" )
end

descriptionLine = function ( line ) 
	print("Definition Line")
	isOutFileOpen()

	if( inExample or inExample2 ) then
		inExample = false
		inExample2 = false
		outFile:write( "</syntaxhighlight></big>\n" )
	end

	if(not line) then line = "" end
	outFile:write( line .. "\n" )
end

descriptionLine2 = function ( line ) 
	print("Description Line 2")
	isOutFileOpen()

	if(not line) then line = "" end
	outFile:write( line .. "\n" )
end

syntaxLine = function ( line ) 
	print("Syntax Line")
	isOutFileOpen()
	if(not line) then line = "" end

	if(inSyntax) then
		outFile:write( line .. "\n" )
	else
		inSyntax = true
		outFile:write( "\n<br>'''<big>Syntax</big>''' <br>\n" )
		outFile:write( line .. "\n" )
	end
end

returnsLine = function ( line ) 
	print("Returns Line")
	isOutFileOpen()
	if(not line) then line = "" end

	if(inReturns) then
		outFile:write( line .. "\n" )
	else
		inReturns = true
		outFile:write( "\n<br>'''<big>Returns</big>''' <br>\n" )
		outFile:write( line .. "\n" )
	end
end

exampleLine = function ( line ) 
	print("Example Line")
	isOutFileOpen()
	if(not line) then line = "" end

	if(inExample) then
		outFile:write( line .. "\n" )
	else
		inExample = true
		outFile:write( "\n<br>'''<big>Example</big>''' <br>\n" )
		outFile:write( "<big><syntaxhighlight lang=\"cpp\">\n" )
		outFile:write( line .. "\n" )
	end
end

exampleLine2 = function ( line ) 
	print("Example Line 2")
	isOutFileOpen()
	if(not line) then line = "" end

	if(inExample2) then
		outFile:write( line .. "\n" )
	else
		inExample2 = true
		outFile:write( "<big><syntaxhighlight lang=\"cpp\">\n" )
		outFile:write( line .. "\n" )
	end
end

seeAlsoLine = function ( line ) 
	print("See Also Line")
	isOutFileOpen()
	if(not line) then line = "" end

	if(inSeeAlso) then
		outFile:write( line .. "\n" )
	else
		if( inExample or inExample2 ) then
			inExample = false
			inExample2 = false
			outFile:write( "</big></syntaxhighlight>" )
		end
		inSeeAlso = true
		outFile:write( "\n<br>'''<big>See Also</big>''' <br>\n" )
		outFile:write( line .. "\n" )
	end
end

endBlock = function ( ) 
	if( inExample or inExample2 ) then
		inExample = false
		inExample2 = false
		outFile:write( "</syntaxhighlight></big>" )
	end

	if(outFile) then
		outFile:write( "\n\n[[SSKCorona#Libraries| Back]]" )
		outFile:write( "\n\n ================================= \n\n" )
	end
end


