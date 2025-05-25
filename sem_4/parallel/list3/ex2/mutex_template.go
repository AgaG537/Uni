package main

import (
	"fmt"
	"math/rand"
	"sync/atomic"
	"time"
)

// --- Constants ---
const (
	NrOfProcesses = 15
	MinSteps      = 50
	MaxSteps      = 100

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
		fmt.Printf("%f %d %d %d %c\n",
			float64(trace.TimeStamp)/float64(time.Second),
			trace.Id,
			trace.Position.X,
			trace.Position.Y,
			trace.Symbol,
		)
	}
}

// --- Max_ticket Task ---
type Max_ticket struct {
	SetChannel chan int32
	GetChannel chan (chan int32)
	ticket     int32
}

func (m *Max_ticket) Start() {
	m.GetChannel = make(chan (chan int32))
	m.SetChannel = make(chan int32)

	go func() {
		for {
			select {
			case newTicket := <-m.SetChannel:
				if newTicket > m.ticket {
					m.ticket = newTicket
				}
			case responseChan := <-m.GetChannel:
				responseChan <- m.ticket
			}
		}
	}()
}

// --- Printer Task ---
type Printer struct {
	traceChannel chan []Trace
	done         chan bool
}

var (
	printer   Printer
	maxTicket Max_ticket
)

func (p *Printer) Start() {
	p.traceChannel = make(chan []Trace, NrOfProcesses)
	p.done = make(chan bool)

	go func() {
		for i := 0; i < NrOfProcesses; i++ {
			traces := <-p.traceChannel
			Print_Traces(traces)
		}

		response := make(chan int32)
		maxTicket.GetChannel <- response
		ticket := <-response

		fmt.Printf("-1 %d %d %d ",
			NrOfProcesses,
			BoardWidth,
			BoardHeight,
		)
		for _, img := range ProcessStateImages {
			fmt.Printf("%s;", img)
		}
		fmt.Printf("MAX_TICKET=%d;\n", ticket)

		p.done <- true
	}()
}

// --- Shared Variables for Lamport's Bakery Algorithm (Atomic) ---
var (
	Choosing = make([]int32, NrOfProcesses) // Automatically 0 initialized
	Number   = make([]int32, NrOfProcesses) // Automatically 0 initialized
)

// --- Process Task ---
type Process struct {
	Id             int
	Symbol         rune
	Position       Position
	Steps          int
	Traces         []Trace
	TimeStamp      time.Duration
	localMaxTicket int32
}

func (p *Process) Store_Trace() {
	p.Traces = append(p.Traces, Trace{
		TimeStamp: p.TimeStamp,
		Id:        p.Id,
		Position:  p.Position,
		Symbol:    p.Symbol,
	})
}

func (p *Process) Max() int32 {
	current := int32(0)
	for n := range Number {
		if atomic.LoadInt32(&Number[n]) > current {
			current = atomic.LoadInt32(&Number[n])
		}
	}
	return current
}

func (p *Process) ChangeState(NewState ProcessState) {
	p.Position.Y = int(NewState)
	p.TimeStamp = time.Since(StartTime)
	p.Store_Trace()
	time.Sleep(time.Millisecond)
}

func (p *Process) Init(id int, symbol rune) {
	p.Id = id
	p.Symbol = symbol

	p.Position = Position{
		X: id,
		Y: int(LocalSection),
	}

	p.Steps = MinSteps + rand.Intn(MaxSteps-MinSteps+1)
	p.TimeStamp = time.Since(StartTime)
	p.Store_Trace()
}

func (p *Process) Start() {
	go func() {
		for i := 0; i < p.Steps/4-1; i++ {
			// LOCAL_SECTION - start
			time.Sleep(MinDelay + time.Duration(rand.Int63n(int64(MaxDelay-MinDelay))))
			// LOCAL_SECTION - end

			p.ChangeState(EntryProtocol) // starting ENTRY_PROTOCOL

			atomic.StoreInt32(&Choosing[p.Id], 1)
			atomic.StoreInt32(&Number[p.Id], 1+p.Max())
			atomic.StoreInt32(&Choosing[p.Id], 0)

			if atomic.LoadInt32(&Number[p.Id]) > p.localMaxTicket {
				p.localMaxTicket = atomic.LoadInt32(&Number[p.Id])
			}

			for j := 0; j < NrOfProcesses; j++ {
				if j != p.Id {
					for { // Wait while process j is choosing
						if atomic.LoadInt32(&Choosing[j]) == 0 {
							break
						}
					}
					for { // Wait if process j has a higher or equal ticket with lower ID
						if atomic.LoadInt32(&Number[j]) == 0 ||
							atomic.LoadInt32(&Number[p.Id]) < atomic.LoadInt32(&Number[j]) ||
							(atomic.LoadInt32(&Number[p.Id]) == atomic.LoadInt32(&Number[j]) && p.Id < j) {
							break
						}
					}
				}
			}

			p.ChangeState(CriticalSection) // starting CRITICAL_SECTION

			// CRITICAL_SECTION - start
			time.Sleep(MinDelay + time.Duration(rand.Int63n(int64(MaxDelay-MinDelay))))
			// CRITICAL_SECTION - end

			p.ChangeState(ExitProtocol) // starting EXIT_PROTOCOL

			atomic.StoreInt32(&Number[p.Id], 0)

			p.ChangeState(LocalSection) // starting LOCAL_SECTION
		}

		maxTicket.SetChannel <- p.localMaxTicket
		printer.traceChannel <- p.Traces
	}()
}

// --- Main Program ---
func main() {
	var Processes [NrOfProcesses]Process

	printer.Start()
	maxTicket.Start()

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
