package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

const (
	NrOfReadingProcesses = 10
	NrOfWritingProcesses = 5
	NrOfProcesses        = NrOfReadingProcesses + NrOfWritingProcesses

	MinSteps = 50
	MaxSteps = 100

	MinDelay = 10 * time.Millisecond
	MaxDelay = 50 * time.Millisecond

	BoardWidth  = NrOfProcesses
	BoardHeight = 4
)

type ProcessState int

const (
	LocalSection ProcessState = iota
	Start
	ReadingRoom
	Stop
)

var Flags = [NrOfProcesses]int{}

type Position struct {
	X int
	Y int
}

type Trace struct {
	TimeStamp time.Duration
	ID        int
	Position  Position
	Symbol    rune
}

type TraceSequence struct {
	Last       int
	TraceArray [MaxSteps + 1]Trace
}

func (p *Printer) PrintTrace(trace Trace) {
	fmt.Printf("%.9f  %d  %d  %d  %c\n", float64(trace.TimeStamp.Nanoseconds())/1e9, trace.ID, trace.Position.X, trace.Position.Y, trace.Symbol)
}

func (p *Printer) PrintTraces(traces TraceSequence) {
	for i := 0; i <= traces.Last; i++ {
		p.PrintTrace(traces.TraceArray[i])
	}
	p.ReturnedTraces++

	if p.ReturnedTraces == NrOfProcesses {
		fmt.Printf("-1 %d %d %d ", NrOfProcesses, BoardWidth, BoardHeight)
		fmt.Printf("LOCAL_SECTION;START;READING_ROOM;STOP;EXTRA_LABEL;")
	}
}

type Printer struct {
	ReturnedTraces int
}

type Process struct {
	ID       int
	Symbol   rune
	Position Position
}

func StoreTrace(timeStamp time.Duration, process *Process, traces *TraceSequence) {
	traces.Last++
	traces.TraceArray[traces.Last] = Trace{
		TimeStamp: timeStamp,
		ID:        process.ID,
		Position:  process.Position,
		Symbol:    process.Symbol,
	}
}

func ChangeState(state ProcessState, StartTime time.Time, process *Process, traces *TraceSequence) {
	timeStamp := time.Since(StartTime)
	process.Position.Y = int(state)
	StoreTrace(timeStamp, process, traces)
}

func ReadingProcessTask(id int, seed int64, StartTime time.Time, printer *Printer, rwMon *RWMonitor) {
	Generator := rand.New(rand.NewSource(seed))
	process := Process{
		ID:       id,
		Symbol:   'R',
		Position: Position{X: id, Y: int(LocalSection)},
	}
	traces := TraceSequence{Last: -1}

	nrOfSteps := MinSteps + Generator.Intn(MaxSteps-MinSteps)
	TimeStamp := time.Since(StartTime)

	StoreTrace(TimeStamp, &process, &traces)

	for range nrOfSteps/4 - 1 {
		// LOCAL_SECTION - start
		time.Sleep(MinDelay + time.Duration(Generator.Float64()*float64(MaxDelay-MinDelay)))
		// LOCAL_SECTION - end

		ChangeState(Start, StartTime, &process, &traces) // starting ENTRY_PROTOCOL
		rwMon.StartRead()

		ChangeState(ReadingRoom, StartTime, &process, &traces) // starting CRITICAL_SECTION

		// CRITICAL_SECTION - start
		time.Sleep(MinDelay + time.Duration(Generator.Float64()*float64(MaxDelay-MinDelay)))
		// CRITICAL_SECTION - end

		ChangeState(Stop, StartTime, &process, &traces) // starting EXIT_PROTOCOL
		rwMon.StopRead()

		ChangeState(LocalSection, StartTime, &process, &traces) // starting LOCAL_SECTION
	}

	printer.PrintTraces(traces)
}

func WritingProcessTask(id int, seed int64, StartTime time.Time, printer *Printer, rwMon *RWMonitor) {
	Generator := rand.New(rand.NewSource(seed))
	process := Process{
		ID:       id,
		Symbol:   'W',
		Position: Position{X: id, Y: int(LocalSection)},
	}
	traces := TraceSequence{Last: -1}

	nrOfSteps := MinSteps + Generator.Intn(MaxSteps-MinSteps)
	TimeStamp := time.Since(StartTime)

	StoreTrace(TimeStamp, &process, &traces)

	for range nrOfSteps/4 - 1 {
		// LOCAL_SECTION - start
		time.Sleep(MinDelay + time.Duration(Generator.Float64()*float64(MaxDelay-MinDelay)))
		// LOCAL_SECTION - end

		ChangeState(Start, StartTime, &process, &traces) // starting ENTRY_PROTOCOL
		rwMon.StartWrite()

		ChangeState(ReadingRoom, StartTime, &process, &traces) // starting CRITICAL_SECTION

		// CRITICAL_SECTION - start
		time.Sleep(MinDelay + time.Duration(Generator.Float64()*float64(MaxDelay-MinDelay)))
		// CRITICAL_SECTION - end

		ChangeState(Stop, StartTime, &process, &traces) // starting EXIT_PROTOCOL
		rwMon.StopWrite()

		ChangeState(LocalSection, StartTime, &process, &traces) // starting LOCAL_SECTION
	}

	printer.PrintTraces(traces)
}

func GenerateSeeds(n int) []int64 {
	seeds := make([]int64, n)
	for i := range seeds {
		seeds[i] = time.Now().UnixNano() + int64(i*1000)
	}
	return seeds
}

func main() {
	StartTime := time.Now()
	seeds := GenerateSeeds(NrOfProcesses)

	printer := &Printer{0}
	rwMon := NewRWMonitor()

	// Start traveler tasks
	var wg sync.WaitGroup
	for i := range NrOfReadingProcesses {
		wg.Add(1)
		go func(id int, seed int64) {
			defer wg.Done()
			ReadingProcessTask(id, seed, StartTime, printer, rwMon)
		}(i, seeds[i])
	}

	for i := range NrOfWritingProcesses {
		wg.Add(1)
		go func(id int, seed int64) {
			defer wg.Done()
			WritingProcessTask(id, seed, StartTime, printer, rwMon)
		}(i+NrOfReadingProcesses, seeds[i+NrOfReadingProcesses])
	}

	// Wait until all tasks are finished
	wg.Wait()
}
