Option Explicit
Const SITE As String = "CY"
Const SERVER As String = "10.154.226.203"
Private Function BuildJson(sht As Worksheet, field As Variant, value As Variant, Optional Save As Boolean = False) As String

Static Json As String
    If Save Then
        If Json <> "" Then
            Json = Left(Json, Len(Json) - 2) 'remove trailing comma
            Json = """data"":{" & Json & "}"
                Dim name As String, user As String, cyear As String, cweek As String, cmonth As String
                name = sht.Range("L11").value
                user = Application.username
                cyear = Left(name, 4)
                cweek = Left(Replace(sht.name, "Week ", ""), 2)
                Dim http As Object
                Dim url As String
                 
                Dim requestBody As String
                
                 requestBody = "{""site"":""" & SITE & """, " & _
              """yearWeek"":""" & cyear & "-" & cweek & """, " & _
              """updatedBy"":""" & user & """, " & _
              """reportmonth"":""" & GetMonth(Monthly.Range("L11").value) & """, " & _
               Json & "}"

                ' Retrieve values from named ranges
                On Error GoTo ErrorHandler
                Debug.Print requestBody
              
                ' Initialize HTTP object
                Set http = CreateObject("MSXML2.ServerXMLHTTP")
                url = "http://" & SERVER & ":3000/api/managementKPI/add-managementKPI/:site/:yearWeek/:updatedby/:reportmonth/:data"
                ' Configure and send HTTP POST request
                With http
                    .Open "POST", url, False
                    .SetRequestHeader "Content-Type", "application/json"
                    .Send requestBody
                End With
            
                ' Check the response
                If http.Status = 201 Then
                    MsgBox "Data posted successfully!"
                Else
                    MsgBox "Error: " & http.Status & " - " & http.responseText
                End If
                Json = "" 'field is static. we should reset
                BuildJson = Json
            
        End If
    Else
        If Trim(field) <> "" Or Trim(value) <> "" Then ' if there is a data compose
            Json = Json & """" & Replace(Replace(Replace(Replace(Replace(field, "+", "and"), "w/o", "without"), ">", ""), "/", " or "), "%", "Percent") & """:""" & Trim(value) & """, "
            BuildJson = Json
        End If
    End If
    Exit Function
ErrorHandler:
                MsgBox "An error occurred: " & Err.Description, vbCritical
  
End Function
 Private Sub test()
    PopulateKpiDataAndSendToNode ActiveSheet
End Sub

Private Function GetMonth(rangeValue As String) As String

Select Case True

    Case InStr(1, rangeValue, "January") > 0
        GetMonth = "01"
    Case InStr(1, rangeValue, "February") > 0
        GetMonth = "02"
    Case InStr(1, rangeValue, "March") > 0
        GetMonth = "03"
    Case InStr(1, rangeValue, "April") > 0
        GetMonth = "04"
    Case InStr(1, rangeValue, "May") > 0
        GetMonth = "05"
    Case InStr(1, rangeValue, "June") > 0
        GetMonth = "06"
    Case InStr(1, rangeValue, "July") > 0
        GetMonth = "07"
    Case InStr(1, rangeValue, "August") > 0
        GetMonth = "01"
    Case InStr(1, rangeValue, "September") > 0
        GetMonth = "09"
    Case InStr(1, rangeValue, "October") > 0
        GetMonth = "10"
    Case InStr(1, rangeValue, "November") > 0
        GetMonth = "11"
    Case InStr(1, rangeValue, "December") > 0
        GetMonth = "12"
  End Select
End Function


Public Sub PopulateKpiDataAndSendToNode(sht As Worksheet)
 
    Dim pkdCurrentWeek, pkdCurrentTimeStamp, pkdMetricName, pkdCommentText, pkdMetricValue As String
    Dim pkdSourceRowNum, pkdTargetRowNum, lrow As Long
  
    pkdCurrentWeek = sht.name
    pkdCurrentTimeStamp = sht.Cells(11, 12)
   
    lrow = sht.Columns(13).Find(What:="*", LookAt:=xlPart, LookIn:=xlFormulas, searchorder:=xlByRows, searchdirection:=xlPrevious, MatchCase:=False).Row
     
    For pkdSourceRowNum = 17 To lrow
        If Not sht.Cells(pkdSourceRowNum, 12) = "" And Not sht.Cells(pkdSourceRowNum, 12) = "Human Resources" And Not sht.Cells(pkdSourceRowNum, 12) = "Production" _
            And Not sht.Cells(pkdSourceRowNum, 12) = "Maintenance" And Not sht.Cells(pkdSourceRowNum, 12) = "Costs" And Not sht.Cells(pkdSourceRowNum, 13) = "" Then
            pkdMetricName = sht.Cells(pkdSourceRowNum, 12)
            pkdMetricValue = sht.Cells(pkdSourceRowNum, 13)
            BuildJson sht, pkdMetricName, pkdMetricValue
           
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
            If pkdMetricName = "Fault Durations (Daily KPI)" And Not sht.Cells(pkdSourceRowNum, 17) = "" Then
                pkdMetricName = "Fault Duration Notes"
                pkdMetricValue = sht.Cells(pkdSourceRowNum, 17).value
                 BuildJson sht, pkdMetricName, pkdMetricValue
            End If
                 
            If pkdMetricName = "Fault Rates (Daily KPI)" And Not Cells(pkdSourceRowNum, 17) = "" Then
                pkdMetricName = "Fault Rate Notes"
                pkdMetricValue = sht.Cells(pkdSourceRowNum, 17).value
                BuildJson sht, pkdMetricName, pkdMetricValue
            End If
             
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
        End If
    Next pkdSourceRowNum
    If Application.WorksheetFunction.CountIf(Range("V8:V11"), "*Empty*") = 0 Then
        pkdMetricName = "Overall KPI Score"
        pkdMetricValue = Worksheets(pkdCurrentWeek).Cells(11, 6).value
        BuildJson sht, pkdMetricName, pkdMetricValue
    End If
    
            BuildJson sht, "", "", True
    'If no empty cells then plug in KPI score

End Sub
