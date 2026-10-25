-- Text arrives through Rainmeter's native UTF-16 command channel.
-- Lua only animates numeric positions; it never decodes Chinese lyrics.
local offset, progress, moving = 0, 0, false
local function paint()
 local height=tonumber(SKIN:GetVariable('LyricsLineHeight')) or 40
 for i=0,5 do SKIN:Bang('!SetOption','Lyric'..i,'Y',tostring(i*height+offset)) end
 SKIN:Bang('!UpdateMeterGroup','Lyrics')
 SKIN:Bang('!Redraw')
end
function Initialize() end
function Reset()
 moving=false;offset=0
 SKIN:Bang('!DisableMeasure','LyricsAnimation')
 paint()
end
function Scroll()
 offset=tonumber(SKIN:GetVariable('LyricsLineHeight')) or 40
 progress=0;moving=true
 SKIN:Bang('!EnableMeasure','LyricsAnimation')
 paint()
end
function Update()
 if not moving then return 0 end
 -- Accumulate the fixed skin update interval, rather than Lua CPU time.
 progress=progress+33/320
 local step=progress
 if step>=1 then SKIN:Bang('!SetVariable','LyricsStep','0');Reset();return 0 end
 local height=tonumber(SKIN:GetVariable('LyricsLineHeight')) or 40
 offset=height*(1-step)^3
 paint()
 return 0
end
