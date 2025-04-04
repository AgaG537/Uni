package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

type Position struct {
	X, Y int
}

type Trace struct {
	TimeStamp float64
	Id        int
	Position  Position
	Symbol    rune
}

type Traveler struct {
	Id       int
	Symbol   rune
	Position Position
	Traces   []Trace
	Mutex    sync.Mutex
}

const (
	NrOfTravelers = 15
	MinSteps      = 10
	MaxSteps      = 100
	MinDelay      = 10 * time.Millisecond
	MaxDelay      = 50 * time.Millisecond
	BoardWidth    = 15
	BoardHeight   = 15
)

var (
	wg          sync.WaitGroup
	startTime   time.Time
	travelers   [NrOfTravelers]*Traveler
	printMutex  sync.Mutex
)

func (t *Traveler) Move() {
	directions := []func(){
		func() { t.Position.Y = (t.Position.Y + 1) % BoardHeight },
		func() { t.Position.Y = (t.Position.Y + BoardHeight - 1) % BoardHeight },
		func() { t.Position.X = (t.Position.X + 1) % BoardWidth },
		func() { t.Position.X = (t.Position.X + BoardWidth - 1) % BoardWidth },
	}
	directions[rand.Intn(len(directions))]()
}

func (t *Traveler) StoreTrace() {
	t.Mutex.Lock()
	t.Traces = append(t.Traces, Trace{
		TimeStamp: time.Since(startTime).Seconds(),
		Id:        t.Id,
		Position:  t.Position,
		Symbol:    t.Symbol,
	})
	t.Mutex.Unlock()
}

func (t *Traveler) Start() {
	nSteps := MinSteps + rand.Intn(MaxSteps-MinSteps)
	for i := 0; i < nSteps; i++ {
		time.Sleep(MinDelay + time.Duration(rand.Int63n(int64(MaxDelay-MinDelay))))
		t.Move()
		t.StoreTrace()
	}

	printMutex.Lock()
	for _, trace := range t.Traces {
		fmt.Printf("%.9f %d %d %d %c\n", trace.TimeStamp, trace.Id, trace.Position.X, trace.Position.Y, trace.Symbol)
	}
	printMutex.Unlock()
	wg.Done()
}

func main() {
	startTime = time.Now()
	symbol := 'A'

	fmt.Printf("-1 %d %d %d\n", NrOfTravelers, BoardWidth, BoardHeight)

	for i := 0; i < NrOfTravelers; i++ {
		travelers[i] = &Traveler{
			Id:       i,
			Symbol:   symbol,
			Position: Position{X: rand.Intn(BoardWidth), Y: rand.Intn(BoardHeight)},
			Traces:   []Trace{},
		}
		travelers[i].StoreTrace()
		symbol++
	}

	for i := 0; i < NrOfTravelers; i++ {
		wg.Add(1)
		go travelers[i].Start()
	}

	wg.Wait()
}