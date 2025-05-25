package main

import (
	"fmt"
	"math/rand"
	"sync/atomic"
	"time"
)

// --- Constants ---
const (
	NrOfProcesses = 2

	MinSteps = 50
	MaxSteps = 100

	MinDelay = 10 * time.Millisecond
	MaxDelay = 50 * time.Millisecond
)

var (
	StartTime = time.Now()
)

// --- Process States ---
type ProcessState int

const (
	LocalSection ProcessState = iota
	EntryProtocol
	CriticalSection
	ExitProtocol
)

var (
	ProcessStateImages = []string{
		"LOCAL_SECTION",
		"ENTRY_PROTOCOL",
		"CRITICAL_SECTION",
		"EXIT_PROTOCOL",
	}
)

const (
	BoardWidth  = NrOfProcesses
	BoardHeight = ExitProtocol + 1
)

// --- Data Structures ---

type Position struct {
	X, Y int
}

type Trace struct {
	TimeStamp time.Duration
	Id        int
	Position  Position
	Symbol    rune
}

func Print_Traces(traces []Trace) {
	for _, trace := range traces {
		fmt.Printf("%.6f %d %d %d %c\n",
			float64(trace.TimeStamp)/float64(time.Second),
			trace.Id,
			trace.Position.X,
			trace.Position.Y,
			trace.Symbol,
		)
	}
}

// --- Printer Task ---
type Printer struct {
	traceChannel chan []Trace
	done         chan bool
}

var (
	printer Printer
)

func (p *Printer) Start() {
	p.traceChannel = make(chan []Trace, NrOfProcesses)
	p.done = make(chan bool)

	go func() {
		for i := 0; i < NrOfProcesses; i++ {
			traces := <-p.traceChannel
			Print_Traces(traces)
		}

		fmt.Printf("-1 %d %d %d ",
			NrOfProcesses,
			BoardWidth,
			BoardHeight,
		)
		for _, img := range ProcessStateImages {
			fmt.Printf("%s;", img)
		}
		fmt.Println("EXTRA_LABEL;")

		p.done <- true
	}()
}

// --- Shared Variables for Peterson's Algorithm (Atomic) ---
var (
	// 0: not interested, 1: interested
	C = make([]int32, NrOfProcesses) // Automatically 0 initialized

	Last atomic.Int32 // Automatically 0 initialized
)

// --- Process Task ---
type Process struct {
	Id        int
	Symbol    rune
	Position  Position
	Steps     int
	Traces    []Trace
	TimeStamp time.Duration
}

func (t *Process) Store_Trace() {
	t.Traces = append(t.Traces, Trace{
		TimeStamp: t.TimeStamp,
		Id:        t.Id,
		Position:  t.Position,
		Symbol:    t.Symbol,
	})
}

func (t *Process) ChangeState(NewState ProcessState) {
	t.Position.Y = int(NewState)
	t.TimeStamp = time.Since(StartTime)
	t.Store_Trace()

	time.Sleep(time.Millisecond)
}

func (t *Process) Init(id int, symbol rune) {
	t.Id = id
	t.Symbol = symbol

	t.Position = Position{
		X: id,
		Y: int(LocalSection),
	}

	t.Steps = MinSteps + rand.Intn(MaxSteps-MinSteps+1)
	t.TimeStamp = time.Since(StartTime)
	t.Store_Trace()
}

func (t *Process) Start() {
	go func() {
		for i := 0; i < t.Steps/4-1; i++ {
			// LOCAL_SECTION - start
			time.Sleep(MinDelay + time.Duration(rand.Int63n(int64(MaxDelay-MinDelay))))
			// LOCAL_SECTION - end

			t.ChangeState(EntryProtocol) // starting ENTRY_PROTOCOL

			if t.Id == 0 {
				atomic.StoreInt32(&C[0], 1)
				Last.Store(0)

				for {
					if atomic.LoadInt32(&C[1]) == 0 ||
						Last.Load() != 0 {
						break
					}
				}
			} else {
				atomic.StoreInt32(&C[1], 1)
				Last.Store(1)

				for {
					if atomic.LoadInt32(&C[0]) == 0 ||
						Last.Load() != 1 {
						break
					}
				}
			}

			t.ChangeState(CriticalSection) // starting CRITICAL_SECTION

			// CRITICAL_SECTION - start
			time.Sleep(MinDelay + time.Duration(rand.Int63n(int64(MaxDelay-MinDelay))))
			// CRITICAL_SECTION - end

			t.ChangeState(ExitProtocol) // starting EXIT_PROTOCOL

			if t.Id == 0 {
				atomic.StoreInt32(&C[0], 0)
			} else {
				atomic.StoreInt32(&C[1], 0)
			}

			t.ChangeState(LocalSection) // starting LOCAL_SECTION
		}

		printer.traceChannel <- t.Traces
	}()
}

// --- Main Program ---
func main() {

	var Processes [NrOfProcesses]Process

	printer.Start()

	// Initialize each process
	symbol := 'A'
	for i := 0; i < NrOfProcesses; i++ {
		rand.Seed(time.Now().UnixNano() + int64(i))
		Processes[i].Init(i, symbol)
		symbol++
	}

	// Start each process goroutine
	for i := 0; i < NrOfProcesses; i++ {
		Processes[i].Start()
	}

	<-printer.done
}
