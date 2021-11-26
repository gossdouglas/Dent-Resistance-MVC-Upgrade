VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Formula"
Attribute VB_GlobalNameSpace = True
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private mstrConn As String
Private mdblNewtons As Double
Private strServer As String

Private oMngt As Object                 ' Com2Com clsDataMngt object
Private rsGrade As ADODB.Recordset      ' Grade Recordset
Private rsFormula As ADODB.Recordset    ' Formula Recordset
Private strSQL As String                ' To be used to get recordsets
Private mdblResult As Double
' Added for Oil Canning and Stiffness code BDS
Private mdblEPS3 As Double              ' Used to Calculate Actual R1, Actual R2, and Actual T
Private mdblActualT As Double           ' Used to Calculate Actual R1 and Actual R2

Public Function Calculate(ByVal GradeKey As Integer, _
                          ByVal R1 As Double, _
                          ByVal R2 As Double, _
                          ByVal Thickness As Double, _
                          ByVal MajorStrain As Double, _
                          ByVal MinorStrain As Double) As Boolean
' This is the main function that will be used from the
' Web interface.  It will get the values of the formula
' from the database, calculate each formula using the
' Calculations.Compound function. It will return the true
' if everything went ok, false if there was an error.
'
' The values will be held in the public (readonly)
' properties:
'   Newtons
'   LBF
'
' The GradeKey value passed to this function relates to
' the primary key (Grade_key) in the Grades table

On Error GoTo ErrHandler
    
    Dim clcCalc As Calculations
    
    Dim dblNormalAnisotropy As Double
    Dim dblCoefficient As Double
    Dim dblEffectiveStretch As Double
    Dim dblConstant As Double
        
    Dim strDBFormula As String          ' The formula as it comes from
                                        ' the Database
    Dim dblCalcResults As Double        ' Temporarily hold the Calculation
                                        ' Results
    Dim dblRunningTotal As Double       ' Storing the running total
    Dim strFormula As String            ' We build the string that
                                        ' will contain the formula to
                                        ' pass to calculations.compound
    dblRunningTotal = 0
    
    ' Set up the databases
'JHF 2021    Set oMngt = CreateObject("com2com.clsDataMngt", strServer)
    
    ' Get the Grade information from the DB
    strSQL = "SELECT * FROM DR_Grades WHERE Grade_Key = " & GradeKey & " and model = 1 "
'JHF 2021    Set rsGrade = oMngt.GetDataFromDB(strSQL)
    Set rsGrade = GetDataFromDB(strSQL)
    
    If rsGrade.RecordCount > 0 Then
    
        dblNormalAnisotropy = CDbl(rsGrade("Normal_Anisotropy"))
        dblConstant = CDbl(rsGrade("Constants"))
        
        dblEffectiveStretch = ((1 + dblNormalAnisotropy) / Sqr(1 + 2 * dblNormalAnisotropy)) * _
                              Sqr(((MajorStrain / 100) ^ 2) + ((MinorStrain / 100) ^ 2) + _
                              (2 * dblNormalAnisotropy / (1 + dblNormalAnisotropy)) * _
                              (MajorStrain / 100) * (MinorStrain / 100))
        
        ' Get the Formula information from the DB
        strSQL = "SELECT * FROM DR_Formulas WHERE Grade_Key = " & _
                 GradeKey & " and model = 1 ORDER BY Process_Order"
'JHF 2021        Set rsFormula = oMngt.GetDataFromDB(strSQL)
        Set rsFormula = GetDataFromDB(strSQL)
        
        ' Loop through the formulas and add their results
        If rsFormula.RecordCount > 0 Then

            dblRunningTotal = dblRunningTotal + dblConstant
            Set clcCalc = New Calculations
            
            Do Until rsFormula.EOF
            
                dblCoefficient = CDbl(rsFormula("Coefficient"))
                strDBFormula = LCase(rsFormula("Formula"))
                
                ' Replace the variables in the free text formula
                ' with the values that were calculated or passed
                strDBFormula = Replace(strDBFormula, "effectivestretch", CStr(dblEffectiveStretch))
                strDBFormula = Replace(strDBFormula, "r1", CStr(R1))
                strDBFormula = Replace(strDBFormula, "r2", CStr(R2))
                strDBFormula = Replace(strDBFormula, "thickness", CStr(Thickness))
                
                ' This should resemble
                '             (coefficient * formula)
                strFormula = "(" & CStr(dblCoefficient) & "*" & strDBFormula & ")"
                dblCalcResults = clcCalc.Compound(strFormula)
                
                ' Calculate the formula and add it to the running total
                dblRunningTotal = dblRunningTotal + dblCalcResults
                
                rsFormula.MoveNext
                
            Loop
            
            Set clcCalc = Nothing
            
        End If
        
        Set rsFormula = Nothing
       
    End If
    
    Set oMngt = Nothing
    Set rsGrade = Nothing
    
    ' put the results into the private mdblNewtons variable
    mdblNewtons = dblRunningTotal

    ' All went well
    Calculate = True

    Exit Function

ErrHandler:
    
    ' Bad things happened
    Calculate = False
    mdblNewtons = 0
    Err.Raise Err.Number, Err.Source, "Formula Calculate Error: " & vbCrLf & Err.Description
    
End Function
Public Function CalculateM2(ByVal GradeKey As Integer, _
                          ByVal R1 As Double, _
                          ByVal R2 As Double, _
                          ByVal Thickness As Double, _
                          ByVal MajorStrain As Double, _
                          ByVal MinorStrain As Double, _
                          ByVal ModelFormula As String) As Boolean
' This is the main function that will be used from the
' Web interface.  It will get the values of the formula
' from the database, calculate each formula using the
' Calculations.Compound function. It will return the true
' if everything went ok, false if there was an error.
'
' The values will be held in the public (readonly)
' properties:
'   Newtons
'   LBF
'
' The GradeKey value passed to this function relates to
' the primary key (Grade_key) in the Grades table

On Error GoTo ErrHandler
    
    Dim clcCalc As Calculations
    
    Dim dblNormalAnisotropy As Double
    Dim dblCoefficient As Double
    Dim dblEffectiveStretch As Double
    Dim dblConstant As Double
        
    Dim strDBFormula As String          ' The formula as it comes from
                                        ' the Database
    Dim dblCalcResults As Double        ' Temporarily hold the Calculation
                                        ' Results
    Dim dblRunningTotal As Double       ' Storing the running total
    Dim strFormula As String            ' We build the string that
                                        ' will contain the formula to
                                        ' pass to calculations.compound
    dblRunningTotal = 0
    
    ' Set up the databases
'JHF 2021    Set oMngt = CreateObject("com2com.clsDataMngt", strServer)
    
    ' Get the Grade information from the DB
    strSQL = "SELECT * FROM DR_Grades WHERE Grade_Key = " & GradeKey & " and model = 2 "
'JHF 2021    Set rsGrade = oMngt.GetDataFromDB(strSQL)
    Set rsGrade = GetDataFromDB(strSQL)
    
    If rsGrade.RecordCount > 0 Then
    
        dblNormalAnisotropy = CDbl(rsGrade("Normal_Anisotropy"))
        
        If ModelFormula = "INTERCEPT" Then
           dblConstant = CDbl(rsGrade("Constants"))
        Else
           dblConstant = CDbl(rsGrade("Constants_1"))
        End If
        
        dblEffectiveStretch = ((1 + dblNormalAnisotropy) / Sqr(1 + 2 * dblNormalAnisotropy)) * _
                              Sqr(((MajorStrain / 100) ^ 2) + ((MinorStrain / 100) ^ 2) + _
                              (2 * dblNormalAnisotropy / (1 + dblNormalAnisotropy)) * _
                              (MajorStrain / 100) * (MinorStrain / 100))
        
        ' Get the Formula information from the DB
        strSQL = "SELECT * FROM DR_Formulas WHERE Grade_Key = " & _
                 GradeKey & " and model = 2 and model_formula = '" & ModelFormula & "' ORDER BY Process_Order"
'JHF 2021        Set rsFormula = oMngt.GetDataFromDB(strSQL)
        Set rsFormula = GetDataFromDB(strSQL)
        
        ' Loop through the formulas and add their results
        If rsFormula.RecordCount > 0 Then
        
            dblRunningTotal = dblRunningTotal + dblConstant
            Set clcCalc = New Calculations
            
            Do Until rsFormula.EOF
            
               dblCoefficient = CDbl(rsFormula("Coefficient"))
                strDBFormula = LCase(rsFormula("Formula"))
                
                ' Replace the variables in the free text formula
                ' with the values that were calculated or passed
                strDBFormula = Replace(strDBFormula, "effectivestretch", CStr(dblEffectiveStretch))
                strDBFormula = Replace(strDBFormula, "r1", CStr(R1))
                strDBFormula = Replace(strDBFormula, "r2", CStr(R2))
                strDBFormula = Replace(strDBFormula, "thickness", CStr(Thickness))
               ' strDBFormula = Replace(strDBFormula, "ModelFormula", CStr(ModelFormula))
                
                ' This should resemble
                '             (coefficient * formula)
                strFormula = "(" & CStr(dblCoefficient) & "*" & strDBFormula & ")"
                dblCalcResults = clcCalc.Compound(strFormula)
                'Debug.Print dblCalcResults
                
                ' Calculate the formula and add it to the running total
                dblRunningTotal = dblRunningTotal + dblCalcResults
                
                rsFormula.MoveNext
                
            Loop
            
            Set clcCalc = Nothing
            
        End If
        
        Set rsFormula = Nothing
       
    End If
    
    Set oMngt = Nothing
    Set rsGrade = Nothing
    
    ' put the results into the private mdblNewtons variable
    mdblResult = dblRunningTotal
    
    ' All went well
    CalculateM2 = True
    
    Exit Function

ErrHandler:
    
    ' Bad things happened
    CalculateM2 = False
    mdblResult = 0
    Err.Raise Err.Number, Err.Source, "Formula CalculateM2 Error: " & vbCrLf & Err.Description
    
End Function

' =======================================================
' Added for Oil Canning and Initial Stiffness Models
' BDS 11/23/2009
Public Function CalculateOilCanning(ByVal IndenterSizeKey As Integer, _
                                    ByVal R1 As Double, _
                                    ByVal R2 As Double, _
                                    ByVal Thickness As Double, _
                                    ByVal MajorStrain As Double, _
                                    ByVal MinorStrain As Double, _
                                    ByVal DeltaSpringback As Double, _
                                    Optional ByVal FreespanRoofBows As Double) As Boolean
' This function is the same concept as the other Calculation Functions, it is used
' from the web interface to calculate the OilCanning in the same basic manner
' as the others

' The "IndenterSizeKey" is the same as the GradeKey for the other calculations
' It is simply renamed

' The "FreespanRoofBows" variable is for future use.  It was put in here
' so that the functionality could be easily added when it is ready
On Error GoTo ErrHandler

    Dim mdblResult As Double
    
    Dim intModel As Integer
    Dim strModelFormula As String
    intModel = 3
    strModelFormula = "OILCANNING"
    
    Dim dblR1 As Double
    Dim dblR2 As Double
    
    ' First we set the EPS and ActualT values
    SetEPS3andActualT Thickness, MajorStrain, MinorStrain
    
    ' set the Actual R1 and Actual R2
    dblR1 = ActualR1(R1, DeltaSpringback)
    dblR2 = ActualR2(R2, DeltaSpringback)

    CalculateOilCanning = RunCalculations(intModel, _
                            strModelFormula, _
                            IndenterSizeKey, _
                            dblR1, _
                            dblR2, _
                            mdblActualT, _
                            MajorStrain, _
                            MinorStrain, _
                            DeltaSpringback, _
                            FreespanRoofBows)

    Exit Function
    
ErrHandler:

    ' Bad things happened
    CalculateOilCanning = False
    mdblResult = 0
    Err.Raise Err.Number, Err.Source, "Formula CalculateOilCanning Error: " & vbCrLf & Err.Description

End Function

Public Function CalculateInitialStiffness(ByVal IndenterSizeKey As Integer, _
                                          ByVal R1 As Double, _
                                          ByVal R2 As Double, _
                                          ByVal Thickness As Double, _
                                          ByVal MajorStrain As Double, _
                                          ByVal MinorStrain As Double, _
                                          ByVal DeltaSpringback As Double, _
                                          Optional ByVal FreespanRoofBows As Double) As Boolean
' This function is the same concept as the other Calculation Functions, it is used
' from the web interface to calculate the InitialStiffness in the same basic manner
' as the others

' The "IndenterSizeKey" is the same as the GradeKey for the other calculations
' It is simply renamed

' The "FreespanRoofBows" variable is for future use.  It was put in here
' so that the functionality could be easily added when it is ready
On Error GoTo ErrHandler

    Dim mdblResult As Double

    Dim intModel As Integer
    Dim strModelFormula As String
    intModel = 3
    strModelFormula = "INITIALSTIFFNESS"
    
    Dim dblR1 As Double
    Dim dblR2 As Double
    
    ' First we set the EPS and ActualT values
    SetEPS3andActualT Thickness, MajorStrain, MinorStrain
    
    ' set the Actual R1 and Actual R2
    dblR1 = ActualR1(R1, DeltaSpringback)
    dblR2 = ActualR2(R2, DeltaSpringback)
    
    CalculateInitialStiffness = RunCalculations(intModel, _
                                    strModelFormula, _
                                    IndenterSizeKey, _
                                    dblR1, _
                                    dblR2, _
                                    mdblActualT, _
                                    MajorStrain, _
                                    MinorStrain, _
                                    DeltaSpringback, _
                                    FreespanRoofBows)
                                    
    
    Exit Function
    
ErrHandler:

    ' Bad things happened
    CalculateInitialStiffness = False
    mdblResult = 0
    Err.Raise Err.Number, Err.Source, "Formula CalculateInitialStiffness Error: " & vbCrLf & Err.Description
    
End Function

Private Function RunCalculations(ByVal Model As Integer, _
                                 ByVal ModelFormula As String, _
                                 ByVal IndenterSizeKey As Integer, _
                                 ByVal R1 As Double, _
                                 ByVal R2 As Double, _
                                 ByVal Thickness As Double, _
                                 ByVal MajorStrain As Double, _
                                 ByVal MinorStrain As Double, _
                                 ByVal DeltaSpringback As Double, _
                                 Optional ByVal FreespanRoofBows As Double) As Double
On Error GoTo ErrHandler
    
    Dim clcCalc As Calculations
    
    Dim dblNormalAnisotropy As Double
    Dim dblCoefficient As Double
    Dim dblEffectiveStretch As Double
    Dim dblConstant As Double
    Dim dblFreespan As Double
    
    Dim strDBFormula As String          ' The formula as it comes from
                                        ' the Database
    Dim dblCalcResults As Double        ' Temporarily hold the Calculation
                                        ' Results
    Dim dblRunningTotal As Double       ' Storing the running total
    Dim strFormula As String            ' We build the string that
                                        ' will contain the formula to
                                        ' pass to calculations.compound
    dblRunningTotal = 0
    
    ' Set up the databases
'JHF 2021    Set oMngt = CreateObject("com2com.clsDataMngt", strServer)
    
    ' Get the Grade information from the DB
    strSQL = "SELECT * FROM DR_Grades WHERE Grade_Key = " & IndenterSizeKey & _
             " and model = " & Model
    
'JHF 2021    Set rsGrade = oMngt.GetDataFromDB(strSQL)
    Set rsGrade = GetDataFromDB(strSQL)
    
    If rsGrade.RecordCount > 0 Then
    
        dblNormalAnisotropy = CDbl(rsGrade("Normal_Anisotropy"))
        dblConstant = CDbl(rsGrade("Constants"))
                
        ' Get the Formula information from the DB
        strSQL = "SELECT * FROM DR_Formulas WHERE Grade_Key = " & _
                 IndenterSizeKey & " and model = " & Model & _
                " and model_formula = '" & ModelFormula & "'" & _
                " ORDER BY Process_Order"
'JHF 2021        Set rsFormula = oMngt.GetDataFromDB(strSQL)
        Set rsFormula = GetDataFromDB(strSQL)
        
        ' Loop through the formulas and add their results
        If rsFormula.RecordCount > 0 Then
        
            If UCase(ModelFormula) = "INITIALSTIFFNESS" And UCase(rsFormula("Variable_name")) = "CONSTANT" Then
            
                dblConstant = rsFormula("Coefficient")
                rsFormula.MoveNext
                
            End If
            
            dblRunningTotal = dblRunningTotal + dblConstant
            Set clcCalc = New Calculations
            
            Do Until rsFormula.EOF
            
                If UCase(ModelFormula) = "INITIALSTIFFNESS" And UCase(rsFormula("Variable_name")) = "CONSTANT" Then
                                    
                    rsFormula.MoveNext
                    
                End If
                
                dblCoefficient = CDbl(rsFormula("Coefficient"))
                strDBFormula = LCase(rsFormula("Formula"))
                
                ' Replace the variables in the free text formula
                ' with the values that were calculated or passed
                strDBFormula = Replace(strDBFormula, "effectivestretch", CStr(dblEffectiveStretch))
                strDBFormula = Replace(strDBFormula, "r1", CStr(R1))
                strDBFormula = Replace(strDBFormula, "r2", CStr(R2))
                strDBFormula = Replace(strDBFormula, "thickness", CStr(Thickness))
                strDBFormula = Replace(strDBFormula, "d", CStr(FreespanRoofBows))
                
                ' This should resemble
                '             (coefficient * formula)
                strFormula = "(" & CStr(dblCoefficient) & "*" & strDBFormula & ")"
                dblCalcResults = clcCalc.Compound(strFormula)
                
                ' Calculate the formula and add it to the running total
                dblRunningTotal = dblRunningTotal + dblCalcResults
                
                rsFormula.MoveNext

            Loop

            Set clcCalc = Nothing
            
        End If
        
        Set rsFormula = Nothing
       
    End If
    
    Set oMngt = Nothing
    Set rsGrade = Nothing
    
    ' put the results into the private mdblNewtons variable
    mdblNewtons = dblRunningTotal
    
    ' All went well
    RunCalculations = True
    
    Exit Function

ErrHandler:
    
    ' Bad things happened
    RunCalculations = False
    mdblNewtons = 0
    Err.Raise Err.Number, Err.Source, "Formula RunCalculations Error: " & vbCrLf & Err.Description
    



End Function

Private Sub SetEPS3andActualT(ByVal Thickness As Double, _
                              ByVal MajorStrain As Double, _
                              ByVal MinorStrain As Double)
' EPS3 Formula will be: -((LN(1+MajorStrain/100))+(LN(1+MinorStrain/100)))
' This value will be stored in the mdblEPS3 private variable to be used in other calculations

' calculating a logarithm should be as simple as using the Log(double) function
' might also use: Log10 = Log(X) / Log(10#)

' ActualT Formula will be: Thickness*(EXP(EPS3))
' This value will be stored in the mdblActualT private variable

On Error GoTo ErrHandler

    mdblEPS3 = -((Log(1 + (MajorStrain / 100))) + (Log(1 + (MinorStrain / 100))))
    mdblActualT = Thickness * (Exp(mdblEPS3))

    Exit Sub
    
ErrHandler:
    
    ' Bad things happened
    mdblEPS3 = 0
    mdblActualT = 0
    Err.Raise Err.Number, Err.Source, "Formula Calculate Actual EPS3 and Actual T Error: " & vbCrLf & Err.Description

End Sub

Private Function ActualR1(ByVal R1 As Double, ByVal Delta As Double) As Double
' we need to ensure that the EPS and ActualT values are set before continuing
' this error should never happen
On Error GoTo ErrHandler
    
    ActualR1 = R1 * (1 + (Delta / 100))

    Exit Function
    
ErrHandler:
    
    ' Bad things happened
    ActualR1 = 0
    Err.Raise Err.Number, Err.Source, "Formula Calculate Actual R1 Error: " & vbCrLf & Err.Description
    
End Function

Private Function ActualR2(ByVal R2 As Double, ByVal Delta As Double) As Double
' we need to ensure that the EPS and ActualT values are set before continuing
' this error should never happen
On Error GoTo ErrHandler

    ActualR2 = R2 * (1 + (Delta / 100))
    
    Exit Function
    
ErrHandler:
    
    ' Bad things happened
    ActualR2 = 0
    Err.Raise Err.Number, Err.Source, "Formula Calculate Actual R2 Error: " & vbCrLf & Err.Description
    
End Function
' End of Oil Canning and Stiffness Models Additions
' BDS 11/23/2009
' =======================================================

Public Property Get Result() As Double

    Result = mdblResult
    
End Property
Public Property Get Newtons() As Double

    Newtons = mdblNewtons
    
End Property

Public Property Get LBF() As Double

    LBF = mdblNewtons / 4.448
    
End Property

Private Sub Class_Initialize()

On Error GoTo ErrHandler
    
    ' NOTE: the server name is SET in ALL CAPS
    strServer = UCase(Environ("ComputerName"))

    Exit Sub
    
ErrHandler:

    Err.Raise Err.Number, "Formula Initialize" & vbCrLf & Err.Source, Err.Description
    
End Sub
