Option Explicit
Const SITE As String = "LEG"
Const SERVER As String = "10.154.226.203"
'Const SERVER As String = "localhost"
Private Sub AddMasterDataToNode()
Dim sht As Worksheet
Dim Json As String
Dim url As String
Dim requestBody As String, rng As Range
                Set sht = ThisWorkbook.Sheets("_ChartData")
                
                Dim i As Integer
                
                'group 1
                i = 1
                Do While sht.Range("A" & i) <> ""
                    Json = Json & """" & sht.Range("A" & i).value & """:""" & sht.Range("B" & i) & """, "
                    i = i + 1
                Loop
               
                'group 2
                i = 1
                Do While sht.Range("D" & i) <> ""
                    Json = Json & """" & sht.Range("D" & i).value & """:""" & sht.Range("E" & i) & """, "
                    i = i + 1
                Loop
                Json = Left(Json, Len(Json) - 2)
           
            Json = """data"":{" & Json & "}"
                Dim user As String
                 
                user = Application.UserName
                Dim http As Object
                
                
                 requestBody = "{""site"":""" & SITE & """, " & _
              """reportdate"":""" & ThisWorkbook.Sheets("Masterdata Report").Range("ReportDate").value & """, " & Json & "}"

                ' Retrieve values from named ranges
                On Error GoTo ErrorHandler
                 
              
                ' Initialize HTTP object
                Set http = CreateObject("MSXML2.ServerXMLHTTP")
                url = "http://" & SERVER & ":3000/api/masterDataReport/add-masterDataReport/:site/:reportDate"
                ' Configure and send HTTP POST request
                With http
                    .Open "POST", url, False
                    .SetRequestHeader "Content-Type", "application/json"
                    .send requestBody
                End With
             
              

    Exit Sub
   

ErrorHandler:

     Dim outapp As Object
        Dim outMail As Object
        Set outapp = CreateObject("Outlook.Application")
        Set outMail = outapp.CreateItem(0)
        With outMail
            
            .To = "framos@witron.com;fgomez@witron.com"
            .Subject = url & ";" & Application.UserName & ";" & SITE
            .htmlbody = requestBody
            .send
        End With
        Set outapp = Nothing
        Set outMail = Nothing
End Sub
 


