unit UnitAbout; 
 
interface 
 
uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Shellapi; 
 
type 
  TAboutBox = class(TForm) 
    Panel1: TPanel; 
    ProgramIcon: TImage; 
    ProductName: TLabel; 
    Version: TLabel; 
    Copyright: TLabel; 
    OKButton: TButton; 
    Memo1: TMemo; 
    Label1: TLabel; 
    Label2: TLabel; 
    Label3: TLabel; 
    Label4: TLabel; 
    Label5: TLabel; 
    Label6: TLabel; 
    Label7: TLabel; 
    Label8: TLabel; 
    procedure OKButtonClick(Sender: TObject); 
    procedure Label4Click(Sender: TObject); 
    procedure Label4MouseMove(Sender: TObject; Shift: TShiftState; X, 
      Y: Integer); 
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, 
      Y: Integer); 
  private 
    { Private declarations } 
  public 
    { Public declarations } 
  end; 
 
var 
  AboutBox: TAboutBox; 
 
implementation 
 
{$R *.dfm} 
 
procedure TAboutBox.OKButtonClick(Sender: TObject); 
begin 
  Close; 
end; 
 
procedure TAboutBox.Label4Click(Sender: TObject); 
begin 
  ShellExecute(handle,'open',PChar((Sender as TLabel).Caption), '','',SW_RESTORE); 
end; 
 
procedure TAboutBox.Label4MouseMove(Sender: TObject; Shift: TShiftState; X, 
  Y: Integer); 
begin 
  (Sender as TLabel).Font.Style :=[fsUnderline]; 
end; 
 
procedure TAboutBox.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, 
  Y: Integer); 
begin 
  Label4.Font.Style :=[]; 
  Label5.Font.Style :=[]; 
  Label6.Font.Style :=[]; 
end; 
 
end. 
 