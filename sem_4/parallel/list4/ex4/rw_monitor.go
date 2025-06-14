package main

import (
	"sync"
)

type RWMonitor struct {
	monitor   *Monitor
	okToRead  *Condition
	okToWrite *Condition
	readers   int
	writing   bool
	stateMtx  sync.Mutex
}

func NewRWMonitor() *RWMonitor {
	m := NewMonitor()
	return &RWMonitor{
		monitor:   m,
		okToRead:  NewCondition(m),
		okToWrite: NewCondition(m),
		readers:   0,
		writing:   false,
	}
}

func (rwMon *RWMonitor) StartRead() {
	rwMon.monitor.Enter()

	rwMon.stateMtx.Lock()
	wait := rwMon.writing || NonEmpty(rwMon.okToWrite)

	if wait {
		rwMon.stateMtx.Unlock()
		Wait(rwMon.okToRead)
	} else {
		rwMon.stateMtx.Unlock()
	}

	rwMon.stateMtx.Lock()
	rwMon.readers++
	rwMon.stateMtx.Unlock()

	rwMon.okToRead.Signal()
}

func (rwMon *RWMonitor) StopRead() {
	rwMon.monitor.Enter()

	rwMon.stateMtx.Lock()
	rwMon.readers--
	isLastReader := rwMon.readers == 0

	if isLastReader {
		rwMon.stateMtx.Unlock()
		rwMon.okToWrite.Signal()
	} else {
		rwMon.stateMtx.Unlock()
		rwMon.monitor.Leave()
	}
}

func (rwMon *RWMonitor) StartWrite() {
	rwMon.monitor.Enter()

	rwMon.stateMtx.Lock()
	wait := rwMon.readers != 0 || rwMon.writing

	if wait {
		rwMon.stateMtx.Unlock()
		Wait(rwMon.okToWrite)
	} else {
		rwMon.stateMtx.Unlock()
	}

	rwMon.stateMtx.Lock()
	rwMon.writing = true
	rwMon.stateMtx.Unlock()

	rwMon.monitor.Leave()
}

func (rwMon *RWMonitor) StopWrite() {
	rwMon.monitor.Enter()

	rwMon.stateMtx.Lock()
	rwMon.writing = false
	nonEmpty := NonEmpty(rwMon.okToRead)

	if nonEmpty {
		rwMon.stateMtx.Unlock()
		rwMon.okToRead.Signal()
	} else {
		rwMon.stateMtx.Unlock()
		rwMon.okToWrite.Signal()
	}
}
