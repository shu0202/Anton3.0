import json
from PyQt5.QtWidgets import QVBoxLayout, QPushButton, QLabel, QDialog, QLineEdit, QApplication, QFileDialog, QHBoxLayout
from PyQt5.QtCore import pyqtSignal

class Option(QDialog):
    directories_chosen = pyqtSignal(str, str)
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Options")
        self.load_directories()

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

        main_layout = QVBoxLayout(self)

        generate_layout = QHBoxLayout()
        generate_label = QLabel("Generate Pieces Directory:")
        self.generate_dir_line_edit = QLineEdit(self.generate_dir)  # Initialize with saved directory
        generate_browse_button = QPushButton("Browse")
        generate_browse_button.clicked.connect(self.browse_generate_dir)
        generate_layout.addWidget(generate_label)
        generate_layout.addWidget(self.generate_dir_line_edit)
        generate_layout.addWidget(generate_browse_button)
        main_layout.addLayout(generate_layout)

        diagnose_layout = QHBoxLayout()
        diagnose_label = QLabel("Diagnose Pieces Directory:")
        self.diagnose_dir_line_edit = QLineEdit(self.diagnose_dir)  # Initialize with saved directory
        diagnose_browse_button = QPushButton("Browse")
        diagnose_browse_button.clicked.connect(self.browse_diagnose_dir)
        diagnose_layout.addWidget(diagnose_label)
        diagnose_layout.addWidget(self.diagnose_dir_line_edit)
        diagnose_layout.addWidget(diagnose_browse_button)
        main_layout.addLayout(diagnose_layout)

        confirm_button = QPushButton("Confirm")
        confirm_button.setStyleSheet(button_style)
        confirm_button.clicked.connect(self.confirm_mode)
        main_layout.addWidget(confirm_button)

    def browse_generate_dir(self):
        directory = QFileDialog.getExistingDirectory(self, "Select Generate Pieces Directory")
        if directory:
            self.generate_dir_line_edit.setText(directory)

    def browse_diagnose_dir(self):
        directory = QFileDialog.getExistingDirectory(self, "Select Diagnose Pieces Directory")
        if directory:
            self.diagnose_dir_line_edit.setText(directory)

    def confirm_mode(self):
        generate_dir = self.generate_dir_line_edit.text()
        diagnose_dir = self.diagnose_dir_line_edit.text()

        self.save_directories(generate_dir, diagnose_dir)

        self.directories_chosen.emit(generate_dir, diagnose_dir) #can delete

        self.accept()

    def load_directories(self):
        try:
            with open('directories.json', 'r') as f:
                data = json.load(f)
                self.generate_dir = data.get('generate_dir', '')
                self.diagnose_dir = data.get('diagnose_dir', '')
        except (FileNotFoundError, json.JSONDecodeError):
            self.generate_dir = ''
            self.diagnose_dir = ''

    def save_directories(self, generate_dir, diagnose_dir):
        data = {
            'generate_dir': generate_dir,
            'diagnose_dir': diagnose_dir
        }
        with open('directories.json', 'w') as f:
            json.dump(data, f)

if __name__ == "__main__":
    app = QApplication([])
    popup = Option()
    popup.exec_()
