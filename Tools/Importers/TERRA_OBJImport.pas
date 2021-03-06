{***********************************************************************************************************************
 *
 * TERRA Game Engine
 * ==========================================
 *
 * Copyright (C) 2003, 2014 by S�rgio Flores (relfos@gmail.com)
 *
 ***********************************************************************************************************************
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 **********************************************************************************************************************
 * TERRA_OBJImport
 * Implements OBJ file importer
 ***********************************************************************************************************************
}
Unit TERRA_OBJImport;

{$I terra.inc}
Interface
Uses TERRA_Application, TERRA_OBJ, TERRA_MeshAnimation, TERRA_Utils, TERRA_OS;

implementation

Uses TERRA_Mesh, TERRA_INI, TERRA_IO, TERRA_Matrix, TERRA_ResourceManager,
  TERRA_Vector3D, TERRA_Vector2D, TERRA_Math, TERRA_Color, TERRA_Log,
  SysUtils, TERRA_MeshFilter, TERRA_FileImport, TERRA_FileIO,
  TERRA_FileUtils;

Function ObjImporter(SourceFile, TargetDir:AnsiString; TargetPlatform:Integer; Settings:AnsiString):AnsiString;
Var
  I,J,K:Integer;
  S:AnsiString;
  Src, Dest:Stream;
  Obj1, Obj2:ModelOBJ;
  G:MeshGroup;
  MyMesh:Mesh;
Begin
	Result := '';
  If Pos('_lmap', SourceFile)>0 Then
  Begin
    Log(logConsole, 'Import', 'Skipping lightmap OBJ file ('+GetFileName(SourceFile, False)+')...');
    Exit;
  End;

  Log(logConsole, 'Import', 'Reading OBJ file ('+GetFileName(SourceFile, False)+')...');
  Src := MemoryStream.Create(SourceFile);
  Obj1 := ModelOBJ.Create;
  Obj1.Load(Src);
  Src.Destroy;

  S := GetFilePath(SourceFile) + PathSeparator + GetFileName(SourceFile, True)+'_lmap.obj';
  If FileExists(S) Then
  Begin
    Log(logConsole, 'Import', 'Reading lightmap file ('+GetFileName(S, False)+')...');
    Src := MemoryStream.Create(SourceFile);
    Obj2 := ModelOBJ.Create;
    Obj2.Load(Src);
    Src.Destroy;
  End Else
    Obj2 := Nil;

  Log(logConsole, 'Import', 'Converting mesh...');
  MyMesh := Mesh.CreateFromFilter(Obj1);

  If Assigned(Obj2) Then
  Begin
    Log(logConsole, 'Import', 'Converting lightmap...');
    For K:=0 To Pred(MyMesh.GroupCount) Do
    Begin
      G := MyMesh.GetGroup(K);
      G.Flags := G.Flags Or meshGroupLightmap;

      For I:=0 To Pred(G.VertexCount) Do
      Begin
        G.Vertices[I].Normal.X := Obj2.GetVertexUV(K, I).X;
        G.Vertices[I].Normal.Y := Obj2.GetVertexUV(K, I).Y;
      End;
    End;
  End;

  Log(logConsole, 'Import', 'Saving mesh...');
  S := TargetDir + PathSeparator + GetFileName(SourceFile, True)+ '.mesh';
  Dest := FileStream.Create(S);
  MyMesh.Save(Dest);
  MyMesh.Destroy;
  Dest.Destroy;
End;



Initialization
  RegisterFileImporter('obj', 'mesh', OBJImporter);
End.
