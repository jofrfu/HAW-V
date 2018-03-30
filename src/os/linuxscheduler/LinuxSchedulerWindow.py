#!/usr/bin/env python

# Author Sebastian Paulsen
# Sebastian_Paulsen@PaulsenKom.de
import sys
import os
from PyQt5 import *
from PyQt5.QtCore import Qt
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
from PyQt5.QtCore import pyqtSlot
from PyQt5 import QtWidgets
from ProcessComperator import *
from ProcessGenerator import *
# kernel.sched_cfs_bandwidth_slice_us = 5000
# kernel.sched_child_runs_first = 0
# kernel.sched_compat_yield = 0
# kernel.sched_latency_ns = 24000000
# kernel.sched_migration_cost_ns = 500000
# kernel.sched_min_granularity_ns = 8000000
# kernel.sched_nr_migrate = 32
# kernel.sched_rr_timeslice_ms = 25
# kernel.sched_rt_period_us = 1000000
# kernel.sched_rt_runtime_us = 950000
# kernel.sched_schedstats = 0
# kernel.sched_shares_window_ns = 10000000
# kernel.sched_time_avg_ms = 1000
# kernel.sched_tunable_scaling = 1
# kernel.sched_wakeup_granularity_ns = 10000000

CPL = CPUList()
P1 = Process1Class()
P2 = Process2Class()


def refreshPicture(name, view):
    scene = QtWidgets.QGraphicsScene()
    item = QtWidgets.QGraphicsPixmapItem(QPixmap(name))
    scene.addItem(item)
    view.setScene(scene)


def systemWrapper():
    print("syscall Here")


def createUpdateThread():
    CPL.UpdateUI.connect(UpdateUI)
    CPL.start()


@pyqtSlot()
def UpdateUI():
    for x in range(0, CPL.CPUCounter):
        CoreValueList[x].setText(str(CPL.ListOfCPU[x].
                                     recentUsage[0]) + "%")
    QApplication.processEvents()
    QApplication.processEvents()
    QApplication.processEvents()


@pyqtSlot()
def Process1TimesetText(TimePassed):
    Process1Label.setText(str(TimePassed))


@pyqtSlot()
def Process2TimesetText(TimePassed):
    Process2Label.setText(str(TimePassed))


def Process1Start():
    P1.P1Signal.connect(Process1TimesetText)
    P1.start()


def Process2Start():
    P2.P2Signal.connect(Process2TimesetText)
    P2.start()


def checkValue(text):
    number = int(text)
    if(number > 100000000 or number < 0):
        return False
    return True


def getTextValues():
    Value1 = LabelEditSchedLatencyNs.text()
    Value2 = LineEditSchedBandwidthSlice.text()
    Value3 = LabelEditSchedGranularity.text()
    DoIt = True
    for v in [Value1, Value2, Value3]:
        if(not checkValue(v)):
            DoIt = False
    if DoIt:
        fd = open("/proc/sys/kernel/sched_latency_ns", "a")
        fd.write(str(Value1))
        fd.close()
        fd = open("/proc/sys/kernel/sched_cfs_bandwidth_slice_us", "a")
        fd.write(str(Value2))
        fd.close()
        fd = open("/proc/sys/kernel/sched_wakeup_granularity_ns", "a")
        fd.write(str(Value3))
        fd.close()
    getSystemValues()


def getSystemValues():
    fd = open("/proc/sys/kernel/sched_latency_ns", "r")
    LabelEditSchedLatencyNs.setText(fd.read())
    fd.close()
    fd = open("/proc/sys/kernel/sched_cfs_bandwidth_slice_us", "r")
    LineEditSchedBandwidthSlice.setText(fd.read())
    fd.close()
    fd = open("/proc/sys/kernel/sched_wakeup_granularity_ns", "r")
    LabelEditSchedGranularity.setText(fd.read())
    fd.close()


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    w = QtWidgets.QWidget()
    CPL.getCPUNames()
    mainLayout = QtWidgets.QHBoxLayout()
    Process1Label = QLabel("0ms")
    Process2Label = QLabel("0ms")
    Process1Button = QtWidgets.QPushButton("Run Process 1")
    Process2Button = QtWidgets.QPushButton("Run Process 2")
    Process1Button.clicked.connect(Process1Start)
    Process2Button.clicked.connect(Process2Start)
    Process1HBox = QtWidgets.QHBoxLayout()
    Process2HBox = QtWidgets.QHBoxLayout()
    Process1HBox.addWidget(Process1Button)
    Process1HBox.addWidget(Process1Label)
    Process2HBox.addWidget(Process2Button)
    Process2HBox.addWidget(Process2Label)
    SaveButton = QtWidgets.QPushButton("Save")
    SaveButton.clicked.connect(getTextValues)
    LabelSchedGranularity = QtWidgets.QLabel("sched_wakeup_granularity_ns")
    LabelEditSchedGranularity = QtWidgets.QLineEdit("0")
    LabelSchedBandwidthSlice = QtWidgets.QLabel("Sched Band width Slice")
    LineEditSchedBandwidthSlice = QtWidgets.QLineEdit("0")
    LabelSchedLatencyNs = QtWidgets.QLabel("Sched Latency ns")
    LabelEditSchedLatencyNs = QtWidgets.QLineEdit("0")
    PrintPreview = QtWidgets.QGraphicsView()
    CoreLabelList = [None] * CPL.CPUCounter
    CoreValueList = [None] * CPL.CPUCounter
    leftBracket = QtWidgets.QVBoxLayout()
    LinkLabel = QLabel("<a href=\"https://doc.opensuse.org/documentation/leap/tuning/html/book.sle.tuning/cha.tuning.taskscheduler.html\">Documentation</a>")
    LinkLabel.setTextFormat(Qt.RichText)
    LinkLabel.setTextInteractionFlags(Qt.TextBrowserInteraction)
    LinkLabel.setOpenExternalLinks(True)
    LinkLabel.setAlignment(Qt.AlignRight)
    for x in range(0, CPL.CPUCounter):
        tempHbox = QtWidgets.QHBoxLayout()
        CoreLabelList[x] = QtWidgets.QLabel(CPL.ListOfCPU[x].CPUName)
        CoreValueList[x] = QtWidgets.QLabel("0")
        tempHbox.addWidget(CoreLabelList[x])
        tempHbox.addWidget(CoreValueList[x])
        leftBracket.addLayout(tempHbox)
    if(os.getuid() != 0):
        print("Please start Script as Root")
        sys.exit()
    rightBracket = QtWidgets.QVBoxLayout()
    print(CoreValueList)
    Spacer = QtWidgets.QSpacerItem(0, 10, QSizePolicy.Expanding,
                                   QSizePolicy.Expanding)
    Spacer2 = QtWidgets.QSpacerItem(0, 10, QSizePolicy.Expanding,
                                    QSizePolicy.Expanding)
    leftBracket.addLayout(Process1HBox)
    leftBracket.addLayout(Process2HBox)
    leftBracket.addItem(Spacer)
    rightBracket.addWidget(LabelSchedGranularity)
    rightBracket.addWidget(LabelEditSchedGranularity)
    rightBracket.addWidget(LabelSchedBandwidthSlice)
    rightBracket.addWidget(LineEditSchedBandwidthSlice)
    rightBracket.addWidget(LabelSchedLatencyNs)
    rightBracket.addWidget(LabelEditSchedLatencyNs)
    rightBracket.addWidget(SaveButton)
    rightBracket.addItem(Spacer2)
    rightBracket.addWidget(LinkLabel)
    view = QtWidgets.QGraphicsView()
    mainLayout.addLayout(leftBracket)
    mainLayout.addLayout(rightBracket)
    # LabelSchedGranularity.setText(str(CPL.ListOfCPU[0].recentUsage[0]))
    w.setLayout(mainLayout)
    getSystemValues()
    w.move(300, 300)
    w.setWindowTitle('Linux Scheduler')
    w.show()
    createUpdateThread()
    sys.exit(app.exec_())
