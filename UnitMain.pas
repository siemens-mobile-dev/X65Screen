unit UnitMain; 
 
interface 
 
uses 
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, BFC, ComPort, Crc16, ComCtrls, ExtCtrls, StdCtrls, Buttons, jpeg, 
  ExtDlgs, Menus, DateUtils ,IniFiles; 
 
type 
  TfrmMain = class(TForm) 
    PanelTop: TPanel; 
    PanelLeft: TPanel; 
    ScrollBox1: TScrollBox; 
    StatusBar1: TStatusBar; 
    btnCommOpen: TBitBtn; 
    CommList: TComboBox; 
    Bevel1: TBevel; 
    Label1: TLabel; 
    DispPic: TPanel; 
    BitBtn1: TBitBtn; 
    ImageA: TImage; 
    Panel1: TPanel; 
    Image1: TImage; 
    Panel2: TPanel; 
    Image2: TImage; 
    Panel3: TPanel; 
    Image3: TImage; 
    Panel4: TPanel; 
    Image4: TImage; 
    Panel6: TPanel; 
    Image6: TImage; 
    Panel5: TPanel; 
    Image5: TImage; 
    Panel7: TPanel; 
    Image7: TImage; 
    Panel8: TPanel; 
    Image8: TImage; 
    CheckBox1: TCheckBox; 
    BitBtn2: TBitBtn; 
    SavePictureDialog1: TSavePictureDialog; 
    RadioGroup1: TRadioGroup; 
    PopupMenu1: TPopupMenu; 
    N1: TMenuItem; 
    SpeedButton4: TSpeedButton; 
    SpeedButton3: TSpeedButton; 
    ImageT: TImage; 
    Label4: TLabel; 
    Label3: TLabel; 
    Label5: TLabel; 
    Label2: TLabel; 
    Label6: TLabel; 
    Label7: TLabel; 
    Label8: TLabel; 
    Label9: TLabel; 
    Panel9: TPanel; 
    SpeedButton1: TSpeedButton; 
    SpeedButton2: TSpeedButton; 
    SpeedButton6: TSpeedButton; 
    SpeedButton5: TSpeedButton; 
    SpeedButton7: TSpeedButton; 
    procedure btnCommOpenClick(Sender: TObject); 
    procedure FormShow(Sender: TObject); 
    procedure BitBtn1Click(Sender: TObject); 
    procedure Image1DragDrop(Sender, Source: TObject; X, Y: Integer); 
    procedure Image1DragOver(Sender, Source: TObject; X, Y: Integer; 
      State: TDragState; var Accept: Boolean); 
    procedure BitBtn2Click(Sender: TObject); 
    procedure N1Click(Sender: TObject); 
    procedure ImageAMouseDown(Sender: TObject; Button: TMouseButton; 
      Shift: TShiftState; X, Y: Integer); 
    procedure SavePictureDialog1TypeChange(Sender: TObject); 
    procedure FormClose(Sender: TObject; var Action: TCloseAction); 
    procedure SpeedButton3Click(Sender: TObject); 
    procedure SpeedButton4Click(Sender: TObject); 
    procedure SpeedButton1Click(Sender: TObject); 
    procedure SpeedButton2Click(Sender: TObject); 
    procedure SpeedButton5Click(Sender: TObject); 
    procedure SpeedButton6Click(Sender: TObject); 
    procedure SpeedButton7Click(Sender: TObject); 
    procedure BitBtn1MouseDown(Sender: TObject; Button: TMouseButton; 
      Shift: TShiftState; X, Y: Integer); 
    procedure FormCreate(Sender: TObject); 
  private 
    { Private declarations } 
  public 
    { Public declarations } 
    procedure ShowErr(Mess:String); 
    function CommOpen(CommNum:Integer):Boolean; 
    procedure GetDisp; 
    //procedure SetLang; 
  end; 
 
const 
  COMSTAT     = 0; 
  MESSINFO    = 1; 
 
var 
  frmMain: TfrmMain; 
  BufferAddress : DWord; 
  DisplayWidth, DisplayHeight : Word; 
  ClientID: Byte; 
  inifile: TIniFile; 
  Product, SW_Version,CurrentMode,CapTime, Scre,CopyErr,OpenErr,Conn:String; 
  DisConn,ConnErr,Tips,ConnSucc :string; 
implementation 
 
uses UnitAbout, UnitTools; 
 
{$R *.dfm} 
{$R WindowsXP.res} 
procedure TfrmMain.ShowErr(Mess:String); 
begin 
  MessageBox(handle,PChar(Mess),'ПµНіМбКѕ',MB_ICONERROR); 
end; 
 
function TfrmMain.CommOpen(CommNum:Integer):Boolean; 
var 
  Ver:string; 
begin 
  Result := false; 
  iComNum := CommNum; 
  if not OpenCom(False) then 
  begin 
    ShowErr('COM'+IntToStr(CommNum)+OpenErr); 
    Exit; 
  end; 
  Sleep(300); 
  WriteComStr('AT^SQWE=1'^M);  // BFC ДЈКЅ 
  ReadBFC; 
  Ver := BFC_GetPhoneModel; 
  StatusBar1.Panels[COMSTAT].Text := 'COM'+IntToStr(CommNum)+ 
                                     ':'+Ver +ConnSucc; 
 
  if BFC_Funcs20($0A, [$07,$01], 2)<>ERR_NO then  // ЖБД»РЕПў 
  begin 
    ShowErr(ConnErr); 
    Exit; 
  end; 
  DisplayWidth  := ibfc.cd.DisplayInfo.Width; 
  DisplayHeight := ibfc.cd.DisplayInfo.Height; 
  ClientID      := ibfc.cd.DisplayInfo.ClientID; 
 
  DispPic.Width := DisplayWidth+2;DispPic.Height:= DisplayHeight+2; 
  Panel1.Width := DisplayWidth+2;Panel1.Height:= DisplayHeight+2; 
  Panel2.Width := DisplayWidth+2;Panel2.Height:= DisplayHeight+2; 
  Panel3.Width := DisplayWidth+2;Panel3.Height:= DisplayHeight+2; 
  Panel4.Width := DisplayWidth+2;Panel4.Height:= DisplayHeight+2; 
  Panel5.Width := DisplayWidth+2;Panel5.Height:= DisplayHeight+2; 
                                 Panel5.Top := Panel1.Top+Panel1.Height+7; 
  Panel6.Width := DisplayWidth+2;Panel6.Height:= DisplayHeight+2; 
                                 Panel6.Top := Panel1.Top+Panel1.Height+7; 
  Panel7.Width := DisplayWidth+2;Panel7.Height:= DisplayHeight+2; 
                                 Panel7.Top := Panel1.Top+Panel1.Height+7; 
  Panel8.Width := DisplayWidth+2;Panel8.Height:= DisplayHeight+2; 
                                 Panel8.Top := Panel1.Top+Panel1.Height+7; 
 
  Label1.Caption := Scre+IntToStr(DisplayHeight)+ 
                    '*'+IntToStr(DisplayWidth); 
  BitBtn1.Top := DispPic.Top + DisplayHeight + 6; 
  SpeedButton6.Top := DispPic.Top + DisplayHeight + 6; 
 
  Label8.Caption := Product+Ver; 
  //Label6.Caption := 'IMEI: '+BFC_GetIMEI; 
  Label7.Caption := SW_Version+'V'+BFC_GetSoftWareVer; 
  Label9.Caption := CurrentMode+BFC_GetSecurityMode; 
 
  if BFC_Funcs20($0A, [$09,ClientID], 2)<>ERR_NO then 
  begin 
    ShowErr('»сИЎКЦ»ъ»єіеЗшµШЦ·К§°Ь!'); 
    Exit; 
  end; 
  BufferAddress := ibfc.cd.DisplayUpdateInfo.BufferAddress; 
  Result := true; 
end; 
 
 
 
procedure TfrmMain.btnCommOpenClick(Sender: TObject); 
var 
  COMID:string; 
begin 
  if btnCommOpen.Tag = 0{'Б¬ЅУ'} then 
  begin 
    COMID := CommList.Text; 
    Delete(COMID,1,3); 
    if not CommOpen(StrToInt(COMID)) then 
    begin 
      //ShowErr('COM'+IntToStr(CommList.ItemIndex+1)+' ґтїЄК§°ЬЈЎ'); 
      Exit; 
    end; 
    btnCommOpen.Caption := DisConn;//'¶ПїЄ'; 
    btnCommOpen.Tag := 1; 
    BitBtn1.Enabled := true; 
    SpeedButton5.Enabled := true; 
    SpeedButton2.Enabled := false; 
    Inifile.WriteString('COMM', 'Port',CommList.Text); 
    //StatusBar1.Panels[COMSTAT].Text := 'COM'+IntToStr(CommList.ItemIndex+1)+' ґтїЄіЙ№¦ЈЎ' 
  end 
  else 
  begin 
    BFC_SendAT('AT^SQWE=0'^M); 
    CloseCom; 
    btnCommOpen.Caption := Conn; 
    btnCommOpen.Tag := 0; 
    Label1.Caption := Scre;//'ЖБД»Јє'; 
    BitBtn1.Enabled := false; 
    SpeedButton5.Enabled := false; 
    SpeedButton2.Enabled := true; 
    StatusBar1.Panels[COMSTAT].Text := 'COM '+DisConn; 
  end; 
end; 
 
procedure TfrmMain.FormShow(Sender: TObject); 
var 
  I,OldCOM: Integer; 
  CommName: String; 
begin 
  OldCOM := -1; 
  Inifile := TInifile.Create(ExtractFilePath(Application.ExeName)+'X65.ini'); 
  CommName := Inifile.ReadString('COMM', 'Port', ''); 
  SpeedButton7.Caption := Inifile.ReadString('LANGUAGE','LANGUAGE', 'English'); 
 
  if SpeedButton7.Caption = 'Chinese' then 
  begin 
    SpeedButton7.Tag := 0; 
    SpeedButton7Click(Sender); 
  end 
  else 
  begin 
    SpeedButton7.Tag := 1; 
    SpeedButton7Click(Sender); 
  end; 
  // ИЎµГґ®їЪБР±н 
  CommList.Items.Clear; 
  for I := 1 to 15 do    // Iterate 
  begin 
    iComNum := I; 
    if OpenCom(False) then 
    begin 
      CommList.Items.Add(Format('COM%d',[I])); 
      if CommName=Format('COM%d',[I]) then OldCOM := CommList.Items.Count-1; 
      CloseCom; 
    end; 
  end;    // for 
 
  if OldCOM=-1 then 
    CommList.ItemIndex := CommList.Items.Count-1 
  else 
    CommList.ItemIndex := OldCOM; 
 
  Label8.Caption := ''; 
  Label6.Caption := ''; 
  Label7.Caption := ''; 
  Label9.Caption := ''; 
end; 
 
procedure TfrmMain.GetDisp; 
var 
  I, J, H : Integer; 
  Addr: DWord; 
  b:array of byte; 
  w:array of word absolute b; 
  Bitmap:  TBitmap; 
  Row   :  pWordArray;// from SysUtils 
begin 
  SetLength(b,DisplayWidth*2); 
  SetLength(w,DisplayWidth); 
  Bitmap := TBitmap.Create; 
  Bitmap.PixelFormat := pf16bit; 
  Bitmap.Width  := DisplayWidth; 
  Bitmap.Height := DisplayHeight; 
  BitBtn1.Enabled := false; 
  CheckBox1.Enabled := false; 
  //StatusBar1.Panels[MESSINFO].Text := 'ХэФЪЅШИЎЖБД»ДЪИЭЈ¬ЗлЙФµИ...'; 
  H := -2; 
  try 
    for I := 0 to DisplayHeight - 1 do    // Iterate 
    begin 
      if CheckBox1.Checked then 
        H := H+2 
      else H := I; 
      if H (DisplayHeight - 1) then 
        Addr := BufferAddress+H*DisplayWidth*2 
      else begin 
        H := -1; 
        continue; 
      end; 
      //Addr := BufferAddress+I*DisplayWidth*2; 
      if not BFCReadMem(Addr,DisplayWidth*2,b) then 
      begin 
        ShowErr(CopyErr); 
        Break; 
      end; 
      Row := Bitmap.Scanline[H]; 
      for J := 0 to DisplayWidth - 1 do    // Iterate 
      begin 
        Row[J] := w[J]; 
        Application.ProcessMessages; 
      end;    // for 
      ImageA.Picture.Graphic := Bitmap; 
      Application.ProcessMessages; 
    end;    // for 
  finally 
    Bitmap.Free; 
    BitBtn1.Enabled := true; 
    CheckBox1.Enabled := true; 
    //StatusBar1.Panels[MESSINFO].Text := 'ЅШИЎЖБД»ДЪИЭЈ¬ЦґРРНк±ПЈЎ'; 
  end; 
end; 
 
procedure TfrmMain.BitBtn1Click(Sender: TObject); 
var 
  bTime:TDateTime; 
  ms: Int64; 
  Image :TImage; 
  i:integer; 
begin 
  Label6.Caption := CapTime; 
  bTime := now; 
  GetDisp; 
  ms := MilliSecondsBetween(now, bTime); 
  Label6.Caption := Format(CapTime+' %5.3fs',[ms/1000]);//IntToStr(ms); 
  for I:=1 to 8 do 
  begin 
    Image := TImage(FindComponent('Image' + IntToStr(i))); 
    if Image.Picture.Graphic = nil then 
    begin 
      Image.Picture.Graphic := ImageA.Picture.Graphic; 
      Exit; 
    end; 
  end; 
end; 
 
procedure TfrmMain.Image1DragDrop(Sender, Source: TObject; X, Y: Integer); 
begin 
  (Sender as TImage).Picture.Graphic:=(Source as TImage).Picture.Graphic; 
end; 
 
procedure TfrmMain.Image1DragOver(Sender, Source: TObject; X, Y: Integer; 
  State: TDragState; var Accept: Boolean); 
begin 
  Accept:= True; 
end; 
 
procedure TfrmMain.BitBtn2Click(Sender: TObject); 
var 
  I: Integer; 
  Image:  TImage; 
  jpg : TJpegImage; 
  Ext : String; 
begin 
  //SavePictureDialog1.FileName := FormatDateTime('yy-MM-dd hh:mm:ss',now); 
  if not SavePictureDialog1.Execute then Exit; 
  Image := TImage.Create(self); 
  jpg := TJpegImage.Create; 
  //jpg.Performance := jpBestQuality ; 
  try 
    Image.Width := DisplayWidth*(RadioGroup1.ItemIndex+3)+16; 
    Image.Height := DisplayHeight*2+16; 
    for I := 1 to RadioGroup1.ItemIndex+3 do    // Iterate 
    begin 
      Image.Canvas.Draw((I-1)*DisplayWidth+6+I,6,TImage(FindComponent('Image'+IntToStr(I))).Picture.Graphic); 
    end;    // for 
    for I := 5 to RadioGroup1.ItemIndex+7 do    // Iterate 
    begin 
      Image.Canvas.Draw((I-5)*DisplayWidth+2+I,DisplayHeight+6,TImage(FindComponent('Image'+IntToStr(I))).Picture.Graphic); 
    end; 
    case SavePictureDialog1.FilterIndex of 
      1: begin 
           //SavePictureDialog1.DefaultExt := '.jpg'; 
           jpg.Assign( Image.Picture.Bitmap); 
           jpg.SaveToFile(SavePictureDialog1.FileName); 
         end; 
      2: begin 
           //SavePictureDialog1.DefaultExt := '.bmp'; 
           Image.Picture.SaveToFile(SavePictureDialog1.FileName); 
         end; 
    end; 
  finally 
    Image.Free; 
    jpg.Free; 
  end; 
end; 
 
procedure TfrmMain.N1Click(Sender: TObject); 
var 
  Image:  TImage; 
  jpg : TJpegImage; 
  Ext : String; 
begin 
  //SavePictureDialog1.FileName := FormatDateTime('yy-MM-dd hh:mm:ss',now); 
  Image:=TImage(FindComponent('Image'+Chr(PopupMenu1.Tag))); 
  if not SavePictureDialog1.Execute then Exit; 
  case SavePictureDialog1.FilterIndex of 
    1:  begin 
          jpg := TJpegImage.Create; 
          try 
            //SavePictureDialog1.DefaultExt := '.jpg'; 
            jpg.Assign( Image.Picture.Bitmap); 
            jpg.SaveToFile(SavePictureDialog1.FileName); 
          finally 
            jpg.Free; 
          end; 
        end; 
    2:  begin 
          //SavePictureDialog1.DefaultExt := '.bmp'; 
          Image.Picture.SaveToFile(SavePictureDialog1.FileName); 
        end; 
  end; 
end; 
 
procedure TfrmMain.ImageAMouseDown(Sender: TObject; Button: TMouseButton; 
  Shift: TShiftState; X, Y: Integer); 
begin 
  PopupMenu1.Tag := (Sender as TImage).Tag; 
end; 
 
procedure TfrmMain.SavePictureDialog1TypeChange(Sender: TObject); 
begin 
  case SavePictureDialog1.FilterIndex of 
    1: SavePictureDialog1.DefaultExt := '.jpg'; 
    2: SavePictureDialog1.DefaultExt := '.bmp'; 
  end; 
end; 
 
procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction); 
begin 
  Inifile.WriteString('LANGUAGE','LANGUAGE',SpeedButton7.Caption); 
  if {btnCommOpen.Caption = '¶ПїЄ'}BitBtn1.Enabled then 
  begin 
    BFC_SendAT('AT^SQWE=0'^M); 
    CloseCom; 
  end; 
  Inifile.Free; 
end; 
 
procedure TfrmMain.SpeedButton3Click(Sender: TObject); 
begin 
  Close; 
end; 
 
procedure TfrmMain.SpeedButton4Click(Sender: TObject); 
begin 
  AboutBox.Show; 
end; 
 
procedure TfrmMain.SpeedButton1Click(Sender: TObject); 
begin 
  MessageBox(handle,PChar(Tips),PChar(SpeedButton1.Hint),MB_ICONQUESTION	); 
end; 
 
procedure TfrmMain.SpeedButton2Click(Sender: TObject); 
var 
  i:integer; 
begin 
  // ИЎµГґ®їЪБР±н 
  CommList.Items.Clear; 
  for I := 1 to 30 do    // Iterate 
  begin 
    iComNum := I; 
    if OpenCom(False) then 
    begin 
      CommList.Items.Add(Format('COM%d',[I])); 
      CloseCom; 
    end; 
    Application.ProcessMessages; 
  end;    // for 
  CommList.ItemIndex := CommList.Items.Count-1; 
end; 
 
procedure TfrmMain.SpeedButton5Click(Sender: TObject); 
begin 
  frmTools := TfrmTools.Create(self); 
  frmTools.ShowModal; 
  frmTools.Free 
end; 
 
procedure TfrmMain.SpeedButton6Click(Sender: TObject); 
begin 
  PopupMenu1.Tag := 65; 
  N1Click(Sender); 
end; 
 
procedure TfrmMain.SpeedButton7Click(Sender: TObject); 
var 
  Image:TImage; 
  i:integer; 
begin 
  if SpeedButton7.Tag = 0 then 
  begin 
    frmMain.Caption := 'Siemens X65 Screen Capturer'; 
    Label3.Caption  := 'Siemens X65 Screen Capturer'; 
    Label4.Caption  := 'Siemens X65 Screen Capturer'; 
    SpeedButton4.Hint := 'About'; 
    SpeedButton3.Hint := 'Close'; 
    Label2.Caption    := 'Port:'; 
    SpeedButton2.Caption := 'Refresh'; 
    btnCommOpen.Caption := 'Connect'; 
    Label1.Caption    := 'Screen:'; 
    CheckBox1.Caption := 'Interleaved'; 
    BitBtn1.Caption := 'Capture!'; 
    SpeedButton6.Hint := 'Save Picture...'; 
    BitBtn2.Caption   := 'Save frames'; 
    RadioGroup1.Caption := 'Frames Format:'; 
    RadioGroup1.Items.Strings[0] := '3*2'; 
    RadioGroup1.Items.Strings[1] := '4*2'; 
    N1.Caption := 'Save Picture...'; 
    ImageA.Hint := 'You can drag the captured pic to a frame on the right'; 
 
    Product      := 'Product:'; 
    SW_Version   := 'SW-Version:'; 
    CurrentMode  := 'SecurityStatus:'; 
    CapTime      := 'Capture Time:'; 
    Scre         := 'Screen:'; 
    CopyErr      := 'Capture Error!'; 
    OpenErr      := 'Port Open Error!'; 
    Conn         := 'Connect'; 
    DisConn      := 'DisConn'; 
    ConnErr      := 'Get mobile info Error!'; 
    ConnSucc    := ' Connect succeed!'; 
    Tips         := 'You can drag the captured pic to a frame on the right.'#13#10+ 
                    'You can drag a pic from one frame to another.'#13#10+ 
                    'Click the right-button of your mouse on a pic,you can'#13#10'save each individually.'; 
    SpeedButton7.Caption := 'Chinese'; 
    SpeedButton1.Hint := 'Tips'; 
    for I:=1 to 8 do 
    begin 
      Image := TImage(FindComponent('Image' + IntToStr(i))); 
      Image.Hint := IntToStr(i)+'#,You can drag a pic from one frame to another'; 
    end; 
 
    SpeedButton7.Tag := 1; 
  end 
  else 
  begin 
    frmMain.Caption := 'ОчГЕЧУ X65 ЅШЖБ'; 
    Label3.Caption  := 'ОчГЕЧУ X65 ЅШЖБ'; 
    Label4.Caption  := 'ОчГЕЧУ X65 ЅШЖБ'; 
    SpeedButton4.Hint := '№ШУЪ'; 
    SpeedButton3.Hint := 'НЛіц'; 
    Label2.Caption    := '¶ЛїЪ:'; 
    SpeedButton2.Caption := 'ЛўРВ'; 
    btnCommOpen.Caption := 'Б¬ЅУ'; 
 
    Label1.Caption    := 'ЖБД»Јє'; 
    CheckBox1.Caption := 'ёфРРЙЁГи'; 
    BitBtn1.Caption := 'ЅШИЎЖБД»'; 
    SpeedButton6.Hint := '±ЈґжНјЖ¬...'; 
    BitBtn2.Caption   := '±ЈґжПаІб'; 
    RadioGroup1.Caption := '±ЈґжґуРЎ:'; 
    RadioGroup1.Items.Strings[0] := '3ЎБ2'; 
    RadioGroup1.Items.Strings[1] := '4ЎБ2'; 
    N1.Caption := '±ЈґжНјЖ¬'; 
    ImageA.Hint := 'ДгїЙТФЅ«НјЖ¬НПµЅУТ±ЯµДПаїтЦРЎЈ'; 
 
    Product      := 'РНєЕЈє'; 
    SW_Version   := '°ж±ѕЈє'; 
    CurrentMode  := 'ДЈКЅЈє'; 
    CapTime      := 'єДК±Јє'; 
    Scre         := 'ЖБД»Јє'; 
    CopyErr      := 'ЖБД»ЅШИЎК§°Ь!'; 
    OpenErr      := '¶ЛїЪґтїЄК§°Ь!'; 
    Conn         := 'Б¬ЅУ'; 
    ConnSucc     := ' Б¬ЅУіЙ№¦!'; 
    DisConn      := '¶ПїЄ'; 
    Tips         := 'ЎЎЎЎДгїЙУГКу±кЅ«Чу±ЯЅШИЎµДНјЖ¬НПµЅУТ±ЯµДПаїт'#13'ЦРЈ¬ТІїЙТФФЪПаїтЦР,Па»ҐЦ®јдАґ»ШЅшРРНП¶ЇЎЈ'#13#13'ЎЎЎЎДгїЙТФУГКу±кУТјьµг»чёчНјЖ¬Ј¬µҐёц±ЈґжЈ¬ТІ'#13'їЙТФЅ«И«ІїНјЖ¬±ЈґжОЄµҐёцОДјюЎЈ'; 
    SpeedButton7.Tag := 0; 
    ConnErr      := '»сИЎКЦ»ъРЕПўК§°Ь!'; 
    SpeedButton7.Caption := 'English'; 
    SpeedButton1.Hint := 'ІЩЧчМбКѕ'; 
    for I:=1 to 8 do 
    begin 
      Image := TImage(FindComponent('Image' + IntToStr(i))); 
      Image.Hint := IntToStr(i)+'#,ДгїЙЅ«НјЖ¬ФЪПаїтјдАґ»ШНП¶ЇЎЈ'; 
    end; 
  end; 
end; 
 
procedure TfrmMain.BitBtn1MouseDown(Sender: TObject; Button: TMouseButton; 
  Shift: TShiftState; X, Y: Integer); 
begin 
  if Shift=[ssCtrl, ssRight] then SpeedButton5.Visible := true; 
end; 
 
procedure TfrmMain.FormCreate(Sender: TObject); 
begin 
  Font.Assign(Screen.IconFont); 
end; 
 
end. 