//Business application is forbidden. 
//Punishment - unavoidable crack and propagation on everything inet. 
unit BFB; 
 
interface 
uses Windows,SysUtils,Crc16,ComPort; 
 
const 
MAXBFBDATA = 32; 
 
  BFB_OK            =0; 
  ERR_BFB           =-1; 
  ERR_BFB_PAR       =-2; 
  ERR_BFB_IN_CRC16  =-3; 
  ERR_BFB_RD_CMD    =-4; 
  ERR_BFB_INIT_HID  =-5; 
  ERR_BFB_DATA      =-6; 
  ERR_BFB_INFO      =-7; 
  ERR_BFB_IO_RS     =-15; 
 
type 
// BFB Head 
 sbfbhead = packed record 
   id   : BYTE; // id 
   len  : BYTE; // size data 
   chk  : BYTE; // =id^len 
 end; 
 sbfbdata = packed record case byte of 
   0: ( cmdb : Byte; 
        datab : array[0..MAXBFBDATA] of Byte ; ); 
   1: ( cmdw : Word; 
        dataw : array[0..(MAXBFBDATA shr 1)] of Word ; ); 
   2: ( cmdd : Dword; 
        datad : array[0..(MAXBFBDATA shr 2)] of Dword ; ); 
 end; 
 
// BFC block 
 sbfb = packed record case byte of 
   0: ( 
      head : sbfbhead; 
      data : array[0..MAXBFBDATA+1] of Byte ; 
      size : integer; ); 
   1: ( 
      b  : array[0..MAXBFBDATA+1+sizeof(sbfbhead)] of byte; ); 
   2: ( 
      headx : sbfbhead; 
      code : sbfbdata; ); 
 end; 
 
 sbfbrdmem = packed record case byte of 
   0: ( subcmd : Byte; 
        addr   : dword; 
        len    : word; ); 
   1: ( b  : array[0..7] of byte; ); 
 end; 
 
 sbfbcomspd = packed record 
    spd : integer; 
    code : string; 
 end; 
 
var 
 bfbcomspd : array[0..16] of sbfbcomspd = ( 
        ( spd: 4800; code: #$34+#$38+#$30+#$30+#$3F+#$87+#$CF; ), 
        ( spd: 9600; code: #$39+#$36+#$30+#$30+#$3F+#$49+#$CF; ), 
        ( spd: 14400; code: #$31+#$34+#$34+#$30+#$30+#$CE+#$8B+#$CF ), 
        ( spd: 19200; code: #$31+#$39+#$32+#$30+#$30+#$CE+#$4D+#$CF; ), 
        ( spd: 23040; code: #$32+#$33+#$30+#$34+#$30+#$CD+#$CF+#$8F; ), 
        ( spd: 28800; code: #$32+#$38+#$38+#$30+#$30+#$CD+#$47+#$CF; ), 
        ( spd: 38400; code: #$33+#$38+#$34+#$30+#$30+#$CC+#$4B+#$CF; ), 
        ( spd: 57600; code: #$35+#$37+#$36+#$30+#$30+#$CA+#$89+#$CF; ), 
        ( spd: 100000; code: #$31+#$30+#$30+#$30+#$30+#$30+#$0C+#$90+#$2B; ), 
        ( spd: 115200; code: #$31+#$31+#$35+#$32+#$30+#$30+#$0D+#$D2+#$2B; ), 
        ( spd: 200000; code: #$32+#$30+#$30+#$30+#$30+#$30+#$0C+#$90+#$2B; ), 
        ( spd: 203000; code: #$32+#$30+#$33+#$30+#$30+#$30+#$0C+#$90+#$2B; ), 
        ( spd: 230000; code: #$32+#$33+#$30+#$30+#$30+#$30+#$0F+#$90+#$2B; ), 
        ( spd: 400000; code: #$34+#$30+#$30+#$30+#$30+#$30+#$4C+#$D0+#$2B; ), 
        ( spd: 406000; code: #$34+#$30+#$36+#$30+#$30+#$30+#$4C+#$D0+#$2B; ), 
        ( spd: 460000; code: #$34+#$36+#$30+#$30+#$30+#$30+#$4A+#$90+#$2B; ), 
        ( spd: 0; code: ''; )); 
 
 ibfb : sbfb; 
 obfb : sbfb; 
 BFB_Error : integer=BFB_OK; 
 
 
function BFB_Ping : boolean; 
function BFB_SimSim : boolean; 
function BFB_SendAT(S: String): boolean; 
function BFB_PhoneModel: PChar; 
function BFB_GetImei: PChar; 
function BFB_GetManufactyre: PChar; 
function BFB_PhoneFW: byte; // if $ff -> Error 
function BFB_FlagStatus : Byte; // if $ff -> Error 
function SetSpeedBFB(Baud:integer): boolean; 
function BFB_GetESN(var ESN: Dword): boolean; 
function BFB_to_BFC : boolean; 
function BFBReadMem(Addr: Dword; Len : Word; var Buffer :  Array of Byte): boolean; 
 
//function BFBReadMem(addr: dword; len: word); 
 
implementation 
 
function SendBFB(id : Byte; buf : array of byte; len : Byte) : integer; 
begin 
   result:=ERR_BFB_PAR; 
   if (len>MAXBFBDATA) then exit; 
   obfb.head.id:=id; 
   obfb.head.len:=len; 
   obfb.head.chk:=len xor id; 
   obfb.size:=len+sizeof(sbfbhead); 
   if len<>0 then Move(buf,obfb.data,len); 
   result:=ERR_BFB_IO_RS; 
   if not WriteCom(@obfb.b,obfb.size) then exit; 
   result:=BFB_OK; 
end; 
 
function ReadBFB : integer; 
begin 
  ibfb.size:=0; 
  ibfb.head.len:=0; 
  result:=ERR_BFB_IO_RS; 
  if not ReadCom(@ibfb.b,sizeof(sbfbhead)) then exit; 
  repeat begin 
    if ((ibfb.head.id=obfb.head.id) 
    and (ibfb.head.len=MAXBFBDATA) 
    and (ibfb.head.chk=(ibfb.head.id xor ibfb.head.len))) then begin 
     if ibfb.head.len<>0 then 
       if not ReadCom(@ibfb.data,ibfb.head.len) then exit 
       else result:=BFB_OK 
     else result:=BFB_OK; 
     if result=BFB_OK then exit; 
    end; 
    ibfb.b[0]:=ibfb.b[1]; 
    ibfb.b[1]:=ibfb.b[2]; 
    if not ReadCom(@ibfb.b[2],1) then exit; 
  end 
  until true; 
end; 
 
function CmdBFB(id : Byte; buf : array of byte; len : Byte) : integer; 
begin 
  BFB_Error:=SendBFB(id, buf, len); 
  if BFB_Error=BFB_OK then 
  begin 
    BFB_Error:=ReadBFB; 
    if BFB_Error=BFB_OK then 
    begin 
      if ((ibfb.head.len=0) or (ibfb.code.cmdb<>obfb.code.cmdb)) then 
        BFB_Error:=ERR_BFB_RD_CMD; 
    end; 
  end; 
   result:=BFB_Error; 
end; 
 
function BFB_Ping : boolean; 
begin 
  result:=False; 
  if CmdBFB($02,[$14],1)<>BFB_OK then exit; 
  if((ibfb.head.len<>2) or (ibfb.code.datab[0]<>$AA)) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  result:=True; 
end; 
 
function BFB_SimSim : boolean; 
begin 
  result:=False; 
  if CmdBFB($05,[$39],1)<>BFB_OK then exit; 
  if ibfb.head.len<>1 then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  result:=True; 
end; 
 
function BFB_SendAT(S: String): boolean; 
var 
 i: integer; 
 Buf: array [0..255] of Byte; 
begin 
  Result:=False; 
  i:=Length(S); 
  if i>255 then begin 
    BFB_Error:=ERR_BFB_PAR; 
    exit; 
  end; 
  Move(S[1],Buf,i); 
  if SendBFB($06,Buf,i)<>BFB_OK then exit; 
  result:=True; 
end; 
 
function BFB_PhoneModel: PChar; 
begin 
  result:=Nil; 
  if CmdBFB($0E,[$07],1)<>BFB_OK then exit; 
  if (ibfb.head.len<3) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  ibfb.code.datab[ibfb.head.len-1]:=0; 
  Result:=@ibfb.code.datab; 
end; 
 
function BFB_PhoneFW: byte; // if $ff -> Error 
begin 
  result:=$ff; 
  if CmdBFB($0E,[$03],1)<>BFB_OK then exit; 
  if (ibfb.head.len<>2) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  Result:=ibfb.code.datab[0]; 
end; 
 
function BFB_GetImei: PChar; 
begin 
  result:=Nil; 
  if CmdBFB($0E,[$0A],1)<>BFB_OK then exit; 
  if (ibfb.head.len<$11) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  ibfb.code.datab[ibfb.head.len-1]:=0; 
  Result:=@ibfb.code.datab; 
end; 
 
function BFB_GetManufactyre: PChar; 
begin 
  result:=Nil; 
  if CmdBFB($0E,[$09],1)<>BFB_OK then exit; 
  if (ibfb.head.len<$11) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  ibfb.code.datab[ibfb.head.len-1]:=0; 
  Result:=@ibfb.code.datab; 
end; 
 
function BFB_SecurityMode : String; 
begin 
  result:='Error'; 
  if CmdBFB($0E,[$0C],1)<>BFB_OK then exit; 
  if (ibfb.head.len<>$2) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  ibfb.code.datab[ibfb.head.len-1]:=0; 
  Case ibfb.code.datab[0] of 
   00: Result:='Repair'; 
//   01: Result:='Factory'; 
   02: Result:='Factory'; 
   03: Result:='Customer'; 
   else 
    Result:='Unknown('+IntToHex(ibfb.code.datab[0],2)+')'; 
  end; 
end; 
 
function BFB_FlagStatus : Byte; // if $ff -> Error 
begin 
  result:=$ff; 
  if CmdBFB($0E,[$05],1)<>BFB_OK then exit; 
  if (ibfb.head.len<>2) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  Result:=ibfb.code.datab[0]; 
end; 
 
function BFB_to_BFC : boolean; 
begin 
  if SendBFB($01,[$04],1)<>BFB_OK then result := False 
  else begin 
   ReadBFB; 
   result := True; 
  end; 
//  if result=BFB_OK then 
end; 
 
function SetSpeedBFB(Baud:integer): boolean; 
var 
 save_baud,i,z : integer; 
 Buf: array [0..32] of Byte; 
begin 
  result:=False; 
  i:=0; 
  while bfbcomspd[i].spd <> Baud do begin 
   inc(i); 
   if (bfbcomspd[i].spd=0) then exit; 
  end; 
  save_baud:=dcb.BaudRate; 
  if Baud>115200 then begin 
    if not ChangeComSpeed(Baud) then exit; 
    if not ChangeComSpeed(save_baud) then exit; 
  end; 
  if CmdBFB($01,[$A1],1)<>BFB_OK then exit; 
  Buf[0]:=$C0; 
  z:=Length(bfbcomspd[i].code); 
  Move(bfbcomspd[i].code[1],Buf[1],z); 
  if CmdBFB($01,buf,z+1)<>ERR_BFB_RD_CMD then exit; 
  if ((ibfb.head.len=1) or (ibfb.code.cmdb=$CC)) then begin 
    if not ChangeComSpeed(Baud) then exit; 
    sleep(50); 
    result:=BFB_Ping; 
  end; 
end; 
 
function BFBReadMem(Addr: Dword; Len : Word; var Buffer : Array of Byte): boolean; 
var 
bfbrdmem: sbfbrdmem; 
begin 
   result:=False; 
   if Len>31 then begin 
    BFB_Error:=ERR_BFB_PAR; 
    exit; 
   end; 
   bfbrdmem.subcmd:=$02; 
   bfbrdmem.addr:=Addr; 
   bfbrdmem.len:=Len; 
   if CmdBFB($02,bfbrdmem.b,7)<>BFB_OK then exit; 
   if (ibfb.head.len<>len+1) then begin 
    BFB_Error:=ERR_BFB_RD_CMD; 
    exit; 
   end; 
   BFB_Error:=BFB_OK; 
   Move(ibfb.code.datab,Buffer,len); 
   result:=True; 
end; 
 
function BFB_GetESN(var ESN: Dword): boolean; 
begin 
//  ESN:=$FFFFFFFF; 
  result:=False; 
  if CmdBFB($05,[$23],1)<>BFB_OK then exit; 
  if (ibfb.head.len<>5) then begin 
   BFB_Error:=ERR_BFB_RD_CMD; 
   exit; 
  end; 
  ESN:=Dword((@ibfb.code.datab)^); 
  result:=True; 
end; 
 
 
end.