VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Calculations"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private mstrSupportedOperators As String    ' Holds all of the supported operators

Private mdblOperands(50) As Double          ' Holds the operands' stack
Private mstrOperators(25) As String         ' Holds the operators' stack

Private mintLastOperand As Integer          ' Position of the last operand in the Operand array
Private mintLastOperator As Integer         ' Position of the last operand in the Operator array

Private Function Simple(ByRef LOperand As Double, ByVal Operator As String, _
                          ByRef ROperand As Double) As Double
' This function calculates the values and operators that
' are passed to it
'
' It will return the results of the calculation
'
' Supported operators:
'   Addition                (+)
'   Subtraction             (-)
'   Multiplication          (*)
'   Division                (/)
'   Raise to the power of   (^)

On Error GoTo ErrHandler
    
    ' ========================================================================
    ' We want to check to make sure the calculation has a
    ' supported operator in it.
    If (InStr(mstrSupportedOperators, Operator) < 1) Then
    
        Err.Raise 20000, "Simple Calculation", "Operator not supported: " & vbCrLf & _
                                                 Operator
        
    End If
    ' End validation
    ' ========================================================================

    Dim dblTemp As Double
    
    ' ========================================================================
    ' Do the calculation based on what the operator is
    ' When adding support for an operator, it must also
    ' be added to the mstrSupportedOperators in the
    ' Initialize Subroutine of this class
    Select Case Operator
    
        Case "+"
        
            dblTemp = LOperand + ROperand
            
        Case "-"
        
            dblTemp = LOperand - ROperand
        
        Case "*"
        
            dblTemp = LOperand * ROperand
        
        Case "/"
        
            dblTemp = LOperand / ROperand
        
        Case "^"
        
            dblTemp = LOperand ^ ROperand
        
        Case Else
        
            dblTemp = 0
            
    End Select
        
    Simple = dblTemp
    
    Exit Function

ErrHandler:

    Simple = 0
    Err.Raise Err.Number, Err.Source, Err.Description
    
End Function

Public Function Compound(ByVal Math As String) As Double
' This function takes a compound formula and calculates it
' It gets a 'free text' math calculation using the same style
' syntax as Excel without the '='.
'   ie: (((3*2)/2)^((4+12)/10))-3
'
' This is intended to work with the Formula class.  The formula
' class builds (via database) the actual formula w/ values
' instead of variables.  This function does the actual calculation.
'
' It will parse out the string and run the calculations through the
' Simple Function of this Calculation class.

On Error GoTo ErrHandler
    
    ' First we make sure the string passed is valid
    If Validate(Math) = False Then Err.Raise Err.Number, Err.Source, Err.Description & vbCrLf & _
                                             "String Passed: " & vbCrLf & _
                                             Math

    Dim intCount As Integer
    
    Dim strPrevChar As String           ' Holds the value of the previous character
    Dim strTempNum As String            ' Used to build a number
    Dim dblTempCalc As Double           ' Used to store results of a simple calculation
    
' ========================================================
' Code here for parsing and running the calculations
' ========================================================
    
    mintLastOperand = 0
    mintLastOperator = 0
    strPrevChar = ""
    
    For intCount = 1 To Len(Math)
        
        Select Case Mid$(Math, intCount, 1)
        
            ' Build the number
            Case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "E"
            
                ' Build the number
                strTempNum = strTempNum & Mid$(Math, intCount, 1)
                
                If (Not IsNumeric(Mid$(Math, intCount + 1, 1))) And _
                   (Mid$(Math, intCount + 1, 1) <> ".") And _
                   (Mid$(Math, intCount + 1, 1) <> "E") And _
                   (Mid$(Math, intCount + 1, 1) <> "-") Then
                
                    'If (Mid$(Math, intCount, 1) <> "E") Then  ' the end of the number is reached
                
                        mdblOperands(mintLastOperand) = CDbl(strTempNum)
                        mintLastOperand = mintLastOperand + 1
                    
                    'End If
                    
                End If
                
            ' Store the operator
            Case "+", "-", "*", "/", "^"
                
                ' Have to catch a negative number
                If strPrevChar = "(" Or strPrevChar = "E" Or intCount = 1 Then
                
                    strTempNum = strTempNum & Mid$(Math, intCount, 1)
                    
                    If (Not IsNumeric(Mid$(Math, intCount + 1, 1))) And _
                       (Mid$(Math, intCount + 1, 1) <> ".") And _
                       (Mid$(Math, intCount + 1, 1) <> "E") Then   ' the end of the number is reached
                    
                        mdblOperands(mintLastOperand) = CDbl(strTempNum)
                        mintLastOperand = mintLastOperand + 1
                        
                    End If
                
                Else
                
                    mstrOperators(mintLastOperator) = Mid$(Math, intCount, 1)
                    mintLastOperator = mintLastOperator + 1
                    
                    strTempNum = ""
                
                End If
                
            ' A calculation needs to be performed
            Case ")"
                
                ' Run the calculation
                dblTempCalc = Simple(mdblOperands(mintLastOperand - 2), _
                              mstrOperators(mintLastOperator - 1), _
                              mdblOperands(mintLastOperand - 1))
                
                MoveStacks (dblTempCalc)
                
                strTempNum = ""
            
            Case "(", " "

                strTempNum = ""
                
            Case Else
            
                ' An error occurred
                Err.Raise 20010, "Calculations - Compound", _
                          "An unexpected character in formula: " & vbCrLf & _
                          Math & vbCrLf & _
                          "Found: " & Mid$(Math, intCount, 1) & _
                          " at position " & intCount
                          
        End Select
        
        ' Store the character temporarily
        strPrevChar = Mid$(Math, intCount, 1)
        
    Next
    
    If mstrOperators(0) <> "" Then

        ' Run the calculation
        dblTempCalc = Simple(mdblOperands(mintLastOperand - 2), _
                      mstrOperators(mintLastOperator - 1), _
                      mdblOperands(mintLastOperand - 1))
        
        MoveStacks (dblTempCalc)
        
    End If
    
    Compound = CDbl(mdblOperands(0))
    
    Exit Function

ErrHandler:

    Compound = 0
    Err.Raise Err.Number, Err.Source, Err.Description
    
End Function

Private Sub MoveStacks(ByVal NewOperand As Double)
' This moves the numbers in the stacks (Arrays) in
' a LIFO manner.  And sets the last value to be
' the 'NewOperand' Value in the Oprands Array

    ' Clear out the last operands and operator
    mdblOperands(mintLastOperand - 1) = 0
    mstrOperators(mintLastOperator - 1) = ""
    
    ' Move the operand pointer back two and
    ' operator pointer back one
    mintLastOperand = mintLastOperand - 2
    mintLastOperator = mintLastOperator - 1
    
    ' Put the new value for the last operand
    mdblOperands(mintLastOperand) = NewOperand
    mintLastOperand = mintLastOperand + 1

End Sub

Public Function Validate(ByVal Math As String) As Boolean
' This function will validate a compound calculation to ensure that
' the string adheres to the correct syntax and has valid operators.
'
' This checks for:
'   Equal number of left and right parenthesis
'   Checks for supported operators

On Error GoTo ErrHandler

    Dim bGood As Boolean
    
    Dim intLParens As Integer
    Dim intRParens As Integer
        
    Dim intCount As Integer
    Dim strValid As String
    
    bGood = False       ' Default value
    strValid = mstrSupportedOperators & ".()Ee "      ' A space must be in there, as it is allowed
    
    For intCount = 1 To Len(Math)
    
        ' make sure that there are no invalid characters
        If (InStr(strValid, Mid$(Math, intCount, 1)) < 1) And _
           (Not IsNumeric(Mid$(Math, intCount, 1))) Then
            
            ' An invalid character was detected, send an error with
            ' the position of the bad character, along with the invalid
            ' character.
            Err.Raise 20020, "Calculations Validate", "There was an invalid character (" & _
                                                      Mid$(Math, intCount, 1) & _
                                                      ") at position " & intCount
            
        End If
        
        ' if it is a parenthesis, count which one it is
        If Mid$(Math, intCount, 1) = "(" Then intLParens = intLParens + 1
        If Mid$(Math, intCount, 1) = ")" Then intRParens = intRParens + 1
        
    Next
    
    ' Make sure the parenthesis are the same
    If intLParens = intRParens Then
        bGood = True
    Else
        Err.Raise 20030, "Calculations Validate", "Missing Parenthesis"
    End If

    Validate = bGood
    
    Exit Function

ErrHandler:

    Validate = False
    Err.Raise Err.Number, Err.Source, Err.Description
    
End Function

Private Sub Class_Initialize()

    ' To add a supported operator, it also must be
    ' added to the select case statement in the
    ' Simple function of this class
    mstrSupportedOperators = "-+*/^"

End Sub
