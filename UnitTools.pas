unit UnitTools; 
 
interface 
 
uses 
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls,bfc,bfb, HexUtils, Buttons,CryptEEP, MD5; 
 
type 
  TfrmTools = class(TForm) 
    MemoInfo: TMemo; 
    GroupBox1: TGroupBox; 
    IMEI: TLabeledEdit; 
    ESN: TLabeledEdit; 
    HASH: TLabeledEdit; 
    SKEY: TLabeledEdit; 
    BOOTKEY: TLabeledEdit; 
    HWID: TLabeledEdit; 
    BitBtn1: TBitBtn; 
    BitBtn2: TBitBtn; 
    Button1: TButton; 
    procedure BitBtn1Click(Sender: TObject); 
    procedure BitBtn2Click(Sender: TObject); 
    procedure Button1Click(Sender: TObject); 
  private 
    { Private declarations } 
  public 
    { Public declarations } 
    dSKey : dword; 
    dESN : dword; 
    dMkey : array[0..5] of dword; 
    procedure ShowMess(Mess:String); 
    function GetMobileInfo:boolean; 
    function ReadESNAndHASH : DWord; 
    function CalkSkey(xesn,xskey:dword): boolean; 
    function ReadEepBlock(num,len: dword; var ver: byte; var buf: array of byte): boolean; 
  end; 
 
var 
  frmTools: TfrmTools; 
  sDevMan,sPhoneModel,sSoftWareVer,sLgVer,sIMEI : string; 
  bHASH : array[0..15] of Byte; 
  bBootKey : array[0..15] of Byte; 
 
implementation 
 
{$R *.dfm} 
procedure TfrmTools.ShowMess(Mess:String); 
begin 
  MemoInfo.Lines.Add(Mess); 
end; 
 
function TfrmTools.GetMobileInfo:boolean; 
var 
u : word; 
begin 
  Result:=True; 
 
  sDevMan:=BFC_GetDevMan; //Ж·ЕЖ 
  if BFC_Error<>ERR_NO then 
  begin 
    ShowMess('>>УлКЦ»ъБЄ»ъК§°ЬЈЎ'); 
    Result:=false; 
    Exit; 
  end; 
 
  if BFC_GetCurentUbat(u) then 
  begin 
    if u<3695 then ShowMess('>>ДгµДКЦ»ъµзіШРиТЄідµзЈЎ'); 
    ShowMess('µзіШµзС№Јє '+ IntToStr(u)+' mV.'); 
  end; 
   
  ShowMess('°ІИ«ДЈКЅЈє '+BFC_GetSecurityMode+''); 
 
  sPhoneModel:=BFC_GetPhoneModel; // РНєЕM6C 
  sSoftWareVer:=BFC_GetSoftWareVer; // V50 
  sLgVer:=BFC_GetLgVer;  // УпСФ°ж±ѕ 
  if BFC_Error=ERR_NO then 
  begin 
    ShowMess('РНєЕЎЎЎЎЈє '+sDevMan+' '+sPhoneModel+' V'+sSoftWareVer+' '+sLgVer); 
  end; 
 
  sIMEI:=BFC_GetIMEI;     //  IMEI 
  if BFC_Error<>ERR_NO then 
  begin 
    sIMEI:='?'; 
    result:=False; 
  end; 
  ShowMess('IMEIЎЎЎЎЈє '+sIMEI); 
  IMEI.Text := sIMEI; 
 
  HWID.Text := IntToStr(BFC_GetHardwareIdentification); // HWID 
  if BFC_Error=ERR_NO then 
    ShowMess('HWIDЎЎЎЎЈє '+HWID.Text) 
  else 
    Result:=False; 
 
 
end; 
 
function TfrmTools.ReadESNAndHASH : dword; 
var 
  xESN : Dword; 
begin 
  if (bSecyrMode = $12) or (bSecyrMode = $11) then 
  begin 
    if BFC_GetESN(xESN) then 
    begin 
      ShowMess('ESN ЎЎЎЎЈє '+IntToHex(xESN,8)); 
      ESN.Text:=IntToHex(xESN,8); 
      if BFCReadMem($A0000238,16,bHASH) then 
      begin 
        Hash.Text:=BufToHexStr(@bHASH,16); 
        ShowMess('HASHЎЎЎЎЈє '+Hash.Text); 
      end 
      else 
      begin 
        ShowMess('>>HASH ¶БИЎК§°Ь!'); 
        Hash.Text:='?'; 
      end; 
    end 
    else 
    begin 
      ShowMess('>>ESNЎЎ¶БИЎК§°Ь!'); 
      ESN.Text:='?'; 
    end; 
  end // if BFC mode On. 
  else 
  begin  // ·ЗЎЎFactroyMode ДЈКЅ 
    if BFC_to_BFB then 
    begin 
      if not BFB_Ping then if not BFB_Ping then BFB_Ping; 
      if BFB_Error=BFB_OK then 
      begin 
        if BFB_GetESN(xESN) then 
        begin 
          ShowMess('ESN ЎЎЎЎЈє '+IntToHex(xESN,8)); 
          ESN.Text:=IntToHex(xESN,8); 
          if BFBReadMem($A0000238,16,bHASH) then 
          begin 
            Hash.Text:=BufToHexStr(@bHASH,16); 
            ShowMess('HASHЎЎЎЎЈє '+Hash.Text); 
          end 
          else 
          begin   //ЎЎИЎЎЎHASHЎЎіцґн 
            ShowMess('>>HASH ¶БИЎК§°Ь!'); 
            Hash.Text:='?'; 
          end; 
        end 
        else 
        begin  // ИЎЎЎESNЈє іцґн 
          ShowMess('>>ESNЎЎ¶БИЎК§°Ь!'); 
          ESN.Text:='?'; 
        end; 
      end //if no BFB_Error 
      else 
      begin   // BFB ДЈКЅОЮПмУ¦ 
        ShowMess('>>BFB ДЈКЅОЮПмУ¦!'); 
      end; 
    end // BFC_to_BFB 
    else 
    begin  // BFB ДЈКЅЗР»»іцґн 
      ShowMess('>>BFB ДЈКЅЗР»»іцґн'); 
    end; // BFC_to_BFB 
    BFB_to_BFC; 
  end; // if BFB mode On. 
  Result:=xESN; 
  ShowMess(''); 
end; 
 
function TfrmTools.ReadEepBlock(num,len: dword; var ver: byte; var buf: array of byte): boolean; 
var 
xlen : dword; 
begin 
  result:=False; 
  ShowMess('¶БИЎEEPїйЈє'+IntToStr(num)+'...'); 
  if BFC_EE_Get_Block_Info(num,xlen,ver) then 
  begin 
    if (len=xlen) then 
    begin 
      if BFC_EE_Read_Block(num,0,len,buf) then 
      begin 
        result:=True; 
      end 
      else 
      begin 
        ShowMess('EEPїйЈє'+IntToStr(num)+'¶БИЎК§°Ь!'); 
      end; 
    end 
    else 
    begin 
      ShowMess('EEPїйЈє'+IntToStr(num)+'і¤¶ИІ»¶Ф!'); 
      ShowMess('¶БИЎі¤¶ИОЄЈє'+IntToStr(len)+' ЧЦЅЪ! ХэИ·і¤¶ИУ¦ОЄЈє '+IntToStr(xlen)+' ЧЦЅЪ.'); 
    end; 
  end 
  else 
  begin 
    ShowMess('¶БИЎEEPїйЈє'+IntToStr(num)+'ЎЎРЕПўК§°Ь!'); 
  end; 
end; 
 
function TfrmTools.CalkSkey(xesn,xskey:dword): boolean; 
var 
i,sss : integer; 
buffer : array[0..63] of byte; 
begin 
  sss:=0; 
  repeat 
  begin 
    buffer[16]:=$80; 
    FillChar(buffer[17], 64-17, 0); 
    buffer[56]:=$80; 
    Dword((@buffer[0])^):=xesn; 
    Dword((@buffer[4])^):=xskey; 
    for i:=0 to 7 do buffer[i+8]:=buffer[i] xor buffer[i+3]; 
    MD5Init; 
    MD5Transform(@buffer); 
    Dword((@buffer[0])^):=MD5buf[0]; 
    Dword((@buffer[4])^):=MD5buf[1]; 
    Dword((@buffer[8])^):=MD5buf[2]; 
    Dword((@buffer[12])^):=MD5buf[3]; 
    MD5Init; 
    MD5Transform(@buffer); 
    if ((Dword((@bHASH[0])^)=MD5buf[0]) 
    and (Dword((@bHASH[4])^)=MD5buf[1]) 
    and (Dword((@bHASH[8])^)=MD5buf[2]) 
    and (Dword((@bHASH[12])^)=MD5buf[3])) then 
    begin 
      Dword((@buffer[0])^):=xesn; 
      Dword((@buffer[4])^):=xskey; 
      for i:=0 to 7 do buffer[i+8]:=buffer[i] xor buffer[i+3]; 
      MD5Init; 
      MD5Transform(@buffer); 
      Move(MD5buf,bBootKey,16); 
      dSKey:=xskey; 
      result:=True; 
      exit; 
    end 
    else 
    begin 
      inc(xskey); 
      inc(sss); 
      if sss>1000000 then 
      begin 
        sss:=0; 
      end; 
    end; 
  end 
  until (xskey=100000000) or (xskey=0); 
  result:=False; 
end; 
 
procedure TfrmTools.BitBtn1Click(Sender: TObject); 
var 
  ver : byte; 
  xESN : Dword; 
  i:integer; 
begin 
  BitBtn1.Enabled := false; 
  try 
  GetMobileInfo; 
  //dESN := ReadESNAndHASH; 
  if dESN=0 then 
  begin 
    BFC_GetESN(xESN); 
    ShowMess('ESN ЎЎЎЎЈє '+IntToHex(xESN,8)); 
    ESN.Text:=IntToHex(xESN,8); 
    dESN := xESN; 
    BFCReadMem($A0000238,16,bHASH); 
    Hash.Text:=BufToHexStr(@bHASH,16); 
    ShowMess('HASHЎЎЎЎЈє '+Hash.Text); 
  end; 
  //ver := Ord('0'); 
  //dESN :=0; 
  ReadEepBlock(52,SizeOf(EEP0052),ver,EEP0052); 
  ShowMess('ґУКЦ»ъ52їй¶БИЎµДBOOTKEY Јє'#13#10+BufToHexStr(@EEP0052,16)); 
   
  ShowMess(#13#10'>>јЖЛгSKEYЎўBOOTKEY(±ШРиТЄУРESN HASH)'#13#10'јЖЛгК±јдТЄК®јёГлІ»µИ,јЖЛгЦРЎЎ...'); 
  Application.ProcessMessages; 
  CalkSkey(dESN,0); 
  ShowMess('јЖЛгіцµДSKEYЎЎЎЎЈє ' +IntToStr(dSKey)); 
  SKEY.Text := IntToStr(dSKey); 
  ShowMess('јЖЛгіцµДBOOTKEY Јє ' +BufToHexStr(@bBootKey,16)); 
  BOOTKEY.Text := BufToHexStr(@bBootKey,16); 
 
  Create512x(sImei,dESN,dSkey,dMkey); 
  ShowMess(#13#10'ТФПВКЗНЁ№эјЖЛгµГµЅµД512XїйµДДЪИЭЈє'); 
  ShowMess('5121 : '+BufToHexStr(@EEP5121,SizeOf(EEP5121))); 
  ShowMess('5122 : '+BufToHexStr(@EEP5122,SizeOf(EEP5122))); 
  ShowMess('5123 : '+BufToHexStr(@EEP5123,SizeOf(EEP5123))); 
 
  //ShowMess(''); 
  for i:=0 to SizeOf(EEP5121) do EEP5121[i] := 0; 
  for i:=0 to SizeOf(EEP5122) do EEP5122[i] := 0; 
  for i:=0 to SizeOf(EEP5123) do EEP5123[i] := 0; 
 
  ShowMess(#13#10'ТФПВКЗґУКЦ»ъЦР¶БИЎµД512XїйµДДЪИЭЈє'); 
  ReadEepBlock(5121,SizeOf(EEP5121),ver,EEP5121); 
  ShowMess('5121 : '+BufToHexStr(@EEP5121,SizeOf(EEP5121))); 
 
  ReadEepBlock(5122,SizeOf(EEP5122),ver,EEP5122); 
  ShowMess('5122 : '+BufToHexStr(@EEP5122,SizeOf(EEP5122))); 
 
  ReadEepBlock(5123,SizeOf(EEP5123),ver,EEP5123); 
  ShowMess('5123 : '+BufToHexStr(@EEP5123,SizeOf(EEP5123))); 
 
  ShowMess(#13#10'*** END ***'); 
  finally 
    BitBtn1.Enabled := true; 
  end; 
end; 
 
procedure TfrmTools.BitBtn2Click(Sender: TObject); 
begin 
  Close; 
end; 
 
procedure TfrmTools.Button1Click(Sender: TObject); 
var 
  xESN : Dword; 
begin 
  BFC_GetESN(xESN); 
  ShowMess('ESN ЎЎЎЎЈє '+IntToHex(xESN,8)); 
  ESN.Text:=IntToHex(xESN,8); 
 
  BFCReadMem($A0000238,16,bHASH); 
  Hash.Text:=BufToHexStr(@bHASH,16); 
  ShowMess('HASHЎЎЎЎЈє '+Hash.Text); 
end; 
 
end. 