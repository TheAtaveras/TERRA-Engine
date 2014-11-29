Unit TERRA_MeshFilter;

{$I terra.inc}

Interface

Uses TERRA_Utils, TERRA_Vector3D, TERRA_Vector2D, TERRA_Color, TERRA_IO;

Const
  meshFormatNormal  = 1;
  meshFormatTangent = 2;
  meshFormatBone    = 4;
  meshFormatColor   = 8;
  meshFormatUV1     = 16;
  meshFormatUV2     = 32;

  meshGroupHidden       = 1 Shl 0;  // Group is hidden
  meshGroupDoubleSided  = 1 Shl 1;
  meshGroupCastShadow   = 1 Shl 2;
  meshGroupTransparency = 1 Shl 3;
  meshGroupAlphaTest    = 1 Shl 4;
  meshGroupPick         = 1 Shl 5;
  meshGroupLightmap     = 1 Shl 6;
  meshGroupSpheremap    = 1 Shl 7;
  meshGroupDepthOff     = 1 Shl 8;
  meshGroupTriplanar    = 1 Shl 9;
  meshGroupVertexColor  = 1 Shl 10;
  meshGroupLightOff     = 1 Shl 11;
  meshGroupOverrideAmbient = 1 Shl 12;
  meshGroupAlphaMap     = 1 Shl 13;
  meshGroupWireframe    = 1 Shl 14;
  meshGroupColorOff     = 1 Shl 15;
  meshGroupOutlineOff   = 1 Shl 16;
  meshGroupForceOpaque  = 1 Shl 17;
  meshGroupLinked       = 1 Shl 18;
  meshGroupVegetation   = 1 Shl 19;
  meshGroupIgnoreColorTable  = 1 Shl 20;
  meshGroupStencilTest  = 1 Shl 21;
  meshGroupNormalsOff   = 1 Shl 22;
  meshGroupSkybox       = 1 Shl 23;
  meshGroupWaterMap     = 1 Shl 24;
  meshGroupDynamic      = 1 Shl 25;
  meshGroupReflective   = 1 Shl 26;
  meshGroupStencilMask  = 1 Shl 27;
  meshGroupReflectiveMap = 1 Shl 28;
  meshGroupTextureMatrix = 1 Shl 29;

{  mgMirror    = 2;  // Group is a reflective surface
  mgCullFace  = 4;  // Group is one sided/two sided
  mgShadow    = 8;  // Group cast shadow
  mgPick      = 128;  // Group is pickable
  mgCollision = 512;
  mgSphereMap = 1024;
  mgAlphaTest = 2048;
  mgTransparency = 4096;
  mgCloth     = 8192;
  mgOverrideMaterial = 16384;
}

Type
  PMeshVertex=^MeshVertex;
	MeshVertex = Packed Record
		Position:Vector3D;
    TextureCoords:Vector2D;
    TextureCoords2:Vector2D;
    Color:TERRA_Color.Color;
    Normal:Vector3D;
    BoneIndex:Single;
    Tangent:Vector3D;
    Handness:Single;
	End;

  MeshVectorKey = Record
    Value:Vector3D;
    Time:Single;
  End;

  {MeshQuaternionKey = Record
    Value:Quaternion;
    Time:Single;
  End;}

  MeshFilter = Class
    Public
      Function GetGroupCount:Integer; Virtual;
      Function GetGroupName(GroupID:Integer):AnsiString; Virtual;
      Function GetGroupFlags(GroupID:Integer):Cardinal; Virtual;
      Function GetGroupBlendMode(GroupID:Integer):Cardinal; Virtual;

      Function GetTriangleCount(GroupID:Integer):Integer; Virtual;
      Function GetTriangle(GroupID, Index:Integer):Triangle; Virtual;

      Function GetVertexCount(GroupID:Integer):Integer; Virtual;
      Function GetVertexFormat(GroupID:Integer):Cardinal; Virtual;
      Function GetVertexPosition(GroupID, Index:Integer):Vector3D; Virtual;
      Function GetVertexNormal(GroupID, Index:Integer):Vector3D; Virtual;
      Function GetVertexTangent(GroupID, Index:Integer):Vector3D; Virtual;
      Function GetVertexHandness(GroupID, Index:Integer):Single; Virtual;
      Function GetVertexBone(GroupID, Index:Integer):Integer; Virtual;
      Function GetVertexColor(GroupID, Index:Integer):Color; Virtual;
      Function GetVertexUV(GroupID, Index:Integer):Vector2D; Virtual;
      Function GetVertexUV2(GroupID, Index:Integer):Vector2D; Virtual;

      Function GetDiffuseColor(GroupID:Integer):Color; Virtual;
      Function GetAmbientColor(GroupID:Integer):Color; Virtual;

      Function GetDiffuseMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetTriplanarMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetGlowMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetRefractionMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetSpecularMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetEmissiveMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetAlphaMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetLightMapName(GroupID:Integer):AnsiString; Virtual;
      Function GetColorRampName(GroupID:Integer):AnsiString; Virtual;

      Function GetBoneCount():Integer; Virtual;
      Function GetBoneName(BoneID:Integer):AnsiString; Virtual;
      Function GetBoneParent(BoneID:Integer):Integer; Virtual;
      Function GetBonePosition(BoneID:Integer):Vector3D; Virtual;
      Function GetBoneRotation(BoneID:Integer):Vector3D; Virtual;

      Function GetAnimationCount():Integer; Virtual;
      Function GetAnimationName(AnimationID:Integer):AnsiString; Virtual;
      Function GetAnimationFrameRate(AnimationID:Integer):Single; Virtual;
      Function GetAnimationDuration(AnimationID:Integer):Single; Virtual;
      Function GetAnimationLoop(AnimationID:Integer):Boolean; Virtual;

      Function GetPositionKeyCount(AnimationID, BoneID:Integer):Integer; Virtual;
      Function GetRotationKeyCount(AnimationID, BoneID:Integer):Integer; Virtual;
      Function GetScaleKeyCount(AnimationID, BoneID:Integer):Integer; Virtual;

      Function GetPositionKey(AnimationID, BoneID:Integer; KeyID:Integer):MeshVectorKey; Virtual;
      Function GetScaleKey(AnimationID, BoneID:Integer; KeyID:Integer):MeshVectorKey; Virtual;
      Function GetRotationKey(AnimationID, BoneID:Integer; KeyID:Integer):MeshVectorKey; Virtual;

      Function Load(Source:Stream):Boolean; Overload; Virtual;
      Function Load(FileName:AnsiString):Boolean; Overload;

      Class Function Save(Dest:Stream; MyMesh:MeshFilter):Boolean; Overload; Virtual;
      Class Function Save(FileName:AnsiString; MyMesh:MeshFilter):Boolean; Overload;
    End;

  MeshFilterClass = Class Of MeshFilter;
  MeshFilterType = Record
    Filter:MeshFilterClass;
    Extension:AnsiString;
  End;

  Procedure RegisterMeshFilter(Filter:MeshFilterClass; Extension:AnsiString);
  Function CreateMeshFilter(FileName:AnsiString):MeshFilter;

Var
  MeshFilterList:Array Of MeshFilterType;
  MeshFilterCount:Integer = 0;

Implementation
Uses TERRA_FileIO, TERRA_GraphicsManager, TERRA_FileUtils;

Procedure RegisterMeshFilter(Filter:MeshFilterClass; Extension:AnsiString);
Begin
  Inc(MeshFilterCount);
  SetLength(MeshFilterList, MeshFilterCount);
  MeshFilterList[Pred(MeshFilterCount)].Filter := Filter;
  MeshFilterList[Pred(MeshFilterCount)].Extension := UpStr(Extension);
End;

Function CreateMeshFilter(FileName:AnsiString):MeshFilter;
Var
  Ext:AnsiString;
  Src:Stream;
  I:Integer;
Begin
  Result := Nil;
  If Not FileStream.Exists(FileName) Then
    Exit;

  Ext := UpStr(GetFileExtension(FileName));
  For I:=0 To Pred(MeshFilterCount) Do
  If (MeshFilterList[I].Extension = Ext) Then
  Begin
    Src := MemoryStream.Create(FileName);
    Result := MeshFilterList[I].Filter.Create;
    Result.Load(Src);
    Src.Destroy;
    Exit;
  End;
End;

{ MeshFilter }
Function MeshFilter.GetDiffuseColor(GroupID: Integer): Color;
Begin
  Result := ColorWhite;
End;

Function MeshFilter.GetDiffuseMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

Function MeshFilter.GetEmissiveMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

Function MeshFilter.GetGroupCount: Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetGroupFlags(GroupID: Integer): Cardinal;
Begin
  Result := meshGroupCastShadow Or meshGroupPick;
End;

Function MeshFilter.GetGroupName(GroupID: Integer):AnsiString;
Begin
  Result := 'Group'+IntToString(Succ(GroupID));
End;

Function MeshFilter.GetSpecularMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
end;

Function MeshFilter.GetTriangle(GroupID, Index: Integer): Triangle;
Begin
  Result.Indices[0] := 0;
  Result.Indices[1] := 0;
  Result.Indices[2] := 0;
End;

Function MeshFilter.GetTriangleCount(GroupID: Integer): Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetVertexBone(GroupID, Index: Integer): Integer;
Begin
  Result := -1;
End;

Function MeshFilter.GetVertexColor(GroupID, Index: Integer): Color;
Begin
  Result := ColorWhite;
End;

Function MeshFilter.GetVertexCount(GroupID: Integer): Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetVertexFormat(GroupID: Integer): Cardinal;
Begin
  Result := 0;
End;

Function MeshFilter.GetVertexHandness(GroupID, Index: Integer): Single;
Begin
  Result := 1.0;
End;

Function MeshFilter.GetVertexNormal(GroupID, Index: Integer): Vector3D;
Begin
  Result := VectorUp;
End;

Function MeshFilter.GetVertexPosition(GroupID, Index: Integer): Vector3D;
Begin
  Result := VectorZero;
End;

Function MeshFilter.GetVertexTangent(GroupID, Index: Integer): Vector3D;
Begin
  Result := VectorZero;
End;

Function MeshFilter.GetVertexUV(GroupID, Index: Integer): Vector2D;
Begin
  Result.X := 0;
  Result.Y := 0;
End;

Function MeshFilter.GetVertexUV2(GroupID, Index: Integer): Vector2D;
Begin
  Result.X := 0;
  Result.Y := 0;
End;

Class Function MeshFilter.Save(Dest:Stream; MyMesh: MeshFilter): Boolean;
Begin
  Result := False;
End;

Function MeshFilter.Load(Source: Stream): Boolean;
Begin
  Result := False;
End;

Function MeshFilter.Load(FileName:AnsiString): Boolean;
Var
  Src:Stream;
Begin
  Src := MemoryStream.Create(FileName);
  Result := Load(Src);
  Src.Destroy;
End;

Class Function MeshFilter.Save(FileName:AnsiString; MyMesh: MeshFilter): Boolean;
Var
  Dest:Stream;
Begin
  Dest := FileStream.Create(FileName);
  Result := Save(Dest, MyMesh);
  Dest.Destroy;
End;

Function MeshFilter.GetGroupBlendMode(GroupID: Integer): Cardinal;
Begin
  Result := blendNone;
End;

Function MeshFilter.GetBoneCount: Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetBoneName(BoneID: Integer):AnsiString;
Begin
  Result := 'bone'+IntToString(BoneID);
End;

Function MeshFilter.GetPositionKeyCount(AnimationID, BoneID:Integer):Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetRotationKeyCount(AnimationID, BoneID:Integer):Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetScaleKeyCount(AnimationID, BoneID:Integer):Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetPositionKey(AnimationID, BoneID:Integer; KeyID:Integer):MeshVectorKey;
Begin
  Result.Value := VectorZero;
  Result.Time := 0;
End;

Function MeshFilter.GetScaleKey(AnimationID, BoneID:Integer; KeyID:Integer):MeshVectorKey;
Begin
  Result.Value := VectorOne;
  Result.Time := 0;
End;

Function MeshFilter.GetRotationKey(AnimationID, BoneID:Integer; KeyID:Integer):MeshVectorKey;
Begin
  Result.Value := VectorZero;
  Result.Time := 0;
End;

Function MeshFilter.GetAnimationCount: Integer;
Begin
  Result := 0;
End;

Function MeshFilter.GetAnimationDuration(AnimationID:Integer):Single;
Begin
  Result := 0;
End;

Function MeshFilter.GetAnimationName(AnimationID: Integer):AnsiString;
Begin
  Result := 'animation'+IntToString(AnimationID);
End;

Function MeshFilter.GetBoneParent(BoneID: Integer): Integer;
Begin
  Result := -1;
End;

Function MeshFilter.GetBonePosition(BoneID: Integer): Vector3D;
Begin
  Result := VectorZero;
End;

Function MeshFilter.GetBoneRotation(BoneID: Integer): Vector3D;
Begin
  Result := VectorZero;
End;

Function MeshFilter.GetAnimationFrameRate(AnimationID: Integer): Single;
Begin
  Result := 24.0;
End;

Function MeshFilter.GetAnimationLoop(AnimationID: Integer): Boolean;
Begin
  Result := False;
End;

Function MeshFilter.GetAlphaMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

function MeshFilter.GetAmbientColor(GroupID: Integer): Color;
Begin
  Result := ColorBlack;
End;

Function MeshFilter.GetColorRampName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

Function MeshFilter.GetGlowMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

Function MeshFilter.GetLightMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

Function MeshFilter.GetRefractionMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

Function MeshFilter.GetTriplanarMapName(GroupID: Integer):AnsiString;
Begin
  Result := '';
End;

End.