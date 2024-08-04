import json
import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout, QPushButton, QHBoxLayout, QLineEdit, QLabel, QInputDialog
from PyQt5.QtGui import QPainter, QPen, QFont, QPixmap
from PyQt5.QtCore import Qt, QRect
import os


class Staff(QWidget):
    def __init__(self, num_notes):
        super().__init__()
        self.note_pattern = 'O'
        self.line_spacing = 14
        self.lines = 10
        self.notes_arr = []
        i = 0
        while i != num_notes:
            self.notes_arr.append(0)
            i += 1
        self.initUI()

    def initUI(self):
        self.setMinimumSize(800, 200)

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.setPen(QPen(Qt.black, 3))
        painter.setFont(QFont('Arial', 1))

        painter.fillRect(self.rect(), Qt.white)

        treble = QPixmap("Treble.png")
        painter.drawPixmap(QRect(10, 0, 69, 172), treble)

        for i in range(self.lines):
            if i%2 == 0:
                y = i * self.line_spacing + 30
                painter.drawLine(20, y, self.width() - 10, y)
            else:
                y = (i-1) * self.line_spacing + 30
                painter.drawLine(20, y, self.width() - 10, y)

        for i, note in enumerate(self.notes_arr):
            painter.setPen(QPen(Qt.black, 3))
            painter.setFont(QFont('Arial', 35))
            note_y = (self.lines - 1 - note) * self.line_spacing + 42
            note_pat = self.note_pattern
            painter.drawText(80 + i * 60, note_y, note_pat)

    def set_note_position(self, i, position):
        if i >= 0:
            if i < len(self.notes_arr):
                self.notes_arr[i] = position
                self.update()

class NotesEditor(QMainWindow):
    def __init__(self):
        super().__init__()
        self.staff = None
        self.note_buttons = QVBoxLayout()
        self.initUI()
        self.piece_dir = ''
        self.load_directories()
        print("Check: ")
        print(self.diagnose_dir)

    def initUI(self):
        self.setWindowTitle('Notes editor')

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

        self.num_notes = QLineEdit()
        self.num_notes.setPlaceholderText('Enter the number of notes')

        self.set_notes = QPushButton('Ok')
        self.set_notes.clicked.connect(self.show_notes)

        layout = QVBoxLayout()
        layout.addWidget(QLabel('Number of Notes:'))
        layout.addWidget(self.num_notes)
        layout.addWidget(self.set_notes)

        self.staff_box = QWidget()
        self.staff_box.setLayout(QVBoxLayout())
        self.staff_box.layout().setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self.staff_box)

        layout.addLayout(self.note_buttons)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        confirm_button = QPushButton("Confirm")
        confirm_button.setStyleSheet(button_style)
        confirm_button.clicked.connect(self.confirm_mode)
        layout.addWidget(confirm_button)

    def show_notes(self):
        if self.staff:
            self.staff.setParent(None)

        while self.note_buttons.count() > 0:
            a = self.note_buttons.takeAt(0)
            if a != None:
                widget = a.widget()
                if widget:
                    widget.setParent(None)
                layout = a.layout()
                if layout:
                    self.clear(layout)

        try:
            num_notes = int(self.num_notes.text())
            if num_notes < 1:
                print("error")
        except ValueError:
            print("Please enter a valid positive integer.")
            return

        self.staff = Staff(num_notes)
        self.staff_box.layout().addWidget(self.staff)

        row = QHBoxLayout()
        for i in range(num_notes):
            plus = QPushButton('+')
            minus = QPushButton('-')
            plus.setFixedSize(30, 30)
            minus.setFixedSize(30, 30)

            plus.clicked.connect(lambda _, idx=i: self.move_note_up(idx))
            minus.clicked.connect(lambda _, idx=i: self.move_note_down(idx))

            label = QLabel(f'Note {i + 1}')
            label.setAlignment(Qt.AlignCenter)

            button_layout = QHBoxLayout()
            button_layout.addWidget(minus)
            button_layout.addWidget(label)
            button_layout.addWidget(plus)
            button_layout.setContentsMargins(100, 0, 100, 0)
            button_layout.setSpacing(2)

            note_button_widget = QWidget()
            note_button_widget.setLayout(button_layout)
            row.addWidget(note_button_widget)

            if ((i + 1) % 3 == 0) or (i == num_notes - 1):
                self.note_buttons.addLayout(row)
                row = QHBoxLayout()

    def clear(self, layout):
        while layout.count():
            item = layout.takeAt(0)
            widget = item.widget()
            if widget:
                widget.setParent(None)
            child_layout = item.layout()
            if child_layout:
                self.clear(child_layout)

    def move_note_down(self, i):
        if (i >= 0) and (i < len(self.staff.notes_arr)):
            new_pos = max(self.staff.notes_arr[i] - 1, 0)
            self.staff.set_note_position(i, new_pos)
            #print(f"Note {i + 1} position: {new_pos}")

    def move_note_up(self, i):
        if (i >= 0)  and (i < len(self.staff.notes_arr)):
            new_pos = min(self.staff.notes_arr[i] + 1, self.staff.lines)
            self.staff.set_note_position(i, new_pos)
            #print(f"Note {i + 1} position: {new_pos}")
    
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
        notes_pos_arr = []
        if self.staff:
            note_pos = [self.staff.notes_arr[i] for i in range(len(self.staff.notes_arr))]
            #print("Note positions:")
            for i, pos in enumerate(note_pos):
                notes_pos_arr.append(pos)
                #print(f"Note {i+1}: {pos}")
            
            #print(notes_pos_arr)

            piece_name, confirm = QInputDialog.getText(self, "Save Piece", "Enter the name of the piece:")
            if confirm and piece_name != None:
                self.piece_dir = self.diagnose_dir + "/" + piece_name
                print(f"Piece Directory: {self.piece_dir}")
                with open(f"{self.piece_dir}", "w") as file:
                    file.write("mode(major).\n")
                    file.write("part(1).\n")
                    for i in range(len(notes_pos_arr)):
                        if notes_pos_arr[i] == 0:
                            file.write(f"choosenNote(1,{i+1},27).\n")
                        elif notes_pos_arr[i] == 1:
                            file.write(f"choosenNote(1,{i+1},29).\n")
                        elif notes_pos_arr[i] == 2:
                            file.write(f"choosenNote(1,{i+1},30).\n")
                        elif notes_pos_arr[i] == 3:
                            file.write(f"choosenNote(1,{i+1},32).\n")
                        elif notes_pos_arr[i] == 4:
                            file.write(f"choosenNote(1,{i+1},34).\n")
                        elif notes_pos_arr[i] == 5:
                            file.write(f"choosenNote(1,{i+1},36).\n")
                        elif notes_pos_arr[i] == 6:
                            file.write(f"choosenNote(1,{i+1},37).\n")
                        elif notes_pos_arr[i] == 7:
                            file.write(f"choosenNote(1,{i+1},39).\n")
                        elif notes_pos_arr[i] == 8:
                            file.write(f"choosenNote(1,{i+1},41).\n")
                        elif notes_pos_arr[i] == 9:
                            file.write(f"choosenNote(1,{i+1},42).\n")
                        elif notes_pos_arr[i] == 10:
                            file.write(f"choosenNote(1,{i+1},44).\n")
                    file.write(f"partTimeMax(P,{len(notes_pos_arr)}) :- part(P).\n")
                    file.write("style(solo).\n")
                print(f"Piece saved as {piece_name}")
            else:
                print("No piece name provided. Piece not saved.")


        else:
            print("No notes created yet.")

        self.close()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = NotesEditor()
    window.show()
    sys.exit(app.exec_())
