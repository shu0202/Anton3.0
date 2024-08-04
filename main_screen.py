from compose import Compose 
from diagnose import Diagnose
from option import Option
from library import Library
import sys
import resources_rc 
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import Qt
from PyQt5.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout, QPushButton, QSizePolicy, QLabel

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.diagnose_popup = None
        self.initUI()

    def initUI(self):
        self.setWindowTitle("Anton 3.0")

        main_screen = QWidget()
        self.setCentralWidget(main_screen)
        vbox = QVBoxLayout(main_screen)
        vbox.setSpacing(20)

        anton_icon = QLabel()
        anton_icon.setPixmap(QIcon("Anton_icon.png").pixmap(500, 500))
        anton_icon.setAlignment(Qt.AlignCenter)
        vbox.addWidget(anton_icon)

        button_style = """
            QPushButton {
                background-color: #6A6A6A  ;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
            }
            QPushButton:hover {
                background-color: #11A9FF;
            }
        """

        button1 = QPushButton("Compose", self)
        button1.setStyleSheet(button_style)
        button1.clicked.connect(self.compose_see)
        button1.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        vbox.addWidget(button1)

        button2 = QPushButton("Diagnose", self)
        button2.setStyleSheet(button_style)
        button2.clicked.connect(self.diagnose_see)
        button2.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        vbox.addWidget(button2)

        button4 = QPushButton("Music Library", self)
        button4.setStyleSheet(button_style)
        button4.clicked.connect(self.library_see)
        button4.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        vbox.addWidget(button4)

        button5 = QPushButton("Option", self)
        button5.setStyleSheet(button_style)
        button5.clicked.connect(self.option_see)
        button5.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        vbox.addWidget(button5)

    def compose_see(self):
        compose_popup = Compose()
        compose_popup.exec_()

    def diagnose_see(self):
        if self.diagnose_popup == None:
            self.diagnose_popup = Diagnose()
        self.diagnose_popup.show()

    def option_see(self):
        option_popup = Option()
        option_popup.exec_()

    def library_see(self):
        check_popup = Library()
        check_popup.exec_()

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())