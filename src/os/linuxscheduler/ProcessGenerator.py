#!/usr/bin/env python

# Author Sebastian Paulsen
# Sebastian_Paulsen@PaulsenKom.de
# import time
from PyQt5.QtCore import QThread
from PyQt5.QtCore import pyqtSignal
from PyQt5.QtCore import QDateTime


class Process1Class(QThread):
    P1Signal = pyqtSignal(str)

    def __init__(self):
        super(Process1Class, self).__init__()

    def run(self, *args):
        self.P1Signal.emit("Running...")
        TimeStamp = QDateTime()
        Time = TimeStamp.currentMSecsSinceEpoch()
        ######################################
        # Current Processing edit here
        counter = 0
        while(counter < 5):
            counter1 = 0
            while counter1 < 100000:
                counter1 += 1
            counter += 1
        ######################################
        self.P1Signal.emit(str(TimeStamp.currentMSecsSinceEpoch() - Time) +
                           " ms")

    def __del__(self):
        self.wait()


class Process2Class(QThread):
    P2Signal = pyqtSignal(str)

    def __init__(self):
        super(Process2Class, self).__init__()

    def run(self, *args):
        self.P2Signal.emit("Running...")
        TimeStamp = QDateTime()
        Time = TimeStamp.currentMSecsSinceEpoch()
        ######################################
        # Current Processing edit here
        counter = 0
        while(counter < 5):
            counter1 = 0
            while counter1 < 100000000:
                counter1 += 1
            counter += 1
        ######################################
        self.P2Signal.emit(str(TimeStamp.currentMSecsSinceEpoch() - Time) +
                           " ms")

    def __del__(self):
        self.wait()
