'*******************************************************************************
'*******************************************************************************
'Author		-	QtpSudhakar.com
'Purpose	-	To Create Html Results
'How to Use -	Make sure you associate all libraries
'			-	Use reporter.reportevent to send the results to hmtl
'			-	Make sure you specify correct path for HtmlResultPath variable
'			-	reporter.reportevent messages will be added in to html file
'			-	This will generate QTP results and Html Results
'			-	No need to write extra statements in functions to create html results
'			-	Use Dim reporter | Set reporter=ScriptReporter in expert view to overwritten reporter
'*******************************************************************************
'For any doubts contact https://www.facebook.com/Qtpsudhakarblog
'*******************************************************************************
'*******************************************************************************

'Specify where do you want to store HtmlResults
	ExecuteGlobal "Dim HtmlResultPath"
	HtmlResultPath="..\HtmlResults"
	
'Backup QTP Reporter object
	ExecuteGlobal "Dim qReporter"
	Set qReporter = Reporter
	
'Overwrite Reporter object with custom html reporting
	ExecuteGlobal "Dim Reporter"
	Set Reporter = New HtmlReporter

Function ScriptReporter()
	'@ Description	:	Return custom reporter to script
	'					The overwritten reporter object will not work in QTP Expert view
	'					The overwritten reporter object will not work in QTP Expert view
	'					You must initialize and use reporter object in expert view like below
	'Syntax			:	Dim reporter | Set reporter=ScriptReporter
	Set ScriptReporter=Reporter 
End Function

'*******************************************************************************
' Custom Html Reporting Class
'*******************************************************************************
Class HtmlReporter

'Initialize Class Variables
Public iIndex	'For Step Index
Public tHtmlResultFilePath	'Exact Result File Path
Public objHtmlFile	'Created result file object
Public clsResultName	'Name of the result to display on top of HtmlResult
Public BrowserCreationTimeIndex	'Browser index to capture screenshot on failure
Public tExecutionStartTime	'Test execution start time
Public tExecutionEndTime	'Test execution End Time
Public tExecutionTime	'How must time Test Executed
Public clsTestCaseID	'ID of the testcase

'*******************************************************************************
'*******************************************************************************
'Execution Code on Class Initialize
   	Private Sub Class_Initialize
   	
		'@ Description	:	This is an initialization code
		'					This will be executed on initialization
		'Syntax			:	Set Reporter = New HtmlReporter 

		'Step index initiated
		iIndex=1
		
		'Assign execution start time
		tExecutionStartTime=now

		'Create File System object to write html code
		Set hFso=CreateObject("scripting.filesystemobject")
		
		'Call CreateHtmlResultFile function to create Html results
		tHtmlResultFilePath=CreateHtmlResultFile
		Set objHtmlFile=hFso.CreateTextFile(tHtmlResultFilePath)
		
		clsResultName=Environment("TestName")	'Assign a result name
		clsTestCaseID=001	' Assign a testcase id

		'The below code will write header table in to html file
		'Write HTML Header
		objHtmlFile.WriteLine ("<html><body  bgcolor=	white>")
		objHtmlFile.WriteLine ("<table align=center width=900 border=0><tr><td align=center bgcolor=#3869B5><font color=white><b>"&clsResultName&" Test Results</b></font></td></tr></table>")
		objHtmlFile.WriteLine ("<br>")
		objHtmlFile.WriteLine ("<table align=center width=900 border=0>")

		'Row1 (Test ScriptId, Start Time)
		objHtmlFile.WriteLine ("<tr><td bgcolor=#3869B5 ><font color=white><b>Test Script ID:</b></font></td>")
		objHtmlFile.WriteLine ("<td bgcolor=#E4F0FF><font color=#000080> "&clsTestCaseID&"</font></td>")
		objHtmlFile.WriteLine ("<td bgcolor=#3869B5 ><font color=white><b>Start Time</b></font></td>")
		objHtmlFile.WriteLine ("<td bgcolor=#E4F0FF><font color=#000080>"&tExecutionStartTime&"</font></td></tr>")

		'Row2 (Project Name, End Time)
		objHtmlFile.WriteLine ("<tr><td bgcolor=#3869B5 ><font color=white><b>Project Name</b></font></td>")
		objHtmlFile.WriteLine ("<td bgcolor=#E4F0FF><font color=#000080> ResultDemo </font></td> ") 
		objHtmlFile.WriteLine ("<td bgcolor=#3869B5 ><font color=white><b>End Time </b></font></td>")
		objHtmlFile.WriteLine ("<td id=""endtime"" bgcolor=#E4F0FF><font color=#000080>replaceExecutionEndTime</font></td></tr>")

		'Row3 (OS Name, Execution Time)
		objHtmlFile.WriteLine ("<tr><td bgcolor=#3869B5 ><font color=white><b>OS Name </b></font></td>")
		objHtmlFile.WriteLine ("<td bgcolor=#E4F0FF><font color=#000080>"&Environment("OS")&"</font></td>")
		objHtmlFile.WriteLine ("<td bgcolor=#3869B5 ><font color=white><b>Execution Time </b></font></td>")
		objHtmlFile.WriteLine ("<td id=""etime"" bgcolor=#E4F0FF><font color=#000080>replaceExecutionTime Sec</font></td></tr>")
		'Row4 (Browser Name, Execution Status)
		objHtmlFile.WriteLine ("<tr><td bgcolor=#3869B5 ><font color=white><b>Browser Name</b></font></font></td>")
		objHtmlFile.WriteLine ("<td bgcolor=#E4F0FF><font color=#000080>IE9</font></td>")
		objHtmlFile.WriteLine ("<td id=""estatus"" bgcolor=#3869B5 ><font color=white><b>Execution Status</b></font></font></td>")

		objHtmlFile.WriteLine ("<td id=""status"" bgcolor=#E4F0FF><font color=replaceStatusColor><b>replaceRunStatus</b></font></td></tr></table><p> </p> ")
		
		'Result Columns
		objHtmlFile.WriteLine ("<table align=center width= 900>")
		objHtmlFile.WriteLine ("<tr bgcolor=#3869B5>")
		objHtmlFile.WriteLine ("<td><font color=white><b>S.No</b></font></td>")
		objHtmlFile.WriteLine ("<td><font color=white><b>Step Name</b></font></td>")
		objHtmlFile.WriteLine ("<td><font color=white><b>Description</b></font></td>")
		objHtmlFile.WriteLine ("<td><font color=white><b>Status</b></font></td>")
		objHtmlFile.WriteLine ("<td><font color=white><b>ScreenShot</b></font></td></tr>")

	End Sub
'*******************************************************************************
'*******************************************************************************

	Function CreateHtmlResultFile()
	
		'@ Description	:	Create HTMLFile in specified result path
		'					Result file will be created using Testname
		'					This function is called by Class_Initialize

				cResFolderPath=HtmlResultPath&"\"&Environment("TestName")
				BuildFolderPath cResFolderPath
				cHTMLFileName=Environment("TestName")&replace(date,"/","_")&"_"&replace(time,":","_")&".html"
				CreateHtmlResultFile=cResFolderPath&"\"&cHTMLFileName
	End Function
'*******************************************************************************
'*******************************************************************************

Sub ReportEvent(qEventStatus,sReportStepName,sDetails)

		'@ Description	:	Report result for each statement
		'					This functions will called when ever there is a statement reporter.reportevent
		'					This function is called by QTP script/function
		'Syntax			:	Reporter.ReportEvent micFail,"StepName",StepDescription"
		
				'Event status are the QTP constants
				'Status string and status color assigned based on the constant value 
				Select case qEventStatus
					case 3
						cEventStatus="WARNING"
						reportColor="FF9900"
					Case 2
						cEventStatus="DONE"
						reportColor="#000080"
					case 1
						cEventStatus="FAIL"
						reportColor="CC0000"
					case 0
						cEventStatus="PASS"
						reportColor="#000080"
				End Select

		'Prepare Html code for each statement
		HTMLStepStart="<TR bgColor=#e4f0ff>"
		HTMLStepIndex="<td align='center' bgcolor='#E4F0FF'><font color="&reportColor&">"&iIndex&"</font></td>"
		HTMLStepName="<td bgcolor='#E4F0FF'><font color="&reportColor&">"&sReportStepName&"</font></td>"
		HTMLStepDescription="<td bgcolor=#E4F0FF><font color="&reportColor&">"&sDetails&"</font></td>"
		HTMLStepStatus="<td bgcolor=#E4F0FF><font color=	"&reportColor&">"&cEventStatus&"</font></td>"
		
		'Capture Bitmap based on Step Status
		'If no creation time specified then capture 0th browser screenshot
			If ucase(cEventStatus)="FAIL" Then
				eImageFilePath=CreateImageFilePath
				If BrowserCreationTimeIndex="" Then
					BrowserCreationTimeIndex=0
				End If
				
				'If no browser found capture desktop screenshot
				If Browser("creationtime:="&BrowserCreationTimeIndex).Exist then
					Browser("creationtime:="&BrowserCreationTimeIndex).CaptureBitmap eImageFilePath,true
				Else
					Desktop.CaptureBitmap eImageFilePath,true
					BrowserCreationTimeIndex=""
				End If
			End If

		'prepare Image file Html Code
		If eImageFilePath<>"" Then
			HTMLStepScreenPath="<td bgcolor=#E4F0FF><a href='"&eImageFilePath&"' target="""">View Error</a></td>"
		else
			HTMLStepScreenPath="<td bgcolor=#E4F0FF>-</td>"
		End If

		'Combine All html step code and write in to html file
		HTMLStepEnd="</TR>"
		HTMLStep=HTMLStepStart&HTMLStepIndex&HTMLStepName&HTMLStepDescription&HTMLStepStatus&HTMLStepScreenPath&HTMLStepEnd
		objHtmlFile.WriteLine(HTMLStep)

		'Parallelly Send QTP result with the stored qReporter object
				qReporter.ReportEvent qEventStatus,sReportStepName,sDetails
		
		'Increase step index for the use of next statement
		iIndex=iIndex+1
		
		'Make eImageFilePath to empty for the use of next error image
		eImageFilePath=""

		End Sub
'*******************************************************************************
'*******************************************************************************
		Function CreateImageFilePath()
		'@ Description	:	Creates image file path and also build folders if not exist
		'					This function is called by ReportEvent Function

           ErrImgFldPath=HtmlResultPath&"\ErrorImages\"
		   BuildFolderPath(ErrImgFldPath)
			CreateImageFilePath=ErrImgFldPath&Environment("TestName")&"_Step"&iIndex&" Error_"&replace(date,"/","_")&"_"&replace(time,":","_")&".png"
		End Function
'*******************************************************************************
'*******************************************************************************
	Function BuildFolderPath(fldPath)
		'@ Description	:	Build complete folder path if the specified path not exists
		'					This function is called by CreateHtmlResultFile and CreateImageFilePath Functions
		
		'Declare variables
		Dim bFso
		Dim PathArray
		Dim rfldPath
		Dim pIndex
		Dim fPath
		
		'Create file system object
		Set bFso=CreateObject("scripting.filesystemobject")
	
		'Split the folder path using \\ if the path is a shared drive path
		If instr(1,fldPath,"\\")=1 Then
			rfldPath=mid(fldPath,3,len(fldPath)-2)
			PathArray=Split(rfldPath,"\")
			fPath="\\"&PathArray(0)
		Else
		'Split the folder path using \ if the path is a local drive path
			PathArray=Split(fldPath,"\")
			fPath=PathArray(0)
		End If
	
			'Verify existance and create a folder for the complete path
			For pIndex=1 to ubound(PathArray)
		
			fPath=fPath&"\"&PathArray(pIndex)
		
				If not bFso.FolderExists(fPath) then
					bFso.CreateFolder(fPath)
				End If

			Next
		
		Set bFso=nothing
	
	End Function

'*******************************************************************************
'*******************************************************************************
	Function GetExecutionTime(StartTime,EndTime)
		'@ Description	:	This will get the execution time
		'					This function is called by Class_Terminate
		
		'Seperate hours, minutes and seconds
		StartHour = Hour(StartTime)
		StartMin = Minute(StartTime)
		StartSec = Second(StartTime)
		EndHour = Hour(EndTime)
		EndMin = Minute(EndTime)
		EndSec = Second(EndTime)
		
		'Convert all in to seconds
		StartingSeconds = (StartSec + (StartMin * 60) + (StartHour * 3600))
		EndingSeconds = (EndSec + (EndMin * 60) + (EndHour * 3600))
	
		'Use subtraction to know the execution time
		GetExecutionTime = EndingSeconds - StartingSeconds
	End Function
'*******************************************************************************
'*******************************************************************************
	Private Sub Class_Terminate
		'@ Description	:	This code automatically executes when the test execution completes
		'					This will get the Execution time, Final status of QTP and updates in result file
			
		'Get the end time
		tExecutionEndTime=Now
		
		'Use GetExecutionTime to calculate execution time
		tExecutionTime=GetExecutionTime(tExecutionStartTime,tExecutionEndTime)

				'Get the final execution status and assign colors
				Select case qReporter.RunStatus
					case 3
						qTcStatus="WARNING"
						fColor="#FF9900"
					Case 2
						qTcStatus="DONE"
						fColor="#000080"
					case 1
						qTcStatus="FAIL"
						fColor="#CC0000"
					case 0
						qTcStatus="PASS"
						fColor="#000080"
				End Select
		
		'Close the Html Result file
		objHtmlFile.WriteLine ("</table></body></html>")
		objHtmlFile.Close

Set objHtmlFile=nothing
Set hFso=Nothing
	
	'Update Execution time, Execution status in html file by reopening it
	Set hFile=createobject("scripting.filesystemobject").GetFile(tHtmlResultFilePath)
	Set hCreatedFile=hFile.OpenAsTextStream
	strHtmlCode=hCreatedFile.ReadAll
	strHtmlCode=replace(strHtmlCode,"replaceExecutionEndTime",tExecutionEndTime,1,1)
	strHtmlCode=replace(strHtmlCode,"replaceExecutionTime",tExecutionTime,1,1)
	strHtmlCode=replace(strHtmlCode,"replaceStatusColor",fColor,1,1)
	strHtmlCode=replace(strHtmlCode,"replaceRunStatus",qTcStatus,1,1)
	
	hCreatedFile.Close

	Set hCreatedFile=hFile.OpenAsTextStream(2)
	hCreatedFile.Write strHtmlCode
	hCreatedFile.Close
	End Sub
'*******************************************************************************
'*******************************************************************************
End Class
