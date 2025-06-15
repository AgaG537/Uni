package main

import (
	"fmt"
	"math/rand"
	"sync"
	"sync/atomic"
	"time"
)

const (
	Nr_Of_Processes int = 15

	Min_Steps int = 50
	Max_Steps int = 100

	Min_Delay time.Duration = 10000000
	Max_Delay time.Duration = 50000000
)

type Process_State int

const (
	LocalSection Process_State = iota
	EntryProtocol1
	EntryProtocol2
	EntryProtocol3
	EntryProtocol4
	CriticalSection
	ExitProtocol
)

const Board_Width int = Nr_Of_Processes
const Board_Height int = int(ExitProtocol) + 1

var Start_Time = time.Now()


type Position_Type struct {
	X, Y int
}

type Trace_Type struct {
	Time_Stamp time.Duration
	Id         int
	Position   Position_Type
	Symbol     rune
}

type Trace_Array_type [Max_Steps + 1]Trace_Type

type Traces_Sequence_Type struct {
	Last        int
	Trace_Array Trace_Array_type
}

func Print_Trace(Trace Trace_Type) {
	fmt.Printf(
		"%.6f %d %d %d %c\n",
		Trace.Time_Stamp.Seconds(),
		Trace.Id,
		Trace.Position.X,
		Trace.Position.Y,
		Trace.Symbol,
	)
}

func Print_Traces(Traces Traces_Sequence_Type) {
	for i := 0; i <= Traces.Last; i++ {
		Print_Trace(Traces.Trace_Array[i])
	}
}

func Printer(printerChan chan Traces_Sequence_Type, Wait_for_Finish *sync.WaitGroup) {
	defer Wait_for_Finish.Done()
	for i := 0; i < Nr_Of_Processes; i++ {
		report := <-printerChan
		Print_Traces(report)
	}

	fmt.Printf("-1 %d %d %d ", Nr_Of_Processes, Board_Width, Board_Height)

	fmt.Printf("LocalSection;Entry_Protocol_1;Entry_Protocol_2;Entry_Protocol_3;Entry_Protocol_4;CriticalSection;ExitProtocol;EXTRA")

}

var Flag = [Nr_Of_Processes]int32{0}

func contains(value int32, allowed []int32) bool {
	for _, a := range allowed {
		if value == a {
			return true
		}
	}
	return false
}

func AllFlagsIn(firstIndex, lastIndex int, allowed []int32) bool {
	if lastIndex <= firstIndex {
		return true
	}
	for i := firstIndex; i < lastIndex; i++ {
		v := atomic.LoadInt32(&Flag[i])
		if !contains(v, allowed) {
			return false
		}
	}
	return true
}

func WaitAllFlagsIn(firstIndex, lastIndex int, allowed []int32) {
	for {
		if AllFlagsIn(firstIndex, lastIndex, allowed) {
			return
		}
		time.Sleep(10 * time.Millisecond)
	}
}

func AnyFlagIn(allowed []int32) bool {
	for i := 0; i < Nr_Of_Processes; i++ {
		v := atomic.LoadInt32(&Flag[i])
		if contains(v, allowed) {
			return true
		}
	}
	return false
}

func WaitAnyFlagIn(allowed []int32) {
	for {
		if AnyFlagIn(allowed) {
			return
		}
		time.Sleep(10 * time.Millisecond)
	}
}

func SetFlag(idx int, value int32) {
	atomic.StoreInt32(&Flag[idx], value)
}

type Process_Type struct {
	Id       int
	Symbol   rune
	Position Position_Type
}

type Process_Task_Type struct {
	Time_Stamp  time.Duration
	Nr_of_Steps int
	Traces      Traces_Sequence_Type
	Process     Process_Type
}

func (t *Process_Task_Type) Init(Id int, Symbol rune, wg *sync.WaitGroup) {
	t.Process.Id = Id
	t.Process.Symbol = Symbol
	t.Traces.Last = -1

	t.Process.Position = Position_Type{X: Id, Y: int(LocalSection)}

	t.Nr_of_Steps = Min_Steps + int(float64(Max_Steps-Min_Steps)*rand.Float64())
	
	t.Time_Stamp = time.Since(Start_Time)
	t.Store_Trace()

	defer wg.Done()
}

func (t *Process_Task_Type) Start(printerChan chan Traces_Sequence_Type, Wait_for_Finish *sync.WaitGroup) {
	for step := 0; step < t.Nr_of_Steps/7; step++ {
		
		// LOCAL_SECTION - start
		time.Sleep(Min_Delay + time.Duration(rand.Float64()*float64(Max_Delay-Min_Delay)))
		// LOCAL_SECTION - end

		t.Change_State(EntryProtocol1)
		SetFlag(t.Process.Id, 1) // t wants to enter
		WaitAllFlagsIn(0, Nr_Of_Processes, []int32{0, 1, 2})

		SetFlag(t.Process.Id, 3) // t enters the waiting room
		t.Change_State(EntryProtocol2)

		if AnyFlagIn([]int32{1}) {
			SetFlag(t.Process.Id, 2) // t waits for other process to enter waiting room
			t.Change_State(EntryProtocol3)
			WaitAnyFlagIn([]int32{4})
		}

		SetFlag(t.Process.Id, 4) // t is leaving the waitng room (entry door closed)
		t.Change_State(EntryProtocol4)
		// wait flags[0..t.Id-1] ∈ {0,1}
		WaitAllFlagsIn(0, t.Process.Id, []int32{0, 1})

		t.Change_State(CriticalSection) // starting CRITICAL_SECTION

		// CRITICAL_SECTION - start
		time.Sleep(Min_Delay + time.Duration(rand.Float64()*float64(Max_Delay-Min_Delay)))
		// CRITICAL_SECTION - end

		t.Change_State(ExitProtocol) // starting EXIT_PROTOCOL

		// wait flags[t.Id+1..NrOfProcesses-1] ∈ {0,1,4}
		WaitAllFlagsIn(t.Process.Id+1, Nr_Of_Processes, []int32{0, 1, 4})
		SetFlag(t.Process.Id, 0)
		time.Sleep(10)

		t.Change_State(LocalSection) // starting LOCAL_SECTION

	}
	printerChan <- t.Traces
	defer Wait_for_Finish.Done()
}

func (t *Process_Task_Type) Change_State(State Process_State) {
	t.Time_Stamp = time.Since(Start_Time)
	t.Process.Position.Y = int(State)
	t.Store_Trace()
}

func (t *Process_Task_Type) Store_Trace() {
	t.Traces.Last++
	t.Traces.Trace_Array[t.Traces.Last] = Trace_Type{
		Time_Stamp: t.Time_Stamp,
		Id:         t.Process.Id,
		Position:   t.Process.Position,
		Symbol:     t.Process.Symbol,
	}
}

func main() {
	var Process_Tasks [Nr_Of_Processes]Process_Task_Type
	var Symbol rune = 'A'

	printerChan := make(chan Traces_Sequence_Type, Nr_Of_Processes)

	var Wait_to_Start sync.WaitGroup
	var Wait_for_Finish sync.WaitGroup

	for index := range Process_Tasks {
		Wait_to_Start.Add(1)
		go Process_Tasks[index].Init(index, Symbol, &Wait_to_Start)
		Symbol++
	}

	Wait_to_Start.Wait()

	Wait_for_Finish.Add(1)
	go Printer(printerChan, &Wait_for_Finish)

	for index := range Process_Tasks {
		Wait_for_Finish.Add(1)
		go Process_Tasks[index].Start(printerChan, &Wait_for_Finish)
	}

	Wait_for_Finish.Wait()
}