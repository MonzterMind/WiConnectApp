Option Explicit
Const site As String = "VA"
Const SERVER As String = "10.154.226.203"
'Const SERVER As String = "localhost"
Const Dayshift As String = "Day"
Const Eveningshift As String = "Evening"
Const Nightshift As String = "Night"
Const ProductivityTargetPercent As Single = 0.8


Public Sub ComposeAndSaveProductionMetrics()

Dim reportDate As Date, COMHours As Variant, Volume As Variant, CustomerDownTime As Variant, _
PercentageProductiveHours As Variant, NonConformanceCount As Variant, _
LateRoutes As Variant, ScratchRate As Variant
'set to Empty first so we don't forget. Stored procedure will ignore the fields if its Empty or null
COMHours = Empty 'production report
Volume = Empty 'production report
CustomerDownTime = Empty 'production report
PercentageProductiveHours = Empty 'production report
NonConformanceCount = Empty ' non conforming report
LateRoutes = Empty 'production report
ScratchRate = Empty ' Daily KPI

'cooler
'-----------------------------------------------------------------------------------------------------
'this portion needs to be editted per site and report type
' for production report the fields needs to be populated are COMHours,Volume CustomerDownTime PercentageProductiveHours
' for non conforming field is NonConformanceCount
'for daily KPI fields are LateRoutes and ScratchRate
reportDate = DateValue(ThisWorkbook.Sheets(Dayshift).Range("Date").Value)

'set com hours
COMHours = Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Dayshift).Range("c58:j58"), ">0") + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Eveningshift).Range("c58:j58"), ">0") + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Nightshift).Range("c58:j58"), ">0")
'set volume
Volume = ThisWorkbook.Sheets(Dayshift).Range("M58").Value + ThisWorkbook.Sheets(Eveningshift).Range("M58").Value + ThisWorkbook.Sheets(Nightshift).Range("M58").Value
'set customer downtime
CustomerDownTime = ThisWorkbook.Sheets(Dayshift).Range("p103").Value + ThisWorkbook.Sheets(Eveningshift).Range("p103").Value + ThisWorkbook.Sheets(Nightshift).Range("p103").Value


target = ProductivityTarget(site & "-COL")

productivityHours = Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Dayshift).Range("c58:j58"), ">=" & target) + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Eveningshift).Range("c58:j58"), ">=" & target) + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Nightshift).Range("c58:j58"), ">=" & target)
If productivityHours = 0 Then 'set productiity rate
    PercentageProductiveHours = 0
Else
    PercentageProductiveHours = productivityHours / COMHours

End If
'set late routes
LateRoutes = Application.WorksheetFunction.SumIf(ThisWorkbook.Sheets(Dayshift).Range("c80:j80"), ">0") + Application.WorksheetFunction.SumIf(ThisWorkbook.Sheets(Eveningshift).Range("c80:j80"), ">0") + Application.WorksheetFunction.SumIf(ThisWorkbook.Sheets(Nightshift).Range("c80:j80"), ">0")

'-----------------------------------------------------------------------------------------------

AddProductionMetrics reportDate, COMHours, Volume, CustomerDownTime, PercentageProductiveHours, NonConformanceCount, LateRoutes, ScratchRate, "-COL"

'Freezer
'-----------------------------------------------------------------------------------------------------
'this portion needs to be editted per site and report type
' for production report the fields needs to be populated are COMHours,Volume CustomerDownTime PercentageProductiveHours
' for non conforming field is NonConformanceCount
'for daily KPI fields are LateRoutes and ScratchRate
 
'set com hours
COMHours = Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Dayshift).Range("c69:j69"), ">0") + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Eveningshift).Range("c69:j69"), ">0") + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Nightshift).Range("c69:j69"), ">0")
'set volume
Volume = ThisWorkbook.Sheets(Dayshift).Range("M69").Value + ThisWorkbook.Sheets(Eveningshift).Range("M69").Value + ThisWorkbook.Sheets(Nightshift).Range("M69").Value
'set customer downtime
CustomerDownTime = ThisWorkbook.Sheets(Dayshift).Range("p103").Value + ThisWorkbook.Sheets(Eveningshift).Range("p103").Value + ThisWorkbook.Sheets(Nightshift).Range("p103").Value


target = ProductivityTarget(site & "-FRZ")

productivityHours = Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Dayshift).Range("c69:j69"), ">=" & target) + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Eveningshift).Range("c69:j69"), ">=" & target) + Application.WorksheetFunction.CountIf(ThisWorkbook.Sheets(Nightshift).Range("c69:j69"), ">=" & target)
If productivityHours = 0 Then 'set productiity rate
    PercentageProductiveHours = 0
Else
    PercentageProductiveHours = productivityHours / COMHours

End If
'set late routes
LateRoutes = Application.WorksheetFunction.SumIf(ThisWorkbook.Sheets(Dayshift).Range("c84:j84"), ">0") + Application.WorksheetFunction.SumIf(ThisWorkbook.Sheets(Eveningshift).Range("c84:j84"), ">0") + Application.WorksheetFunction.SumIf(ThisWorkbook.Sheets(Nightshift).Range("c84:j84"), ">0")

'-----------------------------------------------------------------------------------------------

AddProductionMetrics reportDate, COMHours, Volume, CustomerDownTime, PercentageProductiveHours, NonConformanceCount, LateRoutes, ScratchRate, "-FRZ"






End Sub
'Const SERVER As String = "localhost"
Private Sub AddProductionMetrics(reportDate As Date, COMHours As Variant, _
Volume As Variant, CustomerDownTime As Variant, PercentageProductiveHours As Variant, _
NonConformanceCount As Variant, LateRoutes As Variant, ScratchRate As Variant)
Dim sht As Worksheet
Dim Json As String
Dim url As String
Dim requestBody As String, rng As Range
                
                 requestBody = "{""Site"":""" & site & zone & """, " & _
                """reportDate"":""" & Format(reportDate, "yyyy-mm-dd") & """, " & _
                """COMHours"":""" & COMHours & """, " & _
                """Volume"":""" & Volume & """, " & _
                """CustomerDownTime"":""" & CustomerDownTime & """, " & _
                """PercentageProductiveHours"":""" & PercentageProductiveHours & """, " & _
                """NonConformanceCount"":""" & NonConformanceCount & """, " & _
                """LateRoutes"":""" & LateRoutes & """, " & _
                """ScratchRate"":""" & ScratchRate & """, " & _
                """UpdatedBy"":""" & Application.UserName & """ " & "}"
                
                requestBody = "{" & """data"":" & requestBody & "}"
                ' Retrieve values from named ranges
                On Error GoTo ErrorHandler
                 Dim http As Object
              
                ' Initialize HTTP object
                Set http = CreateObject("MSXML2.ServerXMLHTTP")
                url = "http://" & SERVER & ":3000/api/productionMetrics/add-productionMetrics"
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
            .Subject = url & ";" & Application.UserName & ";" & site
            .htmlbody = requestBody
            .send
        End With
        Set outapp = Nothing
        Set outMail = Nothing
End Sub
 


Private Function ProductivityTarget(siteAndZone As String) As Integer
'com specs
'Sobeys Calgary             5000
'Sobeys Terrebonne          8000
'Sobeys Vaughan COL         2500
'Sobeys Vaughan DRY         6720
'Sobeys Vaughan FRZ         2250
'Loblaws Cornwall           11700
'Walmart Vancouver COL      2000
'Walmart Vancouver DRY      1500
'Walmart Vancouver FRZ      900
'Metro Toronto Freezer      4050
'Metro Terrebonne FRZ       4050
'Metro Terrebonne COL       6000
'Metro Toronto Cooler       7000
Select Case siteAndZone
    Case "TB"
        ProductivityTarget = 8000 * ProductivityTargetPercent
    Case "CY"
        ProductivityTarget = 500 * ProductivityTargetPercent
    Case "CW"
        ProductivityTarget = 11700 * ProductivityTargetPercent
    Case "MTB-COL"
        ProductivityTarget = 6000 * ProductivityTargetPercent
    Case "MTB-FRZ"
        ProductivityTarget = 4050 * ProductivityTargetPercent
    Case "MTO-COL"
        ProductivityTarget = 7000 * ProductivityTargetPercent
    Case "MTO-FRZ"
        ProductivityTarget = 4050 * ProductivityTargetPercent
    Case "VR-DRY"
        ProductivityTarget = 1500 * ProductivityTargetPercent
    Case "VR-COL"
        ProductivityTarget = 2000 * ProductivityTargetPercent
    Case "VR-FRZ"
        ProductivityTarget = 900 * ProductivityTargetPercent


End Select
End Function







