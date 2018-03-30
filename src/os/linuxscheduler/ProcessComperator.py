#!/usr/bin/env python

# Author Sebastian Paulsen
# Sebastian_Paulsen@PaulsenKom.de
import time
from PyQt5.QtCore import QThread
from PyQt5.QtCore import pyqtSignal
from PyQt5.QtCore import pyqtSlot
STAT_PATH = "/proc/stat"


class CPUList(QThread):
    UpdateUI = pyqtSignal()

    def __init__(self):
        super(CPUList, self).__init__()
        self.ListOfCPU = []
        self.oldSumOfOthers = [0] * 9
        self.oldIdle = [0] * 9
        self.CPUCounter = 0

    # start = pyqtSignal()

    def run(self, *args):
        while(1):
            self.updateCPUS()
            self.UpdateUI.emit()
            time.sleep(1)

    def __del__(self):
        self.wait()

    def getCPUNames(self):
        fd = open(STAT_PATH, "r")
        data = fd.readlines()
        for line in data:
            splitlines = line.split(" ")
            if "" in splitlines:
                splitlines.remove("")
            if "cpu" in splitlines[0]:
                temp = CPU(splitlines[0])
                self.ListOfCPU.append(temp)
                self.CPUCounter += 1
        fd.close()
        return 0

    def updateCPUS(self):
        fd = open(STAT_PATH, "r")
        data = fd.readlines()
        counter = 0
        for line in data:
            splitlines = line.split(" ")
            if "" in splitlines:
                splitlines.remove("")
            if "cpu" in splitlines[0]:
                Idle = int(splitlines[4])
                SumOfOthers = int(splitlines[1])
                SumOfOthers += int(splitlines[2])
                SumOfOthers += int(splitlines[3])
                SumOfOthers += int(splitlines[5])
                SumOfOthers += int(splitlines[6])
                SumOfOthers += int(splitlines[7])
                diffIdle = Idle - self.oldIdle[counter]
                diffSumOfOthers = SumOfOthers - self.oldSumOfOthers[counter]
                if diffSumOfOthers + diffIdle is 0:
                    diffIdle += 1
                Usage = 100 - (diffIdle * 100) / (diffSumOfOthers + diffIdle)
                self.ListOfCPU[counter].updateUsage(round(Usage, 2))
                self.oldSumOfOthers[counter] = SumOfOthers
                self.oldIdle[counter] = Idle
                counter += 1
        fd.close()


class CPU():
    def __init__(self, name):
        self.CPUName = name
        self.recentUsage = []
        self.usagecounter = 0

    def updateUsage(self, usage):
        self.recentUsage.insert(0, usage)
        if len(self.recentUsage) > 10:
            self.recentUsage.pop()
