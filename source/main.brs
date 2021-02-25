'************************************************************
'** Application startup
'************************************************************
Sub Main()

	'initialize theme attributes like titles, logos and overhang color
	m.debugFlag = true
	initTheme()
	if initDTV() = -1 then
		print "Error !!!"
		return
	endif
	screen=initPosterScreen("", "")
	if screen=invalid then
		print "unexpected error in initPosterScreen"
		return
	end if

	'set to go, time to get started
	dtvRun(screen)

End Sub
