package main

import (
	"sync"
)

type Monitor struct {
	enter     chan struct{}
	leave     chan struct{}
	terminate chan struct{}
}

func NewMonitor() *Monitor {
	mon := &Monitor{
		enter:     make(chan struct{}),
		leave:     make(chan struct{}),
		terminate: make(chan struct{}),
	}
	go mon.run()
	return mon
}

func (mon *Monitor) run() {
	for {
		select {
		case <-mon.enter:
		case <-mon.terminate:
			return
		}

		select {
		case <-mon.leave:
		case <-mon.terminate:
			return
		}
	}
}

func (mon *Monitor) Enter() {
	mon.enter <- struct{}{}
}

func (mon *Monitor) Leave() {
	mon.leave <- struct{}{}
}

func (mon *Monitor) Stop() {
	mon.terminate <- struct{}{}
	close(mon.terminate)
	close(mon.enter)
	close(mon.leave)
}

type Condition struct {
	monitor   *Monitor
	signal    chan struct{}
	preWait   chan chan struct{}
	waiting   chan chan bool
	terminate chan struct{}
	count     int
	mtx       sync.Mutex
}

func NewCondition(mon *Monitor) *Condition {
	cond := &Condition{
		monitor:   mon,
		signal:    make(chan struct{}),
		preWait:   make(chan chan struct{}),
		waiting:   make(chan chan bool),
		terminate: make(chan struct{}),
		count:     0,
	}
	go cond.run()
	return cond
}

func (cond *Condition) run() {
	queue := make([]chan struct{}, 0)
	for {
		select {
		case <-cond.signal:
			cond.mtx.Lock()
			if cond.count == 0 {
				cond.monitor.Leave()
			} else {
				cond.count--
				ch := queue[0]
				queue = queue[1:]
				ch <- struct{}{}
			}
			cond.mtx.Unlock()
		case ch := <-cond.preWait:
			cond.mtx.Lock()
			queue = append(queue, ch)
			cond.count++
			cond.mtx.Unlock()
		case ch := <-cond.waiting:
			cond.mtx.Lock()
			ch <- cond.count != 0
			cond.mtx.Unlock()
		case <-cond.terminate:
			return
		}
	}
}

func (cond *Condition) Signal() {
	cond.signal <- struct{}{}
}

func (cond *Condition) PreWait() chan struct{} {
	ch := make(chan struct{})
	cond.preWait <- ch
	return ch
}

func (cond *Condition) Waiting() bool {
	ch := make(chan bool)
	cond.waiting <- ch
	return <-ch
}

func (cond *Condition) Stop() {
	cond.terminate <- struct{}{}
	close(cond.signal)
	close(cond.waiting)
	close(cond.preWait)
	close(cond.terminate)
}

func NonEmpty(cond *Condition) bool {
	return cond.Waiting()
}

func Wait(cond *Condition) struct{} {
	ch := cond.PreWait()
	cond.monitor.Leave()
	return <-ch
}
