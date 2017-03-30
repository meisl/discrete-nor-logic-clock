REM  *****  BASIC  *****

Type List
	head As Variant
	tail As Object
	len As Integer
End Type

Type KeyValuePair
	key As String
	val As Variant
	nxt As Object
End Type

Type Env
	daddy As Object
	mappings As Object
End Type

Type Parser
	tp As String
	st As Variant
End Type

Sub Main
	Stop
	Dim s As String
	Dim pDigit As Parser, pHexDigit As Parser, pHexNum As Parser, pHexLit As Parser
	Set pDigit = mkChoice(mkChoice(mkChoice(mkStr("0"), mkStr("1")), mkStr("2")), mkStr("3"))
	Set pHexDigit = mkChoice(pDigit, mkChoice(mkChoice(mkChoice(mkChoice(mkChoice(mkStr("A"), mkStr("B")), mkStr("C")), mkStr("D")), mkStr("E")), mkStr("F")))
	Set pHexNum = mkSeq(Array(mkMany(pHexDigit)), "readHex")
	Set pHexLit = mkSeq(Array(mkStr("0x"), pHexNum), "snd")
	Dim p As Parser 
	'mkChoice(mkItem(), mkReturn("bar"))
	Set p = mkSeq(Array(pHexLit, mkMany(pWs)), "fst")
	s = "FF 0x1F __µ 0"

	MsgBox( _
		"applying parser '" & p.tp & "' to " & toString(s) & ": " & chr(13) _
		& toString(applyP(p, s)) _
	)
	Stop
	
	MsgBox("'" & s & "'" & chr(13) & evalNorExpr(s))
	
	
	Dim e0 As Object
	Dim e1 As Object
	Dim lu As Variant
	Set e0 = Env_new()
	Set e1 = Env_new(e0)

	lu = Env_lookup(e1, "A")
	MsgBox(Env_show(e1) & Chr(13) & "lookup('A') ~> " & toString(lu))	

	Env_add(e0, "A", 1)
	Env_add(e1, "B", 2)
	Env_add(e1, "C", 3)

	lu = Env_lookup(e1, "A")
	MsgBox(Env_show(e1) & Chr(13) & "lookup('A') ~> " & toString(lu))	

	Env_add(e1, "A", "abc")

	lu = Env_lookup(e1, "A")
	MsgBox(Env_show(e1) & Chr(13) & "lookup('A') ~> " & toString(lu))
End Sub

'================================================================================

Sub croak(msg As String)
	Dim provoke As Object
	MsgBox(msg)
	MsgBox(provoke.AnError)
End Sub

Function inspect(o As Object)
	On Local Error Goto ErrorHandler
	Dim result As Variant
	result = o.tpx
		MsgBox("property 'tp' equals " & toString(result))
	Exit Function
	ErrorHandler:
		croak("property 'tp' not found in " & toString(o))
End Function

Function fst(x As Variant, y As Variant)
	fst = x
End Function

Function snd(x As Variant, y As Variant)
	snd = y
End Function

Function cons(x As Variant, xs As List)
	Dim result As New List
	result.head = x
	Set result.tail = xs
	If IsNull(xs) Then
		result.len = 1
	Else
		result.len = xs.len + 1
	End If
	cons = result
End Function

Function List_len(xs As List)
	If IsNull(xs) Then
		List_len = 0
	Else
		List_len = 1 + List_len(xs.tail)
	End If
End Function


Function arityF(fName As String)
	Dim result As Integer
	Select Case fName
		Case "pWs"
			result = 0
		Case "readHex"
			result = 1
		Case "fst"
			result = 2
		Case "snd"
			result = 2
		Case "applyF"
			result = 2
	End Select
	arityF = result
End Function

Function existsF(fName As String)
	existsF = Not(IsNull(arityF(fName)))
End Function

Function applyF(fName As String, Optional arguments As Array)
	Dim result As Variant
	Dim args As Variant
	Dim arity As Integer, k As Integer, n As Integer
	If IsMissing(arguments) Then
		args = Array()
	Else
		args = arguments
	End If
	arity = arityF(fName)
	k = LBound(args)
	n = UBound(args) - k + 1
	If Not(n = a) Then
		croak("applyF " & toString(fName) & ": has arity " & arity & ", got " & n & chr(13) & toString(args)
	End If
	Select Case fName
		Case "pWs"
			result = pWs
		Case "readHex"
			result = readHex(args(k))
		Case "fst"
			result = fst(args(k), args(k + 1))
		Case "snd"
			result = snd(args(k), args(k + 1))
		Case "applyF"
			result = applyF(args(k), args(k + 1))
		Case Else
			croak("applyF: unknown function " & toString(fName))
	End Select	
	applyF = result
End Function

'==================================================================

Function mkParser(tp As String, st As Variant)
	Dim result As New Parser
	result.tp = tp
	result.st = st
	mkParser = result
End Function

Function mkReturn(node As Variant)
	mkReturn = mkParser("return", Array(node))
End Function

Function mkFailure()
	mkFailure = mkParser("failure", Array())
End Function

Function mkItem()
	mkItem = mkParser("item", Array())
End Function

Function mkChoice(p1 As Parser, p2 As Parser)
	mkChoice = mkParser("choice", Array(p1, p2))
End Function

Function mkStr(t As String)
	If (Len(t) = 0) Then
		croak("mkStr: cannot match 'exactly' the empty string t=''")
	Else
		mkStr = mkParser("str", Array(t))
	End If
End Function

Function mkMany(p As Parser)
	mkMany = mkParser("many", Array(p))
End Function

Function mkBind(fName As String, p As Parser)
	If Not existsF(fName) Then
		croak("mkBind: unknown function " & toString(fName))
	Else
		mkBind = mkParser("bind", Array(p, fName))
	End If
End Function

Function mkSeq(ps As Array, fName As String)
	If Not existsF(fName) Then
		croak("mkSeq: unknown function " & toString(fName))
	Else
		mkSeq = mkParser("seq", Array(ps, fName))
	End If
End Function

'==================================================================

Function pWs()
	Static result As Parser	' an uninitialized instance of Parser at first
	If result.tp = "" Then
		result = mkChoice(mkStr(" "), mkStr(Chr(9))
	End If
	pWs = result
End Function

Function pBinDigit()
	Static result As Parser	' an uninitialized instance of Parser at first
	If result.tp = "" Then
		result = mkChoice(mkStr("0"), mkStr("1"))
	End If
	pBinDigit = result
End Function

Function pDecDigit()
	Static result As Parser	' an uninitialized instance of Parser at first
	If result.tp = "" Then
		result = mkChoice(pBinDigit, mkChoice(mkStr("2"), mkStr("3"))
	End If
	pBinDigit = result
End Function

'==================================================================

Function parse(pName As String, s As String)
	Dim result As Variant
	result = applyP(pName, s)
	parse = toString(result)
End Function

Function applyP(ByVal parser As Variant, s As String, Optional pos As Integer)
	Dim p As Parser
	If IsNull(parser) Or IsEmpty(parser) Then
		croak("applyP: parser p = " & toString(parser))
	ElseIf TypeName(parser) = "String" Then
		Set p = applyF(parser)
	ElseIf TypeName(parser) = "Object" Then
		Set p = parser
	Else
		croak("applyP: invalid arg parser - " & toString(parser))
	End If
'	MsgBox(toString(p.tp))
	Dim result As Variant
	If IsMissing(pos) Then
		pos = 1
	End If
	If p.tp = "return" Then
		result = Array(p.st(0), pos)
	ElseIf p.tp = "failure" Then
		result = Empty
	ElseIf p.tp = "item" Then
		If pos <= Len(s) Then
			result = Array(Mid(s, pos, 1), pos + 1)
		Else
			result = Empty
		End If
	ElseIf p.tp = "choice" Then
		result = applyP(p.st(0), s, pos)
		If IsEmpty(result) Then
			result = applyP(p.st(1), s, pos)
		End If
	ElseIf p.tp = "str" Then
		Dim match As String
		Dim matchLen As Integer
		match = p.st(0)
		matchLen = Len(match)
		If (Mid(s, pos, matchLen) = match) Then
			result = Array(match, pos + matchLen)
		Else
			result = Empty
		End If
		'MsgBox("str(" & toString(match) & "), s=" & toString(s) & ", pos=" & toString(pos) & ", matchLen=" & toString(matchLen)_
		'	& chr(13) & "~>" & toString(result))
	ElseIf p.tp = "many" Then
		Dim nxtPos As Integer
		Dim lst As List
		Dim lstLen As Integer
		nxtPos = pos
		lstLen = 0
		Set lst = Nothing
		result = applyP(p.st(0), s, nxtPos)
		While Not(IsEmpty(result))
			nxtPos = result(1)
			Set lst = cons(result(0), lst)
			lstLen = lstLen + 1
			result = applyP(p.st(0), s, nxtPos)
		Wend
		If lstLen = 0 Then
			result = Array(Array(), nxtPos)
		Else
			ReDim things(0 To lstLen-1) As Variant
			While lstLen > 0
				lstLen = lstLen - 1
				things(lstLen) = lst.head
				Set lst = lst.tail
			Wend
			result = Array(things, nxtPos)
		End If
	ElseIf p.tp = "bind" Then
		result = applyP(p.st(0), s, pos)
		If Not IsEmpty(result) Then
			Dim fResult As Variant
			fResult = applyF(p.st(1), result(0))
			result(0) = fResult
		End If
	ElseIf p.tp = "seq" Then
		Dim innerParsers As Variant, t As Variant
		Dim i As Integer, j As Integer, k As Integer
'		Dim nxtPos As Integer
		innerParsers = p.st(0)
		i = LBound(innerParsers)
		k = UBound(innerParsers)
		j = 0
		nxtPos = pos
		Dim iResults(0 To k-i) As Variant
		Do
			t = applyP(innerParsers(i), s, nxtPos)
			If Not IsEmpty(t) Then
				iResults(j) = t(0)
				nxtPos = t(1)
				i = i + 1
				j = j + 1
			End If
		Loop Until (i > k) Or IsEmpty(t)
		If Not IsEmpty(t) Then
'			Dim fResult As Variant
			fResult = applyF(p.st(1), iResults)
			result = t
			result(0) = fResult
		End If
		MsgBox("seq/" & p.st(1) & ": " & toString(result))
	Else
		result = "unknown Parser '" & p.tp & "'"
		MsgBox("Error in applyP: " & result)
	End If
	applyP = result
End Function

Function readHex(arg As Variant)
	Dim result As Integer, d As Integer, x As Integer, digits As String
	If IsArray(arg) Then
		digits = Join(arg, "")
	Else
		digits = arg
	End If
	result = 0
	For i = 1 To Len(digits)
		d = Asc(Mid(digits, i, 1))
		If d <= Asc("9") Then
			x = d - Asc("0")
		ElseIf d <= Asc("F") Then
			x = d - Asc("A") + 10
		Else
			x = d - Asc("a") + 10
		End If
		result = (result * 16) + x
	Next
	readHex = result
End Function

Function toString(ByVal x As Variant) As String
	Dim result As String
	If IsNull(x) Then
		result = "Nothing"
	ElseIf IsEmpty(x) Then
		result = "Empty"
	ElseIf IsObject(x) Then
		result = "Object"
	ElseIf IsArray(x) Then
		result = "Array("
		Dim i As Integer
		For i = LBound(x) To UBound(x)
			If i > LBound(x) Then
				result = result & ", "
			End If
			result = result & toString(x(i))
		Next i
		result = result & ")"
	Else
		Dim t As String
		t = x & ""
		t = Join(Split(t, chr(13)), "\n")
		t = Join(Split(t, chr(9)), "\t")
		If TypeName(x) = "String" Then
			result = "'" & t & "'"
		Else
			result = t
		End If
	End If
	toString = result
End Function

Function KeyValuePair_new(ByVal k As String, ByVal v As Variant)
	Dim result As New KeyValuePair
	result.key = k
	result.val = v
	Set result.nxt = Nothing
	KeyValuePair_new = result
End Function

Function KeyValuePair_show(hd As KeyValuePair, Optional sep As String)
	Dim result As String
	result = ""
	If IsMissing(sep) Then
		sep = ", "
	End If
	If Not(IsNull(hd)) Then
		result = result & indent & "'" & hd.key & "' -> " & hd.val
		If Not(IsNull(hd.nxt)) Then
			result = result & sep & KeyValuePair_show(hd.nxt, sep)
		End If
	End If
	KeyValuePair_show = result
End Function

Function Env_new(Optional p As Object)
	Dim result As New Env
	If IsMissing(p) Then
		Set result.daddy = Nothing
	Else
		Set result.daddy = p
	End If
	Set result.mappings = Nothing
	Env_new = result
End Function

Function Env_show(e As Env, Optional indent As String)
	Dim nl As String
	Dim result As String
	Dim mappingsStr As String
	nl = Chr(13)
	If IsMissing(indent) Then
		indent = ""
	End If
	If IsNull(e) Then
		result = "null"
	Else
		mappingsStr = KeyValuePair_show(e.mappings, ", " & nl & indent & Space(2 + 4))
		result = "{" _
			& nl & indent & "  mappings: [" _
				& IIf(IsNull(e.mappings), "", nl & indent & Space(2 + 4) & mappingsStr) _
				& nl & indent & "  ]," _
			& nl & indent & "  daddy: " & Env_show(e.daddy, indent & Space(4)) _
			& nl & indent & "}"
	End If
	Env_show = result
End Function

Function Env_add(e As Env, key As String, val As Variant)
	Dim kvp As KeyValuePair
	Set kvp = KeyValuePair_new(key, val)
	Set kvp.nxt = e.mappings
	Set e.mappings = kvp
	Env_add = e
End Function

Function Env_lookup(e As Env, k As String)
	Dim kvp As KeyValuePair
	Dim result As Variant
	Set kvp = e.mappings
	Set result = Nothing
	While (IsNull(result) And Not(IsNull(kvp)))
		If (kvp.key = k) Then
			result = kvp.val
		Else
			kvp = kvp.nxt
		End If
	Wend
	If IsNull(result) And Not(IsNull(e.daddy)) Then
		result = Env_lookup(e.daddy, k)
	End If
	Env_lookup = result
End Function


'========================================================

Function NOR(a0, Optional a1, Optional a2, Optional a3, Optional a4, Optional a5, Optional a6, Optional a7)
	If Not IsMissing(a7) Then
		NOR = CVErr("NOR: cannot handle more than 7 arguments")
	Else
		If a0 Then
			NOR = 0
		ElseIf IsMissing(a1) Then
			NOR = 1
		   Else
		   	NOR = NOR(a1, a2, a3, a4, a5, a6)
		End If
	End If
End Function

Function evalArgs(s As String, e As Variant)
	Dim args As Variant
	s = LTrim(s)
	If Len(s) = 0 Then
		evalArgs = Array("xxx")
	Else
		evalArgs = Array()
	End If
End Function

Function evalNorExpr(s As String, Optional e As Variant)
	Dim args As Variant
	Dim result As Variant
	If IsMissing(e) Then
		e = Array()
	End If
	s = LTrim(s)
	If Left(s, 1) = "-" Then
		s = Right(s, Len(s) - 1)
		result = NOR(evalNorExpr(s, e))
	ElseIf IsNumeric(s) Then
	 	result = IIf(s, 1, 0)
	Else
		If Left(s, 1) = "µ" Then
			s = Right(s, Len(s) - 1)
			args = evalArgs(s, e)
			result = "NOR(args " & LBound(args) & "..." & UBound(args) & ")"
		Else
			result = Empty
		End If
	End If
	evalNorExpr = result
End Function

Function foo(x As Variant)
	If IsArray(x) Then
		foo = "size(WxH): " & UBound(x, 1) & " x " & UBound(x, 2)
	Else
		foo = TypeName(x)
	End If
End Function