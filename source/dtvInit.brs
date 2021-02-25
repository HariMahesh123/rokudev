
'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** These attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "25"
    theme.OverhangOffsetSD_Y = "10"
    theme.OverhangSliceSD = "file://images/dtvOverhangSlice_SD.png"	' Background image
    theme.OverhangLogoSD  = "file://images/dtvOverhangLogo_SD.png"	' Left corner logo

    theme.OverhangOffsetHD_X = "123"		' HD offset needs to be tuned with a display
    theme.OverhangOffsetHD_Y = "22"
    theme.OverhangSliceHD = "file://images/dtvOverhangSlice_HD.png"
    theme.OverhangLogoHD  = "file://images/dtvOverhangLogo_HD.png"

    app.SetTheme(theme)

End Sub


'******************************************************
'** Initialize DreamTV specific information
'******************************************************
Sub initDTV() As Integer
	m.baseUrl = "http://www.smeraproductions.com/roku/"
	m.categoryUrl = m.baseUrl + "categories.xml"
	m.mainXml = getCategoryXML()
	m.categoryList = getCategoryListXML(m.mainXml)
	if m.categoryList = invalid then
		return -1
	endif
	m.movieList = getMoviesXML(0)	' Get the list for the first category
	if m.movieList = invalid then
		return -1
	endif
	m.movieList.showItem = buildMovieShowList()
	return 0
End Sub

'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function initPosterScreen(breadA=invalid, breadB=invalid) As Object

    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    screen.SetListStyle("arced-landscape")
    return screen

End Function

