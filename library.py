import sys
import subprocess
import json
from PyQt5.QtWidgets import QVBoxLayout, QPushButton, QLabel, QDialog, QApplication, QProgressBar, QScrollArea, QWidget
from PyQt5.QtCore import Qt, QThread, pyqtSignal, QUrl
from PyQt5.QtGui import QDesktopServices
import os

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

class Library(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Music Library")
        self.load_directories()
        self.piece_dir = self.generate_dir
        
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

        self.files_dict = self.get_files_dict()
        self.create_file_buttons(vbox)

        confirm_button = QPushButton("Close")
        confirm_button.setStyleSheet(button_style)
        confirm_button.clicked.connect(self.confirm_mode)
        vbox.addWidget(confirm_button)

    def load_directories(self):
        try:
            with open('directories.json', 'r') as f:
                data = json.load(f)
                self.generate_dir = data.get('generate_dir', '')
                self.diagnose_dir = data.get('diagnose_dir', '')
        except (FileNotFoundError, json.JSONDecodeError):
            self.generate_dir = ''
            self.diagnose_dir = ''
    
    def get_files_dict(self):
        files = os.listdir(self.piece_dir)
        files_dict = {}

        for file in files:
            file_name, file_extension = os.path.splitext(file)
            if file_extension in ['.pdf', '.wav']:
                if file_name not in files_dict:
                    files_dict[file_name] = []
                files_dict[file_name].append(file_extension)
        
        return files_dict

    def create_file_buttons(self, layout):
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_widget = QWidget()
        scroll_layout = QVBoxLayout(scroll_widget)

        for file_name, extensions in self.files_dict.items():
            button = QPushButton(file_name)
            button.clicked.connect(lambda checked, fn=file_name: self.show_file_extensions(fn))
            scroll_layout.addWidget(button)

        scroll_area.setWidget(scroll_widget)
        scroll_area.setMinimumHeight(25)
        layout.addWidget(scroll_area)

    def show_file_extensions(self, file_name):
        extensions_dialog = QDialog(self)
        extensions_dialog.setWindowTitle(f"Formats for {file_name}")
        layout = QVBoxLayout()

        label = QLabel(f"Available formats for {file_name}:")
        layout.addWidget(label)

        for ext in self.files_dict[file_name]:
            ext_button = QPushButton(ext)
            ext_button.clicked.connect(lambda checked, e=ext: self.handle_extension_click(file_name, e))
            layout.addWidget(ext_button)

        close_button = QPushButton("Close")
        close_button.clicked.connect(extensions_dialog.accept)
        layout.addWidget(close_button)

        extensions_dialog.setLayout(layout)
        extensions_dialog.exec_()
    
    def handle_extension_click(self, file_name, extension):
        if extension == '.pdf':
            file_path = os.path.join(self.piece_dir, file_name + extension)
            self.open_pdf(file_path)
        elif extension == '.wav':
            file_path = os.path.join(self.piece_dir, file_name + extension)
            self.play_music(file_path)
    
    def open_pdf(self, file_path):
        QDesktopServices.openUrl(QUrl.fromLocalFile(file_path))

    def play_music(self, file_path):
        command = "afplay " + file_path
        subprocess.run(command, shell=True)
    
    def confirm_mode(self):
        self.accept()

if __name__ == "__main__":
    app = QApplication([])
    popup = Library()
    popup.exec_()
