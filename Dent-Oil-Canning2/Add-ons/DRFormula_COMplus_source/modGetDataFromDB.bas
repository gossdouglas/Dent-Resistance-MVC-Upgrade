Attribute VB_Name = "modGetDataFromDB"
Option Explicit

' Database constants

Public Const strConnect = "DSIspat"
Public Const vDataBase = "Ispat Test"
Public Const UserID = "user_dent_resist"
Public Const Password = "$rv_D3nt$!"

Dim ErrorDescription As String
Dim conn As Object
Dim sconnectstring As String
Dim bl_okay As Boolean
Dim i_erroradd As Double
Dim ln_found As Long
Dim rsdata As Recordset
Dim rsdataout As Recordset


Public Function GetDataFromDB(vSql) As ADODB.Recordset
On Error GoTo err_Handler
    
'JHF 2021 Dim oRDS As RDS.DataSpace
'JHF 2021 Dim oGet As Object
    
'JHF 2021    Set oRDS = New RDS.DataSpace
'JHF 2021    Set oGet = oRDS.CreateObject(GRDS, GetServerName())
    
'JHF 2021    Set GetDataFromDB = oGet.GetDATAwUP(strConnect, adOpenStatic, vSql, adLockReadOnly, Userid, Password)
    Set GetDataFromDB = GetDATAwUP(strConnect, adOpenStatic, vSql, adLockReadOnly, UserID, Password)
    
'JHF 2021    Set oGet = Nothing
'JHF 2021    Set oRDS = Nothing
    
exit_Function:
    Exit Function
    
err_Handler:
'JHF 2021    Set oGet = Nothing
'JHF 2021    Set oRDS = Nothing
    Err.Raise Err.Number, "clsDataMngt::GetDataFromDB::" & Err.Source, Err.Description & " (" & vSql & ")"
    Resume exit_Function
End Function
Public Function GetDATAwUP(ByVal odbcname As String, ByVal Cursortype As Integer, ByVal sqlcode As String, ByVal locktype As Integer, ByVal UserID As String, ByVal Password As String) As Recordset
'******************************************************
'** Module name: cl_getdayawp.getDATAwUP             **
'** Purpose: This module will be used to make calls  **
'**          to the passed ODBC name to select       **
'**          database table data.                    **
'** Passed Parameters: ODBCNAME = the name of the    **
'**                               datasource to use. **
'**                               This Data source   **
'**                               must be installed  **
'**                               on the COM server. **
'**                    CursorType = The Cursor Type  **
'**                                 to open the      **
'**                                 recordset with.  **
'**                    SQLCODE  = The SQL to run     **
'**                    Locktype = The locktype to    **
'**                               Open the recordset **
'**                               with.              **
'**                    UserId   = Userid for the     **
'**                               datasource         **
'**                    Password = password for the   **
'**                               user-id.           **
'** Returns:  Recordset containing data if SQL       **
'**           execute was sucessful, or an empty     **
'**           Recordset if it failed.                **
'**           Err.Description contains the SQL error **
'**           information.                           **
'**==================================================**
'** Maintenance log                                  **
'**==================================================**
'** Edward J. Szymoniak  06/26/2000  Created Module  **
'JHF 2021 - including in DRFormula
'
'  jhf - 01/06/2014
'     added connection.CommandTimeout adjustment
'     increase from the default value of 30 seconds
'     to 180 seconds allowing much longer SQL to complete
'******************************************************

Err.Clear
ErrorDescription = ""
On Error GoTo ConnError
'JHF 2021 Set objCtx = GetObjectContext()
'Set up connection string
Set conn = New ADODB.Connection
conn.CommandTimeout = 180

'jhf HERE 12/27  sconnectstring = "DSN=" & odbcname & ";User Id=" & Userid & ";Password=" & Password & "; "
'  JHF 2017-05-24       sconnectstring = "DSN=" & odbcname & ";Trusted_Connection = SSPI; Integrated Security = SSPI;"
sconnectstring = "DSN=" & odbcname & ";User Id=" & UserID & ";Password=" & Password & "; "
conn.Open sconnectstring

'Now call the routine to create the recordset
Call CreateRs(Cursortype, sqlcode, locktype)
' Error occurred, so Raise the event
If Not bl_okay Then
   Err.Raise vbObjectError + i_erroradd, , ErrorDescription
End If

Set rsdataout = rsdata
Set GetDATAwUP = rsdataout

'Destroy objects
'Release the Recordset connection to return to pool
Set rsdata.ActiveConnection = Nothing

'Close the recordset
'rsdata.Close
Set rsdata = Nothing

'Close the connection
conn.Close
Set conn = Nothing

'JHF 2021 If Not objCtx Is Nothing Then
'JHF 2021    objCtx.SetComplete
'JHF 2021 End If

Exit Function

ConnError:
'Raise Error Event
'JHF 2021 If Not objCtx Is Nothing Then
'JHF 2021     objCtx.SetAbort
'JHF 2021 End If
If ErrorDescription = "" Then
   ErrorDescription = "Error Connection to Datasource " & odbcname
   i_erroradd = 9000
End If

Err.Raise vbObjectError + i_erroradd, , ErrorDescription
End Function


Private Sub CreateRs(ByVal Cursortype As Integer, sqlcode As String, ByVal locktype As Integer)
On Error GoTo rsERROR
'Check for a valid cursortype parameter passed
If Cursortype = adOpenForwardOnly Or _
   Cursortype = adOpenStatic Or _
   Cursortype = adOpenDynamic Or _
   Cursortype = adOpenKeyset Then
   ' all okay proceed
Else
   Err.Clear
   ErrorDescription = "Invalid CursorType Value Passed " & Cursortype
   i_erroradd = 1000
   bl_okay = False
   Exit Sub
End If

'Check for a valid Locktype parameter passed
If locktype = adLockReadOnly Or _
   locktype = adLockPessimistic Or _
   locktype = adLockOptimistic Then
   ' all okay
Else
   Err.Clear
   ErrorDescription = "Invalid Locktype Value Passed " & locktype
   i_erroradd = 1030
   bl_okay = False
   Exit Sub
End If

'Check to make sure SQL is not blank
If sqlcode <> "" Then
   'all okay proceed
Else
   Err.Clear
   ErrorDescription = "Blank SQL statement Passed "
   i_erroradd = 1010
   bl_okay = False
   Exit Sub
End If

'Check SQL code to make sure no deletes, inserts, or updates
' exist in the code
ln_found = 0
'Search for Update
ln_found = InStr(UCase(sqlcode), " UPDATE ")
'Update Found, Generate Error
If ln_found > 0 Then
   Err.Clear
   ErrorDescription = "Update SQL statement Passed "
   i_erroradd = 1011
   bl_okay = False
   Exit Sub
End If
'Search for Delete
ln_found = InStr(UCase(sqlcode), " DELETE ")
'Delete Found, Generate Error
If ln_found > 0 Then
   Err.Clear
   ErrorDescription = "Delete SQL statement Passed "
   i_erroradd = 1012
   bl_okay = False
   Exit Sub
End If
'Search for Insert
ln_found = InStr(UCase(sqlcode), " INSERT ")
'Insert Found, Generate Error
If ln_found > 0 Then
   Err.Clear
   ErrorDescription = "Insert SQL statement Passed "
   i_erroradd = 1013
   bl_okay = False
   Exit Sub
End If

'Create the recordset
Set rsdata = New ADODB.Recordset
'Execute the recordset to retireve the data
'Set the cursor to a client side cursor
rsdata.CursorLocation = adUseClient
rsdata.Open sqlcode, conn, Cursortype, locktype
bl_okay = True
Exit Sub

'Rescordset Retireval Error
rsERROR:
ErrorDescription = Err.Description
i_erroradd = 2000
bl_okay = False
End Sub











