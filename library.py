import sys
import subprocess
import json
from PyQt5.QtWidgets import QVBoxLayout, QPushButton, QLabel, QDialog, QApplication, QScrollArea, QWidget
from PyQt5.QtCore import QUrl
from PyQt5.QtGui import QDesktopServices
import os
import platform

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

        vbox = QVBoxLayout(self)

        self.files_dict = self.create_dict()
        self.create_file_buttons(vbox)

        confirm_button = QPushButton("Close")
        confirm_button.setStyleSheet(button_style)
        confirm_button.clicked.connect(self.confirm_mode)
        vbox.addWidget(confirm_button)

    def load_directories(self):
        try:
            with open('directories.json', 'r') as dir:
                data = json.load(dir)
                self.generate_dir = data.get('generate_dir', '')
                self.diagnose_dir = data.get('diagnose_dir', '')
        except:
            self.generate_dir = ''
            self.diagnose_dir = ''
    
    def create_dict(self):
        files = os.listdir(self.piece_dir)
        files_dict = {}

        for file in files:
            name, ext = os.path.splitext(file)
            if ext in ['.pdf', '.wav']:
                if name not in files_dict:
                    files_dict[name] = []
                files_dict[name].append(ext)
        
        return files_dict

    def create_file_buttons(self, layout):
        button_style_small = """
            QPushButton {
                background-color: #6A6A6A  ;
                color: white;
                padding: 2px 20px;
                border: none;
                border-radius: 5px;
            }
            QPushButton:hover {
                background-color: #11A9FF;
            }
        """
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_widget = QWidget()
        scroll_layout = QVBoxLayout(scroll_widget)

        for file, extensions in self.files_dict.items():
            button = QPushButton(file)
            button.setStyleSheet(button_style_small)
            button.clicked.connect(lambda checked, f=file: self.show_file_ext(f))
            scroll_layout.addWidget(button)

        scroll_area.setWidget(scroll_widget)
        scroll_area.setMinimumHeight(25)
        layout.addWidget(scroll_area)

    def show_file_ext(self, file):
        button_style_small = """
            QPushButton {
                background-color: #6A6A6A  ;
                color: white;
                padding: 2px 20px;
                border: none;
                border-radius: 5px;
            }
            QPushButton:hover {
                background-color: #11A9FF;
            }
        """
        extensions_dialog = QDialog(self)
        extensions_dialog.setWindowTitle(f"Formats for {file}")
        layout = QVBoxLayout()

        label = QLabel(f"Available formats for {file}:")
        layout.addWidget(label)

        for ext in self.files_dict[file]:
            ext_button = QPushButton(ext)
            ext_button.setStyleSheet(button_style_small)
            ext_button.clicked.connect(lambda checked, e=ext: self.handle_extension_click(file, e))
            layout.addWidget(ext_button)

        close_button = QPushButton("Close")
        close_button.setStyleSheet(button_style_small)
        close_button.clicked.connect(extensions_dialog.accept)
        layout.addWidget(close_button)

        extensions_dialog.setLayout(layout)
        extensions_dialog.exec_()
    
    def handle_extension_click(self, file_name, ext):
        file_path = os.path.join(self.piece_dir, file_name + ext)
        if ext == '.pdf':
            QDesktopServices.openUrl(QUrl.fromLocalFile(file_path))
        elif ext == '.wav':
            if platform.system() == 'Darwin':  # macOS
                command = "afplay " + file_path
            elif platform.system() == 'Windows':  # Windows
                command = "start /B aplay " + file_path
            
            subprocess.run(command, shell=True)

    def confirm_mode(self):
        self.accept()

if __name__ == "__main__":
    app = QApplication([])
    popup = Library()
    popup.exec_()
