import subprocess
import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLineEdit, QPushButton, QLabel
from PyQt5.QtCore import pyqtSlot

class SwappinessChanger(object):

    def __init__(self):
        self.__old_swappiness = self.get_swappiness()
        self.actual = self.__old_swappiness

    def get_swappiness(self):
        fobj = open('/proc/sys/vm/swappiness')
        val = fobj.readline()
        if val[-1] == '\n':
            val = val[:-1]
        fobj.close()
        return val

    def set_swappiness(self, value='60'):
        call_string = "sudo sysctl vm.swappiness=" + value
        subprocess.call(call_string, shell=True)
        self.actual = value

    def reset(self):
        self.set_swappiness(self.__old_swappiness)


class App(QWidget):

    def __init__(self):
        super().__init__()
        self.__sc = SwappinessChanger()
        self.__title = 'Change Swappiness'
        self.__left = 10
        self.__top = 10
        self.__width = 320
        self.__height = 240
        self.__textbox_actual_swappiness = QLineEdit(self)
        self.__textbox_new_swappiness = QLineEdit(self)
        self.__button = QPushButton('PyQt5 button', self)
        self.__reset = QPushButton('PyQt5 button', self)
        self.__label_old = QLabel('old', self)
        self.__label_new = QLabel('new', self)
        self.initUI()

    def initUI(self):
        self.setWindowTitle(self.__title)
        self.setGeometry(self.__left, self.__top, self.__width, self.__height)
        self.__textbox_actual_swappiness.move(100, 20)
        self.__textbox_actual_swappiness.resize(200, 40)
        self.__label_old.move(20,20)
        self.__textbox_new_swappiness.move(100, 80)
        self.__textbox_new_swappiness.resize(200, 40)
        self.__label_new.move(20, 80)
        self.__button.move(100, 140)
        self.__reset.move(190, 140)
        self.__button.setText('Change')
        self.__reset.setText('Reset')
        self.__button.clicked.connect(self.push_button)
        self.__reset.clicked.connect(self.push_reset)
        self.actualize()
        self.show()

    def actualize(self):
        self.__textbox_actual_swappiness.setText(self.__sc.actual)
        self.__textbox_new_swappiness.setText('')

    @pyqtSlot()
    def push_button(self):
        if (self.__textbox_new_swappiness.text() != ''):
            self.__sc.set_swappiness(value=self.__textbox_new_swappiness.text())
            self.actualize()

    @pyqtSlot()
    def push_reset(self):
        self.__sc.reset()
        self.actualize()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = App()
    sys.exit(app.exec_())