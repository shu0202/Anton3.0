import string
import sys
import subprocess
import json
from PyQt5.QtWidgets import QVBoxLayout, QPushButton, QLabel, QComboBox, QDialog, QLineEdit, QApplication, QProgressBar, QMessageBox
from PyQt5.QtCore import Qt, QThread, pyqtSignal

class loading(QThread):
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
        
    loading_screen = LoadingScreen()
    
    load = loading(command)
    load.finished.connect(loading_screen.accept)
    
    load.start()
    loading_screen.exec_()
    
    load.wait()

class Compose(QDialog):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Compose Options")
        self.load_directories()
        print(self.generate_dir)

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

        self.name_label = QLabel("Name of piece:")
        vbox.addWidget(self.name_label)
        
        self.name_input = QLineEdit()
        self.name_input.setPlaceholderText("Enter the name of the piece")
        vbox.addWidget(self.name_input)
        
        self.mode_label = QLabel("Select Mode:")
        vbox.addWidget(self.mode_label)
        
        self.mode_dropdown = QComboBox()
        self.mode_dropdown.addItems(['Major', 'Minor'])
        self.mode_dropdown.currentIndexChanged.connect(self.update_key_dropdown)
        vbox.addWidget(self.mode_dropdown)
        
        self.key_label = QLabel("Select Key:")
        vbox.addWidget(self.key_label)
        
        self.key_dropdown = QComboBox()
        self.update_key_dropdown()
        vbox.addWidget(self.key_dropdown)

        self.rhythm_label = QLabel("Include Rhythm?:")
        vbox.addWidget(self.rhythm_label)
        self.rhythm_dropdown = QComboBox()
        self.rhythm_dropdown.addItems(['Yes', 'No'])
        self.rhythm_dropdown.setCurrentIndex(self.rhythm_dropdown.findText('No'))
        vbox.addWidget(self.rhythm_dropdown)

        self.notes_label = QLabel("Number of Notes:")
        vbox.addWidget(self.notes_label)
        
        self.notes_input = QLineEdit()
        self.notes_input.setPlaceholderText("Enter number of notes")
        vbox.addWidget(self.notes_input)

        self.style_label = QLabel("Select Style:")
        vbox.addWidget(self.style_label)
        
        self.style_dropdown = QComboBox()
        self.style_dropdown.addItems(['Solo', 'Duet', 'Trio', 'Quartet'])
        vbox.addWidget(self.style_dropdown)

        self.output_label = QLabel("Output format:")
        vbox.addWidget(self.output_label)

        self.output_dropdown = QComboBox()
        self.output_dropdown.addItems(['wav', 'pdf', 'wav & pdf'])
        vbox.addWidget(self.output_dropdown)

        self.instrument_label = QLabel("Output style: ")
        vbox.addWidget(self.instrument_label)
        self.instrument_label.setVisible(True)

        self.instrument_dropdown = QComboBox()
        self.instrument_dropdown.addItems(['Basic', 'Voice', 'Flute', 'Wind quartet'])
        self.instrument_dropdown.setVisible(True)
        vbox.addWidget(self.instrument_dropdown)

        self.output_dropdown.currentIndexChanged.connect(self.show_hide_instrument_dropdown)

        confirm_button = QPushButton("Confirm")
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

    def show_hide_instrument_dropdown(self, index):
        if self.output_dropdown.currentText() in ['wav', 'wav & pdf']:
            self.instrument_dropdown.setVisible(True)
            self.instrument_label.setVisible(True)
        else:
            self.instrument_dropdown.setVisible(False)
            self.instrument_label.setVisible(False)

    def update_key_dropdown(self):
        current_mode = self.mode_dropdown.currentText()
        if current_mode == "Major":
            keys = ['F', 'C', 'G', 'D', 'A', 'E', 'B']
        elif current_mode == "Minor":
            keys = ['F', 'C', 'G', 'D', 'A', 'E', 'B']
        
        self.key_dropdown.clear()
        self.key_dropdown.addItems(keys)
        
    def confirm_mode(self):
        mode = self.mode_dropdown.currentText()
        key = self.key_dropdown.currentText()
        include_rhythm = self.rhythm_dropdown.currentText()
        no_of_notes = self.notes_input.text()
        style = self.style_dropdown.currentText()
        name = self.name_input.text()
        output = self.output_dropdown.currentText()
        instrument = self.instrument_dropdown.currentText()
        generate_dir = self.generate_dir
        try:
            notes_test = int(self.notes_input.text())
            space_found = False
            for i in name:
                if i == " ":
                    space_found = True
            if space_found == True:
                self.show_space()
                self.close()
            elif space_found == False:
                print(f"Name: {name}, Selected mode: {mode}, Selected key: {key}, Include Rhythm?: {include_rhythm}, No. of Notes: {no_of_notes}, Style: {style}, Output: {output}")

                command = "./programBuilder.pl --task=compose --mode=" + mode.lower() + " --time=" + no_of_notes + " --style=" + style.lower() + " > " + generate_dir + "/" + name + "_program"
                print(command)
                subprocess.run(command, shell=True)

                command = "cat " + generate_dir + "/" + name + "_program" + " | gringo | clasp --rand-freq=0.05 --seed=$RANDOM $N > " + generate_dir + "/" + name + "_tunes"
                print(command)
                run_command_with_loading_screen(command)
                if output == "pdf":
                    command = "./parse.pl --fundamental=" + key + " --output=lilypond < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.ly"
                    print(command)
                    subprocess.run(command, shell=True)
                    command = "lilypond --output " + generate_dir + "/" + name + " " + generate_dir + "/" + name + "_tunes.ly"
                    print(command)
                    subprocess.run(command, shell=True)
                elif output == "wav":
                    if instrument == "Basic":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=basic < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    elif instrument == "Voice":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=voices < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    elif instrument == "Flute":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=tobiah_challenge < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    elif instrument == "Wind quartet":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=wind-quartet < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    print(command)
                    run_command_with_loading_screen(command)
                    command = "csound " + generate_dir + "/" + name + "_tunes.csd -o " + generate_dir + "/" + name + ".wav -W"
                    print(command)
                    run_command_with_loading_screen(command)
                elif output == "wav & pdf":
                    command = "./parse.pl --fundamental=" + key + " --output=lilypond < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.ly"
                    print(command)
                    subprocess.run(command, shell=True)
                    command = "lilypond --output " + generate_dir + "/" + name + " " + generate_dir + "/" + name + "_tunes.ly"
                    print(command)
                    subprocess.run(command, shell=True)
                    if instrument == "Basic":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=basic < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    elif instrument == "Voice":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=voices < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    elif instrument == "Flute":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=tobiah_challenge < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    elif instrument == "Wind quartet":
                        command = "./parse.pl --fundamental=" + key + " --output=csound --template=wind-quartet < " + generate_dir + "/" + name + "_tunes > " + generate_dir + "/" + name + "_tunes.csd"
                    print(command)
                    run_command_with_loading_screen(command)
                    command = "csound " + generate_dir + "/" + name + "_tunes.csd -o " + generate_dir + "/" + name + ".wav -W"
                    print(command)
                    run_command_with_loading_screen(command)
                self.show_success_message()
                self.close()
        except ValueError:
            self.show_error()
            self.close()
        

    def show_success_message(self):
        msg = QMessageBox(self)
        msg.setWindowTitle("Success")
        msg.setText("The piece has been successfully generated!")
        msg.setStandardButtons(QMessageBox.Ok)
        msg.exec_()

    def show_error(self):
        msg = QMessageBox(self)
        msg.setWindowTitle("Error")
        msg.setText("Please enter a valid number of notes!")
        msg.setStandardButtons(QMessageBox.Ok)
        msg.exec_()
    
    def show_space(self):
        msg = QMessageBox(self)
        msg.setWindowTitle("Error")
        msg.setText("No space in the name!")
        msg.setStandardButtons(QMessageBox.Ok)
        msg.exec_()

if __name__ == "__main__":
    app = QApplication([])
    popup = Compose()
    popup.exec_()
    sys.exit(app.exec_())
