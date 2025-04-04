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
	NrOfTravelers   = 15
	MinSteps        = 10
	MaxSteps        = 100
	MinDelay        = 10 * time.Millisecond
	MaxDelay        = 50 * time.Millisecond
	BoardWidth      = 15
	BoardHeight     = 15
	DeadlockTimeout = 200 * time.Millisecond
)

var (
	travelers  [NrOfTravelers]*Traveler
	startTime  time.Time
	printMutex sync.Mutex
	wg         sync.WaitGroup
	boardLocks [BoardWidth][BoardHeight]sync.Mutex
)

func (t *Traveler) Move() bool {
	for attempt := 0; attempt < 3; attempt++ {
		newPos := t.Position
		switch rand.Intn(4) {
		case 0:
			newPos.Y = (newPos.Y + 1) % BoardHeight
		case 1:
			newPos.Y = (newPos.Y + BoardHeight - 1) % BoardHeight
		case 2:
			newPos.X = (newPos.X + 1) % BoardWidth
		case 3:
			newPos.X = (newPos.X + BoardWidth - 1) % BoardWidth
		}

		lockAcquired := make(chan bool, 1)
		go func() {
			boardLocks[newPos.X][newPos.Y].Lock()
			lockAcquired <- true
		}()

		select {
		case <-lockAcquired:
			boardLocks[t.Position.X][t.Position.Y].Unlock()
			t.Position = newPos
			return true
		case <-time.After(DeadlockTimeout / 3):
			continue
		}
	}
	return false
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
		if !t.Move() {
			t.Symbol = rune(t.Symbol + 32) // Convert to lowercase on deadlock
			break
		}
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
	rand.Seed(time.Now().UnixNano())
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
		boardLocks[travelers[i].Position.X][travelers[i].Position.Y].Lock()
		travelers[i].StoreTrace()
		symbol++
	}

	for i := 0; i < NrOfTravelers; i++ {
		wg.Add(1)
		go travelers[i].Start()
	}

	wg.Wait()
}