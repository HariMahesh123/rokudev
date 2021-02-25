Function getCategoryXML() As Object
	http = NewHttp(m.categoryUrl, "")
	rsp = http.GetToStringWithRetry("")
	'print "rsp : "; rsp
	xml=CreateObject("roXMLElement")
	if not xml.Parse(rsp) then
		print "Can't parse XML"
		return invalid
	endif
	return xml
End Function

Function getCategoryListXML(xml) As Object
	categoryList = parseCategories(xml)
	print "Category list extracted : ";categoryList
	return categoryList
End Function

Function parseCategories(xml As Object) as Object
	'PrintXML(xml,2)
	' Verify if we got the category xml right
	if xml.GetName() <> "categories" then
		print "Error. Invalid starting xml"
		return invalid
	endif
	' No attributes are expected. So go directly to the body
	if xml.GetBody() = invalid then
		print "Error in : "; m.categoryUrl
		return invalid
	else if type(xml.GetBody()) <> "roXMLList" then
		print "Error in category list"
		return invalid
	endif
	i = 0
	categoryList = CreateObject("roAssociativeArray")
	categoryList.name = CreateObject("roArray", 10, true)
	categoryList.title = CreateObject("roArray", 10, true)
	' Get the Title from the category
	for each e in xml.GetBody()
		k = e.GetBody()
		categoryList.name[i] = e.GetName()
		categoryList.title[i] = k[0].GetBody()
		i = i + 1
	next
	return categoryList
End Function

Function getMovieListXML(url As String) As Object
	http = NewHttp(url, "")
	rsp = http.GetToStringWithRetry("")
	'print "rsp : "; rsp
	xml=CreateObject("roXMLElement")
	if not xml.Parse(rsp) then
		print "Can't parse XML"
		return invalid
	endif
	return xml
End Function

Function parseMovies(xml As Object) As Object
	movieList = CreateObject("roAssociativeArray")
	movieList.contentType 	= CreateObject("roArray", 25, true) ' [0]
	movieList.title 	= CreateObject("roArray", 25, true) ' [1]
	movieList.shortDesc	= CreateObject("roArray", 25, true) ' [2]
	movieList.description 	= CreateObject("roArray", 25, true) ' [3]
	movieList.streamUrls 	= CreateObject("roArray", 25, true) ' [4]
	movieList.thumbNail	= CreateObject("roArray", 25, true) ' [5]
	movieList.actor1	= CreateObject("roArray", 25, true) ' [6]
	movieList.actor2	= CreateObject("roArray", 25, true) ' [7]
	movieList.actor3	= CreateObject("roArray", 25, true) ' [8]
	movieList.director	= CreateObject("roArray", 25, true) ' [9]
	movieList.duration	= CreateObject("roArray", 25, true) ' [9]
	movieList.releaseDate	= CreateObject("roArray", 25, true) ' [11]
	i = 0
	for each e in xml.GetBody()
		k = e.GetBody()
		j = 0
		movieList.contentType 	[i] = ""
		movieList.title 	[i] = ""
		movieList.description 	[i] = ""
		movieList.shortDesc 	[i] = ""
		movieList.streamUrls 	[i] = ""
		movieList.thumbNail	[i] = ""
		movieList.actor1	[i] = ""
		movieList.actor2	[i] = ""
		movieList.actor3	[i] = ""
		movieList.director	[i] = ""
		movieList.duration	[i] = 0
		movieList.releaseDate	[i] = ""
		' Parse xml for the valid keys and assign
		while k[j] <> invalid
			name = Lcase(k[j].GetName())
			body = k[j].GetBody()
			if name = "contenttype" then 
				movieList.contentType 	[i] = body
			endif
	
			if name = "title" then
				movieList.title 	[i] = body
			endif

			if name = "shortdesc" then
				movieList.shortDesc	[i] = body
			endif

			if name = "description" then
				movieList.description 	[i] = body
			endif 

			if name = "streamurls" then
				movieList.streamUrls 	[i] = body
			endif

			if name = "thumbnail" then
				movieList.thumbNail	[i] = body
			endif

			if name = "actor1" then
				movieList.actor1	[i] = body
			endif

			if name = "actor2" then
				movieList.actor2	[i] = body
			endif

			if name = "actor3" then
				movieList.actor3	[i] = body
			endif

			if name = "director" then
				movieList.director	[i] = body
			endif

			if name = "duration" then
				movieList.duration	[i] = body
			endif

			if name = "releasedate" then
				movieList.releaseDate	[i] = body
			endif
			j = j + 1
		End while
		i = i + 1
	next
	movieList.totalMovies = i - 1
	return movieList
End Function

Function buildMovieShowList() As Object
	d = m.categoryList.name[m.curIndex]
	tnUrl = m.baseUrl + d + "/"
	showItem = []
	tnImage = ""
	for i = 0 to m.movieList.totalMovies
		tnImage = tnUrl + m.movieList.thumbNail[i]
		showItem[i] = {
			ShortDescriptionLine1:m.movieList.title[i],
			ShortDescriptionLine2:m.movieList.shortDesc[i],
			HDPosterUrl: tnImage, 
			SDPosterUrl: tnImage
		}
	next i
	return showItem

End Function

Function getMoviesXML(index As Integer) As Object
	d = m.categoryList.name[index]
	m.curIndex = index		' Needed for getting the directory name
	url = m.baseUrl + d + "/" + d + ".xml"
	print "Extracting movie url : "; url
	xml = getMovieListXML(url)
	'PrintXML(xml,2)	
	movieList = parseMovies(xml)
	return movieList
End Function

REM ******************************************************
REM
REM Walk an XML tree and print. This is just for testing purpose
REM
REM ******************************************************

Sub PrintXML(element As Object, depth As Integer)
    print tab(depth*3);"Name: ";element.GetName()
    if invalid <> element.GetAttributes() then
        print tab(depth*3);"Attributes: ";
        for each a in element.GetAttributes()
            print a;"=";left(element.GetAttributes()[a], 4000);
            if element.GetAttributes().IsNext() then print ", ";
        next
        print
    endif

    if element.GetBody()=invalid then
        ' print tab(depth*3);"No Body" 
    else if type(element.GetBody())="roString" then
        print tab(depth*3);"Contains string: ";left(element.GetBody(), 4000)
    else
        print tab(depth*3);"Contains list:"
        for each e in element.GetBody()
		print "Content e : "; e
		print "Unwinding :"
            PrintXML(e, depth+1)
        next
    endif
    print
end sub

