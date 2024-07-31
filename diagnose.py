import sys
import subprocess
import json
from PyQt5.QtWidgets import QVBoxLayout, QPushButton, QLabel, QDialog, QLineEdit, QApplication, QProgressBar, QFileDialog
from PyQt5.QtCore import Qt, QThread, pyqtSignal
import subprocess
import re

class Worker(QThread):
    finished = pyqtSignal()
    error = pyqtSignal(str)
    
    def __init__(self, command):
        super().__init__()
        self.command = command

    def run(self):
        try:
            result = subprocess.run(self.command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            if result.returncode != 0:
                self.error.emit(result.stderr.decode('utf-8'))
        except subprocess.CalledProcessError as e:
            self.error.emit(str(e))
        finally:
            self.finished.emit()

class LoadingScreen(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Loading")
        self.setModal(True)
        self.setWindowFlags(self.windowFlags() | Qt.CustomizeWindowHint | Qt.WindowTitleHint)
        self.setWindowFlags(self.windowFlags() & ~Qt.WindowCloseButtonHint)
        
        self.label = QLabel("Processing, please wait...", self)
        self.progress_bar = QProgressBar(self)
        self.progress_bar.setRange(0, 0)
        
        layout = QVBoxLayout()
        layout.addWidget(self.label)
        layout.addWidget(self.progress_bar)
        
        self.setLayout(layout)

def run_command_with_loading_screen(command):
    app = QApplication.instance() 
    if app is None:
        app = QApplication(sys.argv)
        
    loading_screen = LoadingScreen()
    
    worker = Worker(command)
    worker.finished.connect(loading_screen.accept)
    
    worker.start()
    loading_screen.exec_()
    
    worker.wait()

class OutputDialog(QDialog):
    def __init__(self, output_text, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Output")
        self.setModal(True)

        layout = QVBoxLayout()
        label = QLabel(output_text, self)
        layout.addWidget(label)

        close_button = QPushButton("Close", self)
        close_button.clicked.connect(self.accept)
        layout.addWidget(close_button)

        self.setLayout(layout)

class Diagnose(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Diagnose Options")
        self.load_directories()
        self.piece_dir = ''
        print(self.diagnose_dir)

        button_style = """
            QPushButton {
                background-color: #4CAF50;
                color: white;
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
            }
            QPushButton:hover {
                background-color: #3e8e41;
            }
        """

        vbox = QVBoxLayout(self)

        browse_button = QPushButton("Browse")
        #browse_button.setStyleSheet(button_style)
        browse_button.clicked.connect(self.browse_diagnose_dir)
        vbox.addWidget(browse_button)

        self.piece_dir_line_edit = QLineEdit(self)
        vbox.addWidget(self.piece_dir_line_edit)

        confirm_button = QPushButton("Confirm")
        confirm_button.setStyleSheet(button_style)
        confirm_button.clicked.connect(self.confirm_mode)
        vbox.addWidget(confirm_button)
    
    def browse_diagnose_dir(self):
        directory = QFileDialog.getOpenFileName(self, "Select a piece", self.diagnose_dir)
        if directory[0]:
            self.piece_dir_line_edit.setText(directory[0])
            self.piece_dir = directory[0]
    
    def load_directories(self):
        try:
            with open('directories.json', 'r') as f:
                data = json.load(f)
                self.generate_dir = data.get('generate_dir', '')
                self.diagnose_dir = data.get('diagnose_dir', '')
        except (FileNotFoundError, json.JSONDecodeError):
            self.generate_dir = ''
            self.diagnose_dir = ''

    def confirm_mode(self):
        print(f"Piece Directory: {self.piece_dir}")
        command = "./programBuilder.pl --task=diagnose --piece=" + self.piece_dir + " > " + self.piece_dir + "_program"
        print(command)
        run_command_with_loading_screen(command)
        command = "cat " + self.piece_dir + "_program | gringo | clasp > " + self.piece_dir + "_result"
        print(command)
        run_command_with_loading_screen(command)
        result_file = self.piece_dir + "_result"
        try:
            with open(result_file, 'r') as file:
                result_text = file.read()
        except FileNotFoundError:
            print(f"Result file {result_file} not found.")
            return
        
        error_pattern = re.compile(r'error\((.*?)\)')
        errors = error_pattern.findall(result_text)
        
        output_lines = ["Errors:"]
        for i, error in enumerate(errors, start=1):
            output_lines.append(f"{i}. {error}")
        
        output_text = "\n".join(output_lines)

        output_dialog = OutputDialog(output_text)
        output_dialog.exec_()
        
        self.accept()

if __name__ == "__main__":
    app = QApplication([])
    popup = Diagnose()
    popup.exec_()