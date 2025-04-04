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

type Direction int

const (
	Up Direction = iota
	Down
	Left
	Right
)

type Traveler struct {
	Id        int
	Symbol    rune
	Position  Position
	Direction Direction
	Traces    []Trace
	Mutex     sync.Mutex
}

const (
	NrOfTravelers   = 15
	BoardWidth      = 15
	BoardHeight     = 15
	MinSteps        = 10
	MaxSteps        = 100
	MinDelay        = 10 * time.Millisecond
	MaxDelay        = 50 * time.Millisecond
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
	newPos := t.Position

	switch t.Direction {
	case Up:
		newPos.Y = (newPos.Y + BoardHeight - 1) % BoardHeight
	case Down:
		newPos.Y = (newPos.Y + 1) % BoardHeight
	case Left:
		newPos.X = (newPos.X + BoardWidth - 1) % BoardWidth
	case Right:
		newPos.X = (newPos.X + 1) % BoardWidth
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
	case <-time.After(DeadlockTimeout):
		return false
	}
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
	nSteps := MinSteps + rand.Intn(MaxSteps-MinSteps+1)

	for i := 0; i < nSteps; i++ {
		time.Sleep(MinDelay + time.Duration(rand.Int63n(int64(MaxDelay-MinDelay))))
		if !t.Move() {
			t.Symbol = rune(t.Symbol + 32) // na małą literę
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
		dir := Up
		if i%2 == 0 {
			if rand.Intn(2) == 0 {
				dir = Up
			} else {
				dir = Down
			}
		} else {
			if rand.Intn(2) == 0 {
				dir = Left
			} else {
				dir = Right
			}
		}

		travelers[i] = &Traveler{
			Id:        i,
			Symbol:    symbol,
			Position:  Position{X: i, Y: i},
			Direction: dir,
			Traces:    []Trace{},
		}

		boardLocks[i][i].Lock()
		travelers[i].StoreTrace()
		symbol++
	}

	for i := 0; i < NrOfTravelers; i++ {
		wg.Add(1)
		go travelers[i].Start()
	}

	wg.Wait()
}
