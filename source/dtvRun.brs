'******************************************************
'** Obtain the main category file and the item on focus
'** and populate the screen
'******************************************************
Function dtvRun(screen As Object) As Integer
	if showPosterScreen(screen) = -1
		print "Error in Poster Screen Display"
		return -1
	endif
	return 0
End Function

'******************************************************
'** Display the poster screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the show posters
'******************************************************
Function showPosterScreen(screen As Object) As Integer

    screen.SetListNames(m.categoryList.title)
    screen.SetIconArray(m.movieList.showItem)
    screen.Show()

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
		categoryIndex = msg.GetIndex()
            print "showPosterScreen | msg = "; msg.GetMessage() " | index = "; categoryIndex
            if msg.isListFocused() then
		' Invalidate the movie list so that the objects are released
		m.movieList.showItem = invalid
		m.movieList = invalid
                'get the list of shows for the currently selected item
		m.movieList = getMoviesXML(msg.GetIndex())
		m.movieList.showItem = buildMovieShowList()
                screen.SetIconArray(m.movieList.showItem)
                print "list focused | current category = "; msg.GetIndex()
            else if msg.isListItemFocused() then
		showIndex = msg.GetIndex()
                print"list item focused | current show = "; msg.GetIndex()
            else if msg.isListItemSelected() then
                print "list item selected | current show = "; msg.GetIndex() 
		showIndex = msg.GetIndex()
                'if you had a list of shows, the index of the current item 
                'is probably the right show, so you'd do something like this
                m.curShow = showSpringBoard(categoryIndex, showIndex)
            else if msg.isScreenClosed() then
                return 1
            end if
        end If
    end while
	return 1

End Function

'**********************************************************
'** When a poster on the home screen is selected, we call
'** this function passing an roAssociativeArray with the 
'** ContentMetaData for the selected show.  This data should 
'** be sufficient for the springboard to display
'**********************************************************
Function showSpringBoard(categoryIndex as Integer, showIndex as Integer) As Integer

	springBoard = CreateObject("roSpringboardScreen") 
	springBoard.SetBreadcrumbText("__home__", m.movieList.contentType[showIndex]) 
	port = CreateObject("roMessagePort")
	if port = invalid then
		print "Error in creating springboard message port"
		return -1
	endif
	springBoard.SetMessagePort(port)
	springBoard.AddButton(0, "Play")
	springBoard.AddButton(1, "Return")

 
	o = CreateObject("roAssociativeArray") 
	o.ContentType = m.movieList.contentType[showIndex] 
	o.Title = m.movieList.title[showIndex] 
	o.ShortDescriptionLine1 = m.movieList.title[showIndex]
	o.ShortDescriptionLine2 = m.movieList.shortDesc[showIndex]
	o.Description = m.movieList.description[showIndex] 
	d = m.categoryList.name[m.curIndex]
	tnUrl = m.baseUrl + d + "/"
	tnImage = tnUrl + m.movieList.thumbNail[showIndex]
	o.SDPosterUrl = tnImage 
	o.HDPosterUrl = tnImage 
	o.Rating      = "NR" 
	o.StarRating  = "75" 
	o.ReleaseDate = m.movieList.releaseDate[showIndex]
	o.Length           = m.movieList.duration[showIndex]
	'o.Categories       = CreateObject("roArray", 10, true)  
	'o.Categories.Push("[Category1]") 
	'o.Categories.Push("[Category2]") 
	'o.Categories.Push("[Category3]") 
	o.Actors           = CreateObject("roArray", 10, true) 
	o.Actors.Push(m.movieList.actor1[showIndex]) 
	o.Actors.Push(m.movieList.actor2[showIndex]) 
	o.Actors.Push(m.movieList.actor3[showIndex]) 
	o.Director = m.movieList.director[showIndex]
 
	springBoard.SetContent(o) 
	springBoard.Show()

	while true
		msg = wait(0, port)
		print "Springboard Screen event received "; type(msg)
		if type(msg) = "roSpringboardScreenEvent"
			if msg.isScreenClosed()
				return -1
			else if msg.isButtonPressed() then
				if msg.GetIndex() = 0 then       'Play video
					showVideoScreen(showIndex)
				else if msg.GetIndex() = 1 then  'Done
					return 1
				endif
			else
				print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
			endif
		endif
	end while
	return 1

End Function


'********************************************************************* 
' This function plays the selected video
'********************************************************************** 
Function showVideoScreen(index As Integer) As Void
 
	episode = CreateObject("roAssociativeArray")
   screen = CreateObject("roVideoScreen") 
   port = CreateObject("roMessagePort") 
	if port = invalid then
		print "Error in creating springboard message port"
		return
	endif
	screen.SetMessagePort(port)
 
   episode.HDBranded = false 
   episode.IsHD = false 
 
   '  Note: Stream bitrates, url’s and quality values are set as 
   '  array’s.  If there are multiple bitrates available, 
   '  the elements in these arrays must be in aligned by index.  
   '  In this case, we just assume that there's only one bitrate 
   '  available.  The bitrate will be used to select the best  
   '  stream from the list and determine how many dots to display.   
   '  The info in the.mp4 header for the content is used during  
   '  playback, but meta data attributes and header should match. 
   episode.StreamBitrates = [500] 
	d = m.categoryList.name[m.curIndex]
	tnUrl = m.baseUrl + d + "/"
   episode.StreamURLs = [tnUrl + m.movieList.streamUrls[index]]
   episode.StreamQualities = ["SD"] 
 
   ' now just tell the screen about the title to be played, set the  
   ' message port for where you will receive events and call show to  
   ' begin playback.  You should see a buffering screen and then  
   ' playback will start immediately when we have enough data buffered.  
    screen.SetContent(episode) 
    screen.SetMessagePort(port) 
    screen.Show() 
 
   ' Wait in a loop on the message port for events to be received.   
   ' We will just quit the loop and return to the calling function  
   ' when the users terminates playback, but there are other things  
   ' you could do here like monitor playback position and see events  
   ' from the video player.  For example, if you look for event types  
   ' 9 and 11, you can get failure and status messages from the  
   ' video player in case something goes wrong initiating playback.  

    while true
        msg = wait(0, port)

        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then
                print "close video screen"
                exit while
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
		print "Here in Video Playback"
		exit while
            endif
        else
            print "Unexpected message class: "; type(msg)
		exit while
        endif
    end while

	return
End Function 

