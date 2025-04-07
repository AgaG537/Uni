package main

import (
	"fmt"
	"math/rand"
	"sort"
	"sync"
	"time"
)

type Position struct {
	X, Y int
}

type Direction int

const (
	Up Direction = iota
	Down
	Left
	Right
)

type Trace struct {
	TimeStamp float64
	Id        int
	Position  Position
	Symbol    rune
}

type Traveler struct {
	Id        int
	Symbol    rune
	Position  Position
	Direction Direction
	Traces    []Trace
	Mutex     sync.Mutex
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
	travelers  [NrOfTravelers]*Traveler
	startTime  time.Time
	boardLocks [BoardWidth][BoardHeight]sync.Mutex
	wg         sync.WaitGroup
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
	case <-time.After(2 * MaxDelay):
		return false
	}
}

func (t *Traveler) StoreTrace() {
	trace := Trace{
		TimeStamp: time.Since(startTime).Seconds(),
		Id:        t.Id,
		Position:  t.Position,
		Symbol:    t.Symbol,
	}
	t.Mutex.Lock()
	t.Traces = append(t.Traces, trace)
	t.Mutex.Unlock()
}

func (t *Traveler) Start() {
	nSteps := MinSteps + rand.Intn(MaxSteps-MinSteps)
	for i := 0; i < nSteps; i++ {
		time.Sleep(MinDelay + time.Duration(rand.Int63n(int64(MaxDelay-MinDelay))))
		if !t.Move() {
			t.Symbol = rune(t.Symbol + 32)
			t.StoreTrace()
			break
		}
		t.StoreTrace()
	}
	wg.Done()
}

func main() {
	rand.Seed(time.Now().UnixNano())
	startTime = time.Now()
	fmt.Printf("-1 %d %d %d\n", NrOfTravelers, BoardWidth, BoardHeight)

	symbol := 'A'
	for i := 0; i < NrOfTravelers; i++ {
		pos := Position{X: i, Y: i}

		var dir Direction
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
			Position:  pos,
			Direction: dir,
			Traces:    []Trace{},
		}
		boardLocks[pos.X][pos.Y].Lock()
		travelers[i].StoreTrace()
		symbol++
	}

	for i := 0; i < NrOfTravelers; i++ {
		wg.Add(1)
		go travelers[i].Start()
	}

	wg.Wait()

	sort.Slice(travelers[:], func(i, j int) bool {
		return travelers[i].Id < travelers[j].Id
	})

	for _, t := range travelers {
		t.Mutex.Lock()
		for _, trace := range t.Traces {
			fmt.Printf("%.9f %2d %2d %2d %2c\n", trace.TimeStamp, trace.Id, trace.Position.X, trace.Position.Y, trace.Symbol)
		}
		t.Mutex.Unlock()
	}
}
