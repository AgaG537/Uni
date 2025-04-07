with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
with Random_Seeds; use Random_Seeds;
with Ada.Real_Time; use Ada.Real_Time;

procedure Travelers_modified_2 is

  Nr_Of_Travelers : constant Integer := 15;
  Min_Steps : constant Integer := 10;
  Max_Steps : constant Integer := 100;
  Min_Delay : constant Duration := 0.01;
  Max_Delay : constant Duration := 0.05;
  Board_Width  : constant Integer := 15;
  Board_Height : constant Integer := 15;

  Start_Time : Time := Clock;
  Seeds : Seed_Array_Type(1 .. Nr_Of_Travelers) := Make_Seeds(Nr_Of_Travelers);

  type Position_Type is record
    X, Y : Integer range 0 .. Board_Width - 1;
  end record;

  protected type Cell is
    procedure Try_Acquire(Success : out Boolean);
    entry Acquire(Success : out Boolean);
    procedure Release;
  private
    Occupied : Boolean := False;
  end Cell;

  protected body Cell is
    procedure Try_Acquire(Success : out Boolean) is
    begin
      if not Occupied then
        Occupied := True;
        Success := True;
      else
        Success := False;
      end if;
    end Try_Acquire;

    entry Acquire(Success : out Boolean) when not Occupied is
    begin
      Occupied := True;
      Success := True;
    end Acquire;

    procedure Release is
    begin
      Occupied := False;
    end Release;
  end Cell;

  Board : array (0 .. Board_Width - 1, 0 .. Board_Height - 1) of Cell;

  type Trace_Type is record
    Time_Stamp : Duration;
    Id         : Integer;
    Position   : Position_Type;
    Symbol     : Character;
  end record;

  type Trace_Array_Type is array (0 .. Max_Steps) of Trace_Type;

  type Traces_Sequence_Type is record
    Last : Integer := -1;
    Trace_Array : Trace_Array_Type;
  end record;

  procedure Print_Trace(Trace : Trace_Type) is
    Symbol : String := ( ' ', Trace.Symbol );
  begin
    Put_Line(Duration'Image(Trace.Time_Stamp) & " " &
             Integer'Image(Trace.Id) & " " &
             Integer'Image(Trace.Position.X) & " " &
             Integer'Image(Trace.Position.Y) & " " &
             Symbol);
  end Print_Trace;

  procedure Print_Traces(Traces : Traces_Sequence_Type) is
  begin
    for I in 0 .. Traces.Last loop
      Print_Trace(Traces.Trace_Array(I));
    end loop;
  end Print_Traces;

  task Printer is
    entry Report(Traces : Traces_Sequence_Type);
  end Printer;

  task body Printer is
  begin
    for I in 1 .. Nr_Of_Travelers loop
      accept Report(Traces : Traces_Sequence_Type) do
        Print_Traces(Traces);
      end Report;
    end loop;
  end Printer;

  type Traveler_Type is record
    Id      : Integer;
    Symbol  : Character;
    Position: Position_Type;
  end record;

  task type Traveler_Task_Type is
    entry Init(Id: Integer; Seed: Integer; Symbol: Character);
    entry Start;
  end Traveler_Task_Type;

  task body Traveler_Task_Type is
    G        : Generator;
    Traveler : Traveler_Type;
    Time_Stamp : Duration;
    Nr_Of_Steps : Integer;
    Traces     : Traces_Sequence_Type;
    Direction  : Integer;

    procedure Store_Trace is
    begin
      Traces.Last := Traces.Last + 1;
      Traces.Trace_Array(Traces.Last) := (
        Time_Stamp => To_Duration(Clock - Start_Time),
        Id         => Traveler.Id,
        Position   => Traveler.Position,
        Symbol     => Traveler.Symbol
      );
    end Store_Trace;

  begin
    accept Init(Id: Integer; Seed: Integer; Symbol: Character) do
      Reset(G, Seed);
      Traveler.Id := Id;
      Traveler.Symbol := Symbol;

      declare
        Success : Boolean;
        Pos : Position_Type;
      begin
        Pos.X := Id;
        Pos.Y := Id;
        Board(Pos.X, Pos.Y).Try_Acquire(Success);
        Traveler.Position := Pos;
      end;

      Store_Trace;
      Nr_Of_Steps := Min_Steps + Integer(Float(Max_Steps - Min_Steps) * Random(G));

      if Traveler.Id mod 2 = 0 then
        Direction := Integer(Float'Floor(2.0 * Random(G)));
      else
        Direction := 2 + Integer(Float'Floor(2.0 * Random(G)));
      end if;
    end Init;

    accept Start do
      null;
    end Start;

    Step_Loop:
    for Step in 1 .. Nr_Of_Steps loop
      delay Min_Delay + (Max_Delay - Min_Delay) * Duration(Random(G));
      declare
        New_Pos : Position_Type;
        Success : Boolean := False;
      begin
        New_Pos := Traveler.Position;

        case Direction is
          when 0 => New_Pos.Y := (New_Pos.Y + Board_Height - 1) mod Board_Height;
          when 1 => New_Pos.Y := (New_Pos.Y + 1) mod Board_Height;
          when 2 => New_Pos.X := (New_Pos.X + Board_Width - 1) mod Board_Width;
          when 3 => New_Pos.X := (New_Pos.X + 1) mod Board_Width;
          when others => null;
        end case;

        select
          Board(New_Pos.X, New_Pos.Y).Acquire(Success);
          if Success then
            Board(Traveler.Position.X, Traveler.Position.Y).Release;
            Traveler.Position := New_Pos;
          end if;
        or
          delay Max_Delay;
          Traveler.Symbol := Character'Val(Character'Pos(Traveler.Symbol) + 32);
          Store_Trace;
          exit Step_Loop;
        end select;
        Store_Trace;
      end;
    end loop Step_Loop;

    Printer.Report(Traces);
  end Traveler_Task_Type;

  Travel_Tasks : array (0 .. Nr_Of_Travelers - 1) of Traveler_Task_Type;
  Symbol : Character := 'A';

begin
  Put_Line("-1" & Integer'Image(Nr_Of_Travelers) & " " &
           Integer'Image(Board_Width) & " " &
           Integer'Image(Board_Height));

  for I in Travel_Tasks'Range loop
    Travel_Tasks(I).Init(I, Seeds(I + 1), Symbol);
    Symbol := Character'Succ(Symbol);
  end loop;

  for I in Travel_Tasks'Range loop
    Travel_Tasks(I).Start;
  end loop;
end Travelers_modified_2;