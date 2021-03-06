Unit TERRA_Canvas;
{$I terra.inc}

Interface
Uses TERRA_Utils, TERRA_Image, TERRA_Texture, TERRA_Packer;

Type
  CanvasItem = Class(TERRAObject)
    Protected
      _Packed:Boolean;
      _Name:AnsiString;

    Public
      ID:Integer;
      PageID:Integer;
      X:Single;
      Y:Single;
      Buffer:Image;
      
      Destructor Destroy; Override;

      Property Name:AnsiString Read _Name;
  End;

  Canvas = Class(TERRAObject)
    Protected
      _Name:AnsiString;
      _Width:Integer;
      _Height:Integer;
      _ItemList:Array Of CanvasItem;
      _ItemCount:Integer;
      _Textures:Array Of Texture;
      _RefCount:Integer;
      _PageCount:Integer;

      _ContextLost:Boolean;

      Procedure CreateTexture(ID:Integer);

      Procedure RedoAfterContextLost;

    Public
      Constructor Create(Name:AnsiString; Width, Height:Integer);
      Destructor Destroy; Override;

      Function Add(Source:Image; Name:AnsiString):CanvasItem;
      Procedure Delete(ID:Integer);
      Function Get(ID:Integer):CanvasItem; Overload;
      Function Get(Name:AnsiString):CanvasItem; Overload;

      Procedure Clear;
      Procedure Bind(PageID:Integer);
      Function GetTexture(PageID:Integer):Texture;

      Procedure OnContextLost;

      Function Update:Boolean;

      Property Width:Integer Read _Width;
      Property Height:Integer Read _Height;
      Property PageCount:Integer Read _PageCount;

      Property ItemCount:Integer Read _ItemCount;
  End;

Implementation
Uses TERRA_Error, TERRA_FileUtils, TERRA_Log,  {$IFDEF DEBUG_GL}TERRA_DebugGL{$ELSE}TERRA_GL{$ENDIF};

// LCanvas
Constructor Canvas.Create(Name:AnsiString; Width, Height:Integer);
Begin
  _Name := Name;
  _Width := Width;
  _Height := Height;
  _ItemCount := 0;
  _RefCount := 0;
  _PageCount := 1;
  SetLength(_Textures, 1);
End;

Destructor Canvas.Destroy;
Var
  I:Integer;
Begin
  For I:=0 To Pred(Length(_Textures)) Do
  If Assigned(_Textures[I]) Then
    _Textures[I].Destroy;

  Clear;
End;

Procedure Canvas.Clear;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_ItemCount) Do
  Begin
    _ItemList[I].Buffer.Destroy;
    _ItemList[I].Destroy;
  End;
  _ItemCount := 0;
End;

Function Canvas.Add(Source: Image; Name:AnsiString): CanvasItem;
Begin
  Name := UpStr(GetFileName(Name, True));
  Inc(_ItemCount);
  SetLength(_ItemList, _ItemCount);
  Log(logDebug, 'Game', 'Creating canvas item');
  Result := CanvasItem.Create;
  _ItemList[Pred(_ItemCount)] := Result;
  Result._Name := Name;
  Log(logDebug, 'Game', 'Creating image from source');
  Result.Buffer := Image.Create(Source);
  Result.ID := _RefCount;
  Inc(_RefCount);
  Log(logDebug, 'Game', 'Canvas element added');
End;

Procedure Canvas.Delete(ID:Integer);
Var
  I, N:Integer;
Begin
  N := -1;
  For I:=0 To Pred(_ItemCount) Do
  If (_ItemList[I].ID = ID) Then
  Begin
    N := I;
    Break;
  End;

  If (N<0) Then
    Exit;

  _ItemList[N].Buffer.Destroy;
  _ItemList[N] := _ItemList[Pred(_ItemCount)];
  Dec(_ItemCount);
End;

Function Canvas.Get(ID:Integer):CanvasItem;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_ItemCount) Do
  If (_ItemList[I].ID = ID) Then
  Begin
    Result := (_ItemList[I]);
    Exit;
  End;
  Result := Nil;
End;

Function Canvas.Get(Name:AnsiString):CanvasItem;
Var
  I:Integer;
Begin
  Name := UpStr(GetFileName(Name, True));

  For I:=0 To Pred(_ItemCount) Do
  If (_ItemList[I]._Name = Name) Then
  Begin
    Result := (_ItemList[I]);
    Exit;
  End;
  Result := Nil;
End;

{$DEFINE CPUBUFFER}
Function Canvas.Update:Boolean;
Var
  I, X, Y, W, H:Integer;
  Packer:RectanglePacker;
  LastCount, Count:Integer;
  {$IFDEF CPUBUFFER}
  Buffer:Image;
  {$ENDIF}
Begin
  Log(logDebug, 'Canvas', 'Updating');

  _PageCount := 0;
  For I:=0 To Pred(_ItemCount) Do
  Begin
    _ItemList[I]._Packed := False;
    _ItemList[I].PageID := -1;
  End;

  LastCount := Succ(_ItemCount);
  Repeat
    {$IFDEF CPUBUFFER}
    Buffer := Image.Create(_Width, _Height);
    {$ENDIF}

    Packer := RectanglePacker.Create;
    For I:=0 To Pred(_ItemCount) Do
    If Not _ItemList[I]._Packed Then
    Begin
      W := _ItemList[I].Buffer.Width + 1;
      H := _ItemList[I].Buffer.Height + 1;
      If (H<Self._Height) Then
        Inc(H);
      Packer.AddRect(W, H, _ItemList[I].ID);
    End;

    Count := Packer.Pack(Self._Width, Self._Height);
    If (Count=LastCount) Then
    Begin
      RaiseError('Not enough space to pack canvas.');
      Result := False;
      Packer.Destroy;
      Exit;
    End;

    LastCount := Count;
    Inc(_PageCount);
    If Length(_Textures)<_PageCount Then
      SetLength(_Textures, _PageCount);
    If Not Assigned(_Textures[Pred(_PageCount)]) Then
      CreateTexture(Pred(_PageCount));

    For I:=0 To Pred(_ItemCount) Do
    Begin
      If (_ItemList[I]._Packed) Then
        Continue;

      X := 0;
      Y := 0;
      If (Packer.GetRect(_ItemList[I].ID, X, Y)) Then
      Begin
        _ItemList[I].X := (Succ(X) / Self._Width);
        _ItemList[I].Y := (Succ(Y) / Self._Height);
        _ItemList[I].PageID := Pred(_PageCount);
        _ItemList[I]._Packed := True;

        If (Assigned(_ItemList[I].Buffer)) Then
        {$IFNDEF CPUBUFFER}
          _Textures[Pred(_PageCount)].UpdateRect(_ItemList[I].Buffer, X, Y);
        {$ELSE}
          Buffer.Blit(X, Y, 0, 0, _ItemList[I].Buffer.Width, _ItemList[I].Buffer.Height, _ItemList[I].Buffer);
        {$ENDIF}
      End Else
        Log(logError, 'Canvas', 'Could not pack '+_ItemList[I]._Name);
    End;
    Packer.Destroy;

    {$IFDEF CPUBUFFER}
    _Textures[Pred(_PageCount)].UpdateRect(Buffer);

    //Buffer.Save(_Name+'_canvas'+IntToString(_PageCount)+'.png', 'png','depth=32');
    Buffer.Destroy;
    {$ENDIF}
  Until (Count = 0);

  Result := True;
  Log(logDebug, 'Canvas', 'Canvas is now updated');
End;

Procedure Canvas.Bind(PageID:Integer);
Begin
  _Textures[PageID].Bind(0);
End;

Function Canvas.GetTexture(PageID:Integer):Texture;
Begin
  If (_ContextLost) Then
  Begin
    Self.RedoAfterContextLost();
    _ContextLost := False;
  End;

  If (PageID<Length(_Textures)) Then
    Result := _Textures[PageID]
  Else
    Result := Nil;
End;

Procedure Canvas.RedoAfterContextLost;
Var
  I,J:Integer;
  X,Y:Integer;
  {$IFDEF CPUBUFFER}
  Buffer:Image;
  {$ENDIF}
Begin
  For J:=0 To Pred(_PageCount) Do
  If Assigned(_Textures[J]) Then
  Begin
    {$IFDEF CPUBUFFER}
    Buffer := Image.Create(_Width, _Height);
    {$ENDIF}

    _Textures[J].Destroy();
    Self.CreateTexture(J);

    For I:=0 To Pred(_ItemCount) Do
    Begin
      If (_ItemList[I].PageID <> J) Then
        Continue;

      X := Pred(Trunc(_ItemList[I].X * Self._Width));
      Y := Pred(Trunc(_ItemList[I].Y * Self._Height));

      If (Assigned(_ItemList[I].Buffer)) Then
      {$IFNDEF CPUBUFFER}
      _Textures[J].UpdateRect(_ItemList[I].Buffer, X, Y);
      {$ELSE}
      Buffer.Blit(X, Y, 0, 0, _ItemList[I].Buffer.Width, _ItemList[I].Buffer.Height, _ItemList[I].Buffer);
      {$ENDIF}
    End;

    {$IFDEF CPUBUFFER}
    _Textures[Pred(_PageCount)].UpdateRect(Buffer);

    //Buffer.Save(_Name+'_canvas'+IntToString(_PageCount)+'.png', 'png','depth=32');
    Buffer.Destroy;
    {$ENDIF}
  End
End;

Procedure Canvas.OnContextLost;
Begin
  Self._ContextLost := True;
End;

Procedure Canvas.CreateTexture(ID: Integer);
Var
  S:AnsiString;
Begin
  S := _Name+'_page'+IntToString(ID);
  Log(logDebug, 'Canvas', 'Creating canvas texture: '+S);

  _Textures[ID] := TERRA_Texture.Texture.New(S, Width, Height);
  _Textures[ID].MipMapped := False;
  _Textures[ID].Update();
End;

Destructor CanvasItem.Destroy;
Begin
End;

End.
